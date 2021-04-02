module directx.wincodec;

version(Windows):

public import directx.dxgiformat, directx.dxgitype;
public import directx.dcommon, directx.com;

import directx.d2d1 : ID2D1Image;
import directx.d2d1_1 : ID2D1Device;
import core.sys.windows.wtypes;
import core.sys.windows.ocidl, core.sys.windows.oaidl, core.sys.windows.objidl;

enum WINCODEC_SDK_VERSION1 = 0x0236;
enum WINCODEC_SDK_VERSION2 = 0x0237;
// const GUID CLSID_WICImagingFactory  = { 0xcacaf262, 0x9370, 0x4615, [0xa1, 0x3b, 0x9f, 0x55, 0x39, 0xda, 0x4c, 0xa] };
const GUID CLSID_WICImagingFactory1 = { 0xcacaf262, 0x9370, 0x4615, [0xa1, 0x3b, 0x9f, 0x55, 0x39, 0xda, 0x4c, 0xa] };
const GUID CLSID_WICImagingFactory2 = { 0x317d06e8, 0x5f24, 0x433d, [0xbd, 0xf7, 0x79, 0xce, 0x68, 0xd8, 0xab, 0xc2] };
// #if(_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
enum WINCODEC_SDK_VERSION = WINCODEC_SDK_VERSION2;
const CLSID_WICImagingFactory = CLSID_WICImagingFactory2;
// #else
// enum WINCODEC_SDK_VERSION WINCODEC_SDK_VERSION1
// #endif
const GUID GUID_VendorMicrosoft  = { 0xf0e749ca, 0xedef, 0x4589, [0xa7, 0x3a, 0xee, 0xe, 0x62, 0x6a, 0x2a, 0x2b] };
const GUID GUID_VendorMicrosoftBuiltIn = { 0x257a30fd, 0x6b6, 0x462b, [0xae, 0xa4, 0x63, 0xf7, 0xb, 0x86, 0xe5, 0x33] };
// const GUID CLSID_WICPngDecoder   = { 0x389ea17b, 0x5078, 0x4cde, [0xb6, 0xef, 0x25, 0xc1, 0x51, 0x75, 0xc7, 0x51] };
const GUID CLSID_WICPngDecoder1  = { 0x389ea17b, 0x5078, 0x4cde, [0xb6, 0xef, 0x25, 0xc1, 0x51, 0x75, 0xc7, 0x51] };
const GUID CLSID_WICPngDecoder2  = { 0xe018945b, 0xaa86, 0x4008, [0x9b, 0xd4, 0x67, 0x77, 0xa1, 0xe4, 0x0c, 0x11] };
// #if(_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
const CLSID_WICPngDecoder = CLSID_WICPngDecoder2;
// #endif
const GUID CLSID_WICBmpDecoder  = { 0x6b462062, 0x7cbf, 0x400d, [0x9f, 0xdb, 0x81, 0x3d, 0xd1, 0x0f, 0x27, 0x78] };
const GUID CLSID_WICIcoDecoder  = { 0xc61bfcdf, 0x2e0f, 0x4aad, [0xa8, 0xd7, 0xe0, 0x6b, 0xaf, 0xeb, 0xcd, 0xfe] };
const GUID CLSID_WICJpegDecoder = { 0x9456a480, 0xe88b, 0x43ea, [0x9e, 0x73, 0x0b, 0x2d, 0x9b, 0x71, 0xb1, 0xca] };
const GUID CLSID_WICGifDecoder  = { 0x381dda3c, 0x9ce9, 0x4834, [0xa2, 0x3e, 0x1f, 0x98, 0xf8, 0xfc, 0x52, 0xbe] };
const GUID CLSID_WICTiffDecoder = { 0xb54e85d9, 0xfe23, 0x499f, [0x8b, 0x88, 0x6a, 0xce, 0xa7, 0x13, 0x75, 0x2b] };
const GUID CLSID_WICWmpDecoder  = { 0xa26cec36, 0x234c, 0x4950, [0xae, 0x16, 0xe3, 0x4a, 0xac, 0xe7, 0x1d, 0x0d] };
const GUID CLSID_WICDdsDecoder  = { 0x9053699f, 0xa341, 0x429d, [0x9e, 0x90, 0xee, 0x43, 0x7c, 0xf8, 0x0c, 0x73] };
const GUID CLSID_WICBmpEncoder  = { 0x69be8bb4, 0xd66d, 0x47c8, [0x86, 0x5a, 0xed, 0x15, 0x89, 0x43, 0x37, 0x82] };
const GUID CLSID_WICPngEncoder  = { 0x27949969, 0x876a, 0x41d7, [0x94, 0x47, 0x56, 0x8f, 0x6a, 0x35, 0xa4, 0xdc] };
const GUID CLSID_WICJpegEncoder = { 0x1a34f5c1, 0x4a5a, 0x46dc, [0xb6, 0x44, 0x1f, 0x45, 0x67, 0xe7, 0xa6, 0x76] };
const GUID CLSID_WICGifEncoder  = { 0x114f5598, 0x0b22, 0x40a0, [0x86, 0xa1, 0xc8, 0x3e, 0xa4, 0x95, 0xad, 0xbd] };
const GUID CLSID_WICTiffEncoder = { 0x0131be10, 0x2001, 0x4c5f, [0xa9, 0xb0, 0xcc, 0x88, 0xfa, 0xb6, 0x4c, 0xe8] };
const GUID CLSID_WICWmpEncoder  = { 0xac4ce3cb, 0xe1c1, 0x44cd, [0x82, 0x15, 0x5a, 0x16, 0x65, 0x50, 0x9e, 0xc2] };
const GUID CLSID_WICDdsEncoder  = { 0xa61dde94, 0x66ce, 0x4ac1, [0x88, 0x1b, 0x71, 0x68, 0x05, 0x88, 0x89, 0x5e] };
const GUID CLSID_WICAdngDecoder = { 0x981d9411, 0x909e, 0x42a7, [0x8f, 0x5d, 0xa7, 0x47, 0xff, 0x05, 0x2e, 0xdb] };
const GUID CLSID_WICJpegQualcommPhoneEncoder = { 0x68ed5c62, 0xf534, 0x4979, [0xb2, 0xb3, 0x68, 0x6a, 0x12, 0xb2, 0xb3, 0x4c] };
const GUID GUID_ContainerFormatBmp  = { 0x0af1d87e, 0xfcfe, 0x4188, [0xbd, 0xeb, 0xa7, 0x90, 0x64, 0x71, 0xcb, 0xe3] };
const GUID GUID_ContainerFormatPng  = { 0x1b7cfaf4, 0x713f, 0x473c, [0xbb, 0xcd, 0x61, 0x37, 0x42, 0x5f, 0xae, 0xaf] };
const GUID GUID_ContainerFormatIco  = { 0xa3a860c4, 0x338f, 0x4c17, [0x91, 0x9a, 0xfb, 0xa4, 0xb5, 0x62, 0x8f, 0x21] };
const GUID GUID_ContainerFormatJpeg = { 0x19e4a5aa, 0x5662, 0x4fc5, [0xa0, 0xc0, 0x17, 0x58, 0x02, 0x8e, 0x10, 0x57] };
const GUID GUID_ContainerFormatTiff = { 0x163bcc30, 0xe2e9, 0x4f0b, [0x96, 0x1d, 0xa3, 0xe9, 0xfd, 0xb7, 0x88, 0xa3] };
const GUID GUID_ContainerFormatGif  = { 0x1f8a5601, 0x7d4d, 0x4cbd, [0x9c, 0x82, 0x1b, 0xc8, 0xd4, 0xee, 0xb9, 0xa5] };
const GUID GUID_ContainerFormatWmp  = { 0x57a37caa, 0x367a, 0x4540, [0x91, 0x6b, 0xf1, 0x83, 0xc5, 0x09, 0x3a, 0x4b] };
const GUID GUID_ContainerFormatDds  = { 0x9967cb95, 0x2e85, 0x4ac8, [0x8c, 0xa2, 0x83, 0xd7, 0xcc, 0xd4, 0x25, 0xc9] };
const GUID GUID_ContainerFormatAdng = { 0xf3ff6d0d, 0x38c0, 0x41c4, [0xb1, 0xfe, 0x1f, 0x38, 0x24, 0xf1, 0x7b, 0x84] };
const GUID CLSID_WICImagingCategories = { 0xfae3d380, 0xfea4, 0x4623, [0x8c, 0x75, 0xc6, 0xb6, 0x11, 0x10, 0xb6, 0x81] };
const GUID CATID_WICBitmapDecoders    = { 0x7ed96837, 0x96f0, 0x4812, [0xb2, 0x11, 0xf1, 0x3c, 0x24, 0x11, 0x7e, 0xd3] };
const GUID CATID_WICBitmapEncoders    = { 0xac757296, 0x3522, 0x4e11, [0x98, 0x62, 0xc1, 0x7b, 0xe5, 0xa1, 0x76, 0x7e] };
const GUID CATID_WICPixelFormats      = { 0x2b46e70f, 0xcda7, 0x473e, [0x89, 0xf6, 0xdc, 0x96, 0x30, 0xa2, 0x39, 0x0b] };
const GUID CATID_WICFormatConverters  = { 0x7835eae8, 0xbf14, 0x49d1, [0x93, 0xce, 0x53, 0x3a, 0x40, 0x7b, 0x22, 0x48] };
const GUID CATID_WICMetadataReader    = { 0x05af94d8, 0x7174, 0x4cd2, [0xbe, 0x4a, 0x41, 0x24, 0xb8, 0x0e, 0xe4, 0xb8] };
const GUID CATID_WICMetadataWriter    = { 0xabe3b9a4, 0x257d, 0x4b97, [0xbd, 0x1a, 0x29, 0x4a, 0xf4, 0x96, 0x22, 0x2e] };
const GUID CLSID_WICDefaultFormatConverter = { 0x1a3f11dc, 0xb514, 0x4b17, [0x8c, 0x5f, 0x21, 0x54, 0x51, 0x38, 0x52, 0xf1] };
const GUID CLSID_WICFormatConverterHighColor = { 0xac75d454, 0x9f37, 0x48f8, [0xb9, 0x72, 0x4e, 0x19, 0xbc, 0x85, 0x60, 0x11] };
const GUID CLSID_WICFormatConverterNChannel = { 0xc17cabb2, 0xd4a3, 0x47d7, [0xa5, 0x57, 0x33, 0x9b, 0x2e, 0xfb, 0xd4, 0xf1] };
const GUID CLSID_WICFormatConverterWMPhoto = { 0x9cb5172b, 0xd600, 0x46ba, [0xab, 0x77, 0x77, 0xbb, 0x7e, 0x3a, 0x00, 0xd9] };
const GUID CLSID_WICPlanarFormatConverter = { 0x184132b8, 0x32f8, 0x4784, [0x91, 0x31, 0xdd, 0x72, 0x24, 0xb2, 0x34, 0x38] };

alias WICColor = UINT32;

/* [public] */ struct WICRect
    {
    INT X;
    INT Y;
    INT Width;
    INT Height;
    }

alias WICInProcPointer = BYTE*;
/* [public] */ 
alias WICColorContextType = uint;
enum : WICColorContextType
    {
        WICColorContextUninitialized	= 0,
        WICColorContextProfile	= 0x1,
        WICColorContextExifColorSpace	= 0x2
    }

enum	WIC_JPEG_MAX_COMPONENT_COUNT	= 4;

enum	WIC_JPEG_MAX_TABLE_INDEX	= 3;

enum	WIC_JPEG_SAMPLE_FACTORS_ONE	= 0x11;

enum	WIC_JPEG_SAMPLE_FACTORS_THREE_420	= 0x111122;

enum	WIC_JPEG_SAMPLE_FACTORS_THREE_422	= 0x111121;

enum	WIC_JPEG_SAMPLE_FACTORS_THREE_440	= 0x111112;

enum	WIC_JPEG_SAMPLE_FACTORS_THREE_444	= 0x111111;

enum	WIC_JPEG_QUANTIZATION_BASELINE_ONE	= 0;

enum	WIC_JPEG_QUANTIZATION_BASELINE_THREE	= 0x10100;

enum	WIC_JPEG_HUFFMAN_BASELINE_ONE	= 0;

enum	WIC_JPEG_HUFFMAN_BASELINE_THREE	= 0x111100;

/* [public] */ alias REFWICPixelFormatGUID = REFGUID;

/* [public] */ alias WICPixelFormatGUID = GUID;

enum GUID_WICPixelFormatUndefined = GUID_WICPixelFormatDontCare;
const GUID GUID_WICPixelFormatDontCare = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x00] };
const GUID GUID_WICPixelFormat1bppIndexed = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x01] };
const GUID GUID_WICPixelFormat2bppIndexed = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x02] };
const GUID GUID_WICPixelFormat4bppIndexed = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x03] };
const GUID GUID_WICPixelFormat8bppIndexed = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x04] };
const GUID GUID_WICPixelFormatBlackWhite = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x05] };
const GUID GUID_WICPixelFormat2bppGray   = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x06] };
const GUID GUID_WICPixelFormat4bppGray   = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x07] };
const GUID GUID_WICPixelFormat8bppGray   = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x08] };
const GUID GUID_WICPixelFormat8bppAlpha = { 0xe6cd0116, 0xeeba, 0x4161, [0xaa, 0x85, 0x27, 0xdd, 0x9f, 0xb3, 0xa8, 0x95] };
const GUID GUID_WICPixelFormat16bppBGR555 = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x09] };
const GUID GUID_WICPixelFormat16bppBGR565 = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0a] };
const GUID GUID_WICPixelFormat16bppBGRA5551 = { 0x05ec7c2b, 0xf1e6, 0x4961, [0xad, 0x46, 0xe1, 0xcc, 0x81, 0x0a, 0x87, 0xd2] };
const GUID GUID_WICPixelFormat16bppGray   = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0b] };
const GUID GUID_WICPixelFormat24bppBGR = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0c] };
const GUID GUID_WICPixelFormat24bppRGB = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0d] };
const GUID GUID_WICPixelFormat32bppBGR   = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0e] };
const GUID GUID_WICPixelFormat32bppBGRA  = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0f] };
const GUID GUID_WICPixelFormat32bppPBGRA = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x10] };
const GUID GUID_WICPixelFormat32bppGrayFloat  = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x11] };
// #if (_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
const GUID GUID_WICPixelFormat32bppRGB  = { 0xd98c6b95, 0x3efe, 0x47d6, [0xbb, 0x25, 0xeb, 0x17, 0x48, 0xab, 0x0c, 0xf1] };
// #endif
const GUID GUID_WICPixelFormat32bppRGBA = { 0xf5c7ad2d, 0x6a8d, 0x43dd, [0xa7, 0xa8, 0xa2, 0x99, 0x35, 0x26, 0x1a, 0xe9] };
const GUID GUID_WICPixelFormat32bppPRGBA = { 0x3cc4a650, 0xa527, 0x4d37, [0xa9, 0x16, 0x31, 0x42, 0xc7, 0xeb, 0xed, 0xba] };
const GUID GUID_WICPixelFormat48bppRGB = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x15] };
const GUID GUID_WICPixelFormat48bppBGR = { 0xe605a384, 0xb468, 0x46ce, [0xbb, 0x2e, 0x36, 0xf1, 0x80, 0xe6, 0x43, 0x13] };
// #if (_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
const GUID GUID_WICPixelFormat64bppRGB   = { 0xa1182111, 0x186d, 0x4d42, [0xbc, 0x6a, 0x9c, 0x83, 0x03, 0xa8, 0xdf, 0xf9] };
// #endif
const GUID GUID_WICPixelFormat64bppRGBA  = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x16] };
const GUID GUID_WICPixelFormat64bppBGRA  = { 0x1562ff7c, 0xd352, 0x46f9, [0x97, 0x9e, 0x42, 0x97, 0x6b, 0x79, 0x22, 0x46] };
const GUID GUID_WICPixelFormat64bppPRGBA = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x17] };
const GUID GUID_WICPixelFormat64bppPBGRA = { 0x8c518e8e, 0xa4ec, 0x468b, [0xae, 0x70, 0xc9, 0xa3, 0x5a, 0x9c, 0x55, 0x30] };
const GUID GUID_WICPixelFormat16bppGrayFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x13] };
const GUID GUID_WICPixelFormat32bppBGR101010 = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x14] };
const GUID GUID_WICPixelFormat48bppRGBFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x12] };
const GUID GUID_WICPixelFormat48bppBGRFixedPoint = { 0x49ca140e, 0xcab6, 0x493b, [0x9d, 0xdf, 0x60, 0x18, 0x7c, 0x37, 0x53, 0x2a] };
const GUID GUID_WICPixelFormat96bppRGBFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x18] };
// #if (_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
const GUID GUID_WICPixelFormat96bppRGBFloat = { 0xe3fed78f, 0xe8db, 0x4acf, [0x84, 0xc1, 0xe9, 0x7f, 0x61, 0x36, 0xb3, 0x27] };
// #endif
const GUID GUID_WICPixelFormat128bppRGBAFloat  = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x19] };
const GUID GUID_WICPixelFormat128bppPRGBAFloat = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1a] };
const GUID GUID_WICPixelFormat128bppRGBFloat   = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1b] };
const GUID GUID_WICPixelFormat32bppCMYK = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1c] };
const GUID GUID_WICPixelFormat64bppRGBAFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1d] };
const GUID GUID_WICPixelFormat64bppBGRAFixedPoint = { 0x356de33c, 0x54d2, 0x4a23, [0xbb, 0x4, 0x9b, 0x7b, 0xf9, 0xb1, 0xd4, 0x2d] };
const GUID GUID_WICPixelFormat64bppRGBFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x40] };
const GUID GUID_WICPixelFormat128bppRGBAFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1e] };
const GUID GUID_WICPixelFormat128bppRGBFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x41] };
const GUID GUID_WICPixelFormat64bppRGBAHalf = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3a] };
// #if (_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
const GUID GUID_WICPixelFormat64bppPRGBAHalf = { 0x58ad26c2, 0xc623, 0x4d9d, [0xb3, 0x20, 0x38, 0x7e, 0x49, 0xf8, 0xc4, 0x42] };
// #endif
const GUID GUID_WICPixelFormat64bppRGBHalf = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x42] };
const GUID GUID_WICPixelFormat48bppRGBHalf = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3b] };
const GUID GUID_WICPixelFormat32bppRGBE    = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3d] };
const GUID GUID_WICPixelFormat16bppGrayHalf = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3e] };
const GUID GUID_WICPixelFormat32bppGrayFixedPoint = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3f] };
const GUID GUID_WICPixelFormat32bppRGBA1010102 = { 0x25238D72, 0xFCF9, 0x4522, [0xb5, 0x14, 0x55, 0x78, 0xe5, 0xad, 0x55, 0xe0] };
const GUID GUID_WICPixelFormat32bppRGBA1010102XR = { 0x00DE6B9A, 0xC101, 0x434b, [0xb5, 0x02, 0xd0, 0x16, 0x5e, 0xe1, 0x12, 0x2c] };
const GUID GUID_WICPixelFormat64bppCMYK = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1f] };
const GUID GUID_WICPixelFormat24bpp3Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x20] };
const GUID GUID_WICPixelFormat32bpp4Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x21] };
const GUID GUID_WICPixelFormat40bpp5Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x22] };
const GUID GUID_WICPixelFormat48bpp6Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x23] };
const GUID GUID_WICPixelFormat56bpp7Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x24] };
const GUID GUID_WICPixelFormat64bpp8Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x25] };
const GUID GUID_WICPixelFormat48bpp3Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x26] };
const GUID GUID_WICPixelFormat64bpp4Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x27] };
const GUID GUID_WICPixelFormat80bpp5Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x28] };
const GUID GUID_WICPixelFormat96bpp6Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x29] };
const GUID GUID_WICPixelFormat112bpp7Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2a] };
const GUID GUID_WICPixelFormat128bpp8Channels = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2b] };
const GUID GUID_WICPixelFormat40bppCMYKAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2c] };
const GUID GUID_WICPixelFormat80bppCMYKAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2d] };
const GUID GUID_WICPixelFormat32bpp3ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2e] };
const GUID GUID_WICPixelFormat40bpp4ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2f] };
const GUID GUID_WICPixelFormat48bpp5ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x30] };
const GUID GUID_WICPixelFormat56bpp6ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x31] };
const GUID GUID_WICPixelFormat64bpp7ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x32] };
const GUID GUID_WICPixelFormat72bpp8ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x33] };
const GUID GUID_WICPixelFormat64bpp3ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x34] };
const GUID GUID_WICPixelFormat80bpp4ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x35] };
const GUID GUID_WICPixelFormat96bpp5ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x36] };
const GUID GUID_WICPixelFormat112bpp6ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x37] };
const GUID GUID_WICPixelFormat128bpp7ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x38] };
const GUID GUID_WICPixelFormat144bpp8ChannelsAlpha = { 0x6fddc324, 0x4e03, 0x4bfe, [0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x39] };
const GUID GUID_WICPixelFormat8bppY            = { 0x91B4DB54, 0x2DF9, 0x42F0, [0xB4, 0x49, 0x29, 0x09, 0xBB, 0x3D, 0xF8, 0x8E] };
const GUID GUID_WICPixelFormat8bppCb           = { 0x1339F224, 0x6BFE, 0x4C3E, [0x93, 0x02, 0xE4, 0xF3, 0xA6, 0xD0, 0xCA, 0x2A] };
const GUID GUID_WICPixelFormat8bppCr           = { 0xB8145053, 0x2116, 0x49F0, [0x88, 0x35, 0xED, 0x84, 0x4B, 0x20, 0x5C, 0x51] };
const GUID GUID_WICPixelFormat16bppCbCr        = { 0xFF95BA6E, 0x11E0, 0x4263, [0xBB, 0x45, 0x01, 0x72, 0x1F, 0x34, 0x60, 0xA4] };
const GUID GUID_WICPixelFormat16bppYQuantizedDctCoefficients           = { 0xA355F433, 0x48E8, 0x4A42, [0x84, 0xD8, 0xE2, 0xAA, 0x26, 0xCA, 0x80, 0xA4] };
const GUID GUID_WICPixelFormat16bppCbQuantizedDctCoefficients          = { 0xD2C4FF61, 0x56A5, 0x49C2, [0x8B, 0x5C, 0x4C, 0x19, 0x25, 0x96, 0x48, 0x37] };
const GUID GUID_WICPixelFormat16bppCrQuantizedDctCoefficients          = { 0x2FE354F0, 0x1680, 0x42D8, [0x92, 0x31, 0xE7, 0x3C, 0x05, 0x65, 0xBF, 0xC1] };
/* [public] */
alias WICBitmapCreateCacheOption = uint;
enum : WICBitmapCreateCacheOption
    {
        WICBitmapNoCache	= 0,
        WICBitmapCacheOnDemand	= 0x1,
        WICBitmapCacheOnLoad	= 0x2
    }

/* [public] */ 
alias WICDecodeOptions = uint;
enum : WICDecodeOptions
    {
        WICDecodeMetadataCacheOnDemand	= 0,
        WICDecodeMetadataCacheOnLoad	= 0x1
    }

/* [public] */ 
alias WICBitmapEncoderCacheOption = uint;
enum : WICBitmapEncoderCacheOption
    {
        WICBitmapEncoderCacheInMemory	= 0,
        WICBitmapEncoderCacheTempFile	= 0x1,
        WICBitmapEncoderNoCache	= 0x2
    }

/* [public] */ 
alias WICComponentType = uint;
enum : WICComponentType
    {
        WICDecoder	= 0x1,
        WICEncoder	= 0x2,
        WICPixelFormatConverter	= 0x4,
        WICMetadataReader	= 0x8,
        WICMetadataWriter	= 0x10,
        WICPixelFormat	= 0x20,
        WICAllComponents	= 0x3f
    }

/* [public] */ 
alias WICComponentEnumerateOptions = uint;
enum : WICComponentEnumerateOptions
    {
        WICComponentEnumerateDefault	= 0,
        WICComponentEnumerateRefresh	= 0x1,
        WICComponentEnumerateDisabled	= 0x80000000,
        WICComponentEnumerateUnsigned	= 0x40000000,
        WICComponentEnumerateBuiltInOnly	= 0x20000000
    }

/* [public] */ struct WICBitmapPattern
    {
    ULARGE_INTEGER Position;
    ULONG Length;
    /* [size_is] */ BYTE* Pattern;
    /* [size_is] */ BYTE* Mask;
    BOOL EndOfStream;
    }

/* [public] */ 
alias WICBitmapInterpolationMode = uint;
enum : WICBitmapInterpolationMode
    {
        WICBitmapInterpolationModeNearestNeighbor	= 0,
        WICBitmapInterpolationModeLinear	= 0x1,
        WICBitmapInterpolationModeCubic	= 0x2,
        WICBitmapInterpolationModeFant	= 0x3,
        WICBitmapInterpolationModeHighQualityCubic	= 0x4
    }

/* [public] */ 
alias WICBitmapPaletteType = uint;
enum : WICBitmapPaletteType
    {
        WICBitmapPaletteTypeCustom	= 0,
        WICBitmapPaletteTypeMedianCut	= 0x1,
        WICBitmapPaletteTypeFixedBW	= 0x2,
        WICBitmapPaletteTypeFixedHalftone8	= 0x3,
        WICBitmapPaletteTypeFixedHalftone27	= 0x4,
        WICBitmapPaletteTypeFixedHalftone64	= 0x5,
        WICBitmapPaletteTypeFixedHalftone125	= 0x6,
        WICBitmapPaletteTypeFixedHalftone216	= 0x7,
        WICBitmapPaletteTypeFixedWebPalette	= WICBitmapPaletteTypeFixedHalftone216,
        WICBitmapPaletteTypeFixedHalftone252	= 0x8,
        WICBitmapPaletteTypeFixedHalftone256	= 0x9,
        WICBitmapPaletteTypeFixedGray4	= 0xa,
        WICBitmapPaletteTypeFixedGray16	= 0xb,
        WICBitmapPaletteTypeFixedGray256	= 0xc
    }

/* [public] */ 
alias WICBitmapDitherType = uint;
enum : WICBitmapDitherType
    {
        WICBitmapDitherTypeNone	= 0,
        WICBitmapDitherTypeSolid	= 0,
        WICBitmapDitherTypeOrdered4x4	= 0x1,
        WICBitmapDitherTypeOrdered8x8	= 0x2,
        WICBitmapDitherTypeOrdered16x16	= 0x3,
        WICBitmapDitherTypeSpiral4x4	= 0x4,
        WICBitmapDitherTypeSpiral8x8	= 0x5,
        WICBitmapDitherTypeDualSpiral4x4	= 0x6,
        WICBitmapDitherTypeDualSpiral8x8	= 0x7,
        WICBitmapDitherTypeErrorDiffusion	= 0x8
    }

/* [public] */ 
alias WICBitmapAlphaChannelOption = uint;
enum : WICBitmapAlphaChannelOption
    {
        WICBitmapUseAlpha	= 0,
        WICBitmapUsePremultipliedAlpha	= 0x1,
        WICBitmapIgnoreAlpha	= 0x2
    }

/* [public] */ 
alias WICBitmapTransformOptions = uint;
enum : WICBitmapTransformOptions
    {
        WICBitmapTransformRotate0	= 0,
        WICBitmapTransformRotate90	= 0x1,
        WICBitmapTransformRotate180	= 0x2,
        WICBitmapTransformRotate270	= 0x3,
        WICBitmapTransformFlipHorizontal	= 0x8,
        WICBitmapTransformFlipVertical	= 0x10
    }

/* [public] */ 
alias WICBitmapLockFlags = uint;
enum : WICBitmapLockFlags
    {
        WICBitmapLockRead	= 0x1,
        WICBitmapLockWrite	= 0x2
    }

/* [public] */ 
alias WICBitmapDecoderCapabilities = uint;
enum : WICBitmapDecoderCapabilities
    {
        WICBitmapDecoderCapabilitySameEncoder	= 0x1,
        WICBitmapDecoderCapabilityCanDecodeAllImages	= 0x2,
        WICBitmapDecoderCapabilityCanDecodeSomeImages	= 0x4,
        WICBitmapDecoderCapabilityCanEnumerateMetadata	= 0x8,
        WICBitmapDecoderCapabilityCanDecodeThumbnail	= 0x10
    }

/* [public] */ 
alias WICProgressOperation = uint;
enum : WICProgressOperation
    {
        WICProgressOperationCopyPixels	= 0x1,
        WICProgressOperationWritePixels	= 0x2,
        WICProgressOperationAll	= 0xffff
    }

/* [public] */ 
alias WICProgressNotification = uint;
enum : WICProgressNotification
    {
        WICProgressNotificationBegin	= 0x10000,
        WICProgressNotificationEnd	= 0x20000,
        WICProgressNotificationFrequent	= 0x40000,
        WICProgressNotificationAll	= 0xffff0000
    }

/* [public] */ 
alias WICComponentSigning = uint;
enum : WICComponentSigning
    {
        WICComponentSigned	= 0x1,
        WICComponentUnsigned	= 0x2,
        WICComponentSafe	= 0x4,
        WICComponentDisabled	= 0x80000000
    }

/* [public] */ 
alias WICGifLogicalScreenDescriptorProperties = uint;
enum : WICGifLogicalScreenDescriptorProperties
    {
        WICGifLogicalScreenSignature	= 0x1,
        WICGifLogicalScreenDescriptorWidth	= 0x2,
        WICGifLogicalScreenDescriptorHeight	= 0x3,
        WICGifLogicalScreenDescriptorGlobalColorTableFlag	= 0x4,
        WICGifLogicalScreenDescriptorColorResolution	= 0x5,
        WICGifLogicalScreenDescriptorSortFlag	= 0x6,
        WICGifLogicalScreenDescriptorGlobalColorTableSize	= 0x7,
        WICGifLogicalScreenDescriptorBackgroundColorIndex	= 0x8,
        WICGifLogicalScreenDescriptorPixelAspectRatio	= 0x9
    }

/* [public] */ 
alias WICGifImageDescriptorProperties = uint;
enum : WICGifImageDescriptorProperties
    {
        WICGifImageDescriptorLeft	= 0x1,
        WICGifImageDescriptorTop	= 0x2,
        WICGifImageDescriptorWidth	= 0x3,
        WICGifImageDescriptorHeight	= 0x4,
        WICGifImageDescriptorLocalColorTableFlag	= 0x5,
        WICGifImageDescriptorInterlaceFlag	= 0x6,
        WICGifImageDescriptorSortFlag	= 0x7,
        WICGifImageDescriptorLocalColorTableSize	= 0x8
    }

/* [public] */ 
alias WICGifGraphicControlExtensionProperties = uint;
enum : WICGifGraphicControlExtensionProperties
    {
        WICGifGraphicControlExtensionDisposal	= 0x1,
        WICGifGraphicControlExtensionUserInputFlag	= 0x2,
        WICGifGraphicControlExtensionTransparencyFlag	= 0x3,
        WICGifGraphicControlExtensionDelay	= 0x4,
        WICGifGraphicControlExtensionTransparentColorIndex	= 0x5
    }

/* [public] */ 
alias WICGifApplicationExtensionProperties = uint;
enum : WICGifApplicationExtensionProperties
    {
        WICGifApplicationExtensionApplication	= 0x1,
        WICGifApplicationExtensionData	= 0x2
    }

/* [public] */ 
alias WICGifCommentExtensionProperties = uint;
enum : WICGifCommentExtensionProperties
    {
        WICGifCommentExtensionText	= 0x1
    }

/* [public] */ 
alias WICJpegCommentProperties = uint;
enum : WICJpegCommentProperties
    {
        WICJpegCommentText	= 0x1
    }

/* [public] */ 
alias WICJpegLuminanceProperties = uint;
enum : WICJpegLuminanceProperties
    {
        WICJpegLuminanceTable	= 0x1
    }

/* [public] */ 
alias WICJpegChrominanceProperties = uint;
enum : WICJpegChrominanceProperties
    {
        WICJpegChrominanceTable	= 0x1
    }

/* [public] */ 
alias WIC8BIMIptcProperties = uint;
enum : WIC8BIMIptcProperties
    {
        WIC8BIMIptcPString	= 0,
        WIC8BIMIptcEmbeddedIPTC	= 0x1
    }

/* [public] */ 
alias WIC8BIMResolutionInfoProperties = uint;
enum : WIC8BIMResolutionInfoProperties
    {
        WIC8BIMResolutionInfoPString	= 0x1,
        WIC8BIMResolutionInfoHResolution	= 0x2,
        WIC8BIMResolutionInfoHResolutionUnit	= 0x3,
        WIC8BIMResolutionInfoWidthUnit	= 0x4,
        WIC8BIMResolutionInfoVResolution	= 0x5,
        WIC8BIMResolutionInfoVResolutionUnit	= 0x6,
        WIC8BIMResolutionInfoHeightUnit	= 0x7
    }

/* [public] */ 
alias WIC8BIMIptcDigestProperties = uint;
enum : WIC8BIMIptcDigestProperties
    {
        WIC8BIMIptcDigestPString	= 0x1,
        WIC8BIMIptcDigestIptcDigest	= 0x2
    }

/* [public] */ 
alias WICPngGamaProperties = uint;
enum : WICPngGamaProperties
    {
        WICPngGamaGamma	= 0x1
    }

/* [public] */ 
alias WICPngBkgdProperties = uint;
enum : WICPngBkgdProperties
    {
        WICPngBkgdBackgroundColor	= 0x1
    }

/* [public] */ 
alias WICPngItxtProperties = uint;
enum : WICPngItxtProperties
    {
        WICPngItxtKeyword	= 0x1,
        WICPngItxtCompressionFlag	= 0x2,
        WICPngItxtLanguageTag	= 0x3,
        WICPngItxtTranslatedKeyword	= 0x4,
        WICPngItxtText	= 0x5
    }

/* [public] */ 
alias WICPngChrmProperties = uint;
enum : WICPngChrmProperties
    {
        WICPngChrmWhitePointX	= 0x1,
        WICPngChrmWhitePointY	= 0x2,
        WICPngChrmRedX	= 0x3,
        WICPngChrmRedY	= 0x4,
        WICPngChrmGreenX	= 0x5,
        WICPngChrmGreenY	= 0x6,
        WICPngChrmBlueX	= 0x7,
        WICPngChrmBlueY	= 0x8
    }

/* [public] */ 
alias WICPngHistProperties = uint;
enum : WICPngHistProperties
    {
        WICPngHistFrequencies	= 0x1
    }

/* [public] */ 
alias WICPngIccpProperties = uint;
enum : WICPngIccpProperties
    {
        WICPngIccpProfileName	= 0x1,
        WICPngIccpProfileData	= 0x2
    }

/* [public] */ 
alias WICPngSrgbProperties = uint;
enum : WICPngSrgbProperties
    {
        WICPngSrgbRenderingIntent	= 0x1
    }

/* [public] */ 
alias WICPngTimeProperties = uint;
enum : WICPngTimeProperties
    {
        WICPngTimeYear	= 0x1,
        WICPngTimeMonth	= 0x2,
        WICPngTimeDay	= 0x3,
        WICPngTimeHour	= 0x4,
        WICPngTimeMinute	= 0x5,
        WICPngTimeSecond	= 0x6
    }

/* [public] */
alias WICSectionAccessLevel = uint; 
enum : WICSectionAccessLevel
    {
        WICSectionAccessLevelRead	= 0x1,
        WICSectionAccessLevelReadWrite	= 0x3
    }

/* [public] */ 
alias WICPixelFormatNumericRepresentation = uint;
enum : WICPixelFormatNumericRepresentation
    {
        WICPixelFormatNumericRepresentationUnspecified	= 0,
        WICPixelFormatNumericRepresentationIndexed	= 0x1,
        WICPixelFormatNumericRepresentationUnsignedInteger	= 0x2,
        WICPixelFormatNumericRepresentationSignedInteger	= 0x3,
        WICPixelFormatNumericRepresentationFixed	= 0x4,
        WICPixelFormatNumericRepresentationFloat	= 0x5
    }

/* [public] */ 
alias WICPlanarOptions = uint;
enum : WICPlanarOptions
    {
        WICPlanarOptionsDefault	= 0,
        WICPlanarOptionsPreserveSubsampling	= 0x1
    }

/* [public] */ 
alias WICJpegIndexingOptions = uint;
enum : WICJpegIndexingOptions
    {
        WICJpegIndexingOptionsGenerateOnDemand	= 0,
        WICJpegIndexingOptionsGenerateOnLoad	= 0x1
    }

/* [public] */ 
alias WICJpegTransferMatrix = uint;
enum : WICJpegTransferMatrix
    {
        WICJpegTransferMatrixIdentity	= 0,
        WICJpegTransferMatrixBT601	= 0x1
    }

/* [public] */ 
alias WICJpegScanType = uint;
enum : WICJpegScanType
    {
        WICJpegScanTypeInterleaved	= 0,
        WICJpegScanTypePlanarComponents	= 0x1,
        WICJpegScanTypeProgressive	= 0x2
    }

// #if (_WIN32_WINNT >= _WIN32_WINNT_WIN8) || defined(_WIN7_PLATFORM_UPDATE)
/* [public] */ struct WICImageParameters
    {
    D2D1_PIXEL_FORMAT PixelFormat;
    FLOAT DpiX;
    FLOAT DpiY;
    FLOAT Top;
    FLOAT Left;
    UINT32 PixelWidth;
    UINT32 PixelHeight;
    }

// #endif
/* [public] */ struct WICBitmapPlaneDescription
    {
    WICPixelFormatGUID Format;
    UINT Width;
    UINT Height;
    }

/* [public] */ struct WICBitmapPlane
    {
    WICPixelFormatGUID Format;
    /* [size_is] */ BYTE* pbBuffer;
    UINT cbStride;
    UINT cbBufferSize;
    }

/* [public] */ struct WICJpegFrameHeader
    {
    UINT Width;
    UINT Height;
    WICJpegTransferMatrix TransferMatrix;
    WICJpegScanType ScanType;
    /* [range] */ UINT cComponents;
    DWORD ComponentIdentifiers;
    DWORD SampleFactors;
    DWORD QuantizationTableIndices;
    }

/* [public] */ struct WICJpegScanHeader
    {
    /* [range] */ UINT cComponents;
    UINT RestartInterval;
    DWORD ComponentSelectors;
    DWORD HuffmanTableIndices;
    BYTE StartSpectralSelection;
    BYTE EndSpectralSelection;
    BYTE SuccessiveApproximationHigh;
    BYTE SuccessiveApproximationLow;
    }
    

mixin(uuid!(IWICPalette, "00000040-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICPalette : IUnknown
{
extern(Windows):
    HRESULT InitializePredefined( 
            /* [in] */ WICBitmapPaletteType ePaletteType,
            /* [in] */ BOOL fAddTransparentColor);

    HRESULT InitializeCustom( 
            /* [size_is][in] */ WICColor* pColors,
            /* [in] */ UINT cCount);

    HRESULT InitializeFromBitmap( 
            /* [in] */ IWICBitmapSource pISurface,
            /* [in] */ UINT cCount,
            /* [in] */ BOOL fAddTransparentColor);

    HRESULT InitializeFromPalette( 
            /* [in] */ IWICPalette pIPalette);

    HRESULT GetType( 
            /* [out] */ WICBitmapPaletteType* pePaletteType);

    HRESULT GetColorCount( 
            /* [out] */ UINT* pcCount);

    HRESULT GetColors( 
            /* [in] */ UINT cCount,
            /* [size_is][out] */ WICColor* pColors,
            /* [out] */ UINT* pcActualColors);

    HRESULT IsBlackWhite( 
            /* [out] */ BOOL* pfIsBlackWhite);

    HRESULT IsGrayscale( 
            /* [out] */ BOOL* pfIsGrayscale);

    HRESULT HasAlpha( 
            /* [out] */ BOOL* pfHasAlpha);
}

mixin(uuid!(IWICBitmapSource, "00000120-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICBitmapSource : IUnknown
{
extern(Windows):
    HRESULT GetSize( 
        /* [out] */ UINT* puiWidth,
        /* [out] */ UINT* puiHeight);
    
    HRESULT GetPixelFormat( 
        /* [out] */ WICPixelFormatGUID* pPixelFormat);
    
    HRESULT GetResolution( 
        /* [out] */ double* pDpiX,
        /* [out] */ double* pDpiY);
    
    HRESULT CopyPalette( 
        /* [in] */ IWICPalette pIPalette);
    
    HRESULT CopyPixels( 
        /* [unique][in] */ const(WICRect)* prc,
        /* [in] */ UINT cbStride,
        /* [in] */ UINT cbBufferSize,
        /* [size_is][out] */ BYTE* pbBuffer);
    
}
   
mixin(uuid!(IWICFormatConverter, "00000301-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICFormatConverter : IWICBitmapSource
{
extern(Windows):
    HRESULT Initialize( 
        /* [in] */ IWICBitmapSource pISource,
        /* [in] */ REFWICPixelFormatGUID dstFormat,
        /* [in] */ WICBitmapDitherType dither,
        /* [unique][in] */ IWICPalette pIPalette,
        /* [in] */ double alphaThresholdPercent,
        /* [in] */ WICBitmapPaletteType paletteTranslate);
    
    HRESULT CanConvert( 
        /* [in] */ REFWICPixelFormatGUID srcPixelFormat,
        /* [in] */ REFWICPixelFormatGUID dstPixelFormat,
        /* [out] */ BOOL* pfCanConvert);
    
}
    
mixin(uuid!(IWICPlanarFormatConverter, "BEBEE9CB-83B0-4DCC-8132-B0AAA55EAC96"));
interface IWICPlanarFormatConverter : IWICBitmapSource
{
extern(Windows):
    HRESULT Initialize( 
        /* [size_is][in] */ IWICBitmapSource *ppPlanes,
        UINT cPlanes,
        /* [in] */ REFWICPixelFormatGUID dstFormat,
        /* [in] */ WICBitmapDitherType dither,
        /* [unique][in] */ IWICPalette pIPalette,
        /* [in] */ double alphaThresholdPercent,
        /* [in] */ WICBitmapPaletteType paletteTranslate);
    
    HRESULT CanConvert( 
        /* [size_is][in] */ const(WICPixelFormatGUID)* pSrcPixelFormats,
        UINT cSrcPlanes,
        /* [in] */ REFWICPixelFormatGUID dstPixelFormat,
        /* [out] */ BOOL* pfCanConvert);
    
}
    
mixin(uuid!(IWICBitmapScaler, "00000302-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICBitmapScaler : IWICBitmapSource
{
extern(Windows):
    HRESULT Initialize( 
        /* [in] */ IWICBitmapSource pISource,
        /* [in] */ UINT uiWidth,
        /* [in] */ UINT uiHeight,
        /* [in] */ WICBitmapInterpolationMode mode);
    
}
    
mixin(uuid!(IWICBitmapClipper, "E4FBCF03-223D-4e81-9333-D635556DD1B5"));
interface IWICBitmapClipper : IWICBitmapSource
{
extern(Windows):
    HRESULT Initialize( 
        /* [in] */ IWICBitmapSource pISource,
        /* [in] */ const(WICRect)* prc);
    
}
    
mixin(uuid!(IWICBitmapFlipRotator, "5009834F-2D6A-41ce-9E1B-17C5AFF7A782"));
interface IWICBitmapFlipRotator : IWICBitmapSource
{
extern(Windows):
    HRESULT Initialize( 
        /* [in] */ IWICBitmapSource pISource,
        /* [in] */ WICBitmapTransformOptions options);
    
}
    
mixin(uuid!(IWICBitmapLock, "00000123-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICBitmapLock : IUnknown
{
extern(Windows):
    HRESULT GetSize( 
        /* [out] */ UINT* puiWidth,
        /* [out] */ UINT* puiHeight);
    
    HRESULT GetStride( 
        /* [out] */ UINT* pcbStride);
    
    HRESULT GetDataPointer( 
        /* [out] */ UINT* pcbBufferSize,
        /* [size_is][size_is][out] */ WICInProcPointer* ppbData);
    
    HRESULT GetPixelFormat( 
        /* [out] */ WICPixelFormatGUID* pPixelFormat);
    
}
    
mixin(uuid!(IWICBitmap, "00000121-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICBitmap : IWICBitmapSource
{
extern(Windows):
    HRESULT Lock( 
        /* [unique][in] */ const(WICRect)* prcLock,
        /* [in] */ DWORD flags,
        /* [out] */ IWICBitmapLock *ppILock);
    
    HRESULT SetPalette( 
        /* [in] */ IWICPalette pIPalette);
    
    HRESULT SetResolution( 
        /* [in] */ double dpiX,
        /* [in] */ double dpiY);
    
}
    
mixin(uuid!(IWICColorContext, "3C613A02-34B2-44ea-9A7C-45AEA9C6FD6D"));
interface IWICColorContext : IUnknown
{
extern(Windows):
    HRESULT InitializeFromFilename( 
        /* [in] */ LPCWSTR wzFilename);
    
    HRESULT InitializeFromMemory( 
        /* [size_is][in] */ const(BYTE)* pbBuffer,
        /* [in] */ UINT cbBufferSize);
    
    HRESULT InitializeFromExifColorSpace( 
        /* [in] */ UINT value);
    
    HRESULT GetType( 
        /* [out] */ WICColorContextType* pType);
    
    HRESULT GetProfileBytes( 
        /* [in] */ UINT cbBuffer,
        /* [size_is][unique][out][in] */ BYTE* pbBuffer,
        /* [out] */ UINT* pcbActual);
    
    HRESULT GetExifColorSpace( 
        /* [out] */ UINT* pValue);
    
}
    
mixin(uuid!(IWICColorTransform, "B66F034F-D0E2-40ab-B436-6DE39E321A94"));
interface IWICColorTransform : IWICBitmapSource
{
extern(Windows):
    HRESULT Initialize( 
        /* [in] */ IWICBitmapSource pIBitmapSource,
        /* [in] */ IWICColorContext pIContextSource,
        /* [in] */ IWICColorContext pIContextDest,
        /* [in] */ REFWICPixelFormatGUID pixelFmtDest);
    
}
    
mixin(uuid!(IWICFastMetadataEncoder, "B84E2C09-78C9-4AC4-8BD3-524AE1663A2F"));
interface IWICFastMetadataEncoder : IUnknown
{
extern(Windows):
    HRESULT Commit();
    
    HRESULT GetMetadataQueryWriter( 
        /* [out] */ IWICMetadataQueryWriter *ppIMetadataQueryWriter);
    
}
    
mixin(uuid!(IWICStream, "135FF860-22B7-4ddf-B0F6-218F4F299A43"));
interface IWICStream : IStream
{
extern(Windows):
    HRESULT InitializeFromIStream( 
        /* [in] */ IStream pIStream);
    
    HRESULT InitializeFromFilename( 
        /* [in] */ LPCWSTR wzFileName,
        /* [in] */ DWORD dwDesiredAccess);
    
    HRESULT InitializeFromMemory( 
        /* [size_is][in] */ WICInProcPointer pbBuffer,
        /* [in] */ DWORD cbBufferSize);
    
    HRESULT InitializeFromIStreamRegion( 
        /* [in] */ IStream pIStream,
        /* [in] */ ULARGE_INTEGER ulOffset,
        /* [in] */ ULARGE_INTEGER ulMaxSize);
    
}
    
mixin(uuid!(IWICEnumMetadataItem, "DC2BB46D-3F07-481E-8625-220C4AEDBB33"));
interface IWICEnumMetadataItem : IUnknown
{
extern(Windows):
    HRESULT Next( 
        /* [in] */ ULONG celt,
        /* [size_is][unique][out][in] */ PROPVARIANT* rgeltSchema,
        /* [size_is][out][in] */ PROPVARIANT* rgeltId,
        /* [size_is][optional][out][in] */ PROPVARIANT* rgeltValue,
        /* [optional][out] */ ULONG* pceltFetched);
    
    HRESULT Skip( 
        /* [in] */ ULONG celt);
    
    HRESULT Reset();
    
    HRESULT Clone( 
        /* [out] */ IWICEnumMetadataItem *ppIEnumMetadataItem);
    
}
    
mixin(uuid!(IWICMetadataQueryReader, "30989668-E1C9-4597-B395-458EEDB808DF"));
interface IWICMetadataQueryReader : IUnknown
{
extern(Windows):
    HRESULT GetContainerFormat( 
        /* [out] */ GUID* pguidContainerFormat);
    
    HRESULT GetLocation( 
        /* [in] */ UINT cchMaxLength,
        /* [size_is][unique][out][in] */ WCHAR* wzNamespace,
        /* [out] */ UINT* pcchActualLength);
    
    HRESULT GetMetadataByName( 
        /* [in] */ LPCWSTR wzName,
        /* [unique][out][in] */ PROPVARIANT* pvarValue);
    
    HRESULT GetEnumerator( 
        /* [out] */ IEnumString *ppIEnumString);
    
}
    
mixin(uuid!(IWICMetadataQueryWriter, "A721791A-0DEF-4d06-BD91-2118BF1DB10B"));
interface IWICMetadataQueryWriter : IWICMetadataQueryReader
{
extern(Windows):
    HRESULT SetMetadataByName( 
        /* [in] */ LPCWSTR wzName,
        /* [in] */ const(PROPVARIANT)* pvarValue);
    
    HRESULT RemoveMetadataByName( 
        /* [in] */ LPCWSTR wzName);
    
}
    
mixin(uuid!(IWICBitmapEncoder, "00000103-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICBitmapEncoder : IUnknown
{
extern(Windows):
    HRESULT Initialize( 
        /* [in] */ IStream pIStream,
        /* [in] */ WICBitmapEncoderCacheOption cacheOption);
    
    HRESULT GetContainerFormat( 
        /* [out] */ GUID* pguidContainerFormat);
    
    HRESULT GetEncoderInfo( 
        /* [out] */ IWICBitmapEncoderInfo *ppIEncoderInfo);
    
    HRESULT SetColorContexts( 
        /* [in] */ UINT cCount,
        /* [size_is][in] */ IWICColorContext *ppIColorContext);
    
    HRESULT SetPalette( 
        /* [in] */ IWICPalette pIPalette);
    
    HRESULT SetThumbnail( 
        /* [in] */ IWICBitmapSource pIThumbnail);
    
    HRESULT SetPreview( 
        /* [in] */ IWICBitmapSource pIPreview);
    
    HRESULT CreateNewFrame( 
        /* [out] */ IWICBitmapFrameEncode *ppIFrameEncode,
        /* [unique][out][in] */ IPropertyBag2 *ppIEncoderOptions);
    
    HRESULT Commit();
    
    HRESULT GetMetadataQueryWriter( 
        /* [out] */ IWICMetadataQueryWriter *ppIMetadataQueryWriter);
    
}
    
mixin(uuid!(IWICBitmapFrameEncode, "00000105-a8f2-4877-ba0a-fd2b6645fb94"));
interface IWICBitmapFrameEncode : IUnknown
{
extern(Windows):
    HRESULT Initialize( 
        /* [unique][in] */ IPropertyBag2 pIEncoderOptions);
    
    HRESULT SetSize( 
        /* [in] */ UINT uiWidth,
        /* [in] */ UINT uiHeight);
    
    HRESULT SetResolution( 
        /* [in] */ double dpiX,
        /* [in] */ double dpiY);
    
    HRESULT SetPixelFormat( 
        /* [out][in] */ WICPixelFormatGUID* pPixelFormat);
    
    HRESULT SetColorContexts( 
        /* [in] */ UINT cCount,
        /* [size_is][in] */ IWICColorContext* ppIColorContext);
    
    HRESULT SetPalette( 
        /* [in] */ IWICPalette pIPalette);
    
    HRESULT SetThumbnail( 
        /* [in] */ IWICBitmapSource pIThumbnail);
    
    HRESULT WritePixels( 
        /* [in] */ UINT lineCount,
        /* [in] */ UINT cbStride,
        /* [in] */ UINT cbBufferSize,
        /* [size_is][in] */ BYTE* pbPixels);
    
    HRESULT WriteSource( 
        /* [in] */ IWICBitmapSource pIBitmapSource,
        /* [unique][in] */ WICRect* prc);
    
    HRESULT Commit();
    
    HRESULT GetMetadataQueryWriter( 
        /* [out] */ IWICMetadataQueryWriter* ppIMetadataQueryWriter);
    
}
    
mixin(uuid!(IWICPlanarBitmapFrameEncode, "F928B7B8-2221-40C1-B72E-7E82F1974D1A"));
interface IWICPlanarBitmapFrameEncode : IUnknown
{
extern(Windows):
    HRESULT WritePixels( 
        UINT lineCount,
        /* [size_is][in] */ WICBitmapPlane* pPlanes,
        UINT cPlanes);
    
    HRESULT WriteSource( 
        /* [size_is][in] */ IWICBitmapSource* ppPlanes,
        UINT cPlanes,
        /* [unique][in] */ WICRect* prcSource);
    
}
    
mixin(uuid!(IWICImageEncoder, "04C75BF8-3CE1-473B-ACC5-3CC4F5E94999"));
interface IWICImageEncoder : IUnknown
{
extern(Windows):
    HRESULT WriteFrame( 
        /* [in] */ ID2D1Image pImage,
        /* [in] */ IWICBitmapFrameEncode pFrameEncode,
        /* [unique][in] */ const(WICImageParameters)* pImageParameters);
    
    HRESULT WriteFrameThumbnail( 
        /* [in] */ ID2D1Image pImage,
        /* [in] */ IWICBitmapFrameEncode pFrameEncode,
        /* [unique][in] */ const(WICImageParameters)* pImageParameters);
    
    HRESULT WriteThumbnail( 
        /* [in] */ ID2D1Image pImage,
        /* [in] */ IWICBitmapEncoder pEncoder,
        /* [unique][in] */ const(WICImageParameters)* pImageParameters);
    
}
    
mixin(uuid!(IWICBitmapDecoder, "9EDDE9E7-8DEE-47ea-99DF-E6FAF2ED44BF"));
interface IWICBitmapDecoder : IUnknown
{
extern(Windows):
    HRESULT QueryCapability( 
        /* [in] */ IStream pIStream,
        /* [out] */ DWORD* pdwCapability);
    
    HRESULT Initialize( 
        /* [in] */ IStream pIStream,
        /* [in] */ WICDecodeOptions cacheOptions);
    
    HRESULT GetContainerFormat( 
        /* [out] */ GUID* pguidContainerFormat);
    
    HRESULT GetDecoderInfo( 
        /* [out] */ IWICBitmapDecoderInfo* ppIDecoderInfo);
    
    HRESULT CopyPalette( 
        /* [in] */ IWICPalette pIPalette);
    
    HRESULT GetMetadataQueryReader( 
        /* [out] */ IWICMetadataQueryReader* ppIMetadataQueryReader);
    
    HRESULT GetPreview( 
        /* [out] */ IWICBitmapSource* ppIBitmapSource);
    
    HRESULT GetColorContexts( 
        /* [in] */ UINT cCount,
        /* [size_is][unique][out][in] */ IWICColorContext* ppIColorContexts,
        /* [out] */ UINT* pcActualCount);
    
    HRESULT GetThumbnail( 
        /* [out] */ IWICBitmapSource* ppIThumbnail);
    
    HRESULT GetFrameCount( 
        /* [out] */ UINT* pCount);
    
    HRESULT GetFrame( 
        /* [in] */ UINT index,
        /* [out] */ IWICBitmapFrameDecode* ppIBitmapFrame);
    
}
    
mixin(uuid!(IWICBitmapSourceTransform, "3B16811B-6A43-4ec9-B713-3D5A0C13B940"));
interface IWICBitmapSourceTransform : IUnknown
{
extern(Windows):
    HRESULT CopyPixels( 
        /* [unique][in] */ const(WICRect)* prc,
        /* [in] */ UINT uiWidth,
        /* [in] */ UINT uiHeight,
        /* [unique][in] */ WICPixelFormatGUID* pguidDstFormat,
        /* [in] */ WICBitmapTransformOptions dstTransform,
        /* [in] */ UINT nStride,
        /* [in] */ UINT cbBufferSize,
        /* [size_is][out] */ BYTE* pbBuffer);
    
    HRESULT GetClosestSize( 
        /* [out][in] */ UINT* puiWidth,
        /* [out][in] */ UINT* puiHeight);
    
    HRESULT GetClosestPixelFormat( 
        /* [out][in] */ WICPixelFormatGUID* pguidDstFormat);
    
    HRESULT DoesSupportTransform( 
        /* [in] */ WICBitmapTransformOptions dstTransform,
        /* [out] */ BOOL* pfIsSupported);
    
}
    
mixin(uuid!(IWICPlanarBitmapSourceTransform, "3AFF9CCE-BE95-4303-B927-E7D16FF4A613"));
interface IWICPlanarBitmapSourceTransform : IUnknown
{
extern(Windows):
    HRESULT DoesSupportTransform( 
        /* [out][in] */ UINT* puiWidth,
        /* [out][in] */ UINT* puiHeight,
        WICBitmapTransformOptions dstTransform,
        WICPlanarOptions dstPlanarOptions,
        /* [size_is][in] */ const(WICPixelFormatGUID)* pguidDstFormats,
        /* [size_is][out] */ WICBitmapPlaneDescription* pPlaneDescriptions,
        UINT cPlanes,
        /* [out] */ BOOL* pfIsSupported);
    
    HRESULT CopyPixels( 
        /* [unique][in] */ const(WICRect)* prcSource,
        UINT uiWidth,
        UINT uiHeight,
        WICBitmapTransformOptions dstTransform,
        WICPlanarOptions dstPlanarOptions,
        /* [size_is][in] */ const(WICBitmapPlane)* pDstPlanes,
        UINT cPlanes);
    
}
    
mixin(uuid!(IWICBitmapFrameDecode, "3B16811B-6A43-4ec9-A813-3D930C13B940"));
interface IWICBitmapFrameDecode : IWICBitmapSource
{
extern(Windows):
    HRESULT GetMetadataQueryReader( 
        /* [out] */ IWICMetadataQueryReader* ppIMetadataQueryReader);
    
    HRESULT GetColorContexts( 
        /* [in] */ UINT cCount,
        /* [size_is][unique][out][in] */ IWICColorContext* ppIColorContexts,
        /* [out] */ UINT* pcActualCount);
    
    HRESULT GetThumbnail( 
        /* [out] */ IWICBitmapSource* ppIThumbnail);
    
}
    
mixin(uuid!(IWICProgressiveLevelControl, "DAAC296F-7AA5-4dbf-8D15-225C5976F891"));
interface IWICProgressiveLevelControl : IUnknown
{
extern(Windows):
    HRESULT GetLevelCount( 
        /* [retval][out] */ UINT* pcLevels);
    
    HRESULT GetCurrentLevel( 
        /* [retval][out] */ UINT* pnLevel);
    
    HRESULT SetCurrentLevel( 
        /* [in] */ UINT nLevel);
    
}
    
mixin(uuid!(IWICProgressCallback, "4776F9CD-9517-45FA-BF24-E89C5EC5C60C"));
interface IWICProgressCallback : IUnknown
{
extern(Windows):
    HRESULT Notify( 
        /* [in] */ ULONG uFrameNum,
        /* [in] */ WICProgressOperation operation,
        /* [in] */ double dblProgress);
    
}
    
alias PFNProgressNotification = extern(Windows) HRESULT function(LPVOID pvData, ULONG uFrameNum, WICProgressOperation operation, double dblProgress);

mixin(uuid!(IWICBitmapCodecProgressNotification, "64C1024E-C3CF-4462-8078-88C2B11C46D9"));
interface IWICBitmapCodecProgressNotification : IUnknown
{
extern(Windows):
    /* [local] */ HRESULT RegisterProgressNotification( 
        /* [annotation][unique][in] */ 
        PFNProgressNotification pfnProgressNotification,
        /* [annotation][unique][in] */ 
        LPVOID pvData,
        /* [in] */ DWORD dwProgressFlags);
    
}

mixin(uuid!(IWICComponentInfo, "23BC3F0A-698B-4357-886B-F24D50671334"));
interface IWICComponentInfo : IUnknown
{
extern(Windows):
    HRESULT GetComponentType( 
        /* [out] */ WICComponentType* pType);
    
    HRESULT GetCLSID( 
        /* [out] */ CLSID* pclsid);
    
    HRESULT GetSigningStatus( 
        /* [out] */ DWORD* pStatus);
    
    HRESULT GetAuthor( 
        /* [in] */ UINT cchAuthor,
        /* [size_is][unique][out][in] */ WCHAR* wzAuthor,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetVendorGUID( 
        /* [out] */ GUID* pguidVendor);
    
    HRESULT GetVersion( 
        /* [in] */ UINT cchVersion,
        /* [size_is][unique][out][in] */ WCHAR* wzVersion,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetSpecVersion( 
        /* [in] */ UINT cchSpecVersion,
        /* [size_is][unique][out][in] */ WCHAR* wzSpecVersion,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetFriendlyName( 
        /* [in] */ UINT cchFriendlyName,
        /* [size_is][unique][out][in] */ WCHAR* wzFriendlyName,
        /* [out] */ UINT* pcchActual);
    
}
    
mixin(uuid!(IWICFormatConverterInfo, "9F34FB65-13F4-4f15-BC57-3726B5E53D9F"));
interface IWICFormatConverterInfo : IWICComponentInfo
{
extern(Windows):
    HRESULT GetPixelFormats( 
        /* [in] */ UINT cFormats,
        /* [size_is][unique][out][in] */ WICPixelFormatGUID* pPixelFormatGUIDs,
        /* [out] */ UINT* pcActual);
    
    HRESULT CreateInstance( 
        /* [out] */ IWICFormatConverter* ppIConverter);
    
}
    
mixin(uuid!(IWICBitmapCodecInfo, "E87A44C4-B76E-4c47-8B09-298EB12A2714"));
interface IWICBitmapCodecInfo : IWICComponentInfo
{
extern(Windows):
    HRESULT GetContainerFormat( 
        /* [out] */ GUID* pguidContainerFormat);
    
    HRESULT GetPixelFormats( 
        /* [in] */ UINT cFormats,
        /* [size_is][unique][out][in] */ GUID* pguidPixelFormats,
        /* [out] */ UINT* pcActual);
    
    HRESULT GetColorManagementVersion( 
        /* [in] */ UINT cchColorManagementVersion,
        /* [size_is][unique][out][in] */ WCHAR* wzColorManagementVersion,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetDeviceManufacturer( 
        /* [in] */ UINT cchDeviceManufacturer,
        /* [size_is][unique][out][in] */ WCHAR* wzDeviceManufacturer,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetDeviceModels( 
        /* [in] */ UINT cchDeviceModels,
        /* [size_is][unique][out][in] */ WCHAR* wzDeviceModels,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetMimeTypes( 
        /* [in] */ UINT cchMimeTypes,
        /* [size_is][unique][out][in] */ WCHAR* wzMimeTypes,
        /* [out] */ UINT* pcchActual);
    
    HRESULT GetFileExtensions( 
        /* [in] */ UINT cchFileExtensions,
        /* [size_is][unique][out][in] */ WCHAR* wzFileExtensions,
        /* [out] */ UINT* pcchActual);
    
    HRESULT DoesSupportAnimation( 
        /* [out] */ BOOL* pfSupportAnimation);
    
    HRESULT DoesSupportChromakey( 
        /* [out] */ BOOL* pfSupportChromakey);
    
    HRESULT DoesSupportLossless( 
        /* [out] */ BOOL* pfSupportLossless);
    
    HRESULT DoesSupportMultiframe( 
        /* [out] */ BOOL* pfSupportMultiframe);
    
    HRESULT MatchesMimeType( 
        /* [in] */ LPCWSTR wzMimeType,
        /* [out] */ BOOL* pfMatches);
    
}
    
mixin(uuid!(IWICBitmapEncoderInfo, "94C9B4EE-A09F-4f92-8A1E-4A9BCE7E76FB"));
interface IWICBitmapEncoderInfo : IWICBitmapCodecInfo
{
extern(Windows):
    HRESULT CreateInstance(
        /* [out] */ IWICBitmapEncoder* ppIBitmapEncoder);
    
}
    
mixin(uuid!(IWICBitmapDecoderInfo, "D8CD007F-D08F-4191-9BFC-236EA7F0E4B5"));
interface IWICBitmapDecoderInfo : IWICBitmapCodecInfo
{
extern(Windows):
    /* [local] */ HRESULT GetPatterns( 
        /* [in] */ UINT cbSizePatterns,
        /* [annotation][unique][size_is][out] */ 
        WICBitmapPattern* pPatterns,
        /* [annotation][unique][out] */ 
        UINT* pcPatterns,
        /* [annotation][out] */ 
        UINT* pcbPatternsActual);
    
    HRESULT MatchesPattern( 
        /* [in] */ IStream pIStream,
        /* [out] */ BOOL* pfMatches);
    
    HRESULT CreateInstance( 
        /* [out] */ IWICBitmapDecoder* ppIBitmapDecoder);
    
}


mixin(uuid!(IWICPixelFormatInfo, "E8EDA601-3D48-431a-AB44-69059BE88BBE"));
interface IWICPixelFormatInfo : IWICComponentInfo
{
extern(Windows):
    HRESULT GetFormatGUID( 
        /* [out] */ GUID* pFormat);
    
    HRESULT GetColorContext( 
        /* [out] */ IWICColorContext* ppIColorContext);
    
    HRESULT GetBitsPerPixel( 
        /* [out] */ UINT* puiBitsPerPixel);
    
    HRESULT GetChannelCount( 
        /* [out] */ UINT* puiChannelCount);
    
    HRESULT GetChannelMask( 
        /* [in] */ UINT uiChannelIndex,
        /* [in] */ UINT cbMaskBuffer,
        /* [size_is][unique][out][in] */ BYTE* pbMaskBuffer,
        /* [out] */ UINT* pcbActual);
    
}
    
mixin(uuid!(IWICPixelFormatInfo2, "A9DB33A2-AF5F-43C7-B679-74F5984B5AA4"));
interface IWICPixelFormatInfo2 : IWICPixelFormatInfo
{
extern(Windows):
    HRESULT SupportsTransparency( 
        /* [out] */ BOOL* pfSupportsTransparency);
    
    HRESULT GetNumericRepresentation( 
        /* [out] */ WICPixelFormatNumericRepresentation* pNumericRepresentation);
    
}
    
mixin(uuid!(IWICImagingFactory, "ec5ec8a9-c395-4314-9c77-54d7a935ff70"));
interface IWICImagingFactory : IUnknown
{
extern(Windows):
    HRESULT CreateDecoderFromFilename( 
        /* [in] */ LPCWSTR wzFilename,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [in] */ DWORD dwDesiredAccess,
        /* [in] */ WICDecodeOptions metadataOptions,
        /* [retval][out] */ IWICBitmapDecoder* ppIDecoder);
    
    HRESULT CreateDecoderFromStream( 
        /* [in] */ IStream pIStream,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [in] */ WICDecodeOptions metadataOptions,
        /* [retval][out] */ IWICBitmapDecoder* ppIDecoder);
    
    HRESULT CreateDecoderFromFileHandle( 
        /* [in] */ ULONG_PTR hFile,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [in] */ WICDecodeOptions metadataOptions,
        /* [retval][out] */ IWICBitmapDecoder* ppIDecoder);
    
    HRESULT CreateComponentInfo( 
        /* [in] */ REFCLSID clsidComponent,
        /* [out] */ IWICComponentInfo* ppIInfo);
    
    HRESULT CreateDecoder( 
        /* [in] */ REFGUID guidContainerFormat,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [retval][out] */ IWICBitmapDecoder* ppIDecoder);
    
    HRESULT CreateEncoder( 
        /* [in] */ REFGUID guidContainerFormat,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [retval][out] */ IWICBitmapEncoder* ppIEncoder);
    
    HRESULT CreatePalette( 
        /* [out] */ IWICPalette* ppIPalette);
    
    HRESULT CreateFormatConverter( 
        /* [out] */ IWICFormatConverter* ppIFormatConverter);
    
    HRESULT CreateBitmapScaler( 
        /* [out] */ IWICBitmapScaler* ppIBitmapScaler);
    
    HRESULT CreateBitmapClipper( 
        /* [out] */ IWICBitmapClipper* ppIBitmapClipper);
    
    HRESULT CreateBitmapFlipRotator( 
        /* [out] */ IWICBitmapFlipRotator* ppIBitmapFlipRotator);
    
    HRESULT CreateStream( 
        /* [out] */ IWICStream* ppIWICStream);
    
    HRESULT CreateColorContext( 
        /* [out] */ IWICColorContext* ppIWICColorContext);
    
    HRESULT CreateColorTransformer( 
        /* [out] */ IWICColorTransform* ppIWICColorTransform);
    
    HRESULT CreateBitmap( 
        /* [in] */ UINT uiWidth,
        /* [in] */ UINT uiHeight,
        /* [in] */ REFWICPixelFormatGUID pixelFormat,
        /* [in] */ WICBitmapCreateCacheOption option,
        /* [out] */ IWICBitmap* ppIBitmap);
    
    HRESULT CreateBitmapFromSource( 
        /* [in] */ IWICBitmapSource pIBitmapSource,
        /* [in] */ WICBitmapCreateCacheOption option,
        /* [out] */ IWICBitmap* ppIBitmap);
    
    HRESULT CreateBitmapFromSourceRect( 
        /* [in] */ IWICBitmapSource pIBitmapSource,
        /* [in] */ UINT x,
        /* [in] */ UINT y,
        /* [in] */ UINT width,
        /* [in] */ UINT height,
        /* [out] */ IWICBitmap* ppIBitmap);
    
    HRESULT CreateBitmapFromMemory( 
        /* [in] */ UINT uiWidth,
        /* [in] */ UINT uiHeight,
        /* [in] */ REFWICPixelFormatGUID pixelFormat,
        /* [in] */ UINT cbStride,
        /* [in] */ UINT cbBufferSize,
        /* [size_is][in] */ BYTE* pbBuffer,
        /* [out] */ IWICBitmap* ppIBitmap);
    
    HRESULT CreateBitmapFromHBITMAP( 
        /* [in] */ HBITMAP hBitmap,
        /* [unique][in] */ HPALETTE hPalette,
        /* [in] */ WICBitmapAlphaChannelOption options,
        /* [out] */ IWICBitmap* ppIBitmap);
    
    HRESULT CreateBitmapFromHICON( 
        /* [in] */ HICON hIcon,
        /* [out] */ IWICBitmap* ppIBitmap);
    
    HRESULT CreateComponentEnumerator( 
        /* [in] */ DWORD componentTypes,
        /* [in] */ DWORD options,
        /* [out] */ IEnumUnknown* ppIEnumUnknown);
    
    HRESULT CreateFastMetadataEncoderFromDecoder( 
        /* [in] */ IWICBitmapDecoder pIDecoder,
        /* [out] */ IWICFastMetadataEncoder* ppIFastEncoder);
    
    HRESULT CreateFastMetadataEncoderFromFrameDecode( 
        /* [in] */ IWICBitmapFrameDecode pIFrameDecoder,
        /* [out] */ IWICFastMetadataEncoder* ppIFastEncoder);
    
    HRESULT CreateQueryWriter( 
        /* [in] */ REFGUID guidMetadataFormat,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [out] */ IWICMetadataQueryWriter* ppIQueryWriter);
    
    HRESULT CreateQueryWriterFromReader( 
        /* [in] */ IWICMetadataQueryReader pIQueryReader,
        /* [unique][in] */ const(GUID)* pguidVendor,
        /* [out] */ IWICMetadataQueryWriter* ppIQueryWriter);
    
}
    
mixin(uuid!(IWICImagingFactory2, "7B816B45-1996-4476-B132-DE9E247C8AF0"));
interface IWICImagingFactory2 : IWICImagingFactory
{
extern(Windows):
    HRESULT CreateImageEncoder( 
        /* [in] */ ID2D1Device pD2DDevice,
        /* [out] */ IWICImageEncoder* ppWICImageEncoder);
    
}
    
extern(Windows)
{
    HRESULT WICConvertBitmapSource(
        REFWICPixelFormatGUID dstFormat, // Destination pixel format
        IWICBitmapSource  pISrc,    // Source bitmap
        IWICBitmapSource* ppIDst   // Destination bitmap, a copy or addrefed source
        );
    HRESULT WICCreateBitmapFromSection(
        UINT width,
        UINT height,
        REFWICPixelFormatGUID pixelFormat,
        HANDLE hSection,
        UINT stride,
        UINT offset,
        IWICBitmap* ppIBitmap
        );
    HRESULT WICCreateBitmapFromSectionEx(
        UINT width,
        UINT height,
        REFWICPixelFormatGUID pixelFormat,
        HANDLE hSection,
        UINT stride,
        UINT offset,
        WICSectionAccessLevel desiredAccessLevel,
        IWICBitmap* ppIBitmap
        );
    HRESULT WICMapGuidToShortName(
        REFGUID guid,
        UINT cchName,
        WCHAR* wzName,
        UINT* pcchActual
    );
    HRESULT WICMapShortNameToGuid(
        PCWSTR wzName,
        GUID* pguid
    );
    HRESULT WICMapSchemaToName(
        REFGUID guidMetadataFormat,
        LPWSTR pwzSchema,
        UINT cchName,
        WCHAR* wzName,
        UINT* pcchActual
        );
}
enum FACILITY_WINCODEC_ERR = 0x898;
enum WINCODEC_ERR_BASE = 0x2000;
pure MAKE_WINCODECHR(bool sev, uint code) { return MAKE_HRESULT(sev, FACILITY_WINCODEC_ERR, (WINCODEC_ERR_BASE + code)); }
pure MAKE_WINCODECHR_ERR(uint code) { return MAKE_WINCODECHR(true, code); }
enum WINCODEC_ERR_GENERIC_ERROR                    = E_FAIL;
enum WINCODEC_ERR_INVALIDPARAMETER                 = E_INVALIDARG;
enum WINCODEC_ERR_OUTOFMEMORY                      = E_OUTOFMEMORY;
enum WINCODEC_ERR_NOTIMPLEMENTED                   = E_NOTIMPL;
enum WINCODEC_ERR_ABORTED                          = E_ABORT;
enum WINCODEC_ERR_ACCESSDENIED                     = E_ACCESSDENIED;
enum WINCODEC_ERR_VALUEOVERFLOW                    = INTSAFE_E_ARITHMETIC_OVERFLOW;
/* [public] */ 
alias WICTiffCompressionOption = uint;
enum : WICTiffCompressionOption
    {
        WICTiffCompressionDontCare	= 0,
        WICTiffCompressionNone	= 0x1,
        WICTiffCompressionCCITT3	= 0x2,
        WICTiffCompressionCCITT4	= 0x3,
        WICTiffCompressionLZW	= 0x4,
        WICTiffCompressionRLE	= 0x5,
        WICTiffCompressionZIP	= 0x6,
        WICTiffCompressionLZWHDifferencing	= 0x7
    }

/* [public] */ 
alias WICJpegYCrCbSubsamplingOption = uint;
enum : WICJpegYCrCbSubsamplingOption
    {
        WICJpegYCrCbSubsamplingDefault	= 0,
        WICJpegYCrCbSubsampling420	= 0x1,
        WICJpegYCrCbSubsampling422	= 0x2,
        WICJpegYCrCbSubsampling444	= 0x3,
        WICJpegYCrCbSubsampling440	= 0x4
    }

/* [public] */ 
alias WICPngFilterOption = uint;
enum : WICPngFilterOption
    {
        WICPngFilterUnspecified	= 0,
        WICPngFilterNone	= 0x1,
        WICPngFilterSub	= 0x2,
        WICPngFilterUp	= 0x3,
        WICPngFilterAverage	= 0x4,
        WICPngFilterPaeth	= 0x5,
        WICPngFilterAdaptive	= 0x6
    }

/* [public] */ 
alias WICNamedWhitePoint = uint;
enum : WICNamedWhitePoint
    {
        WICWhitePointDefault	= 0x1,
        WICWhitePointDaylight	= 0x2,
        WICWhitePointCloudy	= 0x4,
        WICWhitePointShade	= 0x8,
        WICWhitePointTungsten	= 0x10,
        WICWhitePointFluorescent	= 0x20,
        WICWhitePointFlash	= 0x40,
        WICWhitePointUnderwater	= 0x80,
        WICWhitePointCustom	= 0x100,
        WICWhitePointAutoWhiteBalance	= 0x200,
        WICWhitePointAsShot	= WICWhitePointDefault
    }

/* [public] */ 
alias WICRawCapabilities = uint;
enum : WICRawCapabilities
    {
        WICRawCapabilityNotSupported	= 0,
        WICRawCapabilityGetSupported	= 0x1,
        WICRawCapabilityFullySupported	= 0x2
    }

/* [public] */ 
alias WICRawRotationCapabilities = uint;
enum : WICRawRotationCapabilities
    {
        WICRawRotationCapabilityNotSupported	= 0,
        WICRawRotationCapabilityGetSupported	= 0x1,
        WICRawRotationCapabilityNinetyDegreesSupported	= 0x2,
        WICRawRotationCapabilityFullySupported	= 0x3
    }

/* [public] */ struct WICRawCapabilitiesInfo
    {
    UINT cbSize;
    UINT CodecMajorVersion;
    UINT CodecMinorVersion;
    WICRawCapabilities ExposureCompensationSupport;
    WICRawCapabilities ContrastSupport;
    WICRawCapabilities RGBWhitePointSupport;
    WICRawCapabilities NamedWhitePointSupport;
    UINT NamedWhitePointSupportMask;
    WICRawCapabilities KelvinWhitePointSupport;
    WICRawCapabilities GammaSupport;
    WICRawCapabilities TintSupport;
    WICRawCapabilities SaturationSupport;
    WICRawCapabilities SharpnessSupport;
    WICRawCapabilities NoiseReductionSupport;
    WICRawCapabilities DestinationColorProfileSupport;
    WICRawCapabilities ToneCurveSupport;
    WICRawRotationCapabilities RotationSupport;
    WICRawCapabilities RenderModeSupport;
    }

/* [public] */ 
alias WICRawParameterSet = uint;
enum : WICRawParameterSet
    {
        WICAsShotParameterSet	= 0x1,
        WICUserAdjustedParameterSet	= 0x2,
        WICAutoAdjustedParameterSet	= 0x3
    }

/* [public] */ 
alias WICRawRenderMode = uint;
enum : WICRawRenderMode
    {
        WICRawRenderModeDraft	= 0x1,
        WICRawRenderModeNormal	= 0x2,
        WICRawRenderModeBestQuality	= 0x3
    }

/* [public] */ struct WICRawToneCurvePoint
    {
    double Input;
    double Output;
    }

/* [public] */ struct WICRawToneCurve
    {
    UINT cPoints;
    WICRawToneCurvePoint[1] aPoints;
    }

enum WICRawChangeNotification_ExposureCompensation       = 0x00000001;
enum WICRawChangeNotification_NamedWhitePoint            = 0x00000002;
enum WICRawChangeNotification_KelvinWhitePoint           = 0x00000004;
enum WICRawChangeNotification_RGBWhitePoint              = 0x00000008;
enum WICRawChangeNotification_Contrast                   = 0x00000010;
enum WICRawChangeNotification_Gamma                      = 0x00000020;
enum WICRawChangeNotification_Sharpness                  = 0x00000040;
enum WICRawChangeNotification_Saturation                 = 0x00000080;
enum WICRawChangeNotification_Tint                       = 0x00000100;
enum WICRawChangeNotification_NoiseReduction             = 0x00000200;
enum WICRawChangeNotification_DestinationColorContext    = 0x00000400;
enum WICRawChangeNotification_ToneCurve                  = 0x00000800;
enum WICRawChangeNotification_Rotation                   = 0x00001000;
enum WICRawChangeNotification_RenderMode                 = 0x00002000;

mixin(uuid!(IWICDevelopRawNotificationCallback, "95c75a6e-3e8c-4ec2-85a8-aebcc551e59b"));
interface IWICDevelopRawNotificationCallback : IUnknown
{
extern(Windows):
    HRESULT Notify( 
        /* [in] */ UINT NotificationMask);
    
}
    
mixin(uuid!(IWICDevelopRaw, "fbec5e44-f7be-4b65-b7f8-c0c81fef026d"));
interface IWICDevelopRaw : IWICBitmapFrameDecode
{
extern(Windows):
    /* [local] */ HRESULT QueryRawCapabilitiesInfo( 
        /* [out][in] */ WICRawCapabilitiesInfo* pInfo);
    
    HRESULT LoadParameterSet( 
        /* [in] */ WICRawParameterSet ParameterSet);
    
    HRESULT GetCurrentParameterSet( 
        /* [out] */ IPropertyBag2* ppCurrentParameterSet);
    
    HRESULT SetExposureCompensation( 
        /* [in] */ double ev);
    
    HRESULT GetExposureCompensation( 
        /* [out] */ double* pEV);
    
    HRESULT SetWhitePointRGB( 
        /* [in] */ UINT Red,
        /* [in] */ UINT Green,
        /* [in] */ UINT Blue);
    
    HRESULT GetWhitePointRGB( 
        /* [out] */ UINT* pRed,
        /* [out] */ UINT* pGreen,
        /* [out] */ UINT* pBlue);
    
    HRESULT SetNamedWhitePoint( 
        /* [in] */ WICNamedWhitePoint WhitePoint);
    
    HRESULT GetNamedWhitePoint( 
        /* [out] */ WICNamedWhitePoint* pWhitePoint);
    
    HRESULT SetWhitePointKelvin( 
        /* [in] */ UINT WhitePointKelvin);
    
    HRESULT GetWhitePointKelvin( 
        /* [out] */ UINT* pWhitePointKelvin);
    
    HRESULT GetKelvinRangeInfo( 
        /* [out] */ UINT* pMinKelvinTemp,
        /* [out] */ UINT* pMaxKelvinTemp,
        /* [out] */ UINT* pKelvinTempStepValue);
    
    HRESULT SetContrast( 
        /* [in] */ double Contrast);
    
    HRESULT GetContrast( 
        /* [out] */ double* pContrast);
    
    HRESULT SetGamma( 
        /* [in] */ double Gamma);
    
    HRESULT GetGamma( 
        /* [out] */ double* pGamma);
    
    HRESULT SetSharpness( 
        /* [in] */ double Sharpness);
    
    HRESULT GetSharpness( 
        /* [out] */ double* pSharpness);
    
    HRESULT SetSaturation( 
        /* [in] */ double Saturation);
    
    HRESULT GetSaturation( 
        /* [out] */ double* pSaturation);
    
    HRESULT SetTint( 
        /* [in] */ double Tint);
    
    HRESULT GetTint( 
        /* [out] */ double* pTint);
    
    HRESULT SetNoiseReduction( 
        /* [in] */ double NoiseReduction);
    
    HRESULT GetNoiseReduction( 
        /* [out] */ double* pNoiseReduction);
    
    HRESULT SetDestinationColorContext( 
        /* [unique][in] */ IWICColorContext pColorContext);
    
    /* [local] */ HRESULT SetToneCurve( 
        /* [in] */ UINT cbToneCurveSize,
        /* [annotation][in] */ 
        const(WICRawToneCurve)* pToneCurve);
    
    /* [local] */ HRESULT GetToneCurve( 
        /* [in] */ UINT cbToneCurveBufferSize,
        /* [annotation][unique][out] */ 
        WICRawToneCurve* pToneCurve,
        /* [annotation][unique][out] */ 
        UINT* pcbActualToneCurveBufferSize);
    
    HRESULT SetRotation( 
        /* [in] */ double Rotation);
    
    HRESULT GetRotation( 
        /* [out] */ double* pRotation);
    
    HRESULT SetRenderMode( 
        /* [in] */ WICRawRenderMode RenderMode);
    
    HRESULT GetRenderMode( 
        /* [out] */ WICRawRenderMode* pRenderMode);
    
    HRESULT SetNotificationCallback( 
        /* [unique][in] */ IWICDevelopRawNotificationCallback pCallback);
    
}


/* interface __MIDL_itf_wincodec_0000_0038 */
/* [local] */ 

/* [public] */ 
alias WICDdsDimension = uint;
enum : WICDdsDimension
    {
        WICDdsTexture1D	= 0,
        WICDdsTexture2D	= 0x1,
        WICDdsTexture3D	= 0x2,
        WICDdsTextureCube	= 0x3
    }

/* [public] */ 
alias WICDdsAlphaMode = uint;
enum : WICDdsAlphaMode
    {
        WICDdsAlphaModeUnknown	= 0,
        WICDdsAlphaModeStraight	= 0x1,
        WICDdsAlphaModePremultiplied	= 0x2,
        WICDdsAlphaModeOpaque	= 0x3,
        WICDdsAlphaModeCustom	= 0x4
    }

/* [public] */ struct WICDdsParameters
    {
    UINT Width;
    UINT Height;
    UINT Depth;
    UINT MipLevels;
    UINT ArraySize;
    DXGI_FORMAT DxgiFormat;
    WICDdsDimension Dimension;
    WICDdsAlphaMode AlphaMode;
    }

mixin(uuid!(IWICDdsDecoder, "409cd537-8532-40cb-9774-e2feb2df4e9c"));
interface IWICDdsDecoder : IUnknown
{
extern(Windows):
    HRESULT GetParameters( 
        /* [out] */ WICDdsParameters* pParameters);
    
    HRESULT GetFrame( 
        /* [in] */ UINT arrayIndex,
        /* [in] */ UINT mipLevel,
        /* [in] */ UINT sliceIndex,
        /* [retval][out] */ IWICBitmapFrameDecode* ppIBitmapFrame);
    
}
    
mixin(uuid!(IWICDdsEncoder, "5cacdb4c-407e-41b3-b936-d0f010cd6732"));
interface IWICDdsEncoder : IUnknown
{
extern(Windows):
    HRESULT SetParameters( 
        /* [in] */ WICDdsParameters* pParameters);
    
    HRESULT GetParameters( 
        /* [out] */ WICDdsParameters* pParameters);
    
    HRESULT CreateNewFrame( 
        /* [out] */ IWICBitmapFrameEncode* ppIFrameEncode,
        /* [optional][out] */ UINT* pArrayIndex,
        /* [optional][out] */ UINT* pMipLevel,
        /* [optional][out] */ UINT* pSliceIndex);
    
}
    
/* [public] */ struct WICDdsFormatInfo
    {
    DXGI_FORMAT DxgiFormat;
    UINT BytesPerBlock;
    UINT BlockWidth;
    UINT BlockHeight;
    }

mixin(uuid!(IWICDdsFrameDecode, "3d4c0c61-18a4-41e4-bd80-481a4fc9f464"));
interface IWICDdsFrameDecode : IUnknown
{
extern(Windows):
    HRESULT GetSizeInBlocks( 
        /* [out] */ UINT* pWidthInBlocks,
        /* [out] */ UINT* pHeightInBlocks);
    
    HRESULT GetFormatInfo( 
        /* [out] */ WICDdsFormatInfo* pFormatInfo);
    
    HRESULT CopyBlocks( 
        /* [unique][in] */ const(WICRect)* prcBoundsInBlocks,
        /* [in] */ UINT cbStride,
        /* [in] */ UINT cbBufferSize,
        /* [size_is][out] */ BYTE* pbBuffer);
    
}
    
mixin(uuid!(IWICJpegFrameDecode, "8939F66E-C46A-4c21-A9D1-98B327CE1679"));
interface IWICJpegFrameDecode : IUnknown
{
extern(Windows):
    HRESULT DoesSupportIndexing( 
        /* [out] */ BOOL* pfIndexingSupported);
    
    HRESULT SetIndexing( 
        WICJpegIndexingOptions options,
        UINT horizontalIntervalSize);
    
    HRESULT ClearIndexing();
    
    HRESULT GetAcHuffmanTable( 
        UINT scanIndex,
        /* [range] */ UINT tableIndex,
        /* [out] */ DXGI_JPEG_AC_HUFFMAN_TABLE* pAcHuffmanTable);
    
    HRESULT GetDcHuffmanTable( 
        UINT scanIndex,
        /* [range] */ UINT tableIndex,
        /* [out] */ DXGI_JPEG_DC_HUFFMAN_TABLE* pDcHuffmanTable);
    
    HRESULT GetQuantizationTable( 
        UINT scanIndex,
        /* [range] */ UINT tableIndex,
        /* [out] */ DXGI_JPEG_QUANTIZATION_TABLE* pQuantizationTable);
    
    HRESULT GetFrameHeader( 
        /* [out] */ WICJpegFrameHeader* pFrameHeader);
    
    HRESULT GetScanHeader( 
        UINT scanIndex,
        /* [out] */ WICJpegScanHeader* pScanHeader);
    
    HRESULT CopyScan( 
        UINT scanIndex,
        UINT scanOffset,
        /* [in] */ UINT cbScanData,
        /* [length_is][size_is][out] */ BYTE* pbScanData,
        /* [out] */ UINT* pcbScanDataActual);
    
    HRESULT CopyMinimalStream( 
        UINT streamOffset,
        /* [in] */ UINT cbStreamData,
        /* [length_is][size_is][out] */ BYTE* pbStreamData,
        /* [out] */ UINT* pcbStreamDataActual);
    
}
    
mixin(uuid!(IWICJpegFrameEncode, "2F0C601F-D2C6-468C-ABFA-49495D983ED1"));
interface IWICJpegFrameEncode : IUnknown
{
extern(Windows):
    HRESULT GetAcHuffmanTable( 
        UINT scanIndex,
        /* [range] */ UINT tableIndex,
        /* [out] */ DXGI_JPEG_AC_HUFFMAN_TABLE* pAcHuffmanTable);
    
    HRESULT GetDcHuffmanTable( 
        UINT scanIndex,
        /* [range] */ UINT tableIndex,
        /* [out] */ DXGI_JPEG_DC_HUFFMAN_TABLE* pDcHuffmanTable);
    
    HRESULT GetQuantizationTable( 
        UINT scanIndex,
        /* [range] */ UINT tableIndex,
        /* [out] */ DXGI_JPEG_QUANTIZATION_TABLE* pQuantizationTable);
    
    HRESULT WriteScan( 
        /* [in] */ UINT cbScanData,
        /* [size_is][in] */ const(BYTE)* pbScanData);
    
}

extern(Windows)
{
    import core.stdc.config : c_ulong;

c_ulong              BSTR_UserSize(     c_ulong *, c_ulong            , BSTR * ); 
byte *  BSTR_UserMarshal(  c_ulong *, byte *, BSTR * ); 
byte *  BSTR_UserUnmarshal(c_ulong *, byte *, BSTR * ); 
void                       BSTR_UserFree(     c_ulong *, BSTR * ); 

c_ulong              HBITMAP_UserSize(     c_ulong *, c_ulong            , HBITMAP * ); 
byte *  HBITMAP_UserMarshal(  c_ulong *, byte *, HBITMAP * ); 
byte *  HBITMAP_UserUnmarshal(c_ulong *, byte *, HBITMAP * ); 
void                       HBITMAP_UserFree(     c_ulong *, HBITMAP * ); 

c_ulong              HICON_UserSize(     c_ulong *, c_ulong            , HICON * ); 
byte *  HICON_UserMarshal(  c_ulong *, byte *, HICON * ); 
byte *  HICON_UserUnmarshal(c_ulong *, byte *, HICON * ); 
void                       HICON_UserFree(     c_ulong *, HICON * ); 

c_ulong              HPALETTE_UserSize(     c_ulong *, c_ulong            , HPALETTE * ); 
byte *  HPALETTE_UserMarshal(  c_ulong *, byte *, HPALETTE * ); 
byte *  HPALETTE_UserUnmarshal(c_ulong *, byte *, HPALETTE * ); 
void                       HPALETTE_UserFree(     c_ulong *, HPALETTE * ); 

c_ulong              LPSAFEARRAY_UserSize(     c_ulong *, c_ulong            , LPSAFEARRAY * ); 
byte *  LPSAFEARRAY_UserMarshal(  c_ulong *, byte *, LPSAFEARRAY * ); 
byte *  LPSAFEARRAY_UserUnmarshal(c_ulong *, byte *, LPSAFEARRAY * ); 
void                       LPSAFEARRAY_UserFree(     c_ulong *, LPSAFEARRAY * ); 

c_ulong              WICInProcPointer_UserSize(     c_ulong *, c_ulong            , WICInProcPointer * ); 
byte *  WICInProcPointer_UserMarshal(  c_ulong *, byte *, WICInProcPointer * ); 
byte *  WICInProcPointer_UserUnmarshal(c_ulong *, byte *, WICInProcPointer * ); 
void                       WICInProcPointer_UserFree(     c_ulong *, WICInProcPointer * ); 

/* [local] */ HRESULT IWICBitmapCodecProgressNotification_RegisterProgressNotification_Proxy( 
    IWICBitmapCodecProgressNotification This,
    /* [annotation][unique][in] */ 
    PFNProgressNotification pfnProgressNotification,
    /* [annotation][unique][in] */ 
    LPVOID pvData,
    /* [in] */ DWORD dwProgressFlags);


/* [call_as] */ HRESULT IWICBitmapCodecProgressNotification_RegisterProgressNotification_Stub( 
    IWICBitmapCodecProgressNotification This,
    /* [unique][in] */ IWICProgressCallback pICallback,
    /* [in] */ DWORD dwProgressFlags);

/* [local] */ HRESULT IWICBitmapDecoderInfo_GetPatterns_Proxy( 
    IWICBitmapDecoderInfo This,
    /* [in] */ UINT cbSizePatterns,
    /* [annotation][unique][size_is][out] */ 
    WICBitmapPattern* pPatterns,
    /* [annotation][unique][out] */ 
    UINT* pcPatterns,
    /* [annotation][out] */ 
    UINT* pcbPatternsActual);


/* [call_as] */ HRESULT IWICBitmapDecoderInfo_GetPatterns_Stub( 
    IWICBitmapDecoderInfo This,
    /* [size_is][size_is][out] */ WICBitmapPattern** ppPatterns,
    /* [out] */ UINT* pcPatterns);

/* [local] */ HRESULT IWICDevelopRaw_QueryRawCapabilitiesInfo_Proxy( 
    IWICDevelopRaw This,
    /* [out][in] */ WICRawCapabilitiesInfo* pInfo);


/* [call_as] */ HRESULT IWICDevelopRaw_QueryRawCapabilitiesInfo_Stub( 
    IWICDevelopRaw This,
    /* [out][in] */ WICRawCapabilitiesInfo* pInfo);

/* [local] */ HRESULT IWICDevelopRaw_SetToneCurve_Proxy( 
    IWICDevelopRaw This,
    /* [in] */ UINT cbToneCurveSize,
    /* [annotation][in] */ 
    const(WICRawToneCurve)* pToneCurve);


/* [call_as] */ HRESULT IWICDevelopRaw_SetToneCurve_Stub( 
    IWICDevelopRaw This,
    /* [in] */ UINT cPoints,
    /* [size_is][in] */ const(WICRawToneCurvePoint)* aPoints);

/* [local] */ HRESULT IWICDevelopRaw_GetToneCurve_Proxy( 
    IWICDevelopRaw This,
    /* [in] */ UINT cbToneCurveBufferSize,
    /* [annotation][unique][out] */ 
    WICRawToneCurve* pToneCurve,
    /* [annotation][unique][out] */ 
    UINT* pcbActualToneCurveBufferSize);


/* [call_as] */ HRESULT IWICDevelopRaw_GetToneCurve_Stub( 
    IWICDevelopRaw This,
    /* [out] */ UINT* pcPoints,
    /* [size_is][size_is][out] */ WICRawToneCurvePoint** paPoints);
}
