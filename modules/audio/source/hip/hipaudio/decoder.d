module hip.hipaudio.decoder;
import hip.data.audio.audio;
import core.time;

alias HipDecodingResult = ubyte[];

/**
*   Decodes audio in a background thread
*/
class HipAudioDecoder
{
    IHipAudioDecoder dec;
    bool hasFinishedDecoding;
    ubyte[][] managedBuffers;

    this(IHipAudioDecoder decoder)
    {
        dec = decoder;
    }

    void updateDecodingStatus()
    {
        // receiveTimeout(Duration.zero, 
        //     (uint decodeResult)
        //     {

        //     }
        // );
    }
}