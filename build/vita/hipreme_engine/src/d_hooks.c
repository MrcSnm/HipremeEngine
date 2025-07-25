
/**
 * For using D code, using the LWDR (LightWeight D Runtime) Those functions should be implemented to access several stuff as:
 * 
 * new Class()
 * destroy(classInstance)
 * array~= value (Append value)
 * array.length = 10 (Set dynamic array size)
 * Thread Local Storage (non __gshared data)
 * Class c = new SubClass(); (polymorphism)
 * cast(SubClass)classInstance is null (dynamic cast)
 * 
 * So, this file is pretty important. If you do not wish to integrate it, feel free to use betterC
 */

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <malloc.h>
#include <pthread.h>
#include "debugScreen.h"
#include <psp2/kernel/sysmem.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/threadmgr.h>

#include <psp2/kernel/clib.h>


//LWDR(Lightweight D runtime backend stuff) Do not remove those lines. Please find another way to support a better assertion
void* rtosbackend_heapalloc(unsigned int sz){return malloc(sz);}
void rtosbackend_heapfreealloc(void* ptr){free(ptr);}
void rtosbackend_assert(char* file, uint line){assert(0);}
void rtosbackend_assertmsg(char* msg, char* file, uint line){assert(0);}
void rtosbackend_arrayBoundFailure(char* file, uint line){assert(0);}
size_t allocated = 0;

int VITA_ShowMessageBoxStr(const char* title, const char* msg);

void psv_abort()
{
	sceClibPrintf("DRuntime Aborted PSVita Application.\n");
	VITA_ShowMessageBoxStr("DRuntime Aborted PSVita Application.", "User Message: OMG");
	sceKernelDelayThread(1000000 / 2);
	assert(0);
}

void psv_out_of_mem()
{
	sceClibPrintf("DRuntime Aborted PSVita Application.\n\tOut of Memory");
	assert(0);
}
#define IS_ON_HEAP(ptr) ((uintptr_t)(ptr) >= memoryBoundsStart && (uintptr_t)(ptr) < memoryBoundsEnd)




uintptr_t memoryBoundsStart = 0, memoryBoundsEnd = 0;
int psv_isOnHeap(void* ptr){return IS_ON_HEAP(ptr);}
void psv_init_mem()
{
	SceKernelMemBlockInfo info;
	info.size = sizeof(SceKernelMemBlockInfo);
	void* temp = malloc(1);
	sceKernelGetMemBlockInfoByAddr(temp, &info);
	memoryBoundsStart = (uintptr_t)info.mappedBase;
	memoryBoundsEnd = memoryBoundsStart + info.mappedSize - 1;

	sceClibPrintf("\n\nStarted PSV Memory at [%u..%u] (Max %u )\n\n", memoryBoundsStart, memoryBoundsEnd, memoryBoundsEnd - memoryBoundsStart);
	free(temp);
}

size_t psv_get_allocated_memory()
{
	struct mallinfo info = mallinfo();

	return info.uordblks - info.fordblks;
}

void psv_free(void* ptr)
{
	// if(IS_ON_HEAP(ptr))
		free(ptr);
}

void* psv_malloc(size_t sz)
{
	void* ret = malloc(sz);
	allocated+= sz;
	if(ret == 0)
		psv_out_of_mem();
	return ret;
}


void* psv_realloc(void* ptr, size_t newSize)
{
	ptr = realloc(ptr, newSize);
	if(ptr == 0)
		psv_out_of_mem();
	return ptr;
}

void* psv_calloc(size_t count, size_t newSize){return calloc(count, newSize);}

int psv_rand(){return rand();}

// #define MAX_THREADS 32
// pthread_key_t tls_keys[MAX_THREADS];
// #define CHECK_CREATE_KEY(index) if((index) > MAX_THREADS || (index) < 0) \
// 									assert(0); \
// 								if(tls_keys[index] == NULL) \
// 									pthread_key_create(&tls_keys[index], NULL);



extern void* pte_osTlsGetValue(unsigned int index);
extern void pte_osTlsSetValue(unsigned int index, void* value);

void* rtosbackend_getTLSPointerCurrThread(int index)
{
	//CHECK_CREATE_KEY(index);
	// return pthread_getspecific(tls_keys[index]);
	//SCE -> return sceKernelGetTLSAddr(index);
	return pte_osTlsGetValue(index);
}
void rtosbackend_setTLSPointerCurrThread(void* value, int index)
{
	// CHECK_CREATE_KEY(index);
	// pthread_setspecific(tls_keys[index], value);
	pte_osTlsSetValue(index, value);
}
