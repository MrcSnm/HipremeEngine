// D import file generated from 'source\hipaudio\backend\openal\alefx.d'
module hipaudio.backend.alefx;
import bindbc.openal;
import error.handler;
static bool usingEAXReverb = false;
ALuint loadReverb(ref ReverbProperties r);
