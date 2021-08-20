module directx.win32;

version(Windows):

public import core.sys.windows.windows;
public import core.sys.windows.com;

pure nothrow @safe @nogc
HRESULT MAKE_HRESULT(bool s, uint f, uint c) {
	return (s << 31) | (f << 16) | c;
}

union LARGE_INTEGER {
	struct {
		uint LowPart;
		int  HighPart;
	}
	long QuadPart;
}

alias LARGE_INTEGER LUID;
alias size_t SIZE_T;

alias UINT8 = ubyte;
alias UINT16 = ushort;
alias UINT32 = uint;
alias UINT64 = ulong;

alias INT8 = byte;
alias INT16 = short;
alias INT32 = int;
alias INT64 = long;

alias HANDLE HMONITOR;
alias const(void)* LPCVOID;

struct tagSIZE
{
	LONG        cx;
	LONG        cy;
} 
alias SIZE = tagSIZE;
alias PSIZE = tagSIZE*;
alias LPSIZE = tagSIZE*;
alias SIZEL = SIZE;
alias PSIZEL = SIZE*;
alias LPSIZEL = SIZE*;

// ======= XAudio2 stuff
version (HAS_WIN32)
{
}
else
{
// some predefinitions
align(1)
struct WAVEFORMATEX
{
	align(1):
	WORD        wFormatTag;         /* format type */
	WORD        nChannels;          /* number of channels (i.e. mono, stereo...) */
	DWORD       nSamplesPerSec;     /* sample rate */
	DWORD       nAvgBytesPerSec;    /* for buffer estimation */
	WORD        nBlockAlign;        /* block size of data */
	WORD        wBitsPerSample;     /* number of bits per sample of mono data */
	WORD        cbSize;             /* the count in bytes of the size of */
	/* extra information (after cbSize) */
}
//WAVEFORMATEX, *PWAVEFORMATEX, NEAR *NPWAVEFORMATEX, FAR *LPWAVEFORMATEX;

struct WAVEFORMATEXTENSIBLE
{
	WAVEFORMATEX Format;          // Base WAVEFORMATEX data
	union Samples
	{
		WORD wValidBitsPerSample; // Valid bits in each sample container
		WORD wSamplesPerBlock;    // Samples per block of audio data; valid
                                  // if wBitsPerSample=0 (but rarely used).
		WORD wReserved;           // Zero if neither case above applies.
	}
	DWORD dwChannelMask;          // Positions of the audio channels
	GUID SubFormat;               // Format identifier GUID
}

} // !version (HAS_WIN32)
