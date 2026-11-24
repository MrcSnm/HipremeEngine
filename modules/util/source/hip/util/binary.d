module hip.util.binary;
import hip.util.reflection : isDynamicArray, hasDynamicArray, hasBool;
import hip.util.allocator;
import std.traits : Unqual;

private size_t packedBitSizeOf(T, bool minimum = false)() @nogc nothrow pure
{
	static if(is(Unqual!T == bool))
		return 1;
	else static if(is(T == struct))
	{
		size_t ret;
		static foreach(v; T.init.tupleof)
			ret+= packedBitSizeOf!(typeof(v), minimum);
		return ret;
	}
	else static if(is(T == U[N], U, size_t N))
		return N * packedBitSizeOf!(U, minimum);
	else static if(minimum && isDynamicArray!T)
		return uint.sizeof * 8;
	else
		return T.sizeof * 8;
}

private size_t packedSizeOf(T)() @nogc nothrow pure
{
	return (packedBitSizeOf!T + 7) / 8;
}

private bool isRawCopyable(T)()
{
	return !hasBool!T && !hasDynamicArray!T && packedBitSizeOf!T == T.sizeof * 8;
}

private size_t packedSizeOfTypes(T...)() @nogc nothrow pure if(!hasDynamicArray!T)
{
	size_t ret;
	static foreach(t; T)
		ret+= packedSizeOf!t;
	return ret;
}

@nogc nothrow pure
ubyte[packedSizeOfTypes!T] toBytes(T...)(T input) if(!hasDynamicArray!(T))
{
    typeof(return) ret = void;
	size_t offset;
	static foreach(i, t; T)
	{{
		enum sz = packedSizeOf!t;
		copyIntoMemory(input[i], ret[offset..offset+sz]);
		offset+= sz;
	}}
    return ret;
}

@nogc nothrow pure
void copyIntoMemory(T)(T struc, ubyte[] memory)
{
	memory[0..getPackedTypeSize(struc)] = 0;
	size_t bitPos;
	copyBitsIntoMemory(struc, memory, bitPos);
}

private void writeByteBits()(ubyte byteValue, ubyte[] memory, ref size_t bitPos) @nogc nothrow pure
{
	size_t byteIndex = bitPos >> 3;
	uint shift = cast(uint)(bitPos & 7);
	memory[byteIndex] |= cast(ubyte)(byteValue << shift);
	if(shift != 0)
		memory[byteIndex + 1] |= cast(ubyte)(byteValue >> (8 - shift));
	bitPos+= 8;
}

private void copyRawBits()(ubyte[] bytes, ubyte[] memory, ref size_t bitPos) @nogc nothrow pure
{
	if((bitPos & 7) == 0)
	{
		size_t byteIndex = bitPos >> 3;
		memory[byteIndex..byteIndex+bytes.length] = bytes;
		bitPos+= bytes.length * 8;
	}
	else
	{
		foreach(b; bytes)
			writeByteBits(b, memory, bitPos);
	}
}

private void copyBitsIntoMemory(T)(T struc, ubyte[] memory, ref size_t bitPos) @nogc nothrow pure
{
	static if(is(Unqual!T == bool))
	{
		if(struc)
			memory[bitPos >> 3] |= cast(ubyte)(1 << (bitPos & 7));
		bitPos++;
	}
	else static if(is(T == struct))
	{
		foreach(v; struc.tupleof)
			copyBitsIntoMemory(v, memory, bitPos);
	}
	else static if(isDynamicArray!T)
	{
		alias E = typeof(T.init[0]);
		copyBitsIntoMemory(cast(uint)struc.length, memory, bitPos);
		static if(isRawCopyable!E)
			copyRawBits((cast(ubyte*)struc.ptr)[0..struc.length * E.sizeof], memory, bitPos);
		else
			foreach(v; struc)
				copyBitsIntoMemory(v, memory, bitPos);
	}
	else static if(__traits(isStaticArray, T))
	{
		static if(isRawCopyable!T)
			copyRawBits((cast(ubyte*)&struc)[0..T.sizeof], memory, bitPos);
		else
			foreach(v; struc)
				copyBitsIntoMemory(v, memory, bitPos);
	}
	else
	{
		copyRawBits((cast(ubyte*)&struc)[0..T.sizeof], memory, bitPos);
	}
}

ubyte[] toBytes(T...)(T input) if(hasDynamicArray!T)
{
	return toBytesWithAllocator(gcAllocator, input);
}

ubyte[] toBytesWithAllocator(T...)(Allocator* allocator, T input)
{
	ubyte[] ret = allocator.get!(ubyte)(getPackedTypeSize(input));
	size_t offset;
	foreach(i, t; T)
	{
		size_t sz = getPackedTypeSize(input[i]);
		copyIntoMemory(input[i], ret[offset..offset+sz]);
		offset+= sz;
	}
	return ret;
}

private size_t minPackedBitSizeOf(T)() @nogc nothrow pure
{
	return packedBitSizeOf!(T, true);
}

private struct PackedReader
{
	const(ubyte)[] memory;
	size_t bitPos;

	size_t remainingBits()() const @nogc nothrow pure
	{
		size_t total = memory.length << 3;
		return bitPos < total ? total - bitPos : 0;
	}

	private void requireBits()(size_t bits) const
	{
		if(bits > remainingBits())
			throw new Exception("Packed data is truncated or corrupted");
	}

	bool readBool()()
	{
		requireBits(1);
		bool ret = ((memory[bitPos >> 3] >> (bitPos & 7)) & 1) != 0;
		bitPos++;
		return ret;
	}

	void readRawBytes()(ubyte[] dest)
	{
		requireBits(dest.length * 8);
		size_t bytePos = bitPos >> 3;
		uint shift = cast(uint)(bitPos & 7);
		if(shift == 0)
		{
			foreach(i; 0..dest.length)
				dest[i] = memory[bytePos + i];
		}
		else
		{
			foreach(i; 0..dest.length)
				dest[i] = cast(ubyte)((memory[bytePos + i] >> shift) | (memory[bytePos + i + 1] << (8 - shift)));
		}
		bitPos+= dest.length * 8;
	}

	T readRaw(T)()
	{
		alias U = Unqual!T;
		U ret = void;
		readRawBytes((cast(ubyte*)&ret)[0..U.sizeof]);
		return cast(T)ret;
	}
}

private T readPackedStruct(T)(ref PackedReader reader, Allocator* allocator = gcAllocator)
{
	alias U = Unqual!T;
	U ret;
	foreach(ref v; ret.tupleof)
	{
		alias F = typeof(v);
		F value = readPacked!F(reader, allocator);
		(cast(ubyte*)&v)[0..F.sizeof] = (cast(ubyte*)&value)[0..F.sizeof];
	}
	return cast(T)ret;
}

private T readPackedArray(T, E = typeof(T.init[0]))(ref PackedReader reader, Allocator* allocator = gcAllocator)
{
	auto length = reader.readRaw!uint();
	alias U = Unqual!E;

	enum size_t minBits = minPackedBitSizeOf!E;
	size_t maxLength = minBits == 0 ? reader.memory.length : reader.remainingBits() / minBits;
	if(length > maxLength)
		throw new Exception("Packed array length exceeds the available data");
	if(length > size_t.max / U.sizeof)
		throw new Exception("Packed array length is too large");

	static if(isRawCopyable!E)
	{
		U[] ret = allocator.get!(U)(length);
		reader.readRawBytes((cast(ubyte*)ret.ptr)[0..length * U.sizeof]);
		return cast(T)ret;
	}
	else
	{
		U[] ret = allocator.get!(U)(length);
		static if(minPackedBitSizeOf!E != 0)
		{
			foreach(ref v; ret)
				v = readPacked!E(reader, allocator);
		}
		return cast(T)ret;
	}
}

private T readPacked(T)(ref PackedReader reader, Allocator* allocator = gcAllocator)
{
	static if(is(Unqual!T == bool))
		return reader.readBool();
	else static if(is(T == struct))
		return readPackedStruct!T(reader, allocator);
	else static if(isDynamicArray!T)
		return readPackedArray!T(reader, allocator);
	else static if(is(T == U[N], U, size_t N))
	{
		alias E = Unqual!U;
		E[N] ret;
		static foreach(i; 0..N)
			ret[i] = readPacked!E(reader, allocator);
		return cast(T)ret;
	}
	else
	{
		return reader.readRaw!T();
	}
}

T getStructFromPackedBytes(T)(const ubyte[] data, Allocator* allocator = gcAllocator)
{
	PackedReader reader = PackedReader(data);
	return readPackedStruct!T(reader, allocator);
}

T getArrayFromPackedBytes(T, E = typeof(T.init[0]))(const ubyte[] data, Allocator* allocator = gcAllocator)
{
	PackedReader reader = PackedReader(data);
	return readPackedArray!(T, E)(reader, allocator);
}

T fromPackedBytes(T)(const ubyte[] bytes, Allocator* allocator = gcAllocator)
{
	PackedReader reader = PackedReader(bytes);
	return readPacked!T(reader, allocator);
}


ubyte[N] toBytes(T, uint N)(T input) @nogc nothrow pure if(!hasDynamicArray!T)
{
    ubyte[N] ret = void;
    ret[] = (cast(ubyte*)&input)[0..N];
    return ret;
}

bool isLittleEndian() @nogc nothrow pure
{
    uint value = 1;
    return (cast(ubyte*)&value)[0] == 1;
}

ubyte[N] swapEndian(uint N)(ubyte[N] bytes) @nogc nothrow pure
{
    ubyte[N] swapped = void;
    foreach (i; 0 .. N)
        swapped[i] = bytes[N - 1 - i];
    return swapped;
}

ubyte[] swapEndian(const ubyte[] bytes, Allocator* allocator = gcAllocator)
{
    ubyte[] swapped = allocator.get!(ubyte
	)(bytes.length);
    foreach (i; 0 .. bytes.length)
        swapped[i] = bytes[bytes.length - 1 - i];
    return swapped;
}

void swapEndianInPlace(ref ubyte[] bytes) @nogc nothrow pure
{
    foreach (i; 0 .. bytes.length / 2)
    {
        auto tmp = bytes[i];
        bytes[i] = bytes[bytes.length - 1 - i];
        bytes[bytes.length - 1 - i] = tmp;
    }
}


size_t sizeofTypes(T...)() @nogc nothrow pure if(!hasDynamicArray!T)
{
	size_t ret;
	foreach (t; T)
		ret+= t.sizeof;
	return ret;
}


uint getTypeSize(T...)(const T input) if(T.length > 1)
{
	uint sz;
	foreach(i, t; T)
	{
		sz+= getTypeSize(input[i]);
	}
	return sz;
}

uint getTypeSize(T)(const T input = T.init) if(!is(T == struct) && !isDynamicArray!T)
{
	return T.sizeof;
}
uint getTypeSize(T)(const T input = T.init) if(isDynamicArray!T)
{
	uint sz = uint.sizeof;
	static if(hasDynamicArray!(typeof(T.init[0])))
	{
		foreach(v; input)
		{
			sz+= getTypeSize(v);
		}
	}
	else
	{
		sz+= T.init[0].sizeof * input.length;
	}
	return sz;
}

uint getTypeSize(T)(const T input = T.init) if(is(T == struct))
{
	static if(!hasDynamicArray!T)
		return T.sizeof;
	else
	{
		uint sz;
		foreach(v; input.tupleof)
		{
			static if(hasDynamicArray!(typeof(v)))
			{
				sz+= getTypeSize(v);
			}
			else
			{
				sz+= typeof(v).sizeof;
			}
		}
		return sz;
	}
}

@nogc nothrow pure
uint getPackedTypeSize(T...)(const T input) if(T.length > 1)
{
	uint sz;
	foreach(i, t; T)
	{
		sz+= getPackedTypeSize(input[i]);
	}
	return sz;
}

@nogc nothrow pure
uint getPackedTypeSize(T)(const T input = T.init)
{
	return cast(uint)((getPackedBitSize(input) + 7) / 8);
}

@nogc nothrow pure
size_t getPackedBitSize(T)(const T input = T.init)
{
	static if(!hasDynamicArray!T)
		return packedBitSizeOf!T;
	else static if(isDynamicArray!T)
	{
		size_t sz = uint.sizeof * 8;
		alias E = typeof(T.init[0]);
		static if(hasDynamicArray!E)
		{
			foreach(v; input)
			{
				sz+= getPackedBitSize(v);
			}
		}
		else
		{
			sz+= packedBitSizeOf!E * input.length;
		}
		return sz;
	}
	else static if(is(T == struct))
	{
		size_t sz;
		foreach(v; input.tupleof)
		{
			sz+= getPackedBitSize(v);
		}
		return sz;
	}
	else
	{
		size_t sz;
		foreach(v; input)
		{
			sz+= getPackedBitSize(v);
		}
		return sz;
	}
}

private void assertPackedProperties(T)(T value)
{
	assert(getPackedTypeSize(value) == (getPackedBitSize(value) + 7) / 8);
	assert(getPackedTypeSize(value) <= getTypeSize(value));

	static if(hasDynamicArray!T)
	{
		auto serialized = toBytes(0, value)[int.sizeof..$];
		assert(serialized.length == getPackedTypeSize(value));
		assert(fromPackedBytes!T(serialized) == value);
	}
	else
	{
		auto serialized = toBytes(value);
		assert(serialized.length == getPackedTypeSize(value));
		assert(fromPackedBytes!T(serialized) == value);
	}

	immutable size_t sz = getPackedTypeSize(value);
	ubyte[] buffer = new ubyte[sz + 4];
	buffer[] = 0xCD;
	copyIntoMemory(value, buffer[0..sz]);
	foreach(byteValue; buffer[sz..$])
		assert(byteValue == 0xCD);
}

unittest
{
	import std.meta : AliasSeq;

	static foreach(T; AliasSeq!(ubyte, ushort, uint, ulong, float))
	{{
		T value = cast(T)3;
		assertPackedProperties(value);
		assert(getPackedBitSize(value) == T.sizeof * 8);
		assert(getPackedTypeSize(value) == T.sizeof);
	}}
}

unittest
{
	struct Padded
	{
		ubyte a;
		uint b;
	}

	struct Empty
	{
	}

	foreach(i; 0..32)
	{{
		Padded padded = Padded(cast(ubyte)i, cast(uint)(i * 2654435761u));
		assertPackedProperties(padded);
		assert(getPackedTypeSize(padded) == ubyte.sizeof + uint.sizeof);
		assert(getPackedTypeSize(padded) < Padded.sizeof);
	}}

	Padded padded = Padded(1, 2);
	assert(getTypeSize(padded) == Padded.sizeof);
	assert(getStructFromPackedBytes!Padded(toBytes(padded)) == padded);

	Empty empty;
	assertPackedProperties(empty);
	assert(getPackedTypeSize(empty) == 0);
}

unittest
{
	struct Padded
	{
		ubyte a;
		uint b;
	}

	foreach(n; 0..33)
	{{
		ubyte[] bytes = new ubyte[n];
		foreach(i; 0..n)
			bytes[i] = cast(ubyte)(i * 37 + 1);
		assertPackedProperties(bytes);
		assert(getPackedBitSize(bytes) == uint.sizeof * 8 + n * ubyte.sizeof * 8);
		assert(getPackedTypeSize(bytes) == uint.sizeof + n);
		assert(getArrayFromPackedBytes!(ubyte[])(toBytes(bytes)) == bytes);

		Padded[] padded = new Padded[n];
		foreach(i; 0..n)
			padded[i] = Padded(cast(ubyte)i, cast(uint)(i * 3 + 1));
		assertPackedProperties(padded);
		assert(getPackedTypeSize(padded) == uint.sizeof + n * (ubyte.sizeof + uint.sizeof));
		assert(getArrayFromPackedBytes!(Padded[])(toBytes(padded)) == padded);
		if(n > 0)
			assert(getPackedTypeSize(padded) < uint.sizeof + n * Padded.sizeof);
	}}
}

unittest
{
	struct WithArray
	{
		ubyte id;
		int[] values;
	}

	foreach(n; 0..33)
	{{
		auto value = WithArray(cast(ubyte)n, new int[n]);
		foreach(i; 0..n)
			value.values[i] = cast(int)(i * 7 - 3);
		assertPackedProperties(value);
		assert(getPackedBitSize(value) == ubyte.sizeof * 8 + uint.sizeof * 8 + n * int.sizeof * 8);
		assert(getPackedTypeSize(value) == ubyte.sizeof + uint.sizeof + n * int.sizeof);
		assert(getStructFromPackedBytes!WithArray(toBytes(value)) == value);
	}}
}

unittest
{
	struct Padded
	{
		ubyte a;
		uint b;
	}

	int[3] ints = [1, 2, 3];
	assertPackedProperties(ints);
	assert(getPackedTypeSize(ints) == int[3].sizeof);

	Padded[4] padded = [Padded(1, 2), Padded(3, 4), Padded(5, 6), Padded(7, 8)];
	assertPackedProperties(padded);
	assert(getPackedTypeSize(padded) == 4 * (ubyte.sizeof + uint.sizeof));

	bool[8] flags = [true, false, true, false, true, false, true, false];
	assertPackedProperties(flags);
	assert(getPackedBitSize(flags) == 8);
	assert(getPackedTypeSize(flags) == 1);
	assert(toBytes(flags)[0] == 0b01010101);
}

unittest
{
	struct Bools
	{
		bool first;
		bool second;
	}

	struct BoolsAndInt
	{
		bool flag;
		uint value;
	}

	struct BoolWithArray
	{
		bool enabled;
		ubyte[] data;
	}

	struct BitReader
	{
		const(ubyte)[] data;
		size_t bitPos;

		bool readBool()
		{
			bool ret = ((data[bitPos >> 3] >> (bitPos & 7)) & 1) != 0;
			bitPos++;
			return ret;
		}

		ubyte readByte()
		{
			ubyte ret;
			foreach(i; 0..ubyte.sizeof * 8)
				ret |= cast(ubyte)(readBool() << i);
			return ret;
		}

		uint readUint()
		{
			uint ret;
			foreach(i; 0..uint.sizeof * 8)
				ret |= cast(uint)readBool() << i;
			return ret;
		}
	}

	assert(getPackedBitSize(true) == 1);
	assert(getPackedTypeSize(true) == 1);

	foreach(n; 0..65)
	{{
		bool[] values = new bool[n];
		foreach(i; 0..n)
			values[i] = ((i * 7 + 3) % 5) < 2;
		assertPackedProperties(values);
		assert(getPackedBitSize(values) == uint.sizeof * 8 + n);
		assert(getPackedTypeSize(values) == uint.sizeof + (n + 7) / 8);

		auto serialized = toBytes(values);
		BitReader reader = BitReader(serialized);
		assert(reader.readUint() == n);
		foreach(i; 0..n)
			assert(reader.readBool() == values[i]);
	}}

	foreach(i; 0..16)
	{{
		auto bools = Bools((i & 1) != 0, (i & 2) != 0);
		assertPackedProperties(bools);
		assert(getPackedTypeSize(bools) == 1);
		BitReader boolReader = BitReader(toBytes(bools));
		assert(boolReader.readBool() == bools.first);
		assert(boolReader.readBool() == bools.second);

		auto boolAndInt = BoolsAndInt((i & 1) != 0, cast(uint)(i * 2654435761u));
		assertPackedProperties(boolAndInt);
		assert(getPackedBitSize(boolAndInt) == 1 + uint.sizeof * 8);
		assert(getPackedTypeSize(boolAndInt) == 1 + uint.sizeof);
		BitReader intReader = BitReader(toBytes(boolAndInt));
		assert(intReader.readBool() == boolAndInt.flag);
		assert(intReader.readUint() == boolAndInt.value);
	}}

	foreach(n; 0..17)
	{{
		auto value = BoolWithArray((n & 1) == 0, new ubyte[n]);
		foreach(i; 0..n)
			value.data[i] = cast(ubyte)(i * 11 + 1);
		assertPackedProperties(value);
		assert(getPackedBitSize(value) == 1 + uint.sizeof * 8 + n * ubyte.sizeof * 8);
		assert(getPackedTypeSize(value) == (1 + uint.sizeof * 8 + n * ubyte.sizeof * 8 + 7) / 8);

		auto structBytes = toBytes(0, value)[int.sizeof..$];
		BitReader reader = BitReader(structBytes);
		assert(reader.readBool() == value.enabled);
		assert(reader.readUint() == n);
		foreach(i; 0..n)
			assert(reader.readByte() == value.data[i]);
	}}
}

unittest
{
	struct Padded
	{
		ubyte a;
		uint b;
	}

	struct WithArray
	{
		ubyte id;
		int[] values;
	}

	const Padded constPadded = Padded(1, 2);
	assertPackedProperties(constPadded);

	const WithArray constValue = WithArray(1, [1, 2, 3]);
	assertPackedProperties(constValue);

	const bool[] constBools = [true, false, true];
	assertPackedProperties(constBools);
	assert(getPackedBitSize(constBools) == uint.sizeof * 8 + 3);

	const(int)[] constInts = [1, 2, 3];
	assertPackedProperties(constInts);

	immutable(int)[] immutableInts = [4, 5];
	assertPackedProperties(immutableInts);

	immutable(bool)[] immutableBools = [false, true];
	assertPackedProperties(immutableBools);
	assert(getPackedBitSize(immutableBools) == uint.sizeof * 8 + 2);
}

unittest
{
	struct Padded
	{
		ubyte a;
		uint b;
	}

	auto bytes = toBytes(cast(ubyte)1, cast(uint)2, Padded(3, 4));
	assert(bytes.length == getPackedTypeSize(cast(ubyte)1, cast(uint)2, Padded(3, 4)));
	assert(bytes.length == ubyte.sizeof + uint.sizeof + ubyte.sizeof + uint.sizeof);
}

unittest
{
	struct Fixed
	{
		bool flag;
		uint value;
	}

	struct Empty
	{
	}

	bool threw;

	auto fixedBytes = toBytes(Fixed(true, 7));
	threw = false;
	try fromPackedBytes!Fixed(fixedBytes[0..$ - 1]);
	catch(Exception) threw = true;
	assert(threw);

	ubyte[4] hugeLength = [0xFF, 0xFF, 0xFF, 0xFF];

	threw = false;
	try fromPackedBytes!(int[])(hugeLength);
	catch(Exception) threw = true;
	assert(threw);

	threw = false;
	try getArrayFromPackedBytes!(int[])(hugeLength);
	catch(Exception) threw = true;
	assert(threw);

	threw = false;
	try fromPackedBytes!(bool[])(hugeLength);
	catch(Exception) threw = true;
	assert(threw);

	threw = false;
	try fromPackedBytes!(Empty[])(hugeLength);
	catch(Exception) threw = true;
	assert(threw);

	ubyte[2] shortData = [1, 2];
	threw = false;
	try fromPackedBytes!uint(shortData);
	catch(Exception) threw = true;
	assert(threw);
}
