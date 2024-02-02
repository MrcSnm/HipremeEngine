// expansion at
.object.size_t h = 0;foreach (i, T; typeof(p.tupleof))    static if(is(T* : const(.object.Object)*))         h = h * 33 + typeid(const(.object.Object)).getHash(cast(const void*)&p.tupleof[i]);    else         h = h * 33 + typeid(T).getHash(cast(const void*)&p.tupleof[i]);return h;

// expansion at G:\HipremeEngine\tools\user\build_selector\D\ldc2-opend-windows-x64\bin\..\import\std\functional.d(452)
cast(T)a < cast(T) b

// expansion at
.object.size_t h = 0;foreach (i, T; typeof(p.tupleof))    static if(is(T* : const(.object.Object)*))         h = h * 33 + typeid(const(.object.Object)).getHash(cast(const void*)&p.tupleof[i]);    else         h = h * 33 + typeid(T).getHash(cast(const void*)&p.tupleof[i]);return h;

// expansion at
.object.size_t h = 0;foreach (i, T; typeof(p.tupleof))    static if(is(T* : const(.object.Object)*))         h = h * 33 + typeid(const(.object.Object)).getHash(cast(const void*)&p.tupleof[i]);    else         h = h * 33 + typeid(T).getHash(cast(const void*)&p.tupleof[i]);return h;

// expansion at
.object.size_t h = 0;foreach (i, T; typeof(p.tupleof))    static if(is(T* : const(.object.Object)*))         h = h * 33 + typeid(const(.object.Object)).getHash(cast(const void*)&p.tupleof[i]);    else         h = h * 33 + typeid(T).getHash(cast(const void*)&p.tupleof[i]);return h;

// expansion at G:\HipremeEngine\tools\user\build_selector\D\ldc2-opend-windows-x64\bin\..\import\std\internal\memory.d(32)
onOutOfMemoryError();

// expansion at
.object.size_t h = 0;foreach (i, T; typeof(p.tupleof))    static if(is(T* : const(.object.Object)*))         h = h * 33 + typeid(const(.object.Object)).getHash(cast(const void*)&p.tupleof[i]);    else         h = h * 33 + typeid(T).getHash(cast(const void*)&p.tupleof[i]);return h;

