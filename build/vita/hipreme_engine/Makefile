# You should only use Makefile-based build if you know what you're doing.
# For most vitasdk projects, CMake is a better choice. See CMakeLists.txt for an example.

PHONY := all package clean
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

CC := arm-vita-eabi-gcc
CXX := arm-vita-eabi-g++
# D Compiler
DC := ldc2
STRIP := arm-vita-eabi-strip
VITA_ELF_CREATE := vita-elf-create
VITA_PACK_VPK := vita-pack-vpk
VITA_MAKE_FSELF := vita-make-fself
VITA_MKSFOEX := vita-mksfoex

# Check for WSL
ifeq ($(shell test -e /proc/sys/fs/binfmt_misc/WSLInterop && echo -n yes), yes)
	CC := arm-vita-eabi-gcc.exe
	CXX := arm-vita-eabi-g++.exe
	DC := ldc2.exe
	STRIP := arm-vita-eabi-strip.exe
	VITA_ELF_CREATE := vita-elf-create.exe
	VITA_MKSFOEX := vita-mksfoex.exe
	VITA_PACK_VPK := vita-pack-vpk.exe
	VITA_MAKE_FSELF := vita-make-fself.exe
endif

DFLAGS := -betterC -gcc="/usr/local/vitasdk/bin/$(CC)" -mtriple=armv7a-unknown-unknown --float-abi=hard -mcpu=cortex-a9

PROJECT_TITLE := Hello World
PROJECT_TITLEID := VSDK00007

PROJECT := vita_sample
CFLAGS += -Wl,-q -Iinclude -Isrc_extra
CXXFLAGS += -Wl,-q -std=c++11 
SRC_C :=$(call rwildcard, src/, *.c)
SRC_CPP :=$(call rwildcard, src/, *.cpp)
SRC_D := $(call rwildcard, src/, *.d)

OBJ_DIRS := $(addprefix out/, $(dir $(SRC_C:src/%.c=%.o))) $(addprefix out/, $(dir $(SRC_CPP:src/%.cpp=%.o))) $(addprefix out/, $(dir $(SRC_D:src/%.d=%.o)))
OBJS := $(addprefix out/, $(SRC_C:src/%.c=%.o)) $(addprefix out/, $(SRC_CPP:src/%.cpp=%.o)) $(addprefix out/, $(SRC_D:src/%.d=%.o))


# Hipreme Engine
LIBS += -lhipreme_engine -lassets -laudio -lfilesystem -lfont -larsd-official_ttf -lrenderer  -ld_std
LIBS += -laudio_decoding -laudio-formats -lBindBC_OpenAL -lbind
LIBS += -ldata -lgles -limage -lerror -lconsole -lconfig -ldebugging -lgamut 
LIBS += -lintel-intrinsics -lmath -lwindowing -lruntime -ltween -ltimer -lhipengine_api -lutil

# In future try to use the libIncludes.
# LIBS += $(shell cat libIncludes.txt)

# Needed by psvDebugScreenPrintf
# Third party
LIBS += -lopenal -lpthread -llibGLESv2_stub -lSceDisplay_stub -lSceTouch_stub -lSceCtrl_stub -lSceAudio_stub -lSceAudioIn_stub -llibIMGEGL_stub -llibgpu_es4_ext_stub

all: package

package: $(PROJECT).vpk

$(PROJECT).vpk: eboot.bin param.sfo
	$(VITA_PACK_VPK) -s param.sfo -b eboot.bin \
		--add module/libIMGEGL.suprx=module/libIMGEGL.suprx \
		--add module/libpvr2d.suprx=module/libpvr2d.suprx \
		--add module/libGLESv2.suprx=module/libGLESv2.suprx \
		--add module/libgpu_es4_ext.suprx=module/libgpu_es4_ext.suprx \
		--add module/libpvrPSP2_WSEGL.suprx=module/libpvrPSP2_WSEGL.suprx \
		--add sce_sys/icon0.png=sce_sys/icon0.png \
		--add assets=assets \
		--add sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
		--add sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
		--add sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
	$(PROJECT).vpk

eboot.bin: $(PROJECT).velf
	$(VITA_MAKE_FSELF) $(PROJECT).velf eboot.bin

param.sfo:
	$(VITA_MKSFOEX) -s TITLE_ID="$(PROJECT_TITLEID)" "$(PROJECT_TITLE)" param.sfo

$(PROJECT).velf: $(PROJECT).elf
	$(STRIP) -g $<
	$(VITA_ELF_CREATE) $< $@

$(PROJECT).elf: $(OBJS)
	$(CXX) $(CXXFLAGS) $^  -L/usr/local/vitasdk/arm-vita-eabi/lib/ -L. -Llibs -Lthirdparty $(LIBS) -o $@

out/%.o : src/%.cpp | $(OBJ_DIRS)
	$(CXX) -c $(CXXFLAGS) -o $@ $<

out/%.o : src/%.c | $(OBJ_DIRS)
	$(CC) -c $(CFLAGS) -o $@ $<

out/%.o : src/%.d | $(OBJ_DIRS)
	$(DC) -c $(DFLAGS) --od=out/ $<

$(OBJ_DIRS):
	mkdir -p $@


clean:
	rm -f $(PROJECT).velf $(PROJECT).elf $(PROJECT).vpk param.sfo eboot.bin $(OBJS)
	rm -r $(abspath $(OBJ_DIRS))
