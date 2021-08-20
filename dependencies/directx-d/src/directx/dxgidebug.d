module directx.dxgidebug;

version(Windows):

public import directx.dxgi;

alias DXGI_DEBUG_RLO_FLAGS = DWORD;
enum : DXGI_DEBUG_RLO_FLAGS {
    DXGI_DEBUG_RLO_SUMMARY = 0x1,
    DXGI_DEBUG_RLO_DETAIL  = 0x2,
    DXGI_DEBUG_RLO_ALL     = 0x3
}

alias GUID DXGI_DEBUG_ID;

__gshared DXGI_DEBUG_ALL  = GUID(0xe48ae283, 0xda80, 0x490b, [0x87, 0xe6, 0x43, 0xe9, 0xa9, 0xcf, 0xda, 0x08]);
__gshared DXGI_DEBUG_DX   = GUID(0x35cdd7fc, 0x13b2, 0x421d, [0xa5, 0xd7, 0x7e, 0x44, 0x51, 0x28, 0x7d, 0x64]);
__gshared DXGI_DEBUG_DXGI = GUID(0x25cddaa4, 0xb1c6, 0x47e1, [0xac, 0x3e, 0x98, 0x87, 0x5b, 0x5a, 0x2e, 0x2a]);
__gshared DXGI_DEBUG_APP  = GUID(0x06cd6e01, 0x4219, 0x4ebd, [0x87, 0x09, 0x27, 0xed, 0x23, 0x36, 0x0c, 0x62]);

alias DXGI_INFO_QUEUE_MESSAGE_CATEGORY = DWORD;
enum : DXGI_INFO_QUEUE_MESSAGE_CATEGORY {
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_UNKNOWN	    = 0,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_MISCELLANEOUS	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_UNKNOWN + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_INITIALIZATION	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_MISCELLANEOUS + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_CLEANUP	    = DXGI_INFO_QUEUE_MESSAGE_CATEGORY_INITIALIZATION + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_COMPILATION	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_CLEANUP + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_STATE_CREATION	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_COMPILATION + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_STATE_SETTING	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_STATE_CREATION + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_STATE_GETTING	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_STATE_SETTING + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_RESOURCE_MANIPULATION	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_STATE_GETTING + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_EXECUTION	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_RESOURCE_MANIPULATION + 1,
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY_SHADER	= DXGI_INFO_QUEUE_MESSAGE_CATEGORY_EXECUTION + 1
}

alias DXGI_INFO_QUEUE_MESSAGE_SEVERITY = DWORD;
enum : DXGI_INFO_QUEUE_MESSAGE_SEVERITY {
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY_CORRUPTION	= 0,
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY_ERROR		= DXGI_INFO_QUEUE_MESSAGE_SEVERITY_CORRUPTION + 1,
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY_WARNING	= DXGI_INFO_QUEUE_MESSAGE_SEVERITY_ERROR + 1,
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY_INFO		= DXGI_INFO_QUEUE_MESSAGE_SEVERITY_WARNING + 1,
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY_MESSAGE	= DXGI_INFO_QUEUE_MESSAGE_SEVERITY_INFO + 1
}

alias int DXGI_INFO_QUEUE_MESSAGE_ID;

enum DXGI_INFO_QUEUE_MESSAGE_ID_STRING_FROM_APPLICATION = 0;
struct DXGI_INFO_QUEUE_MESSAGE {
    DXGI_DEBUG_ID                    Producer;
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY Category;
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY Severity;
    DXGI_INFO_QUEUE_MESSAGE_ID       ID;
    const(char)*                     pDescription;
    SIZE_T                           DescriptionByteLength;
}

struct DXGI_INFO_QUEUE_FILTER_DESC {
    UINT NumCategories;
    DXGI_INFO_QUEUE_MESSAGE_CATEGORY* pCategoryList;
    UINT NumSeverities;
    DXGI_INFO_QUEUE_MESSAGE_SEVERITY* pSeverityList;
    UINT NumIDs;
    DXGI_INFO_QUEUE_MESSAGE_ID* pIDList;
}

struct DXGI_INFO_QUEUE_FILTER {
    DXGI_INFO_QUEUE_FILTER_DESC AllowList;
    DXGI_INFO_QUEUE_FILTER_DESC DenyList;
}

enum DXGI_INFO_QUEUE_DEFAULT_MESSAGE_COUNT_LIMIT = 1024;

__gshared _DXGIGetDebugInterface DXGIGetDebugInterface;

extern (Windows) {
    alias _DXGIGetDebugInterface = HRESULT function(REFIID riid, void** ppDebug);
}

mixin(uuid!(IDXGIInfoQueue, "D67441C7-672A-476f-9E82-CD55B44949CE"));
extern (C++) interface IDXGIInfoQueue : IUnknown {
    HRESULT SetMessageCountLimit(DXGI_DEBUG_ID Producer,
                                 UINT64 MessageCountLimit);

    void ClearStoredMessages(DXGI_DEBUG_ID Producer);

    HRESULT GetMessage(DXGI_DEBUG_ID Producer,
                       UINT64 MessageIndex,
                       DXGI_INFO_QUEUE_MESSAGE *pMessage,
                       SIZE_T* pMessageByteLength);

    UINT64 GetNumStoredMessagesAllowedByRetrievalFilters(DXGI_DEBUG_ID Producer);

    UINT64 GetNumStoredMessages(DXGI_DEBUG_ID Producer);

    UINT64 GetNumMessagesDiscardedByMessageCountLimit(DXGI_DEBUG_ID Producer);

    UINT64 GetMessageCountLimit(DXGI_DEBUG_ID Producer);

    UINT64 GetNumMessagesAllowedByStorageFilter(DXGI_DEBUG_ID Producer);

    UINT64 GetNumMessagesDeniedByStorageFilter(DXGI_DEBUG_ID Producer);

    HRESULT AddStorageFilterEntries(DXGI_DEBUG_ID Producer,
                                    DXGI_INFO_QUEUE_FILTER* pFilter);

    HRESULT GetStorageFilter(DXGI_DEBUG_ID Producer,
                             DXGI_INFO_QUEUE_FILTER *pFilter,
                             SIZE_T* pFilterByteLength);

    void ClearStorageFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushEmptyStorageFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushDenyAllStorageFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushCopyOfStorageFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushStorageFilter(DXGI_DEBUG_ID Producer,
                              DXGI_INFO_QUEUE_FILTER* pFilter);

    void PopStorageFilter(DXGI_DEBUG_ID Producer);

    UINT GetStorageFilterStackSize(DXGI_DEBUG_ID Producer);

    HRESULT AddRetrievalFilterEntries(DXGI_DEBUG_ID Producer,
                                      DXGI_INFO_QUEUE_FILTER* pFilter);

    HRESULT GetRetrievalFilter(DXGI_DEBUG_ID Producer,
                               DXGI_INFO_QUEUE_FILTER *pFilter,
                               SIZE_T* pFilterByteLength);

    void ClearRetrievalFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushEmptyRetrievalFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushDenyAllRetrievalFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushCopyOfRetrievalFilter(DXGI_DEBUG_ID Producer);

    HRESULT PushRetrievalFilter(DXGI_DEBUG_ID Producer,
                                DXGI_INFO_QUEUE_FILTER* pFilter);

    void PopRetrievalFilter(DXGI_DEBUG_ID Producer);

    UINT GetRetrievalFilterStackSize(DXGI_DEBUG_ID Producer);

    HRESULT AddMessage(DXGI_DEBUG_ID Producer,
                       DXGI_INFO_QUEUE_MESSAGE_CATEGORY Category,
                       DXGI_INFO_QUEUE_MESSAGE_SEVERITY Severity,
                       DXGI_INFO_QUEUE_MESSAGE_ID ID,
                       LPCSTR pDescription);

    HRESULT AddApplicationMessage(DXGI_INFO_QUEUE_MESSAGE_SEVERITY Severity,
                                  LPCSTR pDescription);

    HRESULT SetBreakOnCategory(DXGI_DEBUG_ID Producer,
                               DXGI_INFO_QUEUE_MESSAGE_CATEGORY Category,
                               BOOL bEnable);

    HRESULT SetBreakOnSeverity(DXGI_DEBUG_ID Producer,
                               DXGI_INFO_QUEUE_MESSAGE_SEVERITY Severity,
                               BOOL bEnable);

    HRESULT SetBreakOnID(DXGI_DEBUG_ID Producer,
                         DXGI_INFO_QUEUE_MESSAGE_ID ID,
                         BOOL bEnable);

    BOOL GetBreakOnCategory(DXGI_DEBUG_ID Producer,
                            DXGI_INFO_QUEUE_MESSAGE_CATEGORY Category);

    BOOL GetBreakOnSeverity(DXGI_DEBUG_ID Producer,
                            DXGI_INFO_QUEUE_MESSAGE_SEVERITY Severity);

    BOOL GetBreakOnID(DXGI_DEBUG_ID Producer,
                      DXGI_INFO_QUEUE_MESSAGE_ID ID);

    void SetMuteDebugOutput(DXGI_DEBUG_ID Producer, BOOL bMute);

    BOOL GetMuteDebugOutput(DXGI_DEBUG_ID Producer);
}

mixin(uuid!(IDXGIDebug, "119E7452-DE9E-40fe-8806-88F90C12B441"));
extern (C++) interface IDXGIDebug : IUnknown {
    HRESULT ReportLiveObjects(GUID apiid, DXGI_DEBUG_RLO_FLAGS flags);
}

mixin(uuid!(IDXGIDebug1, "c5a05f0c-16f2-4adf-9f4d-a8c4d58ac550"));
extern (C++) interface IDXGIDebug1 : IDXGIDebug {
    void EnableLeakTrackingForThread();
    void DisableLeakTrackingForThread();
    BOOL IsLeakTrackingEnabledForThread();
}
