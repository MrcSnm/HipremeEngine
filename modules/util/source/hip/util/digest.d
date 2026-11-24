module hip.util.digest;

private enum uint crc32Polynomial = 0xEDB8_8320;

private @nogc nothrow pure
uint[256] generateCRC32Table()
{
	uint[256] table = void;
	foreach (i; 0 .. 256)
	{
		uint crc = i;
		foreach (_; 0 .. 8)
		{
			if (crc & 1)
				crc = (crc >> 1) ^ crc32Polynomial;
			else
				crc >>= 1;
		}
		table[i] = crc;
	}
	return table;
}

private immutable uint[256] crc32Table = generateCRC32Table();

/**
 * Streaming CRC-32 (IEEE 802.3, the same used by zlib, PNG and ZIP).
 */
struct CRC32
{
	private uint state = 0xFFFF_FFFF;

	/**
	 * Feeds `data` into the checksum.
	 */
	@nogc nothrow pure @trusted
	void put(const(void)[] data)
	{
		const(ubyte)[] bytes = cast(const(ubyte)[]) data;
		uint crc = state;
		foreach (b; bytes)
			crc = crc32Table[(crc ^ b) & 0xFF] ^ (crc >> 8);
		state = crc;
	}

	/**
	 * Returns: the CRC-32 of everything put so far, then resets the state
	 * so the struct can be reused.
	 */
	@nogc nothrow pure
	uint finish()
	{
		uint ret = peek();
		reset();
		return ret;
	}

	/**
	 * Returns: the CRC-32 of everything put so far without resetting.
	 */
	@nogc nothrow pure
	uint peek() const
	{
		return state ^ 0xFFFF_FFFF;
	}

	/**
	 * Resets the checksum to its initial state.
	 */
	@nogc nothrow pure
	void reset()
	{
		state = 0xFFFF_FFFF;
	}
}

/**
 * Computes the CRC-32 (IEEE 802.3) of `data` in a single call.
 */
@nogc nothrow pure @trusted
uint crc32(const(void)[] data)
{
	CRC32 ctx;
	ctx.put(data);
	return ctx.finish();
}

unittest
{
	assert(crc32("") == 0);
	assert(crc32("123456789") == 0xCBF4_3926);
	assert(crc32("The quick brown fox jumps over the lazy dog") == 0x414F_A339);

	CRC32 ctx;
	ctx.put("1234");
	ctx.put("56789");
	assert(ctx.peek() == 0xCBF4_3926);
	assert(ctx.finish() == 0xCBF4_3926);
	assert(ctx.finish() == 0);

	ubyte[] binaryData = [0x00, 0x01, 0x02, 0xFF];
	ctx.put(binaryData);
	assert(ctx.finish() == crc32(binaryData));
}
