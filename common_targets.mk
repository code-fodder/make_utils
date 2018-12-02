include make_utils/common_colours.mk

ALL_PARAMS := $(wordlist 1,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
#$(info ALL_PARAMS = $(ALL_PARAMS))
# Only take the first argument as local make goal
SECONDARY_PARAMS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
#$(info SECONDARY_PARAMS = $(SECONDARY_PARAMS))
# Filter out the non-targets - these are special build modifiers
EXTRA_MAKE_GOALS := $(filter-out debug release test verbose,$(SECONDARY_PARAMS))
#$(info EXTRA_MAKE_GOALS = $(EXTRA_MAKE_GOALS))
#$(info DEPS_LIST = $(DEPS_LIST))

# defaults
export TARGET = x86Linux
export BUILD_TYPE = debug
export CC = g++
export CXX = g++
export RANLIB = ranlib
export AR = ar
export FLAGS_TARGET = -m32
export BUILD_SUFFIX = d
export FLAG_VERBOSE = 

# Turn the other arguments into do-nothing targets for this makefile and pass them on to makefile.mk
# This means that if we do something like "make target_iMX8EVK print", then we setup the target varibles
# in a rule in this file, but we pass those variables on to the makefile.mk with the print goal - thus printing
# out the variables for the iMX8EVK target and not just the default one.
#$(eval $(EXTRA_MAKE_GOALS):;@:)
# Turn any other secondary parameters
$(eval $(SECONDARY_PARAMS):;@:)
# Now check if the secondary parameters contains release, otherwise its a debug build
ifneq (,$(findstring release,$(ALL_PARAMS)))
  BUILD_TYPE = release
  BUILD_SUFFIX =
endif

# If verbose is specified then turn off the silencing so the make lines can be seen (e.g. compile/linker lines
# and other info)
SILENT_MAKE = -s --no-print-directory
ifneq (,$(findstring verbose,$(ALL_PARAMS)))
  SILENT_MAKE =
  FLAG_VERBOSE = verbose
endif

# Set the default target if not already set - this allows the makefile to overule it
.DEFAULT_GOAL := target_x86Linux

# The makefiles that we might find in a repo...
makefile_list =  $(wildcard $(CURDIR)/makefile.mk)
# Add make test if wanted
ifneq (,$(findstring test,$(ALL_PARAMS)))
  makefile_list += $(wildcard $(CURDIR)/makefile_test.mk)
endif

.PHONY: run_make
run_make:
	@for mkfile in $(makefile_list) ; do \
		echo "$(COLOUR_MAK)$$mkfile $(ALL_PARAMS) ($(TARGET) $(BUILD_TYPE))$(COLOUR_RST)"; \
		$(MAKE) -f $$mkfile $(MAKE_GOALS) $(EXTRA_MAKE_GOALS) PATH="$(PATH)" $(SILENT_MAKE); \
		if [ $$? -ne 0 ] ; then \
			echo "$(COLOUR_ERR)$$mkfile - failed$(COLOUR_RST)"; \
			exit 1; \
		else \
			echo "$(COLOUR_MAK)$$mkfile - finished $(COLOUR_RST)"; \
			exit 0; \
		fi; \
	done
	@echo "$(COLOUR_AOK)$${PWD##*/} build succesfully completed$(COLOUR_RST)"

.PHONY: clean
clean: MAKE_GOALS += clean
clean: run_make

.PHONY: cleanall
cleanall: MAKE_GOALS += cleanall
cleanall: run_make

.PHONY: jenkins
jenkins: MAKE_GOALS += jenkins
jenkins: run_make

# Call test without any parameters - use defaults
.PHONY: test
test: run_make

# If you call print or print_<var> directly here - use the default target (x86Linux)
.PHONY: print
print: target_x86Linux
print: MAKE_GOALS += print
print: run_make

# print_var - as above, but does not seem to work at the moment... it did once ?!?
.PHONY: print_%
print_%: target_x86Linux
print_%: MAKE_GOALS += $@
print_%:  run_make

############### Build Modifiers ################

# IMPORTANT NOTE
# These are meant to be called as secondary build goals since they only modify the 
# flags that are passed to the makefile.mk. However if they are the first parameter
# They become THE rule, so we add a rule here to do the default build, but also
# it does the tab completion

# Release build
.PHONY: release
release: FLAGS_TARGET += -O2
release: run_make

# Debug build
.PHONY: debug
debug: FLAGS_TARGET += -g
debug: run_make

# verbose 
.PHONY: verbose
verbose: run_make

################# The Targets #################

# IMPORTANT NOTE
# These are not really meant to be called directly because they simply call make with no parameters.
# In realailty this is the same as calling make build since "build" is the default parameter at the
# moment, but that means it works by luck more then design - e.g. the default goal coult change.

# Linux x86 c++ compiler
.PHONY: target_x86Linux
target_x86Linux: TARGET := x86Linux
target_x86Linux: CC := gcc
target_x86Linux: CXX := g++
target_x86Linux: RANLIB := ranlib
target_x86Linux: AR := ar
target_x86Linux: PATH := $(PATH)
target_x86Linux: FLAGS_TARGET := -m32
target_x86Linux: MAKE_GOALS += 
target_x86Linux: $(BUILD_TYPE)
target_x86Linux: run_make

# Linux x64 c++ compiler
.PHONY: target_x64Linux
target_x64Linux: TARGET := x64Linux
target_x64Linux: CC := gcc
target_x64Linux: CXX := g++
target_x64Linux: RANLIB := ranlib
target_x64Linux: AR := ar
target_x64Linux: PATH := $(PATH)
target_x64Linux: FLAGS_TARGET := -m64
target_x64Linux: MAKE_GOALS += 
target_x64Linux: $(BUILD_TYPE)
target_x64Linux: run_make

## target_iMX8EVK	: build the applications for the armv8 NXP i.MX8 EVK dev board
.PHONY: target_iMX8EVK
target_iMX8EVK: TARGET := iMX8EVK
target_iMX8EVK: CC := aarch64-poky-linux-gcc
target_iMX8EVK: CXX := aarch64-poky-linux-g++
target_iMX8EVK: RANLIB := aarch64-poky-linux-gnueabi-ranlib
target_iMX8EVK: AR := aarch64-poky-linux-gnueabi-ar
target_iMX8EVK: PATH := /opt/fsl-imx-x11/4.9.51-mx8-beta/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux:$(PATH)
target_iMX8EVK: FLAGS_TARGET := -march=armv8-a -mtune=cortex-a53 --sysroot=/opt/fsl-imx-x11/4.9.51-mx8-beta/sysroots/aarch64-poky-linux
target_iMX8EVK: MAKE_GOALS += 
target_iMX8EVK: $(BUILD_TYPE)
target_iMX8EVK: run_make

## target_6GHzRx	: build the applications for the armv7 i.MX6 6GHzRx
.PHONY: target_6GHzRx
target_6GHzRx: TARGET := 6GHzRx
target_6GHzRx: CC := arm-poky-linux-gnueabi-gcc
target_6GHzRx: CXX := arm-poky-linux-gnueabi-g++
target_6GHzRx: RANLIB := arm-poky-linux-gnueabi-ranlib
target_6GHzRx: AR := arm-poky-linux-gnueabi-ar
target_6GHzRx: PATH := /opt/fsl-imx-x11/4.1.15-1.1.1/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi:$(PATH)
target_6GHzRx: FLAGS_TARGET := -march=armv7-a -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9 --sysroot=/opt/fsl-imx-x11/4.1.15-1.1.1/sysroots/cortexa9hf-vfp-neon-poky-linux-gnueabi
target_6GHzRx: MAKE_GOALS += 
target_6GHzRx: $(BUILD_TYPE)
target_6GHzRx: run_make

## target_6GHzTx	: build the applications for the armv7 i.MX6 6GHzTx
.PHONY: target_6GHzTx
target_6GHzTx: TARGET := 6GHzTx
target_6GHzTx: CC := arm-poky-linux-gnueabi-gcc
target_6GHzTx: CXX := arm-poky-linux-gnueabi-g++
target_6GHzTx: RANLIB := arm-poky-linux-gnueabi-ranlib
target_6GHzTx: AR := arm-poky-linux-gnueabi-ar
target_6GHzTx: PATH := /opt/trl-imx-6GTcvr/4.1.15-1.2.0/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi:$(PATH)
target_6GHzTx: FLAGS_TARGET := -march=armv7-a -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9 --sysroot=/opt/trl-imx-6GTcvr/4.1.15-1.2.0/sysroots/cortexa9hf-vfp-neon-poky-linux-gnueabi
target_6GHzTx: MAKE_GOALS += 
target_6GHzTx: $(BUILD_TYPE)
target_6GHzTx: run_make
