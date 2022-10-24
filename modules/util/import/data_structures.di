// D import file generated from 'source\hip\util\data_structures.d'
module hip.util.data_structures;
public import hip.util.string : String;
struct Pair(A, B, string aliasA = "", string aliasB = "")
{
	A first;
	B second;
	alias a = first;
	alias b = second;
	static if (aliasA != "")
	{
		mixin("alias " ~ aliasA ~ " = first;");
	}
	static if (aliasB != "")
	{
		mixin("alias " ~ aliasB ~ " = second;");
	}
}
version (HipDataStructures)
{
	struct RangeMap(K, V)
	{
		import std.traits : isNumeric;
		@nogc
		{
			static assert(isNumeric!K, "RangeMap key must be a numeric type");
			protected Array!K ranges;
			protected Array!V values;
			protected V _default;
			ref RangeMap setDefault(V _default)
			{
				this._default = _default;
				return this;
			}
			ref RangeMap setRange(K a, K b, V value)
			{
				if (ranges == null)
				{
					ranges = Array!K(8);
					values = Array!V(8);
				}
				int rLength = cast(int)ranges.length;
				ranges.reserve(ranges.length + 2);
				if (a > b)
				{
					K temp = a;
					a = b;
					b = temp;
				}
				if (rLength != 0 && (ranges[rLength - 1] > a))
					return this;
				ranges ~= a;
				ranges ~= b;
				values ~= value;
				return this;
			}
			V get(K value)
			{
				int l = 0;
				int length = cast(int)ranges.length;
				int r = length - 1;
				while (l < r)
				{
					int m = cast(int)((l + r) / 2);
					if (m % 2 != 0)
						m--;
					K k = ranges[m];
					if (m + 1 < length && (value >= k) && (value <= ranges[m + 1]))
						return values[cast(int)(m / 2)];
					else if (k < value)
						l = m + 1;
					else if (m > value)
						r = m - 1;
					else if (m + 1 < length && (k > value) && (ranges[m + 1] > value))
						break;
				}
				return _default;
			}
			pragma (inline)auto ref opAssign(V value)
			{
				setDefault(value);
				return this;
			}
			pragma (inline)V opSliceAssign(V value, K start, K end)
			{
				setRange(start, end, value);
				return value;
			}
			pragma (inline)V opIndex(K index)
			{
				return get(index);
			}
		}
	}
	struct Array(T)
	{
		size_t length;
		T* data;
		private size_t capacity;
		private int* countPtr;
		import core.stdc.stdlib : malloc;
		import core.stdc.string : memcpy, memset;
		import core.stdc.stdlib : realloc;
		@nogc this(this)
		{
			*countPtr = *countPtr + 1;
		}
		alias _opApplyFn = int delegate(ref T) @nogc;
		pragma (inline)@nogc int opApply(scope _opApplyFn dg)
		{
			int result = 0;
			for (int i = 0;
			 i < length && result; i++)
			{
				result = dg(data[i]);
			}
			return result;
		}
		private @nogc void initialize(size_t length)
		{
			this.data = cast(T*)malloc(T.sizeof * length);
			this.length = length;
			this.capacity = length;
			this.countPtr = cast(int*)malloc((int).sizeof);
			*this.countPtr = 1;
			this[0..length] = T.init;
		}
		static @nogc Array!T opCall(size_t length)
		{
			Array!T ret;
			ret.initialize(length);
			return ret;
		}
		static @nogc Array!T opCall(in T[] arr)
		{
			Array!T ret = Array!T(arr.length);
			memcpy(ret.data, arr.ptr, ret.length * T.sizeof);
			return ret;
		}
		static @nogc Array!T opCall(T[] arr...)
		{
			static if (isNumeric!T)
			{
				if (arr.length == 1)
					return Array!T(cast(size_t)arr[0]);
			}

			Array!T ret = Array!T(arr.length);
			memcpy(ret.data, arr.ptr, ret.length * T.sizeof);
			return ret;
		}
		void* getRef()
		{
			*countPtr = *countPtr + 1;
			return cast(void*)&this;
		}
		pragma (inline)const bool opEquals(R)(const R other) if (is(R == typeof(null)))
		{
			return data == null;
		}
		@nogc void dispose()
		{
			import core.stdc.stdlib : free;
			if (data != null)
			{
				free(data);
				free(countPtr);
				data = null;
				countPtr = null;
				length = (capacity = 0);
			}
		}
		immutable(T*) ptr()
		{
			return cast(immutable(T*))data;
		}
		@nogc size_t opDollar()
		{
			return length;
		}
		@nogc T[] opSlice(size_t start, size_t end)
		{
			return data[start..end];
		}
		auto @nogc ref opSliceAssign(T)(T value)
		{
			data[0..length] = value;
			return this;
		}
		auto @nogc ref opSliceAssign(T)(T value, size_t start, size_t end)
		{
			data[start..end] = value;
			return this;
		}
		import std.traits : isArray, isNumeric;
		auto @nogc ref opAssign(Q)(Q value) if (isArray!Q)
		{
			if (data == null)
				data = cast(T*)malloc(T.sizeof * value.length);
			else
				data = cast(T*)realloc(data, T.sizeof * value.length);
			length = value.length;
			capacity = value.length;
			memcpy(data, value.ptr, T.sizeof * value.length);
			return this;
		}
		auto @nogc ref opIndex(size_t index)
		{
			assert(index >= 0 && (index < length), "Array out of bounds");
			return data[index];
		}
		pragma (inline)private @nogc void resize(uint newSize)
		{
			if (data == null || capacity == 0)
				initialize(newSize);
			else
			{
				data = cast(T*)realloc(data, newSize * T.sizeof);
				capacity = newSize;
			}
		}
		void reserve(size_t newSize)
		{
			if (newSize > capacity)
				resize(cast(uint)newSize);
		}
		auto @nogc ref opOpAssign(string op, Q)(Q value) if (op == "~")
		{
			if (*countPtr != 1)
			{
				T* oldData = data;
				*countPtr = *countPtr - 1;
				initialize(length);
				memcpy(data, oldData, T.sizeof * length);
			}
			static if (is(Q == T))
			{
				if (data == null)
					initialize(1);
				if (length + 1 >= capacity)
					resize(cast(uint)((length + 1) * 1.5));
				data[length++] = value;
			}
			else
			{
				static if (is(Q == T[]) || is(Q == Array!T))
				{
					if (data == null)
						initialize(value.length);
					if (length + value.length >= capacity)
						resize(cast(uint)((length + value.length) * 1.5));
					memcpy(data + length, value.ptr, T.sizeof * value.length);
					length += value.length;
				}

			}
			return this;
		}
		@nogc String toString()
		{
			return String(this[0..$]);
		}
		@nogc void put(T data)
		{
			this ~= data;
		}
		@nogc ~this()
		{
			if (countPtr != null)
			{
				*countPtr = *countPtr - 1;
				if (*countPtr <= 0)
					dispose();
				countPtr = null;
			}
		}
	}
	private template Array2DMixin(T)
	{
		int opApply(scope int delegate(ref T) dg)
		{
			int result = 0;
			for (int i = 0;
			 i < width * height; i++)
			{
				{
					result = dg(data[i]);
					if (result)
						break;
				}
			}
			return result;
		}
		private uint height;
		private uint width;
		const @nogc int getWidth()
		{
			return width;
		}
		const @nogc int getHeight()
		{
			return height;
		}
		@nogc T[] opSlice(size_t start, size_t end)
		{
			if (end < start)
			{
				size_t temp = end;
				end = start;
				end = temp;
			}
			if (end > width * height)
				end = width * height;
			return data[start..end];
		}
		pragma (inline, true)
		{
			auto @nogc ref opIndex(size_t i, size_t j)
			{
				return data[i * width + j];
			}
			auto @nogc ref opIndex(size_t i)
			{
				size_t temp = i * width;
				return data[temp..temp + width];
			}
			auto @nogc opIndexAssign(T)(T value, size_t i, size_t j)
			{
				return data[i * width + j] = value;
			}
			const @nogc size_t opDollar()
			{
				return width * height;
			}
			const @nogc bool opCast()
			{
				return data !is null;
			}
		}
	}
	struct Array2D(T)
	{
		mixin Array2DMixin!T;
		Array2D_GC!T toGC()
		{
			Array2D_GC!T ret = new Array2D_GC!T(width, height);
			for (int i = 0;
			 i < width * height; i++)
			{
				ret.data[i] = data[i];
			}
			destroy(this);
			return ret;
		}
		@nogc
		{
			private T* data;
			import core.stdc.stdlib;
			private int* countPtr;
			this(this)
			{
				*countPtr = *countPtr + 1;
			}
			this(uint lengthHeight, uint lengthWidth)
			{
				data = cast(T*)malloc(lengthHeight * lengthWidth * T.sizeof);
				countPtr = cast(int*)malloc((int).sizeof);
				*countPtr = 0;
				height = lengthHeight;
				width = lengthWidth;
			}
			~this()
			{
				if (countPtr == null)
					return ;
				*countPtr = *countPtr - 1;
				if (*countPtr <= 0)
				{
					import std.stdio;
					debug (1)
					{
						writeln("Destroyed");
					}

					free(data);
					free(countPtr);
					data = null;
					countPtr = null;
					width = (height = 0);
				}
			}
		}
	}
	class Array2D_GC(T)
	{
		private T[] data;
		this(uint lengthHeight, uint lengthWidth)
		{
			data = new T[](lengthHeight * lengthWidth);
			width = lengthWidth;
			height = lengthHeight;
		}
		mixin Array2DMixin!T;
	}
	private uint hash_fnv1(T)(T value)
	{
		import std.traits : isArray, isPointer;
		enum fnv_offset_basis = 2166136261u;
		enum fnv_prime = 16777619;
		byte[] data;
		static if (isArray!T)
		{
			data = (cast(byte*)value.ptr)[0..value.length * T.sizeof];
		}
		else
		{
			static if (is(T == interface) || is(T == class) || isPointer!T)
			{
				data = cast(byte[])(cast(void*)value)[0..(void*).sizeof];
			}
			else
			{
				data = (cast(byte*)&value)[0..T.sizeof];
			}
		}
		typeof(return) hash = fnv_offset_basis;
		foreach (byteFromData; data)
		{
			hash *= fnv_prime;
			hash ^= byteFromData;
		}
		return hash;
	}
	struct Map(K, V)
	{
		import core.stdc.stdlib;
		static enum initializationLength = 128;
		private static enum increasingFactor = 1.5;
		private static enum increasingThreshold = 0.7;
		private alias hashFunc = hash_fnv1;
		private struct MapData
		{
			K key;
			V value;
		}
		private struct MapBucket
		{
			MapData data;
			MapBucket* next;
		}
		private Array!MapBucket dataSet;
		private int* countPtr;
		this(this)
		{
			if (countPtr !is null)
				*countPtr = *countPtr + 1;
		}
		private int entriesCount;
		private @nogc void initialize()
		{
			dataSet = Array!MapBucket(initializationLength);
			dataSet.length = initializationLength;
			dataSet[] = MapBucket.init;
			countPtr = cast(int*)malloc((int).sizeof);
			*countPtr = 0;
		}
		auto static @nogc opCall()
		{
			Map!(K, V) ret;
			ret.initialize();
			return ret;
		}
		@nogc void clear()
		{
			entriesCount = 0;
			for (int i = 0;
			 i < dataSet.length; i++)
			{
				{
					if (dataSet[i] != MapBucket.init)
					{
						MapBucket* buck = dataSet[i].next;
						while (buck != null)
						{
							MapBucket copy = *buck;
							free(buck);
							buck = copy.next;
						}
					}
				}
			}
		}
		private @nogc void recalculateHashes()
		{
			size_t newSize = cast(size_t)(dataSet.capacity * increasingFactor);
			Array!MapBucket newArray = Array!MapBucket(newSize);
			for (int i = 0;
			 i < dataSet.length; i++)
			{
				{
					if (dataSet[i] != MapBucket.init)
					{
						newArray[hashFunc(dataSet[i].data.key) % newSize] = dataSet[i];
					}
				}
			}
			dataSet = newArray;
		}
		@nogc bool has(K key)
		{
			return dataSet[getIndex(key)] != MapBucket.init;
		}
		pragma (inline)@nogc uint getIndex(K key)
		{
			return hashFunc(key) % dataSet.length;
		}
		auto @nogc ref opIndex(K index)
		{
			if (dataSet.length == 0)
				initialize();
			return dataSet[getIndex(index)].data.value;
		}
		auto @nogc ref opIndexAssign(V value, K key)
		{
			if (dataSet.length == 0)
				initialize();
			uint i = getIndex(key);
			if (dataSet[i] == MapBucket.init)
			{
				entriesCount++;
				dataSet[i] = MapBucket(MapData(key, value), null);
				if (entriesCount > dataSet.length * increasingThreshold)
					recalculateHashes();
			}
			else
			{
				MapBucket* curr = &dataSet[i];
				do
				{
					if (curr.data.key == key)
					{
						curr.data.value = value;
						return this;
					}
					else if (curr.next != null)
						curr = curr.next;
				}
				while (curr.next != null);
				curr.next = cast(MapBucket*)malloc(MapBucket.sizeof);
				*curr.next = MapBucket(MapData(key, value), null);
			}
			return this;
		}
		auto const @nogc opBinaryRight(string op, L)(const L lhs) if (op == "in")
		{
			if (dataSet.length == 0)
				initialize();
			uint i = getIndex(key);
			if (dataSet[i] == MapBucket.init)
				return null;
			return &dataSet[i];
		}
		@nogc ~this()
		{
			if (countPtr !is null)
			{
				*countPtr = *countPtr - 1;
				if (*countPtr == 0)
				{
					clear();
					free(countPtr);
				}
				countPtr = null;
			}
		}
	}
	alias AArray = Map;
	struct RingBuffer(T, uint Length)
	{
		import hip.util.concurrency : Volatile;
		@nogc
		{
			T[Length] data;
			private Volatile!uint writeCursor;
			private Volatile!uint readCursor;
			this()
			{
				this.writeCursor = 0;
				this.readCursor = 0;
			}
			void push(T data)
			{
				this.data[writeCursor] = data;
				writeCursor = (writeCursor + 1) % Length;
			}
			immutable T[] read(uint count)
			{
				uint temp = readCursor;
				if (temp + count > Length)
				{
					readCursor = 0;
					return data[temp..Length];
				}
				readCursor = (temp + count) % Length;
				return data[temp..count];
			}
			immutable T read()
			{
				uint temp = readCursor;
				immutable T ret = data[temp];
				readCursor = (temp + 1) % Length;
				return ret;
			}
			void dispose()
			{
				data = null;
				length = 0;
				writeCursor = 0;
				readCursor = 0;
			}
			~this()
			{
				dispose();
			}
		}
	}
	class EventQueue
	{
		import hip.util.memory;
		@nogc
		{
			struct Event
			{
				ubyte type;
				ubyte evSize;
				void[0] evData;
			}
			void* eventQueue;
			uint bytesCapacity;
			uint bytesOffset;
			protected uint pollCursor;
			protected this(uint capacity)
			{
				bytesCapacity = cast(uint)capacity;
				bytesOffset = 0;
				eventQueue = malloc(bytesCapacity);
			}
			void post(T)(ubyte type, T ev)
			{
				assert(bytesOffset + T.sizeof + Event.sizeof < bytesCapacity, "InputQueue Out of bounds");
				if (pollCursor == bytesOffset)
				{
					pollCursor = 0;
					bytesOffset = 0;
				}
				else if (pollCursor != 0)
				{
					memcpy(eventQueue, eventQueue + pollCursor, bytesOffset - pollCursor);
					bytesOffset -= pollCursor;
					pollCursor = 0;
				}
				Event temp;
				temp.type = type;
				temp.evSize = T.sizeof;
				memcpy(eventQueue + bytesOffset, &temp, Event.sizeof);
				memcpy(eventQueue + bytesOffset + Event.sizeof, &ev, T.sizeof);
				bytesOffset += T.sizeof + Event.sizeof;
			}
			void clear();
			Event* poll();
			protected ~this();
		}
	}
	class Node(T)
	{
		T data;
		Node!T[] children;
		Node!T parent;
		this(T data)
		{
			this.data = data;
		}
		pragma (inline)const nothrow @nogc bool isRoot()
		{
			return parent is null;
		}
		pragma (inline)const nothrow @nogc bool hasChildren()
		{
			return children.length != 0;
		}
		Node!T get(T data)
		{
			foreach (node; this)
			{
				if (node.data == data)
					return node;
			}
			return null;
		}
		pragma (inline)Node!T addChild(T data)
		{
			Node!T ret = new Node(data);
			ret.parent = this;
			children ~= ret;
			return ret;
		}
		Node!T getRoot()
		{
			Node!T ret = this;
			while (ret.parent !is null)
			ret = ret.parent;
			return ret;
		}
		int opApply(scope int delegate(Node!T) cb)
		{
			foreach (child; children)
			{
				if (cb(child) || child.opApply(cb))
					return 1;
			}
			return 0;
		}
	}
	struct Signal(A...)
	{
		Array!(void function(A)) listeners;
		void dispatch(A a)
		{
			foreach (void function(A) l; listeners)
			{
				l(a);
			}
		}
	}
}
