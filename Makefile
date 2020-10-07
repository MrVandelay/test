#
# This is a Makefile duh
#
# make clean 
# make all 
# make all BASE_OUTDIR=out OUTFILE=thebin
#
# Settings: 
#  BUILD_OUTDIRS_TREE TRUE if same treestructure as srcfiles are located in should be created
#  in the $(OUTDIR) FALSE all o files will be created in the $(OUTDIR) 
#  
#  EXT What files to build c (*.c) or cpp (*.cpp)  or both (*.c*)
#
#  BASE_SRCDIRS Where to start searching for c and/or cpp files. The Makefile will build all
#  sourcefiles in the defined directories and its subdirectories.
#

# Create the same tree-structur in the $(BASE_OUTDIR) as in the source directories
BUILD_OUTDIRS_TREE=FALSE

EXT_PATH=/home/seprjfmo/wh2/sources/ascom/application

# What should we build Build c (*.c) or cpp (*.cpp)  or both (*.c*)
EXT="cpp|c"



#ifeq ($(PCENV),1)
	#CPPFLAGS += -DPCENV -DPCENV_ROOT="\"$(PCENV_ROOT)\"" -DDEBUG_TRACE_STDOUT
	#CFLAGS   += -fno-omit-frame-pointer -g
	#CXXFLAGS += -fno-omit-frame-pointer -g
	LDFLAGS  += -Wl,-rpath=$(EXT_PATH)/build/Ascom_i63/lib

	CFLAGS   += -fsanitize=address  
	CXXFLAGS +=  -Wuninitialized -Wall -Wextra -O1
#	LDFLAGS  += -fsanitize=address




#endif
#-Wall -Wextra -Wuninitialized -Wuninitialized -Weffc++
# Where to search for source files
BASE_SRCDIRS = \
          src \
          
#          $(EXT_PATH)/WLANManager/Netlink

# Create a list of all source directories 
SRCDIRS := $(sort $(foreach module, $(BASE_SRCDIRS), ${shell find ${module} -mindepth 0 -type d -print}) )

INCDIRS = \
          $(SRCDIRS) \
         
         # /home/seprjfmo/ascom-wh2/1.0.0/sysroots/cortexa7hf-neon-poky-linux-gnueabi/usr/src/kernel/include \
         # /home/seprjfmo/ascom-wh2/1.0.0/sysroots/cortexa7hf-neon-poky-linux-gnueabi/usr/src/kernel/arch/arm/include/
         
          #$(EXT_PATH) \
          $(EXT_PATH)/WLANManager
                   
# If the base out dircectory (BASE_OUTDIR) is not provided in the makecall then set it to "out"
ifeq ($(BASE_OUTDIR),)
   BASE_OUTDIR=out
endif

# If the name of the file to buld (OUTFILE) is not provided in the makecall then set it to "thebinfile"
ifeq ($(OUTFILE),)
   OUTFILE=$(BASE_OUTDIR)/test
else
   override OUTFILE:=$(BASE_OUTDIR)/$(OUTFILE)
endif

COMMON_BASE_SRCDIRS = $(sort $(foreach dir, $(BASE_SRCDIRS),$(word 1,$(subst /, ,$(dir)))))
BASE_DIR_TO_REPLACE=
ifeq ($(words $(COMMON_BASE_SRCDIRS)),1)
   BASE_DIR_TO_REPLACE=$(COMMON_BASE_SRCDIRS)/
endif

# Create a list of all sorucefiles to build, both c and cpp
#SRCFILES = $(foreach dir,$(SRCDIRS),$(shell find $(dir) -maxdepth 1 -name $(EXT)))

SRCFILES = $(foreach dir,$(SRCDIRS),$(shell find $(dir) -maxdepth 1 -type f -regex '.*/.*\.\('$(subst |,\|,$(EXT))'\)' ))
#This will tell the compiler where to search for c and cpp files
vpath %.c $(dir $(SRCFILES))
vpath %.cpp $(dir $(SRCFILES))

# Create a list of all  object files that should be created
OBJFILES = $(patsubst $(BASE_DIR_TO_REPLACE)%.c,$(BASE_OUTDIR)/%.o,$(SRCFILES))
OBJFILES := $(patsubst $(BASE_DIR_TO_REPLACE)%.cpp,$(BASE_OUTDIR)/%.o,$(OBJFILES))
ifeq ($(BUILD_OUTDIRS_TREE),FALSE)
   OBJFILES := $(addprefix $(BASE_OUTDIR)/,$(notdir $(OBJFILES)))
endif

# Create a list of all out dirs that should be created, only folders with c and/or cpp files 
OUTDIRS = $(sort $(dir $(OBJFILES)))

# Create a list of all include paths
#INC_PARAMS = $(foreach dir,$(INCDIRS), $(patsubst %,-I%,$(wildcard $(dir))))
INC_PARAMS = $(addprefix -I,$(INCDIRS))
CXXFLAGS+=$(INC_PARAMS)   -DPCENV -std=c++11
CFLAGS+=$(INC_PARAMS)  


#-fno-elide-constructors
ifeq ($(DEBUG),1)
LIBS += -L/home/seprjfmo/eclipse-workspace/debugWrap/out -ldebugWrap -lssl -lcrypto $(aes_obj) -lsqlite3
#LDFLAGS += -Wl,-wrap,malloc -Wl,-wrap=malloc -Wl,-wrap=calloc -Wl,-wrap=realloc -Wl,-wrap=free
LDFLAGS += -Wl,-wrap,malloc -Wl,-wrap=malloc
endif


# Libraries
#LIBSDYN = -Wl,-Bdynamic -lpthread -lrt -lz -lnl-genl-3 -lnl-3 -lwpa_client
#LIBS +=  -L.
#LIBS +=  -lbase -lnl-genl-3 -lnl-3 
#LIBS +=  -L/home/seprjfmo/eclipse-workspace/usbTest/out -lusbg -lconfig
#pkg-config --cflags --libs libsystemd

# To create the dependency files
DEPFLAGS = -MT $@ -MD -MP

# This is just te print som debug data
.PHONY: print
print:
	@echo $(INC_PARAMS)
	@echo $(INCDIRS)
 
# The make all will create the out directories, objectfiles and finaly the binary
.PHONY: all
all: MAKE_OUTDIRS  $(OUTFILE)
	@echo ---------------------------- Everything is built ----------------------------

#aes_obj := src/aes_key_x86_64.o


# Link all the objectfiles in the output dir to one binary
$(OUTFILE): $(OBJFILES) 
	$(CXX)  -o $(OUTFILE) ${aes_obj} $(OBJFILES) $(LDFLAGS) $(LIBSDYN)   $(LIBS) 

# Build every cpp and c file in the source dir and put in the output dir
# We also take the oppurtunity to generate dep files 
$(BASE_OUTDIR)/%.o:%.cpp
	@echo $()
	$(CXX) $(CXXFLAGS)  -g $(DEPFLAGS) -c $< -o $@  

$(BASE_OUTDIR)/%.o: %.c
	$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

install:
	adb push $(OUTFILE) /usr/bin

# Here we have the depency rules that are generated above
-include $(OBJFILES:.o=.d)

# Create all the output librarys
.PHONY: MAKE_OUTDIRS
MAKE_OUTDIRS: $(OUTDIRS)

$(OUTDIRS):
	mkdir -p $(OUTDIRS)

.PHONY: clean
clean:
ifeq ($(BASE_OUTDIR),.)
	rm -f $(OUTDIR)/*.o rm -f $(OUTFILE)
else
	rm -rf $(BASE_OUTDIR)
endif
	@echo ---------------------------- Everything is clean ----------------------------
