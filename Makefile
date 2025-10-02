.PHONY: all objdir cleantarget clean realclean distclean lzma

# CORE VARIABLES

MODULE := gfx
VERSION := 0.0.1
CONFIG := release
ifndef COMPILER
COMPILER := default
endif

TARGET_TYPE = sharedlib

# FLAGS

ECFLAGS =
ifndef DEBIAN_PACKAGE
CFLAGS =
LDFLAGS =
endif
PRJ_CFLAGS =
CECFLAGS =
OFLAGS =
LIBS =

ifdef DEBUG
NOSTRIP := y
endif

CONSOLE = -mwindows

# INCLUDES

GFX_ABSPATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

ifndef EC_SDK_SRC
EC_SDK_SRC := $(GFX_ABSPATH)../eC
endif

_CF_DIR = $(EC_SDK_SRC)/
include $(_CF_DIR)crossplatform.mk
include $(_CF_DIR)default.cf

# POST-INCLUDES VARIABLES

OBJ = obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX)/

RES = res/

TARGET_NAME := gfx

TARGET = obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX)/$(LP)$(TARGET_NAME)$(OUT)

_ECSOURCES = $(_ECSOURCES1) $(_ECSOURCES2)
_ECSOURCES1 = \
	src/gfx/3D/meshes/Cube.ec \
	src/gfx/3D/meshes/SkyBox.ec \
	src/gfx/3D/meshes/Sphere.ec \
	src/gfx/3D/models/e3d/e3dDefs.ec \
	src/gfx/3D/models/e3d/e3dRead.ec \
	src/gfx/3D/models/e3d/e3dWrite.ec \
	src/gfx/3D/models/Object3DSFormat.ec \
	src/gfx/3D/models/e3d.ec \
	src/gfx/3D/depthsort/Tetrahedron.ec \
	src/gfx/3D/depthsort/TopoSort.ec \
	src/gfx/3D/depthsort/DepthSort.ec \
	src/gfx/3D/depthsort/Pool.ec \
	src/gfx/3D/Camera.ec \
	src/gfx/3D/Matrix.ec \
	src/gfx/3D/Mesh.ec \
	src/gfx/3D/Object.ec \
	src/gfx/3D/Plane.ec \
	src/gfx/3D/Quaternion.ec \
	src/gfx/3D/Vector3D.ec \
	src/gfx/bitmaps/BMPFormat.ec \
	src/gfx/bitmaps/GIFFormat.ec \
	src/gfx/bitmaps/JPEGFormat.ec \
	src/gfx/bitmaps/PCXFormat.ec \
	src/gfx/bitmaps/PNGFormat.ec \
	src/gfx/bitmaps/RGBFormat.ec \
	src/gfx/bitmaps/ETC2Format.ec \
	src/gfx/drivers/gl3/glab.ec \
	src/gfx/drivers/gl3/immediate.ec \
	src/gfx/drivers/gl3/matrixStack.ec \
	src/gfx/drivers/gl3/shaders.ec \
	src/gfx/drivers/gl3/defaultShader.ec \
	src/gfx/drivers/gl3/GLMultiDraw.ec \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/Direct3D8DisplayDriver.ec,) \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/Direct3D9DisplayDriver.ec,) \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/DirectDrawDisplayDriver.ec,) \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/GDIDisplayDriver.ec,) \
	src/gfx/drivers/lfbBlit.ec \
	src/gfx/drivers/lfbConvert.ec \
	src/gfx/drivers/LFBDisplayDriver.ec \
	$(if $(or $(LINUX_TARGET),$(OSX_TARGET)),src/gfx/drivers/NCursesDisplayDriver.ec,) \
	src/gfx/drivers/OpenGLDisplayDriver.ec
_ECSOURCES2 = \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/Win32BitmapPrinterDisplayDriver.ec,) \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/Win32ConsoleDisplayDriver.ec,) \
	$(if $(WINDOWS_TARGET),src/gfx/drivers/Win32PrinterDisplayDriver.ec,) \
	$(if $(or $(LINUX_TARGET),$(OSX_TARGET)),src/gfx/drivers/XDisplayDriver.ec,) \
	src/gfx/newFonts/atlasBuilder.ec \
	src/gfx/newFonts/drawManager.ec \
	src/gfx/newFonts/fmFontManager.ec \
	src/gfx/newFonts/fontRenderer.ec \
	src/gfx/newFonts/textureManager.ec \
	src/gfx/Bitmap.ec \
	src/gfx/BitmapResource.ec \
	src/gfx/Color.ec \
	src/gfx/Display.ec \
	src/gfx/DisplaySystem.ec \
	src/gfx/FontResource.ec \
	src/gfx/Resource.ec \
	src/gfx/Surface.ec \
	src/gfx/fontManagement.ec \
	src/gfx/fontRendering.ec \
	src/gfx/imgDistMap.ec \
	src/gfx/Extent.ec

ECSOURCES = $(call shwspace,$(_ECSOURCES))
ECSOURCES1 = $(call shwspace,$(_ECSOURCES1))
ECSOURCES2 = $(call shwspace,$(_ECSOURCES2))

_COBJECTS = $(COBJECTS1) $(COBJECTS2)
_COBJECTS1 = $(addprefix $(OBJ),$(patsubst %.ec,%$(C),$(notdir $(_ECSOURCES1))))
_COBJECTS2 = $(addprefix $(OBJ),$(patsubst %.ec,%$(C),$(notdir $(_ECSOURCES2))))

_SYMBOLS = $(SYMBOLS1) $(SYMBOLS2)
_SYMBOLS1 = $(addprefix $(OBJ),$(patsubst %.ec,%$(S),$(notdir $(_ECSOURCES1))))
_SYMBOLS2 = $(addprefix $(OBJ),$(patsubst %.ec,%$(S),$(notdir $(_ECSOURCES2))))

_IMPORTS = $(IMPORTS1) $(IMPORTS2)
_IMPORTS1 = $(addprefix $(OBJ),$(patsubst %.ec,%$(I),$(notdir $(_ECSOURCES1))))
_IMPORTS2 = $(addprefix $(OBJ),$(patsubst %.ec,%$(I),$(notdir $(_ECSOURCES2))))

_ECOBJECTS = $(ECOBJECTS1) $(ECOBJECTS2)
_ECOBJECTS1 = $(addprefix $(OBJ),$(patsubst %.ec,%$(O),$(notdir $(_ECSOURCES1))))
_ECOBJECTS2 = $(addprefix $(OBJ),$(patsubst %.ec,%$(O),$(notdir $(_ECSOURCES2))))

_BOWLS = $(BOWLS1) $(BOWLS2)
_BOWLS1 = $(addprefix $(OBJ),$(patsubst %.ec,%$(B),$(notdir $(_ECSOURCES1))))
_BOWLS2 = $(addprefix $(OBJ),$(patsubst %.ec,%$(B),$(notdir $(_ECSOURCES2))))

COBJECTS = $(COBJECTS1) $(COBJECTS2)
COBJECTS1 = $(call shwspace,$(_COBJECTS1))
COBJECTS2 = $(call shwspace,$(_COBJECTS2))

SYMBOLS = $(SYMBOLS1) $(SYMBOLS2)
SYMBOLS1 = $(call shwspace,$(_SYMBOLS1))
SYMBOLS2 = $(call shwspace,$(_SYMBOLS2))

IMPORTS = $(IMPORTS1) $(IMPORTS2)
IMPORTS1 = $(call shwspace,$(_IMPORTS1))
IMPORTS2 = $(call shwspace,$(_IMPORTS2))

ECOBJECTS = $(ECOBJECTS1) $(ECOBJECTS2)
ECOBJECTS1 = $(call shwspace,$(_ECOBJECTS1))
ECOBJECTS2 = $(call shwspace,$(_ECOBJECTS2))

BOWLS = $(BOWLS1) $(BOWLS2)
BOWLS1 = $(call shwspace,$(_BOWLS1))
BOWLS2 = $(call shwspace,$(_BOWLS2))

_OBJECTS = \
	$(OBJ)harfbuzz-freetype$(O) \
	$(OBJ)harfbuzz-unicode-tables$(O) \
	$(OBJ)harfbuzz-unicode$(O) \
	$(OBJ)harfbuzz-arabic$(O) \
	$(OBJ)harfbuzz-buffer$(O) \
	$(OBJ)harfbuzz-gdef$(O) \
	$(OBJ)harfbuzz-gpos$(O) \
	$(OBJ)harfbuzz-gsub$(O) \
	$(OBJ)harfbuzz-hangul$(O) \
	$(OBJ)harfbuzz-hebrew$(O) \
	$(OBJ)harfbuzz-indic$(O) \
	$(OBJ)harfbuzz-khmer$(O) \
	$(OBJ)harfbuzz-myanmar$(O) \
	$(OBJ)harfbuzz-open$(O) \
	$(OBJ)harfbuzz-shaper$(O) \
	$(OBJ)harfbuzz-stream$(O) \
	$(OBJ)harfbuzz-tibetan$(O) \
	$(OBJ)harfbuzz-impl$(O) \
	$(OBJ)harfbuzz-thai$(O) \
	$(OBJ)gl_compat_4_4$(O) \
	$(OBJ)QuickETC2Pak$(O) \
	$(OBJ)cc$(O) \
	$(OBJ)mm$(O) \
	$(OBJ)ccstr$(O) \
	$(OBJ)mmhash$(O)

OBJECTS = $(_OBJECTS) $(ECOBJECTS) $(OBJ)$(MODULE).main$(O)

SOURCES = $(ECSOURCES) \
	src/gfx/drivers/harfbuzz/unicode/harfbuzz-freetype.c \
	src/gfx/drivers/harfbuzz/unicode/harfbuzz-unicode-tables.c \
	src/gfx/drivers/harfbuzz/unicode/harfbuzz-unicode.c \
	src/gfx/drivers/harfbuzz/harfbuzz-arabic.c \
	src/gfx/drivers/harfbuzz/harfbuzz-buffer.c \
	src/gfx/drivers/harfbuzz/harfbuzz-gdef.c \
	src/gfx/drivers/harfbuzz/harfbuzz-gpos.c \
	src/gfx/drivers/harfbuzz/harfbuzz-gsub.c \
	src/gfx/drivers/harfbuzz/harfbuzz-hangul.c \
	src/gfx/drivers/harfbuzz/harfbuzz-hebrew.c \
	src/gfx/drivers/harfbuzz/harfbuzz-indic.c \
	src/gfx/drivers/harfbuzz/harfbuzz-khmer.c \
	src/gfx/drivers/harfbuzz/harfbuzz-myanmar.c \
	src/gfx/drivers/harfbuzz/harfbuzz-open.c \
	src/gfx/drivers/harfbuzz/harfbuzz-shaper.c \
	src/gfx/drivers/harfbuzz/harfbuzz-stream.c \
	src/gfx/drivers/harfbuzz/harfbuzz-tibetan.c \
	src/gfx/drivers/harfbuzz/harfbuzz-impl.c \
	src/gfx/drivers/harfbuzz/harfbuzz-thai.c \
	src/gfx/drivers/gl3/gl_compat_4_4.c \
	deps/etcpak/QuickETC2Pak.c \
	$(EC_SDK_SRC)/ecrt/src/containers/cc/cc.c \
	$(EC_SDK_SRC)/ecrt/src/containers/cc/mm.c \
	$(EC_SDK_SRC)/ecrt/src/containers/cc/ccstr.c \
	$(EC_SDK_SRC)/ecrt/src/containers/cc/mmhash.c

RESOURCES = \
	src/gfx/drivers/gl3/default.frag \
	src/gfx/drivers/gl3/default.vert

ifdef USE_RESOURCES_EAR
RESOURCES_EAR = $(OBJ)resources.ear
else
RESOURCES_EAR = $(RESOURCES)
endif

LIBS += $(SHAREDLIB) $(EXECUTABLE) $(LINKOPT)

ifndef STATIC_LIBRARY_TARGET
LIBS += \
	$(call _L,ecrt) \
	$(call _L,jpeg) \
	$(call _L,png) \
	$(call _L,z) \
	$(call _L,freetype) \
	$(call _L,7z-lzma)
endif

PRJ_CFLAGS += \
	 $(if $(WINDOWS_TARGET), \
			 -DNOT_OPENSSL_CURL \
			 -I../deps/jpeg-9a \
			 -I../deps/libpng-1.6.12 \
			 -I../deps/libungif-4.1.1/lib \
			 -I../deps/zlib-1.2.8 \
			 -I../deps/freetype-2.3.12/include \
			 -I../deps/glext \
			 -I../deps/curl-8.5.0/include \
			 -I$(OPENSSL_INCLUDE_DIR),) \
	 $(if $(LINUX_TARGET), \
			 -I/usr/include/freetype2 \
			 -I../deps/jpeg-9a,) \
	 $(if $(OSX_TARGET), \
			 -I/usr/include/freetype2 \
			 -I$(SYSROOT)/usr/X11/include/freetype2 \
			 -I$(SYSROOT)/usr/X11/include \
			 -I/usr/X11R6/include/freetype2 \
			 -I/usr/X11R6/include \
			 -I../deps/jpeg-9a \
			 -I../deps/libpng-1.6.12 \
			 -I../deps/libungif-4.1.1/lib,) \
	 $(if $(DEBUG), -g, -O2 -ffast-math) $(FPIC) -Wall -DREPOSITORY_VERSION="\"$(REPOSITORY_VER)\"" \
			 -DETC2_COMPRESS \
			 -Isrc/gfx/drivers/harfbuzz \
			 -I/usr/X11R6/include \
			 -I/usr/X11R6/include/freetype2 \
			 -Isrc/gfx/drivers/gl3 \
			 -Ideps/lzma-2107

CUSTOM1_PRJ_CFLAGS = \
			 -Isrc/gfx/newFonts/cc \
			 -I$(EC_SDK_SRC)/ecrt/src/containers/cc \
	 $(PRJ_CFLAGS)

ECFLAGS += -module $(MODULE)
ECFLAGS += \
	 -defaultns gfx

# PLATFORM-SPECIFIC OPTIONS

ifdef WINDOWS_TARGET

OFLAGS += \
	$(if $(EC_SDK_SRC)/obj/$(PLATFORM)$(COMPILER_SUFFIX)/bin,-L$(call quote_path,$(EC_SDK_SRC)/obj/$(PLATFORM)$(COMPILER_SUFFIX)/bin),) \
	-static-libgcc


ifndef STATIC_LIBRARY_TARGET
OFLAGS += \
	 -L$(call quote_path,../deps/zlib-1.2.8/obj/release.$(PLATFORM)$(COMPILER_SUFFIX)) \
	 -L$(call quote_path,../deps/jpeg-9a/obj/release.$(PLATFORM)$(COMPILER_SUFFIX)) \
	 -L$(call quote_path,../deps/libpng-1.6.12/obj/release.$(PLATFORM)$(COMPILER_SUFFIX)) \
	 -L$(call quote_path,../deps/libungif-4.1.1/obj/release.$(PLATFORM)$(COMPILER_SUFFIX)) \
	 -L$(call quote_path,../deps/freetype-2.3.12/obj/release.$(PLATFORM)$(COMPILER_SUFFIX))
LIBS += \
	$(call _L,dxguid) \
	$(call _L,ddraw) \
	$(call _L,opengl32) \
	$(call _L,kernel32) \
	$(call _L,gdi32) \
	$(call _L,ungif)
endif

else
OFLAGS += \
	$(if $(EC_SDK_SRC)/obj/$(PLATFORM)$(COMPILER_SUFFIX)/lib,-L$(call quote_path,$(EC_SDK_SRC)/obj/$(PLATFORM)$(COMPILER_SUFFIX)/lib),)

ifdef LINUX_TARGET

ifndef STATIC_LIBRARY_TARGET
OFLAGS += \
	 -L$(call quote_path,/usr/X11R6/lib) \
	 -L$(call quote_path,../deps/jpeg-9a/obj/release.$(PLATFORM)$(COMPILER_SUFFIX))
LIBS += \
	$(call _L,ncurses) \
	$(call _L,m) \
	$(call _L,fontconfig) \
	$(call _L,gif) \
	$(call _L,X11) \
	$(call _L,Xext) \
	$(call _L,Xrender) \
	$(call _L,GL)
endif

else
ifdef OSX_TARGET

ifndef STATIC_LIBRARY_TARGET
OFLAGS += \
	 -L$(call quote_path,$(SYSROOT)/usr/X11/lib) \
	 -L$(call quote_path,/usr/X11R6/lib) \
	 -L$(call quote_path,../deps/jpeg-9a/obj/release.$(PLATFORM)$(COMPILER_SUFFIX)) \
	 -L$(call quote_path,../deps/libungif-4.1.1/obj/release.$(PLATFORM)$(COMPILER_SUFFIX))
LIBS += \
	$(call _L,curses) \
	$(call _L,m) \
	$(call _L,fontconfig) \
	$(call _L,ungif) \
	$(call _L,X11) \
	$(call _L,Xext) \
	$(call _L,Xrender) \
	$(call _L,GL)
endif

endif
endif
endif

CFLAGS += \
	 -mmmx -msse -msse2 -msse3

OFLAGS += \
	 -Wl,--wrap=fcntl64

CECFLAGS += -cpp $(_CPP)

ifndef STATIC_LIBRARY_TARGET
OFLAGS += \
	 -L$(call quote_path,deps/lzma-2107/obj/release.$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX))
endif

# TARGETS

all: objdir $(TARGET)

objdir:
	$(if $(wildcard $(OBJ)),,$(call mkdir,$(OBJ)))
	$(if $(ECERE_SDK_SRC),$(if $(wildcard $(call escspace,$(ECERE_SDK_SRC)/crossplatform.mk)),,@$(call echo,Ecere SDK Source Warning: The value of ECERE_SDK_SRC is pointing to an incorrect ($(ECERE_SDK_SRC)) location.)),)
	$(if $(ECERE_SDK_SRC),,$(if $(ECP_DEBUG)$(ECC_DEBUG)$(ECS_DEBUG),@$(call echo,ECC Debug Warning: Please define ECERE_SDK_SRC before using ECP_DEBUG, ECC_DEBUG or ECS_DEBUG),))

$(OBJ)$(MODULE).main.ec: $(SYMBOLS) $(COBJECTS)
	@$(call rm,$(OBJ)symbols.lst)
	@$(call touch,$(OBJ)symbols.lst)
	$(call addtolistfile,$(SYMBOLS1),$(OBJ)symbols.lst)
	$(call addtolistfile,$(SYMBOLS2),$(OBJ)symbols.lst)
	$(call addtolistfile,$(IMPORTS1),$(OBJ)symbols.lst)
	$(call addtolistfile,$(IMPORTS2),$(OBJ)symbols.lst)
	$(ECS) $(ARCH_FLAGS) $(ECSLIBOPT) @$(OBJ)symbols.lst -symbols obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX) -o $(call quote_path,$@)

$(OBJ)$(MODULE).main.c: $(OBJ)$(MODULE).main.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(OBJ)$(MODULE).main.ec -o $(OBJ)$(MODULE).main.sym -symbols $(OBJ)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(OBJ)$(MODULE).main.ec -o $(call quote_path,$@) -symbols $(OBJ)

ifdef USE_RESOURCES_EAR
$(RESOURCES_EAR): $(RESOURCES) | objdir
	$(EAR) aw$(EARFLAGS) $(RESOURCES_EAR) src/gfx/drivers/gl3/default.frag src/gfx/drivers/gl3/default.vert "shaders"
endif

lzma:
	+cd deps/lzma-2107 && $(MAKE)

$(SYMBOLS): | objdir
$(OBJECTS): | objdir
$(TARGET): $(SOURCES) $(RESOURCES_EAR) $(SYMBOLS) $(OBJECTS) lzma | objdir
	@$(call rm,$(OBJ)objects.lst)
	@$(call touch,$(OBJ)objects.lst)
	$(call addtolistfile,$(_OBJECTS),$(OBJ)objects.lst)
	$(call addtolistfile,$(OBJ)$(MODULE).main$(O),$(OBJ)objects.lst)
	$(call addtolistfile,$(ECOBJECTS1),$(OBJ)objects.lst)
	$(call addtolistfile,$(ECOBJECTS2),$(OBJ)objects.lst)
ifndef STATIC_LIBRARY_TARGET
	$(LD) $(OFLAGS) @$(OBJ)objects.lst $(LIBS) -o $(TARGET) $(INSTALLNAME) $(SONAME)
ifndef NOSTRIP
	$(STRIP) $(STRIPOPT) $(TARGET)
endif
ifndef USE_RESOURCES_EAR
	$(EAR) aw$(EARFLAGS) $(TARGET) src/gfx/drivers/gl3/default.frag src/gfx/drivers/gl3/default.vert "shaders"
endif
else
ifdef WINDOWS_HOST
	$(AR) rcs $(TARGET) @$(OBJ)objects.lst $(LIBS)
else
	$(AR) rcs $(TARGET) $(OBJECTS) $(LIBS)
endif
endif
ifdef SHARED_LIBRARY_TARGET
ifdef LINUX_TARGET
ifdef LINUX_HOST
	$(if $(basename $(basename $(VER))),ln -sf $(LP)$(MODULE)$(SO)$(VER) $(OBJ)$(LP)$(MODULE)$(SO)$(basename $(basename $(VER))),)
	$(if $(basename $(VER)),ln -sf $(LP)$(MODULE)$(SO)$(VER) $(OBJ)$(LP)$(MODULE)$(SO)$(basename $(VER)),)
	$(if $(VER),ln -sf $(LP)$(MODULE)$(SO)$(VER) $(OBJ)$(LP)$(MODULE)$(SO),)
endif
endif
endif
	$(call mkdir,$(GFX_ABSPATH)/$(SODESTDIR))
	$(call cp,$(TARGET),$(GFX_ABSPATH)/$(SODESTDIR))
ifdef SHARED_LIBRARY_TARGET
ifdef LINUX_HOST
ifndef SKIP_SONAME
	$(if $(basename $(VER)),ln -sf $(LP)$(MODULE)$(SO)$(VER) $(GFX_ABSPATH)/$(HOST_SODESTDIR)$(LP)$(MODULE)$(SO)$(basename $(VER)),)
	$(if $(basename $(basename $(VER))),ln -sf $(LP)$(MODULE)$(SO)$(VER) $(GFX_ABSPATH)/$(HOST_SODESTDIR)$(LP)$(MODULE)$(SO)$(basename $(basename $(VER))),)
	$(if $(VER),ln -sf $(LP)$(MODULE)$(SO)$(VER) $(GFX_ABSPATH)/$(HOST_SODESTDIR)$(LP)$(MODULE)$(SO),)
endif
endif
endif

install:
	$(call cp,$(TARGET),"$(DESTLIBDIR)/")
	$(if $(WINDOWS_HOST),,ln -sf $(LP)$(MODULE)$(SOV) $(DESTLIBDIR)/$(LP)$(MODULE)$(SO).0)
	$(if $(WINDOWS_HOST),,ln -sf $(LP)$(MODULE)$(SOV) $(DESTLIBDIR)/$(LP)$(MODULE)$(SO))

# SYMBOL RULES

$(OBJ)Cube.sym: src/gfx/3D/meshes/Cube.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/meshes/Cube.ec) -o $(call quote_path,$@)

$(OBJ)SkyBox.sym: src/gfx/3D/meshes/SkyBox.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/meshes/SkyBox.ec) -o $(call quote_path,$@)

$(OBJ)Sphere.sym: src/gfx/3D/meshes/Sphere.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/meshes/Sphere.ec) -o $(call quote_path,$@)

$(OBJ)e3dDefs.sym: src/gfx/3D/models/e3d/e3dDefs.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/models/e3d/e3dDefs.ec) -o $(call quote_path,$@)

$(OBJ)e3dRead.sym: src/gfx/3D/models/e3d/e3dRead.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/models/e3d/e3dRead.ec) -o $(call quote_path,$@)

$(OBJ)e3dWrite.sym: src/gfx/3D/models/e3d/e3dWrite.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/models/e3d/e3dWrite.ec) -o $(call quote_path,$@)

$(OBJ)Object3DSFormat.sym: src/gfx/3D/models/Object3DSFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/models/Object3DSFormat.ec) -o $(call quote_path,$@)

$(OBJ)e3d.sym: src/gfx/3D/models/e3d.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/models/e3d.ec) -o $(call quote_path,$@)

$(OBJ)Tetrahedron.sym: src/gfx/3D/depthsort/Tetrahedron.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/depthsort/Tetrahedron.ec) -o $(call quote_path,$@)

$(OBJ)TopoSort.sym: src/gfx/3D/depthsort/TopoSort.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/depthsort/TopoSort.ec) -o $(call quote_path,$@)

$(OBJ)DepthSort.sym: src/gfx/3D/depthsort/DepthSort.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/depthsort/DepthSort.ec) -o $(call quote_path,$@)

$(OBJ)Pool.sym: src/gfx/3D/depthsort/Pool.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/depthsort/Pool.ec) -o $(call quote_path,$@)

$(OBJ)Camera.sym: src/gfx/3D/Camera.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Camera.ec) -o $(call quote_path,$@)

$(OBJ)Matrix.sym: src/gfx/3D/Matrix.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Matrix.ec) -o $(call quote_path,$@)

$(OBJ)Mesh.sym: src/gfx/3D/Mesh.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Mesh.ec) -o $(call quote_path,$@)

$(OBJ)Object.sym: src/gfx/3D/Object.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Object.ec) -o $(call quote_path,$@)

$(OBJ)Plane.sym: src/gfx/3D/Plane.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Plane.ec) -o $(call quote_path,$@)

$(OBJ)Quaternion.sym: src/gfx/3D/Quaternion.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Quaternion.ec) -o $(call quote_path,$@)

$(OBJ)Vector3D.sym: src/gfx/3D/Vector3D.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/3D/Vector3D.ec) -o $(call quote_path,$@)

$(OBJ)BMPFormat.sym: src/gfx/bitmaps/BMPFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/BMPFormat.ec) -o $(call quote_path,$@)

$(OBJ)GIFFormat.sym: src/gfx/bitmaps/GIFFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/GIFFormat.ec) -o $(call quote_path,$@)

$(OBJ)JPEGFormat.sym: src/gfx/bitmaps/JPEGFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/JPEGFormat.ec) -o $(call quote_path,$@)

$(OBJ)PCXFormat.sym: src/gfx/bitmaps/PCXFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/PCXFormat.ec) -o $(call quote_path,$@)

$(OBJ)PNGFormat.sym: src/gfx/bitmaps/PNGFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/PNGFormat.ec) -o $(call quote_path,$@)

$(OBJ)RGBFormat.sym: src/gfx/bitmaps/RGBFormat.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/RGBFormat.ec) -o $(call quote_path,$@)

$(OBJ)ETC2Format.sym: src/gfx/bitmaps/ETC2Format.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/bitmaps/ETC2Format.ec) -o $(call quote_path,$@)

$(OBJ)glab.sym: src/gfx/drivers/gl3/glab.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/glab.ec) -o $(call quote_path,$@)

$(OBJ)immediate.sym: src/gfx/drivers/gl3/immediate.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/immediate.ec) -o $(call quote_path,$@)

$(OBJ)matrixStack.sym: src/gfx/drivers/gl3/matrixStack.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/matrixStack.ec) -o $(call quote_path,$@)

$(OBJ)shaders.sym: src/gfx/drivers/gl3/shaders.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/shaders.ec) -o $(call quote_path,$@)

$(OBJ)defaultShader.sym: src/gfx/drivers/gl3/defaultShader.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/defaultShader.ec) -o $(call quote_path,$@)

$(OBJ)GLMultiDraw.sym: src/gfx/drivers/gl3/GLMultiDraw.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/GLMultiDraw.ec) -o $(call quote_path,$@)

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Direct3D8DisplayDriver.sym: src/gfx/drivers/Direct3D8DisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/Direct3D8DisplayDriver.ec) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Direct3D9DisplayDriver.sym: src/gfx/drivers/Direct3D9DisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/Direct3D9DisplayDriver.ec) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)DirectDrawDisplayDriver.sym: src/gfx/drivers/DirectDrawDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/DirectDrawDisplayDriver.ec) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)GDIDisplayDriver.sym: src/gfx/drivers/GDIDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/GDIDisplayDriver.ec) -o $(call quote_path,$@)
endif

$(OBJ)lfbBlit.sym: src/gfx/drivers/lfbBlit.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/lfbBlit.ec) -o $(call quote_path,$@)

$(OBJ)lfbConvert.sym: src/gfx/drivers/lfbConvert.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/lfbConvert.ec) -o $(call quote_path,$@)

$(OBJ)LFBDisplayDriver.sym: src/gfx/drivers/LFBDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/LFBDisplayDriver.ec) -o $(call quote_path,$@)

ifneq ($(or $(LINUX_TARGET),$(OSX_TARGET)),)
$(OBJ)NCursesDisplayDriver.sym: src/gfx/drivers/NCursesDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/NCursesDisplayDriver.ec) -o $(call quote_path,$@)
endif

$(OBJ)OpenGLDisplayDriver.sym: src/gfx/drivers/OpenGLDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/OpenGLDisplayDriver.ec) -o $(call quote_path,$@)

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32BitmapPrinterDisplayDriver.sym: src/gfx/drivers/Win32BitmapPrinterDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/Win32BitmapPrinterDisplayDriver.ec) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32ConsoleDisplayDriver.sym: src/gfx/drivers/Win32ConsoleDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/Win32ConsoleDisplayDriver.ec) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32PrinterDisplayDriver.sym: src/gfx/drivers/Win32PrinterDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/Win32PrinterDisplayDriver.ec) -o $(call quote_path,$@)
endif

ifneq ($(or $(LINUX_TARGET),$(OSX_TARGET)),)
$(OBJ)XDisplayDriver.sym: src/gfx/drivers/XDisplayDriver.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/XDisplayDriver.ec) -o $(call quote_path,$@)
endif

$(OBJ)atlasBuilder.sym: src/gfx/newFonts/atlasBuilder.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,src/gfx/newFonts/atlasBuilder.ec) -o $(call quote_path,$@)

$(OBJ)drawManager.sym: src/gfx/newFonts/drawManager.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,src/gfx/newFonts/drawManager.ec) -o $(call quote_path,$@)

$(OBJ)fmFontManager.sym: src/gfx/newFonts/fmFontManager.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,src/gfx/newFonts/fmFontManager.ec) -o $(call quote_path,$@)

$(OBJ)fontRenderer.sym: src/gfx/newFonts/fontRenderer.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,src/gfx/newFonts/fontRenderer.ec) -o $(call quote_path,$@)

$(OBJ)textureManager.sym: src/gfx/newFonts/textureManager.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,src/gfx/newFonts/textureManager.ec) -o $(call quote_path,$@)

$(OBJ)Bitmap.sym: src/gfx/Bitmap.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/Bitmap.ec) -o $(call quote_path,$@)

$(OBJ)BitmapResource.sym: src/gfx/BitmapResource.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/BitmapResource.ec) -o $(call quote_path,$@)

$(OBJ)Color.sym: src/gfx/Color.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/Color.ec) -o $(call quote_path,$@)

$(OBJ)Display.sym: src/gfx/Display.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/Display.ec) -o $(call quote_path,$@)

$(OBJ)DisplaySystem.sym: src/gfx/DisplaySystem.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/DisplaySystem.ec) -o $(call quote_path,$@)

$(OBJ)FontResource.sym: src/gfx/FontResource.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/FontResource.ec) -o $(call quote_path,$@)

$(OBJ)Resource.sym: src/gfx/Resource.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/Resource.ec) -o $(call quote_path,$@)

$(OBJ)Surface.sym: src/gfx/Surface.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/Surface.ec) -o $(call quote_path,$@)

$(OBJ)fontManagement.sym: src/gfx/fontManagement.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/fontManagement.ec) -o $(call quote_path,$@)

$(OBJ)fontRendering.sym: src/gfx/fontRendering.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/fontRendering.ec) -o $(call quote_path,$@)

$(OBJ)imgDistMap.sym: src/gfx/imgDistMap.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/imgDistMap.ec) -o $(call quote_path,$@)

$(OBJ)Extent.sym: src/gfx/Extent.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/Extent.ec) -o $(call quote_path,$@)

# C OBJECT RULES

$(OBJ)Cube.c: src/gfx/3D/meshes/Cube.ec $(OBJ)Cube.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/meshes/Cube.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)SkyBox.c: src/gfx/3D/meshes/SkyBox.ec $(OBJ)SkyBox.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/meshes/SkyBox.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Sphere.c: src/gfx/3D/meshes/Sphere.ec $(OBJ)Sphere.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/meshes/Sphere.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)e3dDefs.c: src/gfx/3D/models/e3d/e3dDefs.ec $(OBJ)e3dDefs.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/models/e3d/e3dDefs.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)e3dRead.c: src/gfx/3D/models/e3d/e3dRead.ec $(OBJ)e3dRead.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/models/e3d/e3dRead.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)e3dWrite.c: src/gfx/3D/models/e3d/e3dWrite.ec $(OBJ)e3dWrite.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/models/e3d/e3dWrite.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Object3DSFormat.c: src/gfx/3D/models/Object3DSFormat.ec $(OBJ)Object3DSFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/models/Object3DSFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)e3d.c: src/gfx/3D/models/e3d.ec $(OBJ)e3d.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/models/e3d.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Tetrahedron.c: src/gfx/3D/depthsort/Tetrahedron.ec $(OBJ)Tetrahedron.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/depthsort/Tetrahedron.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)TopoSort.c: src/gfx/3D/depthsort/TopoSort.ec $(OBJ)TopoSort.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/depthsort/TopoSort.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)DepthSort.c: src/gfx/3D/depthsort/DepthSort.ec $(OBJ)DepthSort.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/depthsort/DepthSort.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Pool.c: src/gfx/3D/depthsort/Pool.ec $(OBJ)Pool.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/depthsort/Pool.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Camera.c: src/gfx/3D/Camera.ec $(OBJ)Camera.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Camera.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Matrix.c: src/gfx/3D/Matrix.ec $(OBJ)Matrix.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Matrix.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Mesh.c: src/gfx/3D/Mesh.ec $(OBJ)Mesh.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Mesh.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Object.c: src/gfx/3D/Object.ec $(OBJ)Object.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Object.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Plane.c: src/gfx/3D/Plane.ec $(OBJ)Plane.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Plane.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Quaternion.c: src/gfx/3D/Quaternion.ec $(OBJ)Quaternion.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Quaternion.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Vector3D.c: src/gfx/3D/Vector3D.ec $(OBJ)Vector3D.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/3D/Vector3D.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)BMPFormat.c: src/gfx/bitmaps/BMPFormat.ec $(OBJ)BMPFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/BMPFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)GIFFormat.c: src/gfx/bitmaps/GIFFormat.ec $(OBJ)GIFFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/GIFFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)JPEGFormat.c: src/gfx/bitmaps/JPEGFormat.ec $(OBJ)JPEGFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/JPEGFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)PCXFormat.c: src/gfx/bitmaps/PCXFormat.ec $(OBJ)PCXFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/PCXFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)PNGFormat.c: src/gfx/bitmaps/PNGFormat.ec $(OBJ)PNGFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/PNGFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)RGBFormat.c: src/gfx/bitmaps/RGBFormat.ec $(OBJ)RGBFormat.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/RGBFormat.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)ETC2Format.c: src/gfx/bitmaps/ETC2Format.ec $(OBJ)ETC2Format.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/bitmaps/ETC2Format.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)glab.c: src/gfx/drivers/gl3/glab.ec $(OBJ)glab.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/gl3/glab.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)immediate.c: src/gfx/drivers/gl3/immediate.ec $(OBJ)immediate.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/gl3/immediate.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)matrixStack.c: src/gfx/drivers/gl3/matrixStack.ec $(OBJ)matrixStack.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/gl3/matrixStack.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)shaders.c: src/gfx/drivers/gl3/shaders.ec $(OBJ)shaders.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/gl3/shaders.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)defaultShader.c: src/gfx/drivers/gl3/defaultShader.ec $(OBJ)defaultShader.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/gl3/defaultShader.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)GLMultiDraw.c: src/gfx/drivers/gl3/GLMultiDraw.ec $(OBJ)GLMultiDraw.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/gl3/GLMultiDraw.ec) -o $(call quote_path,$@) -symbols $(OBJ)

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Direct3D8DisplayDriver.c: src/gfx/drivers/Direct3D8DisplayDriver.ec $(OBJ)Direct3D8DisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/Direct3D8DisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Direct3D9DisplayDriver.c: src/gfx/drivers/Direct3D9DisplayDriver.ec $(OBJ)Direct3D9DisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/Direct3D9DisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)DirectDrawDisplayDriver.c: src/gfx/drivers/DirectDrawDisplayDriver.ec $(OBJ)DirectDrawDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/DirectDrawDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)GDIDisplayDriver.c: src/gfx/drivers/GDIDisplayDriver.ec $(OBJ)GDIDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/GDIDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

$(OBJ)lfbBlit.c: src/gfx/drivers/lfbBlit.ec $(OBJ)lfbBlit.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/lfbBlit.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)lfbConvert.c: src/gfx/drivers/lfbConvert.ec $(OBJ)lfbConvert.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/lfbConvert.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)LFBDisplayDriver.c: src/gfx/drivers/LFBDisplayDriver.ec $(OBJ)LFBDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/LFBDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)

ifneq ($(or $(LINUX_TARGET),$(OSX_TARGET)),)
$(OBJ)NCursesDisplayDriver.c: src/gfx/drivers/NCursesDisplayDriver.ec $(OBJ)NCursesDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/NCursesDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

$(OBJ)OpenGLDisplayDriver.c: src/gfx/drivers/OpenGLDisplayDriver.ec $(OBJ)OpenGLDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/OpenGLDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32BitmapPrinterDisplayDriver.c: src/gfx/drivers/Win32BitmapPrinterDisplayDriver.ec $(OBJ)Win32BitmapPrinterDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/Win32BitmapPrinterDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32ConsoleDisplayDriver.c: src/gfx/drivers/Win32ConsoleDisplayDriver.ec $(OBJ)Win32ConsoleDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/Win32ConsoleDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32PrinterDisplayDriver.c: src/gfx/drivers/Win32PrinterDisplayDriver.ec $(OBJ)Win32PrinterDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/Win32PrinterDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

ifneq ($(or $(LINUX_TARGET),$(OSX_TARGET)),)
$(OBJ)XDisplayDriver.c: src/gfx/drivers/XDisplayDriver.ec $(OBJ)XDisplayDriver.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/drivers/XDisplayDriver.ec) -o $(call quote_path,$@) -symbols $(OBJ)
endif

$(OBJ)atlasBuilder.c: src/gfx/newFonts/atlasBuilder.ec $(OBJ)atlasBuilder.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/newFonts/atlasBuilder.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)drawManager.c: src/gfx/newFonts/drawManager.ec $(OBJ)drawManager.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/newFonts/drawManager.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)fmFontManager.c: src/gfx/newFonts/fmFontManager.ec $(OBJ)fmFontManager.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/newFonts/fmFontManager.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)fontRenderer.c: src/gfx/newFonts/fontRenderer.ec $(OBJ)fontRenderer.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/newFonts/fontRenderer.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)textureManager.c: src/gfx/newFonts/textureManager.ec $(OBJ)textureManager.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/newFonts/textureManager.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Bitmap.c: src/gfx/Bitmap.ec $(OBJ)Bitmap.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/Bitmap.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)BitmapResource.c: src/gfx/BitmapResource.ec $(OBJ)BitmapResource.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/BitmapResource.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Color.c: src/gfx/Color.ec $(OBJ)Color.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/Color.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Display.c: src/gfx/Display.ec $(OBJ)Display.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/Display.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)DisplaySystem.c: src/gfx/DisplaySystem.ec $(OBJ)DisplaySystem.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/DisplaySystem.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)FontResource.c: src/gfx/FontResource.ec $(OBJ)FontResource.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/FontResource.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Resource.c: src/gfx/Resource.ec $(OBJ)Resource.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/Resource.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Surface.c: src/gfx/Surface.ec $(OBJ)Surface.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/Surface.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)fontManagement.c: src/gfx/fontManagement.ec $(OBJ)fontManagement.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/fontManagement.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)fontRendering.c: src/gfx/fontRendering.ec $(OBJ)fontRendering.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/fontRendering.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)imgDistMap.c: src/gfx/imgDistMap.ec $(OBJ)imgDistMap.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/imgDistMap.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)Extent.c: src/gfx/Extent.ec $(OBJ)Extent.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,src/gfx/Extent.ec) -o $(call quote_path,$@) -symbols $(OBJ)

# OBJECT RULES

$(OBJ)Cube$(O): $(OBJ)Cube.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Cube.c) -o $(call quote_path,$@)

$(OBJ)SkyBox$(O): $(OBJ)SkyBox.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)SkyBox.c) -o $(call quote_path,$@)

$(OBJ)Sphere$(O): $(OBJ)Sphere.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Sphere.c) -o $(call quote_path,$@)

$(OBJ)e3dDefs$(O): $(OBJ)e3dDefs.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)e3dDefs.c) -o $(call quote_path,$@)

$(OBJ)e3dRead$(O): $(OBJ)e3dRead.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)e3dRead.c) -o $(call quote_path,$@)

$(OBJ)e3dWrite$(O): $(OBJ)e3dWrite.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)e3dWrite.c) -o $(call quote_path,$@)

$(OBJ)Object3DSFormat$(O): $(OBJ)Object3DSFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Object3DSFormat.c) -o $(call quote_path,$@)

$(OBJ)e3d$(O): $(OBJ)e3d.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)e3d.c) -o $(call quote_path,$@)

$(OBJ)Tetrahedron$(O): $(OBJ)Tetrahedron.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Tetrahedron.c) -o $(call quote_path,$@)

$(OBJ)TopoSort$(O): $(OBJ)TopoSort.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)TopoSort.c) -o $(call quote_path,$@)

$(OBJ)DepthSort$(O): $(OBJ)DepthSort.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)DepthSort.c) -o $(call quote_path,$@)

$(OBJ)Pool$(O): $(OBJ)Pool.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Pool.c) -o $(call quote_path,$@)

$(OBJ)Camera$(O): $(OBJ)Camera.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Camera.c) -o $(call quote_path,$@)

$(OBJ)Matrix$(O): $(OBJ)Matrix.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Matrix.c) -o $(call quote_path,$@)

$(OBJ)Mesh$(O): $(OBJ)Mesh.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Mesh.c) -o $(call quote_path,$@)

$(OBJ)Object$(O): $(OBJ)Object.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Object.c) -o $(call quote_path,$@)

$(OBJ)Plane$(O): $(OBJ)Plane.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Plane.c) -o $(call quote_path,$@)

$(OBJ)Quaternion$(O): $(OBJ)Quaternion.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Quaternion.c) -o $(call quote_path,$@)

$(OBJ)Vector3D$(O): $(OBJ)Vector3D.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Vector3D.c) -o $(call quote_path,$@)

$(OBJ)BMPFormat$(O): $(OBJ)BMPFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)BMPFormat.c) -o $(call quote_path,$@)

$(OBJ)GIFFormat$(O): $(OBJ)GIFFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)GIFFormat.c) -o $(call quote_path,$@)

$(OBJ)JPEGFormat$(O): $(OBJ)JPEGFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)JPEGFormat.c) -o $(call quote_path,$@)

$(OBJ)PCXFormat$(O): $(OBJ)PCXFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)PCXFormat.c) -o $(call quote_path,$@)

$(OBJ)PNGFormat$(O): $(OBJ)PNGFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)PNGFormat.c) -o $(call quote_path,$@)

$(OBJ)RGBFormat$(O): $(OBJ)RGBFormat.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)RGBFormat.c) -o $(call quote_path,$@)

$(OBJ)ETC2Format$(O): $(OBJ)ETC2Format.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)ETC2Format.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-freetype$(O): src/gfx/drivers/harfbuzz/unicode/harfbuzz-freetype.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/unicode/harfbuzz-freetype.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-unicode-tables$(O): src/gfx/drivers/harfbuzz/unicode/harfbuzz-unicode-tables.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/unicode/harfbuzz-unicode-tables.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-unicode$(O): src/gfx/drivers/harfbuzz/unicode/harfbuzz-unicode.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/unicode/harfbuzz-unicode.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-arabic$(O): src/gfx/drivers/harfbuzz/harfbuzz-arabic.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-arabic.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-buffer$(O): src/gfx/drivers/harfbuzz/harfbuzz-buffer.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-buffer.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-gdef$(O): src/gfx/drivers/harfbuzz/harfbuzz-gdef.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-gdef.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-gpos$(O): src/gfx/drivers/harfbuzz/harfbuzz-gpos.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-gpos.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-gsub$(O): src/gfx/drivers/harfbuzz/harfbuzz-gsub.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-gsub.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-hangul$(O): src/gfx/drivers/harfbuzz/harfbuzz-hangul.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-hangul.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-hebrew$(O): src/gfx/drivers/harfbuzz/harfbuzz-hebrew.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-hebrew.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-indic$(O): src/gfx/drivers/harfbuzz/harfbuzz-indic.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-indic.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-khmer$(O): src/gfx/drivers/harfbuzz/harfbuzz-khmer.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-khmer.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-myanmar$(O): src/gfx/drivers/harfbuzz/harfbuzz-myanmar.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-myanmar.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-open$(O): src/gfx/drivers/harfbuzz/harfbuzz-open.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-open.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-shaper$(O): src/gfx/drivers/harfbuzz/harfbuzz-shaper.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-shaper.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-stream$(O): src/gfx/drivers/harfbuzz/harfbuzz-stream.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-stream.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-tibetan$(O): src/gfx/drivers/harfbuzz/harfbuzz-tibetan.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-tibetan.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-impl$(O): src/gfx/drivers/harfbuzz/harfbuzz-impl.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-impl.c) -o $(call quote_path,$@)

$(OBJ)harfbuzz-thai$(O): src/gfx/drivers/harfbuzz/harfbuzz-thai.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/harfbuzz/harfbuzz-thai.c) -o $(call quote_path,$@)

$(OBJ)glab$(O): $(OBJ)glab.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)glab.c) -o $(call quote_path,$@)

$(OBJ)immediate$(O): $(OBJ)immediate.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)immediate.c) -o $(call quote_path,$@)

$(OBJ)matrixStack$(O): $(OBJ)matrixStack.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)matrixStack.c) -o $(call quote_path,$@)

$(OBJ)gl_compat_4_4$(O): src/gfx/drivers/gl3/gl_compat_4_4.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,src/gfx/drivers/gl3/gl_compat_4_4.c) -o $(call quote_path,$@)

$(OBJ)shaders$(O): $(OBJ)shaders.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)shaders.c) -o $(call quote_path,$@)

$(OBJ)defaultShader$(O): $(OBJ)defaultShader.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)defaultShader.c) -o $(call quote_path,$@)

$(OBJ)GLMultiDraw$(O): $(OBJ)GLMultiDraw.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)GLMultiDraw.c) -o $(call quote_path,$@)

$(OBJ)QuickETC2Pak$(O): deps/etcpak/QuickETC2Pak.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,deps/etcpak/QuickETC2Pak.c) -o $(call quote_path,$@)

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Direct3D8DisplayDriver$(O): $(OBJ)Direct3D8DisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Direct3D8DisplayDriver.c) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Direct3D9DisplayDriver$(O): $(OBJ)Direct3D9DisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Direct3D9DisplayDriver.c) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)DirectDrawDisplayDriver$(O): $(OBJ)DirectDrawDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)DirectDrawDisplayDriver.c) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)GDIDisplayDriver$(O): $(OBJ)GDIDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)GDIDisplayDriver.c) -o $(call quote_path,$@)
endif

$(OBJ)lfbBlit$(O): $(OBJ)lfbBlit.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)lfbBlit.c) -o $(call quote_path,$@)

$(OBJ)lfbConvert$(O): $(OBJ)lfbConvert.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)lfbConvert.c) -o $(call quote_path,$@)

$(OBJ)LFBDisplayDriver$(O): $(OBJ)LFBDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)LFBDisplayDriver.c) -o $(call quote_path,$@)

ifneq ($(or $(LINUX_TARGET),$(OSX_TARGET)),)
$(OBJ)NCursesDisplayDriver$(O): $(OBJ)NCursesDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)NCursesDisplayDriver.c) -o $(call quote_path,$@)
endif

$(OBJ)OpenGLDisplayDriver$(O): $(OBJ)OpenGLDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)OpenGLDisplayDriver.c) -o $(call quote_path,$@)

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32BitmapPrinterDisplayDriver$(O): $(OBJ)Win32BitmapPrinterDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Win32BitmapPrinterDisplayDriver.c) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32ConsoleDisplayDriver$(O): $(OBJ)Win32ConsoleDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Win32ConsoleDisplayDriver.c) -o $(call quote_path,$@)
endif

ifneq ($(WINDOWS_TARGET),)
$(OBJ)Win32PrinterDisplayDriver$(O): $(OBJ)Win32PrinterDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Win32PrinterDisplayDriver.c) -o $(call quote_path,$@)
endif

ifneq ($(or $(LINUX_TARGET),$(OSX_TARGET)),)
$(OBJ)XDisplayDriver$(O): $(OBJ)XDisplayDriver.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)XDisplayDriver.c) -o $(call quote_path,$@)
endif

$(OBJ)cc$(O): $(EC_SDK_SRC)/ecrt/src/containers/cc/cc.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,$(EC_SDK_SRC)/ecrt/src/containers/cc/cc.c) -o $(call quote_path,$@)

$(OBJ)mm$(O): $(EC_SDK_SRC)/ecrt/src/containers/cc/mm.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,$(EC_SDK_SRC)/ecrt/src/containers/cc/mm.c) -o $(call quote_path,$@)

$(OBJ)ccstr$(O): $(EC_SDK_SRC)/ecrt/src/containers/cc/ccstr.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,$(EC_SDK_SRC)/ecrt/src/containers/cc/ccstr.c) -o $(call quote_path,$@)

$(OBJ)mmhash$(O): $(EC_SDK_SRC)/ecrt/src/containers/cc/mmhash.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) -c $(call quote_path,$(EC_SDK_SRC)/ecrt/src/containers/cc/mmhash.c) -o $(call quote_path,$@)

$(OBJ)atlasBuilder$(O): $(OBJ)atlasBuilder.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)atlasBuilder.c) -o $(call quote_path,$@)

$(OBJ)drawManager$(O): $(OBJ)drawManager.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)drawManager.c) -o $(call quote_path,$@)

$(OBJ)fmFontManager$(O): $(OBJ)fmFontManager.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)fmFontManager.c) -o $(call quote_path,$@)

$(OBJ)fontRenderer$(O): $(OBJ)fontRenderer.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)fontRenderer.c) -o $(call quote_path,$@)

$(OBJ)textureManager$(O): $(OBJ)textureManager.c
	$(CC) $(CFLAGS) $(CUSTOM1_PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)textureManager.c) -o $(call quote_path,$@)

$(OBJ)Bitmap$(O): $(OBJ)Bitmap.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Bitmap.c) -o $(call quote_path,$@)

$(OBJ)BitmapResource$(O): $(OBJ)BitmapResource.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)BitmapResource.c) -o $(call quote_path,$@)

$(OBJ)Color$(O): $(OBJ)Color.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Color.c) -o $(call quote_path,$@)

$(OBJ)Display$(O): $(OBJ)Display.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Display.c) -o $(call quote_path,$@)

$(OBJ)DisplaySystem$(O): $(OBJ)DisplaySystem.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)DisplaySystem.c) -o $(call quote_path,$@)

$(OBJ)FontResource$(O): $(OBJ)FontResource.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)FontResource.c) -o $(call quote_path,$@)

$(OBJ)Resource$(O): $(OBJ)Resource.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Resource.c) -o $(call quote_path,$@)

$(OBJ)Surface$(O): $(OBJ)Surface.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Surface.c) -o $(call quote_path,$@)

$(OBJ)fontManagement$(O): $(OBJ)fontManagement.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)fontManagement.c) -o $(call quote_path,$@)

$(OBJ)fontRendering$(O): $(OBJ)fontRendering.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)fontRendering.c) -o $(call quote_path,$@)

$(OBJ)imgDistMap$(O): $(OBJ)imgDistMap.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)imgDistMap.c) -o $(call quote_path,$@)

$(OBJ)Extent$(O): $(OBJ)Extent.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Extent.c) -o $(call quote_path,$@)

$(OBJ)$(MODULE).main$(O): $(OBJ)$(MODULE).main.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(OBJ)$(MODULE).main.c -o $(call quote_path,$@)

cleantarget:
	$(call rm,$(OBJ)$(MODULE).main$(O) $(OBJ)$(MODULE).main.c $(OBJ)$(MODULE).main.ec $(OBJ)$(MODULE).main$(I) $(OBJ)$(MODULE).main$(S))
	$(call rm,$(OBJ)symbols.lst)
	$(call rm,$(OBJ)objects.lst)
	$(call rm,$(TARGET))
ifdef SHARED_LIBRARY_TARGET
ifdef LINUX_TARGET
ifdef LINUX_HOST
	$(call rm,$(OBJ)$(LP)$(MODULE)$(SO)$(basename $(VER)))
	$(call rm,$(OBJ)$(LP)$(MODULE)$(SO))
endif
endif
endif

clean: cleantarget
	$(call rm,$(_OBJECTS))
	$(call rm,$(_ECOBJECTS1))
	$(call rm,$(_ECOBJECTS2))
	$(call rm,$(_COBJECTS1))
	$(call rm,$(_COBJECTS2))
	$(call rm,$(_BOWLS1))
	$(call rm,$(_BOWLS2))
	$(call rm,$(_IMPORTS1))
	$(call rm,$(_IMPORTS2))
	$(call rm,$(_SYMBOLS1))
	$(call rm,$(_SYMBOLS2))
ifdef USE_RESOURCES_EAR
	$(call rm,$(RESOURCES_EAR))
endif

realclean: cleantarget
	$(call rmr,$(OBJ))

distclean: cleantarget
	$(call rmr,obj/)
	$(call rmr,.configs/)
	$(call rm,*.ews)
	$(call rm,*.Makefile)
