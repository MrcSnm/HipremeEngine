
//          Copyright Michael D. Parker 2018 & Marcelo S. N. Mancini 2020.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.openal.presets;

/**
* Prsets came from OpenAL Soft repository
*/
struct ReverbProperties
{
    float density;
    float diffusion;
    float gain;
    float gainHF;
    float gainLF;
    float decayTime;
    float decayHFRatio;
    float decayLFRatio;
    float reflectionsGain;
    float reflectionsDelay;
    float[3] reflectionsPan;
    float lateReverbGain;
    float lateReverbDelay;
    float[3] lateReverbPan;
    float echoTime;
    float echoDepth;
    float modulationTime;
    float modulationDepth;
    float airAbsorptionGainHF;
    float HFReference;
    float LFReference;
    float roomRolloffFactor;
    int   decayHFLimit;

    static ReverbProperties GENERIC()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.8913f, 1.0000f, 1.4900f, 0.8300f, 1.0000f, 0.0500f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
         1.2589f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );
    }

    static ReverbProperties PADDED_CELL()
    {
        return ReverbProperties(0.1715f, 1.0000f, 0.3162f, 0.0010f, 1.0000f, 0.1700f, 0.1000f, 1.0000f, 0.2500f, 0.0010f, [0.0000f, 0.0000f, 0.0000f],
        1.2691f, 0.0020f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ROOM()
    {
        return ReverbProperties(0.4287f, 1.0000f, 0.3162f, 0.5929f, 1.0000f, 0.4000f, 0.8300f, 1.0000f, 0.1503f, 0.0020f, [0.0000f, 0.0000f, 0.0000f],
        1.0629f, 0.0030f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties BATHROOM()
    {
        return ReverbProperties(0.1715f, 1.0000f, 0.3162f, 0.2512f, 1.0000f, 1.4900f, 0.5400f, 1.0000f, 0.6531f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        3.2734f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties LIVING_ROOM()
    {
        return ReverbProperties(0.9766f, 1.0000f, 0.3162f, 0.0010f, 1.0000f, 0.5000f, 0.1000f, 1.0000f, 0.2051f, 0.0030f, [0.0000f, 0.0000f, 0.0000f],
        0.2805f, 0.0040f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties STONE_ROOM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.7079f, 1.0000f, 2.3100f, 0.6400f, 1.0000f, 0.4411f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.1003f, 0.0170f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties AUDITORIUM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.5781f, 1.0000f, 4.3200f, 0.5900f, 1.0000f, 0.4032f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        0.7170f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CONCERT_HALL()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.5623f, 1.0000f, 3.9200f, 0.7000f, 1.0000f, 0.2427f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        0.9977f, 0.0290f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CAVE()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 1.0000f, 1.0000f, 2.9100f, 1.3000f, 1.0000f, 0.5000f, 0.0150f, [0.0000f, 0.0000f, 0.0000f],
        0.7063f, 0.0220f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );
    }

    static ReverbProperties ARENA()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.4477f, 1.0000f, 7.2400f, 0.3300f, 1.0000f, 0.2612f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        1.0186f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties HANGAR()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.3162f, 1.0000f, 10.0500f, 0.2300f, 1.0000f, 0.5000f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        1.2560f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CARPETEDHALLWAY()
    {
        return ReverbProperties(0.4287f, 1.0000f, 0.3162f, 0.0100f, 1.0000f, 0.3000f, 0.1000f, 1.0000f, 0.1215f, 0.0020f, [0.0000f, 0.0000f, 0.0000f],
        0.1531f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties HALLWAY()
    {
        return ReverbProperties(0.3645f, 1.0000f, 0.3162f, 0.7079f, 1.0000f, 1.4900f, 0.5900f, 1.0000f, 0.2458f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.6615f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties STONECORRIDOR()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.7612f, 1.0000f, 2.7000f, 0.7900f, 1.0000f, 0.2472f, 0.0130f, [0.0000f, 0.0000f, 0.0000f],
        1.5758f, 0.0200f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ALLEY()
    {
        return ReverbProperties(1.0000f, 0.3000f, 0.3162f, 0.7328f, 1.0000f, 1.4900f, 0.8600f, 1.0000f, 0.2500f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        0.9954f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.1250f, 0.9500f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FOREST()
    {
        return ReverbProperties(1.0000f, 0.3000f, 0.3162f, 0.0224f, 1.0000f, 1.4900f, 0.5400f, 1.0000f, 0.0525f, 0.1620f, [0.0000f, 0.0000f, 0.0000f],
        0.7682f, 0.0880f, [0.0000f, 0.0000f, 0.0000f], 0.1250f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CITY()
    {
        return ReverbProperties(1.0000f, 0.5000f, 0.3162f, 0.3981f, 1.0000f, 1.4900f, 0.6700f, 1.0000f, 0.0730f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        0.1427f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties MOUNTAINS()
    {
        return ReverbProperties(1.0000f, 0.2700f, 0.3162f, 0.0562f, 1.0000f, 1.4900f, 0.2100f, 1.0000f, 0.0407f, 0.3000f, [0.0000f, 0.0000f, 0.0000f],
        0.1919f, 0.1000f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties QUARRY()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.3162f, 1.0000f, 1.4900f, 0.8300f, 1.0000f, 0.0000f, 0.0610f, [0.0000f, 0.0000f, 0.0000f],
        1.7783f, 0.0250f, [0.0000f, 0.0000f, 0.0000f], 0.1250f, 0.7000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties PLAIN()
    {
        return ReverbProperties(1.0000f, 0.2100f, 0.3162f, 0.1000f, 1.0000f, 1.4900f, 0.5000f, 1.0000f, 0.0585f, 0.1790f, [0.0000f, 0.0000f, 0.0000f],
        0.1089f, 0.1000f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties PARKINGLOT()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 1.0000f, 1.0000f, 1.6500f, 1.5000f, 1.0000f, 0.2082f, 0.0080f, [0.0000f, 0.0000f, 0.0000f],
        0.2652f, 0.0120f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties SEWERPIPE()
    {
        return ReverbProperties(0.3071f, 0.8000f, 0.3162f, 0.3162f, 1.0000f, 2.8100f, 0.1400f, 1.0000f, 1.6387f, 0.0140f, [0.0000f, 0.0000f, 0.0000f],
        3.2471f, 0.0210f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties UNDERWATER()
    {
        return ReverbProperties(0.3645f, 1.0000f, 0.3162f, 0.0100f, 1.0000f, 1.4900f, 0.1000f, 1.0000f, 0.5963f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        7.0795f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 1.1800f, 0.3480f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties DRUGGED()
    {
        return ReverbProperties(0.4287f, 0.5000f, 0.3162f, 1.0000f, 1.0000f, 8.3900f, 1.3900f, 1.0000f, 0.8760f, 0.0020f, [0.0000f, 0.0000f, 0.0000f],
        3.1081f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 1.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties DIZZY()
    {
        return ReverbProperties(0.3645f, 0.6000f, 0.3162f, 0.6310f, 1.0000f, 17.2300f, 0.5600f, 1.0000f, 0.1392f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        0.4937f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 1.0000f, 0.8100f, 0.3100f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties PSYCHOTIC()
    {
        return ReverbProperties(0.0625f, 0.5000f, 0.3162f, 0.8404f, 1.0000f, 7.5600f, 0.9100f, 1.0000f, 0.4864f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        2.4378f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 4.0000f, 1.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

/* Castle Presets */

    static ReverbProperties CASTLE_SMALLROOM()
    {
        return ReverbProperties(1.0000f, 0.8900f, 0.3162f, 0.3981f, 0.1000f, 1.2200f, 0.8300f, 0.3100f, 0.8913f, 0.0220f, [0.0000f, 0.0000f, 0.0000f],
        1.9953f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.1380f, 0.0800f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_SHORTPASSAGE()
    {
        return ReverbProperties(1.0000f, 0.8900f, 0.3162f, 0.3162f, 0.1000f, 2.3200f, 0.8300f, 0.3100f, 0.8913f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0230f, [0.0000f, 0.0000f, 0.0000f], 0.1380f, 0.0800f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_MEDIUMROOM()
    {
        return ReverbProperties(1.0000f, 0.9300f, 0.3162f, 0.2818f, 0.1000f, 2.0400f, 0.8300f, 0.4600f, 0.6310f, 0.0220f, [0.0000f, 0.0000f, 0.0000f],
        1.5849f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.1550f, 0.0300f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_LARGEROOM()
    {
        return ReverbProperties(1.0000f, 0.8200f, 0.3162f, 0.2818f, 0.1259f, 2.5300f, 0.8300f, 0.5000f, 0.4467f, 0.0340f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0160f, [0.0000f, 0.0000f, 0.0000f], 0.1850f, 0.0700f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_LONGPASSAGE()
    {
        return ReverbProperties(1.0000f, 0.8900f, 0.3162f, 0.3981f, 0.1000f, 3.4200f, 0.8300f, 0.3100f, 0.8913f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0230f, [0.0000f, 0.0000f, 0.0000f], 0.1380f, 0.0800f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_HALL()
    {
        return ReverbProperties(1.0000f, 0.8100f, 0.3162f, 0.2818f, 0.1778f, 3.1400f, 0.7900f, 0.6200f, 0.1778f, 0.0560f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0240f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_CUPBOARD()
    {
        return ReverbProperties(1.0000f, 0.8900f, 0.3162f, 0.2818f, 0.1000f, 0.6700f, 0.8700f, 0.3100f, 1.4125f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        3.5481f, 0.0070f, [0.0000f, 0.0000f, 0.0000f], 0.1380f, 0.0800f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CASTLE_COURTYARD()
    {
        return ReverbProperties(1.0000f, 0.4200f, 0.3162f, 0.4467f, 0.1995f, 2.1300f, 0.6100f, 0.2300f, 0.2239f, 0.1600f, [0.0000f, 0.0000f, 0.0000f],
        0.7079f, 0.0360f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.3700f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties CASTLE_ALCOVE()
    {
        return ReverbProperties(1.0000f, 0.8900f, 0.3162f, 0.5012f, 0.1000f, 1.6400f, 0.8700f, 0.3100f, 1.0000f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0340f, [0.0000f, 0.0000f, 0.0000f], 0.1380f, 0.0800f, 0.2500f, 0.0000f, 0.9943f, 5168.6001f, 139.5000f, 0.0000f, 0x1 );

    }

/* Factory Presets */

    static ReverbProperties FACTORY_SMALLROOM()
    {
        return ReverbProperties(0.3645f, 0.8200f, 0.3162f, 0.7943f, 0.5012f, 1.7200f, 0.6500f, 1.3100f, 0.7079f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.7783f, 0.0240f, [0.0000f, 0.0000f, 0.0000f], 0.1190f, 0.0700f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_SHORTPASSAGE()
    {
        return ReverbProperties(0.3645f, 0.6400f, 0.2512f, 0.7943f, 0.5012f, 2.5300f, 0.6500f, 1.3100f, 1.0000f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0380f, [0.0000f, 0.0000f, 0.0000f], 0.1350f, 0.2300f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_MEDIUMROOM()
    {
        return ReverbProperties(0.4287f, 0.8200f, 0.2512f, 0.7943f, 0.5012f, 2.7600f, 0.6500f, 1.3100f, 0.2818f, 0.0220f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0230f, [0.0000f, 0.0000f, 0.0000f], 0.1740f, 0.0700f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_LARGEROOM()
    {
        return ReverbProperties(0.4287f, 0.7500f, 0.2512f, 0.7079f, 0.6310f, 4.2400f, 0.5100f, 1.3100f, 0.1778f, 0.0390f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0230f, [0.0000f, 0.0000f, 0.0000f], 0.2310f, 0.0700f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_LONGPASSAGE()
    {
        return ReverbProperties(0.3645f, 0.6400f, 0.2512f, 0.7943f, 0.5012f, 4.0600f, 0.6500f, 1.3100f, 1.0000f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0370f, [0.0000f, 0.0000f, 0.0000f], 0.1350f, 0.2300f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_HALL()
    {
        return ReverbProperties(0.4287f, 0.7500f, 0.3162f, 0.7079f, 0.6310f, 7.4300f, 0.5100f, 1.3100f, 0.0631f, 0.0730f, [0.0000f, 0.0000f, 0.0000f],
        0.8913f, 0.0270f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0700f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_CUPBOARD()
    {
        return ReverbProperties(0.3071f, 0.6300f, 0.2512f, 0.7943f, 0.5012f, 0.4900f, 0.6500f, 1.3100f, 1.2589f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.9953f, 0.0320f, [0.0000f, 0.0000f, 0.0000f], 0.1070f, 0.0700f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_COURTYARD()
    {
        return ReverbProperties(0.3071f, 0.5700f, 0.3162f, 0.3162f, 0.6310f, 2.3200f, 0.2900f, 0.5600f, 0.2239f, 0.1400f, [0.0000f, 0.0000f, 0.0000f],
        0.3981f, 0.0390f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.2900f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

    static ReverbProperties FACTORY_ALCOVE()
    {
        return ReverbProperties(0.3645f, 0.5900f, 0.2512f, 0.7943f, 0.5012f, 3.1400f, 0.6500f, 1.3100f, 1.4125f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.0000f, 0.0380f, [0.0000f, 0.0000f, 0.0000f], 0.1140f, 0.1000f, 0.2500f, 0.0000f, 0.9943f, 3762.6001f, 362.5000f, 0.0000f, 0x1 );

    }

/* Ice Palace Presets */

    static ReverbProperties ICEPALACE_SMALLROOM()
    {
        return ReverbProperties(1.0000f, 0.8400f, 0.3162f, 0.5623f, 0.2818f, 1.5100f, 1.5300f, 0.2700f, 0.8913f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.1640f, 0.1400f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_SHORTPASSAGE()
    {
        return ReverbProperties(1.0000f, 0.7500f, 0.3162f, 0.5623f, 0.2818f, 1.7900f, 1.4600f, 0.2800f, 0.5012f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0190f, [0.0000f, 0.0000f, 0.0000f], 0.1770f, 0.0900f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_MEDIUMROOM()
    {
        return ReverbProperties(1.0000f, 0.8700f, 0.3162f, 0.5623f, 0.4467f, 2.2200f, 1.5300f, 0.3200f, 0.3981f, 0.0390f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0270f, [0.0000f, 0.0000f, 0.0000f], 0.1860f, 0.1200f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_LARGEROOM()
    {
        return ReverbProperties(1.0000f, 0.8100f, 0.3162f, 0.5623f, 0.4467f, 3.1400f, 1.5300f, 0.3200f, 0.2512f, 0.0390f, [0.0000f, 0.0000f, 0.0000f],
        1.0000f, 0.0270f, [0.0000f, 0.0000f, 0.0000f], 0.2140f, 0.1100f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_LONGPASSAGE()
    {
        return ReverbProperties(1.0000f, 0.7700f, 0.3162f, 0.5623f, 0.3981f, 3.0100f, 1.4600f, 0.2800f, 0.7943f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0250f, [0.0000f, 0.0000f, 0.0000f], 0.1860f, 0.0400f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_HALL()
    {
        return ReverbProperties(1.0000f, 0.7600f, 0.3162f, 0.4467f, 0.5623f, 5.4900f, 1.5300f, 0.3800f, 0.1122f, 0.0540f, [0.0000f, 0.0000f, 0.0000f],
        0.6310f, 0.0520f, [0.0000f, 0.0000f, 0.0000f], 0.2260f, 0.1100f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_CUPBOARD()
    {
        return ReverbProperties(1.0000f, 0.8300f, 0.3162f, 0.5012f, 0.2239f, 0.7600f, 1.5300f, 0.2600f, 1.1220f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.9953f, 0.0160f, [0.0000f, 0.0000f, 0.0000f], 0.1430f, 0.0800f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_COURTYARD()
    {
        return ReverbProperties(1.0000f, 0.5900f, 0.3162f, 0.2818f, 0.3162f, 2.0400f, 1.2000f, 0.3800f, 0.3162f, 0.1730f, [0.0000f, 0.0000f, 0.0000f],
        0.3162f, 0.0430f, [0.0000f, 0.0000f, 0.0000f], 0.2350f, 0.4800f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties ICEPALACE_ALCOVE()
    {
        return ReverbProperties(1.0000f, 0.8400f, 0.3162f, 0.5623f, 0.2818f, 2.7600f, 1.4600f, 0.2800f, 1.1220f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        0.8913f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.1610f, 0.0900f, 0.2500f, 0.0000f, 0.9943f, 12428.5000f, 99.6000f, 0.0000f, 0x1 );

    }

/* Space Station Presets */

    static ReverbProperties SPACESTATION_SMALLROOM()
    {
        return ReverbProperties(0.2109f, 0.7000f, 0.3162f, 0.7079f, 0.8913f, 1.7200f, 0.8200f, 0.5500f, 0.7943f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0130f, [0.0000f, 0.0000f, 0.0000f], 0.1880f, 0.2600f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_SHORTPASSAGE()
    {
        return ReverbProperties(0.2109f, 0.8700f, 0.3162f, 0.6310f, 0.8913f, 3.5700f, 0.5000f, 0.5500f, 1.0000f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0160f, [0.0000f, 0.0000f, 0.0000f], 0.1720f, 0.2000f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_MEDIUMROOM()
    {
        return ReverbProperties(0.2109f, 0.7500f, 0.3162f, 0.6310f, 0.8913f, 3.0100f, 0.5000f, 0.5500f, 0.3981f, 0.0340f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0350f, [0.0000f, 0.0000f, 0.0000f], 0.2090f, 0.3100f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_LARGEROOM()
    {
        return ReverbProperties(0.3645f, 0.8100f, 0.3162f, 0.6310f, 0.8913f, 3.8900f, 0.3800f, 0.6100f, 0.3162f, 0.0560f, [0.0000f, 0.0000f, 0.0000f],
        0.8913f, 0.0350f, [0.0000f, 0.0000f, 0.0000f], 0.2330f, 0.2800f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_LONGPASSAGE()
    {
        return ReverbProperties(0.4287f, 0.8200f, 0.3162f, 0.6310f, 0.8913f, 4.6200f, 0.6200f, 0.5500f, 1.0000f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0310f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.2300f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_HALL()
    {
        return ReverbProperties(0.4287f, 0.8700f, 0.3162f, 0.6310f, 0.8913f, 7.1100f, 0.3800f, 0.6100f, 0.1778f, 0.1000f, [0.0000f, 0.0000f, 0.0000f],
        0.6310f, 0.0470f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.2500f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_CUPBOARD()
    {
        return ReverbProperties(0.1715f, 0.5600f, 0.3162f, 0.7079f, 0.8913f, 0.7900f, 0.8100f, 0.5500f, 1.4125f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.7783f, 0.0180f, [0.0000f, 0.0000f, 0.0000f], 0.1810f, 0.3100f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPACESTATION_ALCOVE()
    {
        return ReverbProperties(0.2109f, 0.7800f, 0.3162f, 0.7079f, 0.8913f, 1.1600f, 0.8100f, 0.5500f, 1.4125f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        1.0000f, 0.0180f, [0.0000f, 0.0000f, 0.0000f], 0.1920f, 0.2100f, 0.2500f, 0.0000f, 0.9943f, 3316.1001f, 458.2000f, 0.0000f, 0x1 );

    }

/* Wooden Galleon Presets */

    static ReverbProperties WOODEN_SMALLROOM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.1122f, 0.3162f, 0.7900f, 0.3200f, 0.8700f, 1.0000f, 0.0320f, [0.0000f, 0.0000f, 0.0000f],
        0.8913f, 0.0290f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_SHORTPASSAGE()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.1259f, 0.3162f, 1.7500f, 0.5000f, 0.8700f, 0.8913f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        0.6310f, 0.0240f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_MEDIUMROOM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.1000f, 0.2818f, 1.4700f, 0.4200f, 0.8200f, 0.8913f, 0.0490f, [0.0000f, 0.0000f, 0.0000f],
        0.8913f, 0.0290f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_LARGEROOM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.0891f, 0.2818f, 2.6500f, 0.3300f, 0.8200f, 0.8913f, 0.0660f, [0.0000f, 0.0000f, 0.0000f],
        0.7943f, 0.0490f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_LONGPASSAGE()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.1000f, 0.3162f, 1.9900f, 0.4000f, 0.7900f, 1.0000f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        0.4467f, 0.0360f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_HALL()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.0794f, 0.2818f, 3.4500f, 0.3000f, 0.8200f, 0.8913f, 0.0880f, [0.0000f, 0.0000f, 0.0000f],
        0.7943f, 0.0630f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_CUPBOARD()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.1413f, 0.3162f, 0.5600f, 0.4600f, 0.9100f, 1.1220f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0280f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_COURTYARD()
    {
        return ReverbProperties(1.0000f, 0.6500f, 0.3162f, 0.0794f, 0.3162f, 1.7900f, 0.3500f, 0.7900f, 0.5623f, 0.1230f, [0.0000f, 0.0000f, 0.0000f],
        0.1000f, 0.0320f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

    static ReverbProperties WOODEN_ALCOVE()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.1259f, 0.3162f, 1.2200f, 0.6200f, 0.9100f, 1.1220f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        0.7079f, 0.0240f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 4705.0000f, 99.6000f, 0.0000f, 0x1 );

    }

/* Sports Presets */

    static ReverbProperties SPORT_EMPTYSTADIUM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.4467f, 0.7943f, 6.2600f, 0.5100f, 1.1000f, 0.0631f, 0.1830f, [0.0000f, 0.0000f, 0.0000f],
        0.3981f, 0.0380f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPORT_SQUASHCOURT()
    {
        return ReverbProperties(1.0000f, 0.7500f, 0.3162f, 0.3162f, 0.7943f, 2.2200f, 0.9100f, 1.1600f, 0.4467f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        0.7943f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.1260f, 0.1900f, 0.2500f, 0.0000f, 0.9943f, 7176.8999f, 211.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPORT_SMALLSWIMMINGPOOL()
    {
        return ReverbProperties(1.0000f, 0.7000f, 0.3162f, 0.7943f, 0.8913f, 2.7600f, 1.2500f, 1.1400f, 0.6310f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        0.7943f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.1790f, 0.1500f, 0.8950f, 0.1900f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties SPORT_LARGESWIMMINGPOOL()
    {
        return ReverbProperties(1.0000f, 0.8200f, 0.3162f, 0.7943f, 1.0000f, 5.4900f, 1.3100f, 1.1400f, 0.4467f, 0.0390f, [0.0000f, 0.0000f, 0.0000f],
        0.5012f, 0.0490f, [0.0000f, 0.0000f, 0.0000f], 0.2220f, 0.5500f, 1.1590f, 0.2100f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties SPORT_GYMNASIUM()
    {
        return ReverbProperties(1.0000f, 0.8100f, 0.3162f, 0.4467f, 0.8913f, 3.1400f, 1.0600f, 1.3500f, 0.3981f, 0.0290f, [0.0000f, 0.0000f, 0.0000f],
        0.5623f, 0.0450f, [0.0000f, 0.0000f, 0.0000f], 0.1460f, 0.1400f, 0.2500f, 0.0000f, 0.9943f, 7176.8999f, 211.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPORT_FULLSTADIUM()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.0708f, 0.7943f, 5.2500f, 0.1700f, 0.8000f, 0.1000f, 0.1880f, [0.0000f, 0.0000f, 0.0000f],
        0.2818f, 0.0380f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SPORT_STADIUMTANNOY()
    {
        return ReverbProperties(1.0000f, 0.7800f, 0.3162f, 0.5623f, 0.5012f, 2.5300f, 0.8800f, 0.6800f, 0.2818f, 0.2300f, [0.0000f, 0.0000f, 0.0000f],
        0.5012f, 0.0630f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.2000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

/* Prefab Presets */

    static ReverbProperties PREFAB_WORKSHOP()
    {
        return ReverbProperties(0.4287f, 1.0000f, 0.3162f, 0.1413f, 0.3981f, 0.7600f, 1.0000f, 1.0000f, 1.0000f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0120f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties PREFAB_SCHOOLROOM()
    {
        return ReverbProperties(0.4022f, 0.6900f, 0.3162f, 0.6310f, 0.5012f, 0.9800f, 0.4500f, 0.1800f, 1.4125f, 0.0170f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0150f, [0.0000f, 0.0000f, 0.0000f], 0.0950f, 0.1400f, 0.2500f, 0.0000f, 0.9943f, 7176.8999f, 211.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties PREFAB_PRACTISEROOM()
    {
        return ReverbProperties(0.4022f, 0.8700f, 0.3162f, 0.3981f, 0.5012f, 1.1200f, 0.5600f, 0.1800f, 1.2589f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0110f, [0.0000f, 0.0000f, 0.0000f], 0.0950f, 0.1400f, 0.2500f, 0.0000f, 0.9943f, 7176.8999f, 211.2000f, 0.0000f, 0x1 );

    }

    static ReverbProperties PREFAB_OUTHOUSE()
    {
        return ReverbProperties(1.0000f, 0.8200f, 0.3162f, 0.1122f, 0.1585f, 1.3800f, 0.3800f, 0.3500f, 0.8913f, 0.0240f, [0.0000f, 0.0000f, -0.0000f],
        0.6310f, 0.0440f, [0.0000f, 0.0000f, 0.0000f], 0.1210f, 0.1700f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 107.5000f, 0.0000f, 0x0 );

    }

    static ReverbProperties PREFAB_CARAVAN()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.0891f, 0.1259f, 0.4300f, 1.5000f, 1.0000f, 1.0000f, 0.0120f, [0.0000f, 0.0000f, 0.0000f],
        1.9953f, 0.0120f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

/* Dome and Pipe Presets */

    static ReverbProperties DOME_TOMB()
    {
        return ReverbProperties(1.0000f, 0.7900f, 0.3162f, 0.3548f, 0.2239f, 4.1800f, 0.2100f, 0.1000f, 0.3868f, 0.0300f, [0.0000f, 0.0000f, 0.0000f],
        1.6788f, 0.0220f, [0.0000f, 0.0000f, 0.0000f], 0.1770f, 0.1900f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 20.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties PIPE_SMALL()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.3548f, 0.2239f, 5.0400f, 0.1000f, 0.1000f, 0.5012f, 0.0320f, [0.0000f, 0.0000f, 0.0000f],
        2.5119f, 0.0150f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 20.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties DOME_SAINTPAULS()
    {
        return ReverbProperties(1.0000f, 0.8700f, 0.3162f, 0.3548f, 0.2239f, 10.4800f, 0.1900f, 0.1000f, 0.1778f, 0.0900f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0420f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.1200f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 20.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties PIPE_LONGTHIN()
    {
        return ReverbProperties(0.2560f, 0.9100f, 0.3162f, 0.4467f, 0.2818f, 9.2100f, 0.1800f, 0.1000f, 0.7079f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        0.7079f, 0.0220f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 20.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties PIPE_LARGE()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.3548f, 0.2239f, 8.4500f, 0.1000f, 0.1000f, 0.3981f, 0.0460f, [0.0000f, 0.0000f, 0.0000f],
        1.5849f, 0.0320f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 20.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties PIPE_RESONANT()
    {
        return ReverbProperties(0.1373f, 0.9100f, 0.3162f, 0.4467f, 0.2818f, 6.8100f, 0.1800f, 0.1000f, 0.7079f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.0000f, 0.0220f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 20.0000f, 0.0000f, 0x0 );

    }

/* Outdoors Presets */

    static ReverbProperties OUTDOORS_BACKYARD()
    {
        return ReverbProperties(1.0000f, 0.4500f, 0.3162f, 0.2512f, 0.5012f, 1.1200f, 0.3400f, 0.4600f, 0.4467f, 0.0690f, [0.0000f, 0.0000f, -0.0000f],
        0.7079f, 0.0230f, [0.0000f, 0.0000f, 0.0000f], 0.2180f, 0.3400f, 0.2500f, 0.0000f, 0.9943f, 4399.1001f, 242.9000f, 0.0000f, 0x0 );

    }

    static ReverbProperties OUTDOORS_ROLLINGPLAINS()
    {
        return ReverbProperties(1.0000f, 0.0000f, 0.3162f, 0.0112f, 0.6310f, 2.1300f, 0.2100f, 0.4600f, 0.1778f, 0.3000f, [0.0000f, 0.0000f, -0.0000f],
        0.4467f, 0.0190f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 4399.1001f, 242.9000f, 0.0000f, 0x0 );

    }

    static ReverbProperties OUTDOORS_DEEPCANYON()
    {
        return ReverbProperties(1.0000f, 0.7400f, 0.3162f, 0.1778f, 0.6310f, 3.8900f, 0.2100f, 0.4600f, 0.3162f, 0.2230f, [0.0000f, 0.0000f, -0.0000f],
        0.3548f, 0.0190f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 4399.1001f, 242.9000f, 0.0000f, 0x0 );

    }

    static ReverbProperties OUTDOORS_CREEK()
    {
        return ReverbProperties(1.0000f, 0.3500f, 0.3162f, 0.1778f, 0.5012f, 2.1300f, 0.2100f, 0.4600f, 0.3981f, 0.1150f, [0.0000f, 0.0000f, -0.0000f],
        0.1995f, 0.0310f, [0.0000f, 0.0000f, 0.0000f], 0.2180f, 0.3400f, 0.2500f, 0.0000f, 0.9943f, 4399.1001f, 242.9000f, 0.0000f, 0x0 );

    }

    static ReverbProperties OUTDOORS_VALLEY()
    {
        return ReverbProperties(1.0000f, 0.2800f, 0.3162f, 0.0282f, 0.1585f, 2.8800f, 0.2600f, 0.3500f, 0.1413f, 0.2630f, [0.0000f, 0.0000f, -0.0000f],
        0.3981f, 0.1000f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.3400f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 107.5000f, 0.0000f, 0x0 );

    }

/* Mood Presets */

    static ReverbProperties MOOD_HEAVEN()
    {
        return ReverbProperties(1.0000f, 0.9400f, 0.3162f, 0.7943f, 0.4467f, 5.0400f, 1.1200f, 0.5600f, 0.2427f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0290f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0800f, 2.7420f, 0.0500f, 0.9977f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties MOOD_HELL()
    {
        return ReverbProperties(1.0000f, 0.5700f, 0.3162f, 0.3548f, 0.4467f, 3.5700f, 0.4900f, 2.0000f, 0.0000f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.1100f, 0.0400f, 2.1090f, 0.5200f, 0.9943f, 5000.0000f, 139.5000f, 0.0000f, 0x0 );

    }

    static ReverbProperties MOOD_MEMORY()
    {
        return ReverbProperties(1.0000f, 0.8500f, 0.3162f, 0.6310f, 0.3548f, 4.0600f, 0.8200f, 0.5600f, 0.0398f, 0.0000f, [0.0000f, 0.0000f, 0.0000f],
        1.1220f, 0.0000f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.4740f, 0.4500f, 0.9886f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

/* Driving Presets */

    static ReverbProperties DRIVING_COMMENTATOR()
    {
        return ReverbProperties(1.0000f, 0.0000f, 0.3162f, 0.5623f, 0.5012f, 2.4200f, 0.8800f, 0.6800f, 0.1995f, 0.0930f, [0.0000f, 0.0000f, 0.0000f],
        0.2512f, 0.0170f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9886f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties DRIVING_PITGARAGE()
    {
        return ReverbProperties(0.4287f, 0.5900f, 0.3162f, 0.7079f, 0.5623f, 1.7200f, 0.9300f, 0.8700f, 0.5623f, 0.0000f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0160f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.1100f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties DRIVING_INCAR_RACER()
    {
        return ReverbProperties(0.0832f, 0.8000f, 0.3162f, 1.0000f, 0.7943f, 0.1700f, 2.0000f, 0.4100f, 1.7783f, 0.0070f, [0.0000f, 0.0000f, 0.0000f],
        0.7079f, 0.0150f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 10268.2002f, 251.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties DRIVING_INCAR_SPORTS()
    {
        return ReverbProperties(0.0832f, 0.8000f, 0.3162f, 0.6310f, 1.0000f, 0.1700f, 0.7500f, 0.4100f, 1.0000f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        0.5623f, 0.0000f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 10268.2002f, 251.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties DRIVING_INCAR_LUXURY()
    {
        return ReverbProperties(0.2560f, 1.0000f, 0.3162f, 0.1000f, 0.5012f, 0.1300f, 0.4100f, 0.4600f, 0.7943f, 0.0100f, [0.0000f, 0.0000f, 0.0000f],
        1.5849f, 0.0100f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 10268.2002f, 251.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties DRIVING_FULLGRANDSTAND()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 0.2818f, 0.6310f, 3.0100f, 1.3700f, 1.2800f, 0.3548f, 0.0900f, [0.0000f, 0.0000f, 0.0000f],
        0.1778f, 0.0490f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 10420.2002f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties DRIVING_EMPTYGRANDSTAND()
    {
        return ReverbProperties(1.0000f, 1.0000f, 0.3162f, 1.0000f, 0.7943f, 4.6200f, 1.7500f, 1.4000f, 0.2082f, 0.0900f, [0.0000f, 0.0000f, 0.0000f],
        0.2512f, 0.0490f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 10420.2002f, 250.0000f, 0.0000f, 0x0 );

    }

    static ReverbProperties DRIVING_TUNNEL()
    {
        return ReverbProperties(1.0000f, 0.8100f, 0.3162f, 0.3981f, 0.8913f, 3.4200f, 0.9400f, 1.3100f, 0.7079f, 0.0510f, [0.0000f, 0.0000f, 0.0000f],
        0.7079f, 0.0470f, [0.0000f, 0.0000f, 0.0000f], 0.2140f, 0.0500f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 155.3000f, 0.0000f, 0x1 );

    }

/* City Presets */

    static ReverbProperties CITY_STREETS()
    {
        return ReverbProperties(1.0000f, 0.7800f, 0.3162f, 0.7079f, 0.8913f, 1.7900f, 1.1200f, 0.9100f, 0.2818f, 0.0460f, [0.0000f, 0.0000f, 0.0000f],
        0.1995f, 0.0280f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.2000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CITY_SUBWAY()
    {
        return ReverbProperties(1.0000f, 0.7400f, 0.3162f, 0.7079f, 0.8913f, 3.0100f, 1.2300f, 0.9100f, 0.7079f, 0.0460f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0280f, [0.0000f, 0.0000f, 0.0000f], 0.1250f, 0.2100f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CITY_MUSEUM()
    {
        return ReverbProperties(1.0000f, 0.8200f, 0.3162f, 0.1778f, 0.1778f, 3.2800f, 1.4000f, 0.5700f, 0.2512f, 0.0390f, [0.0000f, 0.0000f, -0.0000f],
        0.8913f, 0.0340f, [0.0000f, 0.0000f, 0.0000f], 0.1300f, 0.1700f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 107.5000f, 0.0000f, 0x0 );

    }

    static ReverbProperties CITY_LIBRARY()
    {
        return ReverbProperties(1.0000f, 0.8200f, 0.3162f, 0.2818f, 0.0891f, 2.7600f, 0.8900f, 0.4100f, 0.3548f, 0.0290f, [0.0000f, 0.0000f, -0.0000f],
        0.8913f, 0.0200f, [0.0000f, 0.0000f, 0.0000f], 0.1300f, 0.1700f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 107.5000f, 0.0000f, 0x0 );

    }

    static ReverbProperties CITY_UNDERPASS()
    {
        return ReverbProperties(1.0000f, 0.8200f, 0.3162f, 0.4467f, 0.8913f, 3.5700f, 1.1200f, 0.9100f, 0.3981f, 0.0590f, [0.0000f, 0.0000f, 0.0000f],
        0.8913f, 0.0370f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.1400f, 0.2500f, 0.0000f, 0.9920f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CITY_ABANDONED()
    {
        return ReverbProperties(1.0000f, 0.6900f, 0.3162f, 0.7943f, 0.8913f, 3.2800f, 1.1700f, 0.9100f, 0.4467f, 0.0440f, [0.0000f, 0.0000f, 0.0000f],
        0.2818f, 0.0240f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.2000f, 0.2500f, 0.0000f, 0.9966f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

/* Misc. Presets */

    static ReverbProperties DUSTYROOM()
    {
        return ReverbProperties(0.3645f, 0.5600f, 0.3162f, 0.7943f, 0.7079f, 1.7900f, 0.3800f, 0.2100f, 0.5012f, 0.0020f, [0.0000f, 0.0000f, 0.0000f],
        1.2589f, 0.0060f, [0.0000f, 0.0000f, 0.0000f], 0.2020f, 0.0500f, 0.2500f, 0.0000f, 0.9886f, 13046.0000f, 163.3000f, 0.0000f, 0x1 );

    }

    static ReverbProperties CHAPEL()
    {
        return ReverbProperties(1.0000f, 0.8400f, 0.3162f, 0.5623f, 1.0000f, 4.6200f, 0.6400f, 1.2300f, 0.4467f, 0.0320f, [0.0000f, 0.0000f, 0.0000f],
        0.7943f, 0.0490f, [0.0000f, 0.0000f, 0.0000f], 0.2500f, 0.0000f, 0.2500f, 0.1100f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 );

    }

    static ReverbProperties SMALLWATERROOM()
    {
        return ReverbProperties(1.0000f, 0.7000f, 0.3162f, 0.4477f, 1.0000f, 1.5100f, 1.2500f, 1.1400f, 0.8913f, 0.0200f, [0.0000f, 0.0000f, 0.0000f],
        1.4125f, 0.0300f, [0.0000f, 0.0000f, 0.0000f], 0.1790f, 0.1500f, 0.8950f, 0.1900f, 0.9920f, 5000.0000f, 250.0000f, 0.0000f, 0x0 );

    }
}