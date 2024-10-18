module hconfigs;

version(ARM) 
    enum isARM = true;
else version(AArch64) 
    enum isARM = true;
else 
    enum isARM = false;