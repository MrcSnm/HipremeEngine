
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.openal;

public import bindbc.openal.types;
public import bindbc.openal.efx;
public import bindbc.openal.presets;

version(BindBC_Static) version = BindOpenAL_Static;
version(BindOpenAL_Static) public import bindbc.openal.bindstatic;
else public import bindbc.openal.binddynamic;