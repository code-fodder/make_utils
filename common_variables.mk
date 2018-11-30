#colours for aesthetics
RED := \033[1;31m
GREEN := \033[1;32m
YELLOW := \033[1;33m
BLUE := \033[1;34m
CYAN := \033[1;36m
NC := \033[m

# Util functions to return the root makefile name and the current makefile name
GET_THIS_MAKEFILE = $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
GET_ROOT_MAKEFILE = $(firstword $(MAKEFILE_LIST))

# For printing. This takes a copy of all the environment variables. We take
# this copy before we set any variables so that we can filter those variables 
# out later and just print the new variables we have set.
VARS_OLD := $(.VARIABLES)
VARS_OLD := $(filter-out TARGET CC CXX RANLIB AR PATH FLAGS_TARGET LIB_DEPS BUILD_SUFFIX,$(VARS_OLD))

# This is really just a reminder. Can use these variables as required.
# Rule format is  "$@: $<"
RULE_TARGET = $@
RULE_DEPENDENCY = $<

### Build Configuation ###
# Passed in build variables they are just here for reference really - they are already set.
TARGET ?=
BUILD_TYPE ?=
CC ?=
CXX ?=
RANLIB ?=
AR ?=
PATH ?=
FLAGS_TARGET ?=
# Other build variables
CFLAGS = $(FLAGS_TARGET)
LFLAGS = $(FLAGS_TARGET)
DEFINES =

### Commands ###
MAKE_DIR = mkdir -p
RM = rm -rf

### Inputs ###
# Source directories
SOURCE_DIRS = .
# Source files (can be manually added or allow var_expansions to find then for you)
SOURCES =
# Paths where required headers files are found
INC_DIRS = .
# Header files (not sure if this will be used/needed for anything - useful for printing/debugging)
HEADERS =
# List of paths to include (-I<path>) used by the compiler
INC_PATHS =

### Dependencies ###
# These are folders which contain makefile that this project depends on building first
DEP_MAKE_DIRS =
# This is the make goal to pass to the dependency make project dir
DEP_MAKE_GOAL =
# Libs deps contains the library linker-command options (-Lpaths and -llib names)
LIB_DEPS ?=
# These are the required libraries that need linking
LIB_DEP_LIBS =
# The common standard libraries
STANDARD_LIBS = -lstdc++ -lpthread -lrt

### Outputs ###
# The name of the generated executable/library is dependant on this
PROJECT_NAME = out
# Location where the object files are put
OBJECT_DIR = obj/$(TARGET)_$(BUILD_TYPE)
# List of object files
OBJECTS =
# Location where the object deps (obj.d) files are put
DEP_DIR = dep/$(TARGET)_$(BUILD_TYPE)
# Object specific dependencies (obj.d files)
DEPS =
# Location where binary/executable output files are put
BIN_DIR = bin
# Location where the libary files are put
LIB_DIR = lib
# The output directory - this is set to BIN_DIR or LIB_DIR depending on the type of output required, can be set manually or by calling
# common_executable.mk or common_shared_lib.mk
OUTPUT_DIR = $(BIN_DIR)
# project name should be set in makefile*.mk. It can be modified into OUTPUT_FILE depending on output type (e.g. library) and
# build type (release/debug)
OUTPUT_FILE = $(PROJECT_NAME)
# Items to clean for the currecnt specific target
CLEAN_ITEMS =
# Items to clean for all targets
CLEANALL_ITEMS =

### Warnings ###
# Warning flags used by the C compiler
FLAGS_C_WARNINGS =
# Warning flags used by the C++ compiler
FLAGS_CPP_WARNINGS =
# Base levels
FLAGS_WARNINGS_BASE =
FLAGS_WARNINGS_CPP_BASE =
FLAGS_WARNINGS_C_BASE =
# Selectable levels
FLAGS_WARNINGS_CPP_HOST =
FLAGS_WARNINGS_CPP_TARGET =
FLAGS_WARNINGS_C_HOST =
FLAGS_WARNINGS_C_TARGET =
FLAGS_WARNINGS_DISABLED =

# Third party flag - set to true if the project is 3rd party and then warnings and other checks will not be applied
FLAGS_THIRD_PARTY = false