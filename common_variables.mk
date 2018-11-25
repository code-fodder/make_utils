#colours for aesthetics
RED := \033[1;31m
GREEN := \033[1;32m
YELLOW := \033[1;33m
BLUE := \033[1;34m
CYAN := \033[1;36m
NC := \033[m

# If no goals are set then use the default goal "build"
.DEFAULT_GOAL = build

# For printing. This takes a copy of all the environment variables. We take
# this copy before we set any variables so that we can filter those variables 
# out later and just print the new variables we have set.
VARS_OLD := $(.VARIABLES)
VARS_OLD := $(filter-out TARGET CC CXX RANLIB AR PATH FLAGS_TARGET LIB_DEPS,$(VARS_OLD))

# Just for me so I can read my own makefile :o
RULE_TARGET = $@
RULE_DEPENDENCY = $<

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

# Resolve lib deps into the correct library names
LIB_DEPS ?=
LIB_DEP_INCS = 
LIB_DEP_PROJECT_DIRS =
LIB_DEP_TARGETS = 
# These are dependencies on other makefile projects (for example testers or such)
PROJECT_DEPS =

#Commands
MAKE_DIR = mkdir -p
RM = rm -rf

# Source
SOURCE_DIRS = .
SOURCES =
INC_DIRS = .
HEADERS =
INC_PATHS =

# Outputs
PROJECT_NAME = out
OBJECT_DIR = obj/$(TARGET)_$(BUILD_TYPE)
OBJECTS =
DEP_DIR = dep/$(TARGET)_$(BUILD_TYPE)
DEPS =
BIN_DIR = bin/$(TARGET)_$(BUILD_TYPE)
LIB_DIR = lib
OUTPUT_DIR = $(BIN_DIR)
# Note this must be set in the makefile.mk
OUTPUT_FILE = $(PROJECT_NAME)
CLEAN_ITEMS =
CLEANALL_ITEMS = 

# Warnings
FLAGS_C_WARNINGS =
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

# Third party flag
FLAGS_THIRD_PARTY = false