module hip.audio_decoding.resampler;

/* Copyright (C) 2007-2008 Jean-Marc Valin
    * Copyright (C) 2008      Thorvald Natvig
    * D port by Ketmar // Invisible Vector
    * D Source took from ARSD codebase
    *
    * Arbitrary resampling code
    *
    * Redistribution and use in source and binary forms, with or without
    * modification, are permitted provided that the following conditions are
    * met:
    *
    * 1. Redistributions of source code must retain the above copyright notice,
    * this list of conditions and the following disclaimer.
    *
    * 2. Redistributions in binary form must reproduce the above copyright
    * notice, this list of conditions and the following disclaimer in the
    * documentation and/or other materials provided with the distribution.
    *
    * 3. The name of the author may not be used to endorse or promote products
    * derived from this software without specific prior written permission.
    *
    * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
    * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
    * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
    * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    * POSSIBILITY OF SUCH DAMAGE.
    */

/* A-a-a-and now... D port is covered by the following license!
    *
    * This program is free software: you can redistribute it and/or modify
    * it under the terms of the GNU General Public License as published by
    * the Free Software Foundation, either version 3 of the License, or
    * (at your option) any later version.
    *
    * This program is distributed in the hope that it will be useful,
    * but WITHOUT ANY WARRANTY; without even the implied warranty of
    * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    * GNU General Public License for more details.
    *
    * You should have received a copy of the GNU General Public License
    * along with this program. If not, see <http://www.gnu.org/licenses/>.
    */
//module iv.follin.resampler /*is aliced*/;
//import iv.alice;

/*
    The design goals of this code are:
        - Very fast algorithm
        - SIMD-friendly algorithm
        - Low memory requirement
        - Good *perceptual* quality (and not best SNR)
    Warning: This resampler is relatively new. Although I think I got rid of
    all the major bugs and I don't expect the API to change anymore, there
    may be something I've missed. So use with caution.
    This algorithm is based on this original resampling algorithm:
    Smith, Julius O. Digital Audio Resampling Home Page
    Center for Computer Research in Music and Acoustics (CCRMA),
    Stanford University, 2007.
    Web published at http://www-ccrma.stanford.edu/~jos/resample/.
    There is one main difference, though. This resampler uses cubic
    interpolation instead of linear interpolation in the above paper. This
    makes the table much smaller and makes it possible to compute that table
    on a per-stream basis. In turn, being able to tweak the table for each
    stream makes it possible to both reduce complexity on simple ratios
    (e.g. 2/3), and get rid of the rounding operations in the inner loop.
    The latter both reduces CPU time and makes the algorithm more SIMD-friendly.
*/
version = sincresample_use_full_table;
version(X86) {
    version(sincresample_disable_sse) {
    } else {
    version(D_PIC) {} else version = sincresample_use_sse;
    }
}


// ////////////////////////////////////////////////////////////////////////// //
public struct SpeexResampler {
public:
    alias Quality = int;
    enum : uint {
    Fastest = 0,
    Voip = 3,
    Default = 4,
    Desktop = 5,
    Music = 8,
    Best = 10,
    }

    enum Error {
    OK = 0,
    NoMemory,
    BadState,
    BadArgument,
    BadData,
    }

private:
nothrow @trusted @nogc:
    alias ResamplerFn = int function (ref SpeexResampler st, uint chanIdx, const(float)* indata, uint *indataLen, float *outdata, uint *outdataLen);

private:
    uint inRate;
    uint outRate;
    uint numRate; // from
    uint denRate; // to

    Quality srQuality;
    uint chanCount;
    uint filterLen;
    uint memAllocSize;
    uint bufferSize;
    int intAdvance;
    int fracAdvance;
    float cutoff;
    uint oversample;
    bool started;

    // these are per-channel
    int[64] lastSample;
    uint[64] sampFracNum;
    uint[64] magicSamples;

    float* mem;
    uint realMemLen; // how much memory really allocated
    float* sincTable;
    uint sincTableLen;
    uint realSincTableLen; // how much memory really allocated
    ResamplerFn resampler;

    int inStride;
    int outStride;

public:
    static string errorStr (int err) {
    switch (err) with (Error) {
        case OK: return "success";
        case NoMemory: return "memory allocation failed";
        case BadState: return "bad resampler state";
        case BadArgument: return "invalid argument";
        case BadData: return "bad data passed";
        default:
    }
    return "unknown error";
    }

public:
    @disable this (this);
    ~this () { deinit(); }

    @property bool inited () const pure { return (resampler !is null); }

    void deinit () {
    import core.stdc.stdlib : free;
    if (mem !is null) { free(mem); mem = null; }
    if (sincTable !is null) { free(sincTable); sincTable = null; }
    /*
    memAllocSize = realMemLen = 0;
    sincTableLen = realSincTableLen = 0;
    resampler = null;
    started = false;
    */
    inRate = outRate = numRate = denRate = 0;
    srQuality = cast(Quality)666;
    chanCount = 0;
    filterLen = 0;
    memAllocSize = 0;
    bufferSize = 0;
    intAdvance = 0;
    fracAdvance = 0;
    cutoff = 0;
    oversample = 0;
    started = 0;

    mem = null;
    realMemLen = 0; // how much memory really allocated
    sincTable = null;
    sincTableLen = 0;
    realSincTableLen = 0; // how much memory really allocated
    resampler = null;

    inStride = outStride = 0;
    }

    /** Create a new resampler with integer input and output rates.
    *
    * Params:
    *  chans = Number of channels to be processed
    *  inRate = Input sampling rate (integer number of Hz).
    *  outRate = Output sampling rate (integer number of Hz).
    *  aquality = Resampling quality between 0 and 10, where 0 has poor quality and 10 has very high quality.
    *
    * Returns:
    *  0 or error code
    */
    Error setup (uint chans, uint ainRate, uint aoutRate, Quality aquality/*, usize line=__LINE__*/) {
    //{ import core.stdc.stdio; printf("init: %u -> %u at %u\n", ainRate, aoutRate, cast(uint)line); }
    import core.stdc.stdlib : malloc, free;

    deinit();
    if (aquality < 0) aquality = 0;
    if (aquality > SpeexResampler.Best) aquality = SpeexResampler.Best;
    if (chans < 1 || chans > 16) return Error.BadArgument;

    started = false;
    inRate = 0;
    outRate = 0;
    numRate = 0;
    denRate = 0;
    srQuality = cast(Quality)666; // it's ok
    sincTableLen = 0;
    memAllocSize = 0;
    filterLen = 0;
    mem = null;
    resampler = null;

    cutoff = 1.0f;
    chanCount = chans;
    inStride = 1;
    outStride = 1;

    bufferSize = 160;

    // per channel data
    lastSample[] = 0;
    magicSamples[] = 0;
    sampFracNum[] = 0;

    setQuality(aquality);
    setRate(ainRate, aoutRate);

    if (auto filterErr = updateFilter()) { deinit(); return filterErr; }
    skipZeros(); // make sure that the first samples to go out of the resamplers don't have leading zeros

    return Error.OK;
    }

    /** Set (change) the input/output sampling rates (integer value).
    *
    * Params:
    *  ainRate = Input sampling rate (integer number of Hz).
    *  aoutRate = Output sampling rate (integer number of Hz).
    *
    * Returns:
    *  0 or error code
    */
    Error setRate (uint ainRate, uint aoutRate/*, usize line=__LINE__*/) {
    //{ import core.stdc.stdio; printf("changing rate: %u -> %u at %u\n", ainRate, aoutRate, cast(uint)line); }
    if (inRate == ainRate && outRate == aoutRate) return Error.OK;
    //{ import core.stdc.stdio; printf("changing rate: %u -> %u at %u\n", ratioNum, ratioDen, cast(uint)line); }

    uint oldDen = denRate;
    inRate = ainRate;
    outRate = aoutRate;
    auto div = gcd(ainRate, aoutRate);
    numRate = ainRate/div;
    denRate = aoutRate/div;

    if (oldDen > 0) {
        foreach (ref v; sampFracNum.ptr[0..chanCount]) {
    v = v*denRate/oldDen;
    // safety net
    if (v >= denRate) v = denRate-1;
        }
    }

    return (inited ? updateFilter() : Error.OK);
    }

    /** Get the current input/output sampling rates (integer value).
    *
    * Params:
    *  ainRate = Input sampling rate (integer number of Hz) copied.
    *  aoutRate = Output sampling rate (integer number of Hz) copied.
    */
    void getRate (out uint ainRate, out uint aoutRate) {
    ainRate = inRate;
    aoutRate = outRate;
    }

    @property uint getInRate () { return inRate; }
    @property uint getOutRate () { return outRate; }

    @property uint getChans () { return chanCount; }

    /** Get the current resampling ratio. This will be reduced to the least common denominator.
    *
    * Params:
    *  ratioNum = Numerator of the sampling rate ratio copied
    *  ratioDen = Denominator of the sampling rate ratio copied
    */
    void getRatio (out uint ratioNum, out uint ratioDen) {
    ratioNum = numRate;
    ratioDen = denRate;
    }

    /** Set (change) the conversion quality.
    *
    * Params:
    *  quality = Resampling quality between 0 and 10, where 0 has poor quality and 10 has very high quality.
    *
    * Returns:
    *  0 or error code
    */
    Error setQuality (Quality aquality) {
    if (aquality < 0) aquality = 0;
    if (aquality > SpeexResampler.Best) aquality = SpeexResampler.Best;
    if (srQuality == aquality) return Error.OK;
    srQuality = aquality;
    return (inited ? updateFilter() : Error.OK);
    }

    /** Get the conversion quality.
    *
    * Returns:
    *  Resampling quality between 0 and 10, where 0 has poor quality and 10 has very high quality.
    */
    int getQuality () { return srQuality; }

    /** Get the latency introduced by the resampler measured in input samples.
    *
    * Returns:
    *  Input latency;
    */
    int inputLatency () { return filterLen/2; }

    /** Get the latency introduced by the resampler measured in output samples.
    *
    * Returns:
    *  Output latency.
    */
    int outputLatency () { return ((filterLen/2)*denRate+(numRate>>1))/numRate; }

    /* Make sure that the first samples to go out of the resamplers don't have
    * leading zeros. This is only useful before starting to use a newly created
    * resampler. It is recommended to use that when resampling an audio file, as
    * it will generate a file with the same length. For real-time processing,
    * it is probably easier not to use this call (so that the output duration
    * is the same for the first frame).
    *
    * Setup/reset sequence will automatically call this, so it is private.
    */
    private void skipZeros () { foreach (immutable i; 0..chanCount) lastSample.ptr[i] = filterLen/2; }

    static struct Data {
    const(float)[] dataIn;
    float[] dataOut;
    uint inputSamplesUsed; // out value, in samples (i.e. multiplied by channel count)
    uint outputSamplesUsed; // out value, in samples (i.e. multiplied by channel count)
    }

    /** Resample (an interleaved) float array. The input and output buffers must *not* overlap.
    * `data.dataIn` can be empty, but `data.dataOut` can't.
    * Function will return number of consumed samples (*not* *frames*!) in `data.inputSamplesUsed`,
    * and number of produced samples in `data.outputSamplesUsed`.
    * You should provide enough samples for all channels, and all channels will be processed.
    *
    * Params:
    *  data = input and output buffers, number of frames consumed and produced
    *
    * Returns:
    *  0 or error code
    */
    Error process(string mode="interleaved") (ref Data data) {
    static assert(mode == "interleaved" || mode == "sequential");

    data.inputSamplesUsed = data.outputSamplesUsed = 0;
    if (!inited) return Error.BadState;

    if (data.dataIn.length%chanCount || data.dataOut.length < 1 || data.dataOut.length%chanCount) return Error.BadData;
    if (data.dataIn.length > uint.max/4 || data.dataOut.length > uint.max/4) return Error.BadData;

    static if (mode == "interleaved") {
        inStride = outStride = chanCount;
    } else {
        inStride = outStride = 1;
    }
    uint iofs = 0, oofs = 0;
    immutable uint idclen = cast(uint)(data.dataIn.length/chanCount);
    immutable uint odclen = cast(uint)(data.dataOut.length/chanCount);
    foreach (immutable i; 0..chanCount) {
        data.inputSamplesUsed = idclen;
        data.outputSamplesUsed = odclen;
        if (data.dataIn.length) {
    processOneChannel(i, data.dataIn.ptr+iofs, &data.inputSamplesUsed, data.dataOut.ptr+oofs, &data.outputSamplesUsed);
        } else {
    processOneChannel(i, null, &data.inputSamplesUsed, data.dataOut.ptr+oofs, &data.outputSamplesUsed);
        }
        static if (mode == "interleaved") {
    ++iofs;
    ++oofs;
        } else {
    iofs += idclen;
    oofs += odclen;
        }
    }
    data.inputSamplesUsed *= chanCount;
    data.outputSamplesUsed *= chanCount;
    return Error.OK;
    }


    //HACK for libswresample
    // return -1 or number of outframes
    int swrconvert (float** outbuf, int outframes, const(float)**inbuf, int inframes) {
    if (!inited || outframes < 1 || inframes < 0) return -1;
    inStride = outStride = 1;
    Data data;
    foreach (immutable i; 0..chanCount) {
        data.dataIn = (inframes ? inbuf[i][0..inframes] : null);
        data.dataOut = (outframes ? outbuf[i][0..outframes] : null);
        data.inputSamplesUsed = inframes;
        data.outputSamplesUsed = outframes;
        if (inframes > 0) {
    processOneChannel(i, data.dataIn.ptr, &data.inputSamplesUsed, data.dataOut.ptr, &data.outputSamplesUsed);
        } else {
    processOneChannel(i, null, &data.inputSamplesUsed, data.dataOut.ptr, &data.outputSamplesUsed);
        }
    }
    return data.outputSamplesUsed;
    }

    /// Reset a resampler so a new (unrelated) stream can be processed.
    void reset () {
    lastSample[] = 0;
    magicSamples[] = 0;
    sampFracNum[] = 0;
    //foreach (immutable i; 0..chanCount*(filterLen-1)) mem[i] = 0;
    if (mem !is null) mem[0..chanCount*(filterLen-1)] = 0;
    skipZeros(); // make sure that the first samples to go out of the resamplers don't have leading zeros
    }

private:
    Error processOneChannel (uint chanIdx, const(float)* indata, uint* indataLen, float* outdata, uint* outdataLen) {
    uint ilen = *indataLen;
    uint olen = *outdataLen;
    float* x = mem+chanIdx*memAllocSize;
    immutable int filterOfs = filterLen-1;
    immutable uint xlen = memAllocSize-filterOfs;
    immutable int istride = inStride;
    if (magicSamples.ptr[chanIdx]) olen -= magic(chanIdx, &outdata, olen);
    if (!magicSamples.ptr[chanIdx]) {
        while (ilen && olen) {
    uint ichunk = (ilen > xlen ? xlen : ilen);
    uint ochunk = olen;
    if (indata !is null) {
        //foreach (immutable j; 0..ichunk) x[j+filterOfs] = indata[j*istride];
        if (istride == 1) {
        x[filterOfs..filterOfs+ichunk] = indata[0..ichunk];
        } else {
        auto sp = indata;
        auto dp = x+filterOfs;
        foreach (immutable j; 0..ichunk) { *dp++ = *sp; sp += istride; }
        }
    } else {
        //foreach (immutable j; 0..ichunk) x[j+filterOfs] = 0;
        x[filterOfs..filterOfs+ichunk] = 0;
    }
    processNative(chanIdx, &ichunk, outdata, &ochunk);
    ilen -= ichunk;
    olen -= ochunk;
    outdata += ochunk*outStride;
    if (indata !is null) indata += ichunk*istride;
        }
    }
    *indataLen -= ilen;
    *outdataLen -= olen;
    return Error.OK;
    }

    Error processNative (uint chanIdx, uint* indataLen, float* outdata, uint* outdataLen) {
    immutable N = filterLen;
    int outSample = 0;
    float* x = mem+chanIdx*memAllocSize;
    uint ilen;
    started = true;
    // call the right resampler through the function ptr
    outSample = resampler(this, chanIdx, x, indataLen, outdata, outdataLen);
    if (lastSample.ptr[chanIdx] < cast(int)*indataLen) *indataLen = lastSample.ptr[chanIdx];
    *outdataLen = outSample;
    lastSample.ptr[chanIdx] -= *indataLen;
    ilen = *indataLen;
    foreach (immutable j; 0..N-1) x[j] = x[j+ilen];
    return Error.OK;
    }

    int magic (uint chanIdx, float **outdata, uint outdataLen) {
    uint tempInLen = magicSamples.ptr[chanIdx];
    float* x = mem+chanIdx*memAllocSize;
    processNative(chanIdx, &tempInLen, *outdata, &outdataLen);
    magicSamples.ptr[chanIdx] -= tempInLen;
    // if we couldn't process all "magic" input samples, save the rest for next time
    if (magicSamples.ptr[chanIdx]) {
        immutable N = filterLen;
        foreach (immutable i; 0..magicSamples.ptr[chanIdx]) x[N-1+i] = x[N-1+i+tempInLen];
    }
    *outdata += outdataLen*outStride;
    return outdataLen;
    }

    Error updateFilter () {
    uint oldFilterLen = filterLen;
    uint oldAllocSize = memAllocSize;
    bool useDirect;
    uint minSincTableLen;
    uint minAllocSize;

    intAdvance = numRate/denRate;
    fracAdvance = numRate%denRate;
    oversample = qualityMap.ptr[srQuality].oversample;
    filterLen = qualityMap.ptr[srQuality].baseLength;

    if (numRate > denRate) {
        // down-sampling
        cutoff = qualityMap.ptr[srQuality].downsampleBandwidth*denRate/numRate;
        // FIXME: divide the numerator and denominator by a certain amount if they're too large
        filterLen = filterLen*numRate/denRate;
        // round up to make sure we have a multiple of 8 for SSE
        filterLen = ((filterLen-1)&(~0x7))+8;
        if (2*denRate < numRate) oversample >>= 1;
        if (4*denRate < numRate) oversample >>= 1;
        if (8*denRate < numRate) oversample >>= 1;
        if (16*denRate < numRate) oversample >>= 1;
        if (oversample < 1) oversample = 1;
    } else {
        // up-sampling
        cutoff = qualityMap.ptr[srQuality].upsampleBandwidth;
    }

    // choose the resampling type that requires the least amount of memory
    version(sincresample_use_full_table) {
        useDirect = true;
        if (int.max/float.sizeof/denRate < filterLen) goto fail;
    } else {
        useDirect = (filterLen*denRate <= filterLen*oversample+8 && int.max/float.sizeof/denRate >= filterLen);
    }

    if (useDirect) {
        minSincTableLen = filterLen*denRate;
    } else {
        if ((int.max/float.sizeof-8)/oversample < filterLen) goto fail;
        minSincTableLen = filterLen*oversample+8;
    }

    if (sincTableLen < minSincTableLen) {
        import core.stdc.stdlib : realloc;
        auto nslen = cast(uint)(minSincTableLen*float.sizeof);
        if (nslen > realSincTableLen) {
    if (nslen < 512*1024) nslen = 512*1024; // inc to 3 mb?
    auto x = cast(float*)realloc(sincTable, nslen);
    if (!x) goto fail;
    sincTable = x;
    realSincTableLen = nslen;
        }
        sincTableLen = minSincTableLen;
    }

    if (useDirect) {
        foreach (int i; 0..denRate) {
    foreach (int j; 0..filterLen) {
        sincTable[i*filterLen+j] = sinc(cutoff, ((j-cast(int)filterLen/2+1)-(cast(float)i)/denRate), filterLen, qualityMap.ptr[srQuality].windowFunc);
    }
        }
        if (srQuality > 8) {
    resampler = &resamplerBasicDirect!double;
        } else {
    resampler = &resamplerBasicDirect!float;
        }
    } else {
        foreach (immutable int i; -4..cast(int)(oversample*filterLen+4)) {
    sincTable[i+4] = sinc(cutoff, (i/cast(float)oversample-filterLen/2), filterLen, qualityMap.ptr[srQuality].windowFunc);
        }
        if (srQuality > 8) {
    resampler = &resamplerBasicInterpolate!double;
        } else {
    resampler = &resamplerBasicInterpolate!float;
        }
    }

    /* Here's the place where we update the filter memory to take into account
        the change in filter length. It's probably the messiest part of the code
        due to handling of lots of corner cases. */

    // adding bufferSize to filterLen won't overflow here because filterLen could be multiplied by float.sizeof above
    minAllocSize = filterLen-1+bufferSize;
    if (minAllocSize > memAllocSize) {
        import core.stdc.stdlib : realloc;
        if (int.max/float.sizeof/chanCount < minAllocSize) goto fail;
        auto nslen = cast(uint)(chanCount*minAllocSize*mem[0].sizeof);
        if (nslen > realMemLen) {
    if (nslen < 16384) nslen = 16384;
    auto x = cast(float*)realloc(mem, nslen);
    if (x is null) goto fail;
    mem = x;
    realMemLen = nslen;
        }
        memAllocSize = minAllocSize;
    }
    if (!started) {
        //foreach (i=0;i<chanCount*memAllocSize;i++) mem[i] = 0;
        mem[0..chanCount*memAllocSize] = 0;
    } else if (filterLen > oldFilterLen) {
        // increase the filter length
        foreach_reverse (uint i; 0..chanCount) {
    uint j;
    uint olen = oldFilterLen;
    {
        // try and remove the magic samples as if nothing had happened
        //FIXME: this is wrong but for now we need it to avoid going over the array bounds
        olen = oldFilterLen+2*magicSamples.ptr[i];
        for (j = oldFilterLen-1+magicSamples.ptr[i]; j--; ) mem[i*memAllocSize+j+magicSamples.ptr[i]] = mem[i*oldAllocSize+j];
        //for (j = 0; j < magicSamples.ptr[i]; ++j) mem[i*memAllocSize+j] = 0;
        mem[i*memAllocSize..i*memAllocSize+magicSamples.ptr[i]] = 0;
        magicSamples.ptr[i] = 0;
    }
    if (filterLen > olen) {
        // if the new filter length is still bigger than the "augmented" length
        // copy data going backward
        for (j = 0; j < olen-1; ++j) mem[i*memAllocSize+(filterLen-2-j)] = mem[i*memAllocSize+(olen-2-j)];
        // then put zeros for lack of anything better
        for (; j < filterLen-1; ++j) mem[i*memAllocSize+(filterLen-2-j)] = 0;
        // adjust lastSample
        lastSample.ptr[i] += (filterLen-olen)/2;
    } else {
        // put back some of the magic!
        magicSamples.ptr[i] = (olen-filterLen)/2;
        for (j = 0; j < filterLen-1+magicSamples.ptr[i]; ++j) mem[i*memAllocSize+j] = mem[i*memAllocSize+j+magicSamples.ptr[i]];
    }
        }
    } else if (filterLen < oldFilterLen) {
        // reduce filter length, this a bit tricky
        // we need to store some of the memory as "magic" samples so they can be used directly as input the next time(s)
        foreach (immutable i; 0..chanCount) {
    uint j;
    uint oldMagic = magicSamples.ptr[i];
    magicSamples.ptr[i] = (oldFilterLen-filterLen)/2;
    // we must copy some of the memory that's no longer used
    // copy data going backward
    for (j = 0; j < filterLen-1+magicSamples.ptr[i]+oldMagic; ++j) {
        mem[i*memAllocSize+j] = mem[i*memAllocSize+j+magicSamples.ptr[i]];
    }
    magicSamples.ptr[i] += oldMagic;
        }
    }
    return Error.OK;

    fail:
    resampler = null;
    /* mem may still contain consumed input samples for the filter.
        Restore filterLen so that filterLen-1 still points to the position after
        the last of these samples. */
    filterLen = oldFilterLen;
    return Error.NoMemory;
    }
}

enum BUFFER_SIZE_FRAMES = 1024;//512;//2048;
enum BUFFER_SIZE_SHORT = BUFFER_SIZE_FRAMES * 2;


// ////////////////////////////////////////////////////////////////////////// //
static immutable double[68] kaiser12Table = [
    0.99859849, 1.00000000, 0.99859849, 0.99440475, 0.98745105, 0.97779076,
    0.96549770, 0.95066529, 0.93340547, 0.91384741, 0.89213598, 0.86843014,
    0.84290116, 0.81573067, 0.78710866, 0.75723148, 0.72629970, 0.69451601,
    0.66208321, 0.62920216, 0.59606986, 0.56287762, 0.52980938, 0.49704014,
    0.46473455, 0.43304576, 0.40211431, 0.37206735, 0.34301800, 0.31506490,
    0.28829195, 0.26276832, 0.23854851, 0.21567274, 0.19416736, 0.17404546,
    0.15530766, 0.13794294, 0.12192957, 0.10723616, 0.09382272, 0.08164178,
    0.07063950, 0.06075685, 0.05193064, 0.04409466, 0.03718069, 0.03111947,
    0.02584161, 0.02127838, 0.01736250, 0.01402878, 0.01121463, 0.00886058,
    0.00691064, 0.00531256, 0.00401805, 0.00298291, 0.00216702, 0.00153438,
    0.00105297, 0.00069463, 0.00043489, 0.00025272, 0.00013031, 0.0000527734,
    0.00001000, 0.00000000];

static immutable double[36] kaiser10Table = [
    0.99537781, 1.00000000, 0.99537781, 0.98162644, 0.95908712, 0.92831446,
    0.89005583, 0.84522401, 0.79486424, 0.74011713, 0.68217934, 0.62226347,
    0.56155915, 0.50119680, 0.44221549, 0.38553619, 0.33194107, 0.28205962,
    0.23636152, 0.19515633, 0.15859932, 0.12670280, 0.09935205, 0.07632451,
    0.05731132, 0.04193980, 0.02979584, 0.02044510, 0.01345224, 0.00839739,
    0.00488951, 0.00257636, 0.00115101, 0.00035515, 0.00000000, 0.00000000];

static immutable double[36] kaiser8Table = [
    0.99635258, 1.00000000, 0.99635258, 0.98548012, 0.96759014, 0.94302200,
    0.91223751, 0.87580811, 0.83439927, 0.78875245, 0.73966538, 0.68797126,
    0.63451750, 0.58014482, 0.52566725, 0.47185369, 0.41941150, 0.36897272,
    0.32108304, 0.27619388, 0.23465776, 0.19672670, 0.16255380, 0.13219758,
    0.10562887, 0.08273982, 0.06335451, 0.04724088, 0.03412321, 0.02369490,
    0.01563093, 0.00959968, 0.00527363, 0.00233883, 0.00050000, 0.00000000];

static immutable double[36] kaiser6Table = [
    0.99733006, 1.00000000, 0.99733006, 0.98935595, 0.97618418, 0.95799003,
    0.93501423, 0.90755855, 0.87598009, 0.84068475, 0.80211977, 0.76076565,
    0.71712752, 0.67172623, 0.62508937, 0.57774224, 0.53019925, 0.48295561,
    0.43647969, 0.39120616, 0.34752997, 0.30580127, 0.26632152, 0.22934058,
    0.19505503, 0.16360756, 0.13508755, 0.10953262, 0.08693120, 0.06722600,
    0.05031820, 0.03607231, 0.02432151, 0.01487334, 0.00752000, 0.00000000];

struct FuncDef {
    immutable(double)* table;
    int oversample;
}

static immutable FuncDef Kaiser12 = FuncDef(kaiser12Table.ptr, 64);
static immutable FuncDef Kaiser10 = FuncDef(kaiser10Table.ptr, 32);
static immutable FuncDef Kaiser8 = FuncDef(kaiser8Table.ptr, 32);
static immutable FuncDef Kaiser6 = FuncDef(kaiser6Table.ptr, 32);


struct QualityMapping {
    int baseLength;
    int oversample;
    float downsampleBandwidth;
    float upsampleBandwidth;
    immutable FuncDef* windowFunc;
}


/* This table maps conversion quality to internal parameters. There are two
    reasons that explain why the up-sampling bandwidth is larger than the
    down-sampling bandwidth:
    1) When up-sampling, we can assume that the spectrum is already attenuated
        close to the Nyquist rate (from an A/D or a previous resampling filter)
    2) Any aliasing that occurs very close to the Nyquist rate will be masked
        by the sinusoids/noise just below the Nyquist rate (guaranteed only for
        up-sampling).
*/
static immutable QualityMapping[11] qualityMap = [
    QualityMapping(  8,  4, 0.830f, 0.860f, &Kaiser6 ), /* Q0 */
    QualityMapping( 16,  4, 0.850f, 0.880f, &Kaiser6 ), /* Q1 */
    QualityMapping( 32,  4, 0.882f, 0.910f, &Kaiser6 ), /* Q2 */  /* 82.3% cutoff ( ~60 dB stop) 6  */
    QualityMapping( 48,  8, 0.895f, 0.917f, &Kaiser8 ), /* Q3 */  /* 84.9% cutoff ( ~80 dB stop) 8  */
    QualityMapping( 64,  8, 0.921f, 0.940f, &Kaiser8 ), /* Q4 */  /* 88.7% cutoff ( ~80 dB stop) 8  */
    QualityMapping( 80, 16, 0.922f, 0.940f, &Kaiser10), /* Q5 */  /* 89.1% cutoff (~100 dB stop) 10 */
    QualityMapping( 96, 16, 0.940f, 0.945f, &Kaiser10), /* Q6 */  /* 91.5% cutoff (~100 dB stop) 10 */
    QualityMapping(128, 16, 0.950f, 0.950f, &Kaiser10), /* Q7 */  /* 93.1% cutoff (~100 dB stop) 10 */
    QualityMapping(160, 16, 0.960f, 0.960f, &Kaiser10), /* Q8 */  /* 94.5% cutoff (~100 dB stop) 10 */
    QualityMapping(192, 32, 0.968f, 0.968f, &Kaiser12), /* Q9 */  /* 95.5% cutoff (~100 dB stop) 10 */
    QualityMapping(256, 32, 0.975f, 0.975f, &Kaiser12), /* Q10 */ /* 96.6% cutoff (~100 dB stop) 10 */
];


nothrow @trusted @nogc:
/*8, 24, 40, 56, 80, 104, 128, 160, 200, 256, 320*/
double computeFunc (float x, immutable FuncDef* func) 
{
    version(Posix) import core.stdc.math : lrintf;
    import std.math : floor;
    //double[4] interp;
    float y = x*func.oversample;
    version(Posix) {
    int ind = cast(int)lrintf(floor(y));
    } else {
    int ind = cast(int)(floor(y));
    }
    float frac = (y-ind);
    immutable f2 = frac*frac;
    immutable f3 = f2*frac;
    double interp3 = -0.1666666667*frac+0.1666666667*(f3);
    double interp2 = frac+0.5*(f2)-0.5*(f3);
    //double interp2 = 1.0f-0.5f*frac-f2+0.5f*f3;
    double interp0 = -0.3333333333*frac+0.5*(f2)-0.1666666667*(f3);
    // just to make sure we don't have rounding problems
    double interp1 = 1.0f-interp3-interp2-interp0;
    //sum = frac*accum[1]+(1-frac)*accum[2];
    return interp0*func.table[ind]+interp1*func.table[ind+1]+interp2*func.table[ind+2]+interp3*func.table[ind+3];
}


// the slow way of computing a sinc for the table; should improve that some day
float sinc (float cutoff, float x, int N, immutable FuncDef *windowFunc) 
{
    version(LittleEndian) {
    align(1) union temp_float { align(1): float f; uint n; }
    } else {
    static T fabs(T) (T n) pure { static if (__VERSION__ > 2067) pragma(inline, true); return (n < 0 ? -n : n); }
    }
    import std.math : sin, PI;
    version(LittleEndian) {
    temp_float txx = void;
    txx.f = x;
    txx.n &= 0x7fff_ffff; // abs
    if (txx.f < 1.0e-6f) return cutoff;
    if (txx.f > 0.5f*N) return 0;
    } else {
    if (fabs(x) < 1.0e-6f) return cutoff;
    if (fabs(x) > 0.5f*N) return 0;
    }
    //FIXME: can it really be any slower than this?
    immutable float xx = x*cutoff;
    immutable pixx = PI*xx;
    version(LittleEndian) {
    return cutoff*sin(pixx)/pixx*computeFunc(2.0*txx.f/N, windowFunc);
    } else {
    return cutoff*sin(pixx)/pixx*computeFunc(fabs(2.0*x/N), windowFunc);
    }
}


void cubicCoef (in float frac, float* interp) {
    immutable f2 = frac*frac;
    immutable f3 = f2*frac;
    // compute interpolation coefficients; i'm not sure whether this corresponds to cubic interpolation but I know it's MMSE-optimal on a sinc
    interp[0] =  -0.16667f*frac+0.16667f*f3;
    interp[1] = frac+0.5f*f2-0.5f*f3;
    //interp[2] = 1.0f-0.5f*frac-f2+0.5f*f3;
    interp[3] = -0.33333f*frac+0.5f*f2-0.16667f*f3;
    // just to make sure we don't have rounding problems
    interp[2] = 1.0-interp[0]-interp[1]-interp[3];
}


// ////////////////////////////////////////////////////////////////////////// //
int resamplerBasicDirect(T) (ref SpeexResampler st, uint chanIdx, const(float)* indata, uint* indataLen, float* outdata, uint* outdataLen)
if (is(T == float) || is(T == double))
{
    auto N = st.filterLen;
    static if (is(T == double)) assert(N%4 == 0);
    int outSample = 0;
    int lastSample = st.lastSample.ptr[chanIdx];
    uint sampFracNum = st.sampFracNum.ptr[chanIdx];
    const(float)* sincTable = st.sincTable;
    immutable outStride = st.outStride;
    immutable intAdvance = st.intAdvance;
    immutable fracAdvance = st.fracAdvance;
    immutable denRate = st.denRate;
    T sum = void;
    while (!(lastSample >= cast(int)(*indataLen) || outSample >= cast(int)(*outdataLen))) {
    const(float)* sinct = &sincTable[sampFracNum*N];
    const(float)* iptr = &indata[lastSample];
    static if (is(T == float)) {
        // at least 2x speedup with SSE here (but for unrolled loop)
        if (N%4 == 0) {
    version(sincresample_use_sse) {
        //align(64) __gshared float[4] zero = 0;
        align(64) __gshared float[4+128] zeroesBuf = 0; // dmd cannot into such aligns, alas
        __gshared uint zeroesptr = 0;
        if (zeroesptr == 0) {
        zeroesptr = cast(uint)zeroesBuf.ptr;
        if (zeroesptr&0x3f) zeroesptr = (zeroesptr|0x3f)+1;
        }
        //assert((zeroesptr&0x3f) == 0, "wtf?!");
        asm nothrow @safe @nogc {
        mov       ECX,[N];
        shr       ECX,2;
        mov       EAX,[zeroesptr];
        movaps    XMM0,[EAX];
        mov       EAX,[sinct];
        mov       EBX,[iptr];
        mov       EDX,16;
        align 8;
        rbdseeloop:
        movups    XMM1,[EAX];
        movups    XMM2,[EBX];
        mulps     XMM1,XMM2;
        addps     XMM0,XMM1;
        add       EAX,EDX;
        add       EBX,EDX;
        dec       ECX;
        jnz       rbdseeloop;
        // store result in sum
        movhlps   XMM1,XMM0; // now low part of XMM1 contains high part of XMM0
        addps     XMM0,XMM1; // low part of XMM0 is ok
        movaps    XMM1,XMM0;
        shufps    XMM1,XMM0,0b_01_01_01_01; // 2nd float of XMM0 goes to the 1st float of XMM1
        addss     XMM0,XMM1;
        movss     [sum],XMM0;
        }
        /*
        float sum1 = 0;
        foreach (immutable j; 0..N) sum1 += sinct[j]*iptr[j];
        import std.math;
        if (fabs(sum-sum1) > 0.000001f) {
        import core.stdc.stdio;
        printf("sum=%f; sum1=%f\n", sum, sum1);
        assert(0);
        }
        */
    } else {
        // no SSE; for my i3 unrolled loop is almost of the speed of SSE code
        T[4] accum = 0;
        foreach (immutable j; 0..N/4) {
        accum.ptr[0] += *sinct++ * *iptr++;
        accum.ptr[1] += *sinct++ * *iptr++;
        accum.ptr[2] += *sinct++ * *iptr++;
        accum.ptr[3] += *sinct++ * *iptr++;
        }
        sum = accum.ptr[0]+accum.ptr[1]+accum.ptr[2]+accum.ptr[3];
    }
        } else {
    sum = 0;
    foreach (immutable j; 0..N) sum += *sinct++ * *iptr++;
        }
        outdata[outStride*outSample++] = sum;
    } else {
        if (N%4 == 0) {
    //TODO: write SSE code here!
    // for my i3 unrolled loop is ~2 times faster
    T[4] accum = 0;
    foreach (immutable j; 0..N/4) {
        accum.ptr[0] += cast(double)*sinct++ * cast(double)*iptr++;
        accum.ptr[1] += cast(double)*sinct++ * cast(double)*iptr++;
        accum.ptr[2] += cast(double)*sinct++ * cast(double)*iptr++;
        accum.ptr[3] += cast(double)*sinct++ * cast(double)*iptr++;
    }
    sum = accum.ptr[0]+accum.ptr[1]+accum.ptr[2]+accum.ptr[3];
        } else {
    sum = 0;
    foreach (immutable j; 0..N) sum += cast(double)*sinct++ * cast(double)*iptr++;
        }
        outdata[outStride*outSample++] = cast(float)sum;
    }
    lastSample += intAdvance;
    sampFracNum += fracAdvance;
    if (sampFracNum >= denRate) {
        sampFracNum -= denRate;
        ++lastSample;
    }
    }
    st.lastSample.ptr[chanIdx] = lastSample;
    st.sampFracNum.ptr[chanIdx] = sampFracNum;
    return outSample;
}


int resamplerBasicInterpolate(T) (ref SpeexResampler st, uint chanIdx, const(float)* indata, uint *indataLen, float *outdata, uint *outdataLen)
if (is(T == float) || is(T == double))
{
    immutable N = st.filterLen;
    assert(N%4 == 0);
    int outSample = 0;
    int lastSample = st.lastSample.ptr[chanIdx];
    uint sampFracNum = st.sampFracNum.ptr[chanIdx];
    immutable outStride = st.outStride;
    immutable intAdvance = st.intAdvance;
    immutable fracAdvance = st.fracAdvance;
    immutable denRate = st.denRate;
    float sum;

    float[4] interp = void;
    T[4] accum = void;
    while (!(lastSample >= cast(int)(*indataLen) || outSample >= cast(int)(*outdataLen))) {
    const(float)* iptr = &indata[lastSample];
    const int offset = sampFracNum*st.oversample/st.denRate;
    const float frac = (cast(float)((sampFracNum*st.oversample)%st.denRate))/st.denRate;
    accum[] = 0;
    //TODO: optimize!
    foreach (immutable j; 0..N) {
        immutable T currIn = iptr[j];
        accum.ptr[0] += currIn*(st.sincTable[4+(j+1)*st.oversample-offset-2]);
        accum.ptr[1] += currIn*(st.sincTable[4+(j+1)*st.oversample-offset-1]);
        accum.ptr[2] += currIn*(st.sincTable[4+(j+1)*st.oversample-offset]);
        accum.ptr[3] += currIn*(st.sincTable[4+(j+1)*st.oversample-offset+1]);
    }

    cubicCoef(frac, interp.ptr);
    sum = (interp.ptr[0]*accum.ptr[0])+(interp.ptr[1]*accum.ptr[1])+(interp.ptr[2]*accum.ptr[2])+(interp.ptr[3]*accum.ptr[3]);

    outdata[outStride*outSample++] = sum;
    lastSample += intAdvance;
    sampFracNum += fracAdvance;
    if (sampFracNum >= denRate) {
        sampFracNum -= denRate;
        ++lastSample;
    }
    }

    st.lastSample.ptr[chanIdx] = lastSample;
    st.sampFracNum.ptr[chanIdx] = sampFracNum;
    return outSample;
}


// ////////////////////////////////////////////////////////////////////////// //
uint gcd (uint a, uint b) pure {
    if (a == 0) return b;
    if (b == 0) return a;
    for (;;) {
    if (a > b) {
        a %= b;
        if (a == 0) return b;
        if (a == 1) return 1;
    } else {
        b %= a;
        if (b == 0) return a;
        if (b == 1) return 1;
    }
    }
}


// ////////////////////////////////////////////////////////////////////////// //
// very simple and cheap cubic upsampler
struct CubicUpsampler 
{
public:
nothrow @trusted @nogc:
    float[2] curposfrac; // current position offset [0..1)
    float step; // how long we should move on one step?
    float[4][2] data; // -1..3
    uint[2] drain;

    void reset () 
    {
        curposfrac[] = 0.0f;
        foreach (ref d; data) d[] = 0.0f;
        drain[] = 0;
    }

    bool setup (float astep) 
    {
        if (astep >= 1.0f) return false;
        step = astep;
        return true;
    }

    /*
    static struct Data {
    const(float)[] dataIn;
    float[] dataOut;
    uint inputSamplesUsed; // out value, in samples (i.e. multiplied by channel count)
    uint outputSamplesUsed; // out value, in samples (i.e. multiplied by channel count)
    }
    */

    SpeexResampler.Error process (ref SpeexResampler.Data d) 
    {
        d.inputSamplesUsed = d.outputSamplesUsed = 0;
        if (d.dataOut.length < 2) return SpeexResampler.Error.OK;
        foreach (uint cidx; 0..2) {
            uint inleft = cast(uint)d.dataIn.length/2;
            uint outleft = cast(uint)d.dataOut.length/2;
            processChannel(inleft, outleft, (d.dataIn.length ? d.dataIn.ptr+cidx : null), (d.dataOut.length ? d.dataOut.ptr+cidx : null), cidx);
            d.outputSamplesUsed += cast(uint)(d.dataOut.length/2)-outleft;
            d.inputSamplesUsed += cast(uint)(d.dataIn.length/2)-inleft;
        }
        return SpeexResampler.Error.OK;
    }

    private void processChannel (ref uint inleft, ref uint outleft, const(float)* dataIn, float* dataOut, uint cidx) 
    {
        if (outleft == 0) return;
        if (inleft == 0 && drain.ptr[cidx] <= 1) return;
        auto dt = data.ptr[cidx].ptr;
        auto drn = drain.ptr+cidx;
        auto cpf = curposfrac.ptr+cidx;
        immutable float st = step;
        for (;;) {
            // fill buffer
            while ((*drn) < 4) {
        if (inleft == 0) return;
        dt[(*drn)++] = *dataIn;
        dataIn += 2;
        --inleft;
            }
            if (outleft == 0) return;
            --outleft;
            // cubic interpolation
            /*version(none)*/ {
        // interpolate between y1 and y2
        immutable float mu = (*cpf); // how far we are moved from y1 to y2
        immutable float mu2 = mu*mu; // wow
        immutable float y0 = dt[0], y1 = dt[1], y2 = dt[2], y3 = dt[3];
        version(complex_cubic) {
            immutable float z0 = 0.5*y3;
            immutable float z1 = 0.5*y0;
            immutable float a0 = 1.5*y1-z1-1.5*y2+z0;
            immutable float a1 = y0-2.5*y1+2*y2-z0;
            immutable float a2 = 0.5*y2-z1;
        } else {
            immutable float a0 = y3-y2-y0+y1;
            immutable float a1 = y0-y1-a0;
            immutable float a2 = y2-y0;
        }
        *dataOut = a0*mu*mu2+a1*mu2+a2*mu+y1;
            }// else *dataOut = dt[1];
            dataOut += 2;
            if (((*cpf) += st) >= 1.0f) 
            {
                (*cpf) -= 1.0f;
                dt[0] = dt[1];
                dt[1] = dt[2];
                dt[2] = dt[3];
                dt[3] = 0.0f;
                --(*drn); // will request more input bytes
            }
        }
    }
}


interface SampleController {
	/++
		Pauses playback, keeping its position. Use [resume] to pick up where it left off.
	+/
	void pause();
	/++
		Resumes playback after a call to [pause].
	+/
	void resume();
	/++
		Stops playback. Once stopped, it cannot be restarted
		except by creating a new sample from the [AudioOutputThread]
		object.
	+/
	void stop();
	/++
		Reports the current stream position, in seconds, if available (NaN if not).
	+/
	float position();

	/++
		If the sample has finished playing. Happens when it runs out or if it is stopped.
	+/
	bool finished();

	/++
		If the sample has been paused.
		History:
			Added May 26, 2021 (dub v10.0)
	+/
	bool paused();
}

package class SampleControlFlags : SampleController 
{
	void pause() { paused_ = true; }
	void resume() { paused_ = false; }
	void stop() { paused_ = false; stopped = true; }

	bool paused_;
	bool stopped;
	bool finished_;

	float position() { return currentPosition; }
	bool finished() { return finished_; }
	bool paused() { return paused_; }

	float currentPosition = 0.0;
}


abstract class ResamplingContext {
	int inputSampleRate;
	int outputSampleRate;

	int inputChannels;
	int outputChannels;

	SpeexResampler resamplerLeft;
	SpeexResampler resamplerRight;

	SpeexResampler.Data resamplerDataLeft;
	SpeexResampler.Data resamplerDataRight;

	float[][2] buffersIn;
	float[][2] buffersOut;

	uint rateNum;
	uint rateDem;

	float[][2] dataReady;

	SampleControlFlags scflags;

	this(SampleControlFlags scflags, int inputSampleRate, int outputSampleRate, int inputChannels, int outputChannels) {
		this.scflags = scflags;
		this.inputSampleRate = inputSampleRate;
		this.outputSampleRate = outputSampleRate;
		this.inputChannels = inputChannels;
		this.outputChannels = outputChannels;


		if(auto err = resamplerLeft.setup(1, inputSampleRate, outputSampleRate, 5))
			throw new Exception("ugh");
		resamplerRight.setup(1, inputSampleRate, outputSampleRate, 5);

		resamplerLeft.getRatio(rateNum, rateDem);

		int add = (rateNum % rateDem) ? 1 : 0;

		buffersIn[0] = new float[](BUFFER_SIZE_FRAMES * rateNum / rateDem + add);
		buffersOut[0] = new float[](BUFFER_SIZE_FRAMES);
		if(inputChannels > 1) {
			buffersIn[1] = new float[](BUFFER_SIZE_FRAMES * rateNum / rateDem + add);
			buffersOut[1] = new float[](BUFFER_SIZE_FRAMES);
		}
	}

	/+
		float*[2] tmp;
		tmp[0] = buffersIn[0].ptr;
		tmp[1] = buffersIn[1].ptr;
		auto actuallyGot = v.getSamplesFloat(v.chans, tmp.ptr, cast(int) buffersIn[0].length);
		resamplerDataLeft.dataIn should be a slice of buffersIn[0] that is filled up
		ditto for resamplerDataRight if the source has two channels
	+/
	abstract void loadMoreSamples();

	bool loadMore() {
		resamplerDataLeft.dataIn = buffersIn[0];
		resamplerDataLeft.dataOut = buffersOut[0];

		resamplerDataRight.dataIn = buffersIn[1];
		resamplerDataRight.dataOut = buffersOut[1];

		loadMoreSamples();

		//resamplerLeft.reset();

		if(auto err = resamplerLeft.process(resamplerDataLeft))
			throw new Exception("ugh");
		if(inputChannels > 1)
			//resamplerRight.reset();
			resamplerRight.process(resamplerDataRight);

		resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[0 .. resamplerDataLeft.outputSamplesUsed];
		resamplerDataRight.dataOut = resamplerDataRight.dataOut[0 .. resamplerDataRight.outputSamplesUsed];

		if(resamplerDataLeft.dataOut.length == 0) {
			return true;
		}
		return false;
	}


	bool fillBuffer(short[] buffer) {
		if(cast(int) buffer.length != buffer.length)
			throw new Exception("eeeek");

		if(scflags.paused) {
			buffer[] = 0;
			return true;
		}

		if(outputChannels == 1) {
			foreach(ref s; buffer) {
				if(resamplerDataLeft.dataOut.length == 0) {
					if(loadMore()) {
						scflags.finished_ = true;
						return false;
					}
				}

				if(inputChannels == 1) {
					s = cast(short) (resamplerDataLeft.dataOut[0] * short.max);
					resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
				} else {
					s = cast(short) ((resamplerDataLeft.dataOut[0] + resamplerDataRight.dataOut[0]) * short.max / 2);

					resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
					resamplerDataRight.dataOut = resamplerDataRight.dataOut[1 .. $];
				}
			}

			scflags.currentPosition += cast(float) buffer.length / outputSampleRate / outputChannels;
		} else if(outputChannels == 2) {
			foreach(idx, ref s; buffer) {
				if(resamplerDataLeft.dataOut.length == 0) {
					if(loadMore()) {
						scflags.finished_ = true;
						return false;
					}
				}

				if(inputChannels == 1) {
					s = cast(short) (resamplerDataLeft.dataOut[0] * short.max);
					if(idx & 1)
						resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
				} else {
					if(idx & 1) {
						s = cast(short) (resamplerDataRight.dataOut[0] * short.max);
						resamplerDataRight.dataOut = resamplerDataRight.dataOut[1 .. $];
					} else {
						s = cast(short) (resamplerDataLeft.dataOut[0] * short.max);
						resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
					}
				}
			}

			scflags.currentPosition += cast(float) buffer.length / outputSampleRate / outputChannels;
		} else assert(0);

		if(scflags.stopped)
			scflags.finished_ = true;
		return !scflags.stopped;
	}

    bool fillBuffer(float[] buffer) {
		if(cast(int) buffer.length != buffer.length)
			throw new Exception("eeeek");

		if(scflags.paused) {
			buffer[] = 0;
			return true;
		}

		if(outputChannels == 1) 
        {
			foreach(ref s; buffer) 
            {
				if(resamplerDataLeft.dataOut.length == 0) 
                {
					if(loadMore()) 
                    {
						scflags.finished_ = true;
						return false;
					}
				}

				if(inputChannels == 1) 
                {
					s = resamplerDataLeft.dataOut[0];
					resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
				} 
                else 
                {
					s = (resamplerDataLeft.dataOut[0] + resamplerDataRight.dataOut[0]) / 2;

					resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
					resamplerDataRight.dataOut = resamplerDataRight.dataOut[1 .. $];
				}
			}

			scflags.currentPosition += cast(float) buffer.length / outputSampleRate / outputChannels;
		}
        else if(outputChannels == 2) 
        {
			foreach(idx, ref s; buffer) 
            {
				if(resamplerDataLeft.dataOut.length == 0) 
                {
					if(loadMore()) 
                    {
						scflags.finished_ = true;
						return false;
					}
				}

				if(inputChannels == 1) 
                {
					s = resamplerDataLeft.dataOut[0];
					if(idx & 1)
						resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
                } 
                else 
                {
					if(idx & 1) 
                    {
						s = resamplerDataRight.dataOut[0];
						resamplerDataRight.dataOut = resamplerDataRight.dataOut[1 .. $];
					} 
                    else 
                    {
						s = resamplerDataLeft.dataOut[0];
						resamplerDataLeft.dataOut = resamplerDataLeft.dataOut[1 .. $];
					}
				}
			}

			scflags.currentPosition += cast(float) buffer.length / outputSampleRate / outputChannels;
		} else assert(0);

		if(scflags.stopped)
			scflags.finished_ = true;
		return !scflags.stopped;
	}
}