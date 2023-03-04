module core.stdc.fenv;


version (ARM)     version = ARM_Any;
version (AArch64) version = ARM_Any;
version (HPPA)    version = HPPA_Any;
version (MIPS32)  version = MIPS_Any;
version (MIPS64)  version = MIPS_Any;
version (PPC)     version = PPC_Any;
version (PPC64)   version = PPC_Any;
version (RISCV32) version = RISCV_Any;
version (RISCV64) version = RISCV_Any;
version (S390)    version = IBMZ_Any;
version (SPARC)   version = SPARC_Any;
version (SPARC64) version = SPARC_Any;
version (SystemZ) version = IBMZ_Any;
version (X86)     version = X86_Any;
version (X86_64)  version = X86_Any;

version (ARM_Any)
{
    // Define bits representing exceptions in the FPU status word.
    enum
    {
        FE_INVALID      = 1,  ///
        FE_DIVBYZERO    = 2,  ///
        FE_OVERFLOW     = 4,  ///
        FE_UNDERFLOW    = 8,  ///
        FE_INEXACT      = 16, ///
        FE_ALL_EXCEPT   = 31, ///
    }

    // VFP supports all of the four defined rounding modes.
    enum
    {
        FE_TONEAREST    = 0,        ///
        FE_UPWARD       = 0x400000, ///
        FE_DOWNWARD     = 0x800000, ///
        FE_TOWARDZERO   = 0xC00000, ///
    }
}

