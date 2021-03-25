#
# This is a Makefile duh
#
# make clean 
# make all 
# make all BASE_OUTDIR=out OUTFILE=theDim
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

EXT_PATH=

# What should we build Build c (*.c) or cpp (*.cpp)  or both (*.c*)
EXT="cpp|c"

# Where to search for source files
BASE_SRCDIRS = \
          src \
          
# Create a list of all source directories 
SRCDIRS := $(sort $(foreach module, $(BASE_SRCDIRS), ${shell find ${module} -mindepth 0 -type d -print}) )
# Where to search for include files
INCDIRS = 
# If the base out dircectory (BASE_OUTDIR) is not provided in the makecall then set it to "out"
BASE_OUTDIR?=out
# Where to install the outfile
DESTDIR?=/usr/bin
# If the name of the file to buld (OUTFILE_NAME) is not provided in the makecall then set it to "thebinfile"
OUTFILE_NAME?=kaffe
# Complete name with path 
OUTFILE=$(BASE_OUTDIR)/$(OUTFILE_NAME)

COMMON_BASE_SRCDIRS = $(sort $(foreach dir, $(BASE_SRCDIRS),$(word 1,$(subst /, ,$(dir)))))
BASE_DIR_TO_REPLACE=
ifeq ($(words $(COMMON_BASE_SRCDIRS)),1)
   BASE_DIR_TO_REPLACE=$(COMMON_BASE_SRCDIRS)/
endif

# Create a list of all sorucefiles to build, both c and cpp
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
INC_PARAMS = $(addprefix -I,$(INCDIRS))
CXXFLAGS+=$(INC_PARAMS)   -DPCENV -std=c++14
CFLAGS+=$(INC_PARAMS)  

ifeq ($(DEBUG),1)
LIBS += -L/home/fmoberg/eclipse-workspace/debugWrap/out -ldebugWrap 
LDFLAGS += -Wl,-wrap,malloc -Wl,-wrap=malloc
endif

# Libraries
#LIBS +=  -L/home/fmoberg/project/MockData/out -lDimData 
LIBS +=

# To create the dependency files
DEPFLAGS = -MT $@ -MD -MP

# This is just te print som debug data
.PHONY: print
print:
	@echo $(OBJFILES)
 
# The make all will create the out directories, objectfiles and finaly the binary
.PHONY: all
all: MAKE_OUTDIRS  $(OUTFILE)
	@echo ---------------------------- Everything is built ----------------------------

# Link all the objectfiles in the output dir to one binary
$(OUTFILE): $(OBJFILES) 
	$(CXX) -o $(OUTFILE) $(OBJFILES) $(LDFLAGS) $(LIBS) 

# Build every cpp and c file in the source dir and put in the output dir
# We also take the oppurtunity to generate dep files 
$(BASE_OUTDIR)/%.o:%.cpp
	$(CXX) $(CXXFLAGS) $(DEPFLAGS) -c  $< -o $@  

$(BASE_OUTDIR)/%.o: %.c
	$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

.PHONY: install
install: $(OUTFILE)
	cp $(OUTFILE) $(DESTDIR)/$(OUTFILE_NAME)

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
