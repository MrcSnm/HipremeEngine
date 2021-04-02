// helper module for xaudio2 tutorial from http://www.win32developer.com/tutorial/xaudio/xaudio_tutorial_1.shtm
module wave;

import core.stdc.string : memset, memcpy;

import std.conv;
import std.stdio;

import directx.com;
import directx.xaudio2;


struct Wave
{
private:
	WAVEFORMATEX m_wf;
	XAUDIO2_BUFFER m_xa;
	ubyte[] m_waveData;
public:
	this(string szFile) 
	{
		// i don't like this calls, but let it be here for a moment
		memset(&m_wf, 0, m_wf.sizeof);
		memset(&m_xa, 0, m_xa.sizeof);

		load(szFile);
	}
	const (XAUDIO2_BUFFER)* xaBuffer() {return &m_xa;}

	const (WAVEFORMATEX)* wf() {return &m_wf;}

	bool load(string szFile) {

		auto file = File(szFile, "rb");	

		// additional variables for some hacking
		char[4] dwChunkId = 0;
		char[4] dwExtra = 0;
		byte[4] tmp;
		DWORD dwFileSize = 0, dwChunkSize = 0;

		file.seek(0);
		file.rawRead(dwChunkId);
		if( dwChunkId != "RIFF")
			return false;

		file.seek(4);
		file.rawRead(tmp);
		dwFileSize = *cast(DWORD*)tmp.ptr;
		if(dwFileSize <= 16)
			return false;

		file.seek(8);
		file.rawRead(dwExtra);
		if(dwExtra != "WAVE")
		{
			file.close();
			return false;
		}

		//look for 'fmt ' chunk id
		bool bFilledFormat = false;

		// byte offset 12 is where the data starts
		for(uint i = 12; i < dwFileSize; )
		{
			file.seek(i);
			file.rawRead(dwChunkId);

			file.seek(i+4);
			file.rawRead(tmp);
			dwChunkSize = cast(DWORD)*tmp.ptr;

			if(dwChunkId == "fmt ")
			{
				
				byte[WAVEFORMATEX.sizeof] wavetmp;

				file.seek(i+8);
				file.rawRead(wavetmp);
				memcpy(&m_wf, wavetmp.ptr, WAVEFORMATEX.sizeof);
				bFilledFormat = true;
				break;
			}
			dwChunkSize += 8; //add offsets of the chunk id, and chunk size data entries
			dwChunkSize += 1;
			dwChunkSize &= 0xfffffffe; //guarantees WORD padding alignment
			i += dwChunkSize;
		}
		if(!bFilledFormat)
		{
			file.close();
			return false;
		}

		//look for 'data' chunk id
		bool bFilledData = false;
		for(uint i = 12; i < dwFileSize; )
		{
			file.seek(i);
			file.rawRead(dwChunkId);

			file.seek(i + 4);
			file.rawRead(tmp);
			dwChunkSize = *cast(DWORD*)tmp.ptr;

			if(dwChunkId == "data")
			{
				m_waveData.length = dwChunkSize;

				file.seek(i + 8);
				file.rawRead(m_waveData);

				m_xa.AudioBytes = dwChunkSize;
				m_xa.pAudioData = m_waveData.ptr;
				m_xa.PlayBegin = 0;
				m_xa.PlayLength = 0;
				bFilledData = true;
				break;
			}
			dwChunkSize += 8; //add offsets of the chunk id, and chunk size data entries
			dwChunkSize += 1;
			dwChunkSize &= 0xfffffffe; //guarantees WORD padding alignment
			i += dwChunkSize;
		}
		if(!bFilledData)
		{
			file.close();
			return false;
		}

		return true;
	}
}