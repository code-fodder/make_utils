# Generate sources list for cpp, cxx and c files
SOURCES = $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/*.cpp $(dir)/*.cxx $(dir)/*.c))

# Generate headers list for hpp, hxx and h files
HEADERS = \
	$(foreach dir,$(INC_DIRS),$(wildcard $(dir)/*.hpp $(dir)/*.hxx $(dir)/*.h $(dir)/*.hh)) \
	$(foreach dir,$(SYS_INC_DIRS),$(wildcard $(dir)/*.hpp $(dir)/*.hxx $(dir)/*.h $(dir)/*.hh)) \

# Generate includ dirs list
INC_PATHS = \
	$(addprefix -I,$(INC_DIRS)) \
	$(addprefix -isystem,$(SYS_INC_DIRS)) \

# Generate objects list from the sources list prefixed with the object dir
OBJECTS = $(addprefix $(OBJECT_DIR)/,$(addsuffix .o,$(basename $(patsubst %,%,$(SOURCES)))))

# Generate dependency files list. The compiler creates these (-MMD flag) same as obj file with a .d extension
DEPS = $(subst $(OBJECT_DIR),$(DEP_DIR),$(OBJECTS:%.o=%.d))

# Comiler flags
CFLAGS += $(INC_PATHS)
CXXFLAGS += $(INC_PATHS) $(CXX_STD)

# Generate the output directories list (used for creating/cleaning output dirs
OUTPUT_DIRS = \
	$(OUTPUT_DIR) \
	$(OBJECT_DIR) \
	$(addprefix $(OBJECT_DIR)/,$(SOURCE_DIRS)) \
	$(DEP_DIR) \
	$(addprefix $(DEP_DIR)/,$(SOURCE_DIRS))

# Create the library depenendies line for the linker (-L<path> and -l<lib>)
LIB_DEPS = \
	$(addprefix -L,$(LIB_DEP_PATHS)) \
	$(addprefix -l,$(LIB_DEP_LIBS)) \
	$(STANDARD_LIBS)

# Clean items will clean all the items for one specific target - e.g. running "make target_x64Linux release clean" will just clean the file for 
# the x86Linux release build
CLEAN_ITEMS = $(BIN_DIR)/*$(TARGET)$(BUILD_SUFFIX)* \
              $(LIB_DIR)/*$(TARGET)$(BUILD_SUFFIX)* \
              $(OBJECT_DIR) \
			  $(addprefix $(OBJECT_DIR)/,$(SOURCE_DIRS)) \
			  $(DEP_DIR) \
			  $(addprefix $(DEP_DIR)/,$(SOURCE_DIRS))

# Derive this from the CLEAN_ITEMS by taking the base dir of each since we are going to remove the entire dir:
# $(subst /, ,$(p)) : substitutes all / by space in the expansion of make variable p
# firstword         : keeps only the first word of the result, that is the first folder you are interested in
# foreach           : iterates over the words of VAR and sets make variable p to the current word
# sort              : removes duplicates (and... sorts).
CLEANALL_ITEMS = $(sort $(foreach p,$(CLEAN_ITEMS),$(firstword $(subst /, ,$(p)))))
#CLEANALL_ITEMS = obj dep bin lib
