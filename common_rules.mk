THIS_MAKEFILE := $(call GET_THIS_MAKEFILE)
ROOT_MAKEFILE := $(call GET_ROOT_MAKEFILE)

###### Object dependencies (part 1) ######
# include the auto generated dependecies targets (if they exist)
-include $(DEPS)
#see: http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
#GCC flags to create the temporary .Td dependency file containing all header files
#that the object depends on and empty targets for each one so that if the
#header file is missing Make doesn't crash
DEP_FLAGS = -MT $(RULE_TARGET) -MMD -MP -MF $(DEP_DIR)/$*.Td
#Command to rename the temporary dependency file to a permanent .d
#dependency file. Done seperately so that failures during compilation
#won't corrupt the dependency file. Touch the object, to correct its date
POSTCOMPILE = @mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d && touch $(RULE_TARGET)

# Set the default goal to build.
.DEFAULT_GOAL = build
$(info BUILD GOAL: $(or $(MAKECMDGOALS),$(.DEFAULT_GOAL)))

# build - builds the depenedcy projects and then the target output file itself
.PHONY: build
build: DEP_MAKE_GOAL = build
build: build_header $(DEP_MAKE_DIRS) $(OUTPUT_DIR)/$(OUTPUT_FILE)

.PHONY: build_header
build_header:
	@echo "$(COLOUR_ACT)building: $(OUTPUT_DIR)/$(OUTPUT_FILE)$(COLOUR_RST) : $(COLOUR_DEP)$(DEP_MAKE_DIRS)$(COLOUR_RST)" \

###### The target rule ######
$(OUTPUT_DIR)/$(OUTPUT_FILE): $(OUTPUT_DIRS) $(OBJECTS)
	@echo "$(COLOUR_ACT)linking: $(RULE_TARGET)$(COLOUR_RST)"
	$(CC) $(LFLAGS) $(OBJECTS) -o $(OUTPUT_DIR)/$(OUTPUT_FILE) $(LIB_DEPS)
	@echo build complete

###### External Dependency Rules ######
# Dependency makefile directories rule (builds projects in other directories)
.PHONY: $(DEP_MAKE_DIRS)
$(DEP_MAKE_DIRS):
	@echo "$(COLOUR_DEP)Processing dependency: '$(RULE_TARGET)'$(COLOUR_RST)"
	@cd $(RULE_TARGET) && $(MAKE) target_$(TARGET) $(BUILD_TYPE) $(DEP_MAKE_GOAL)
	@echo "$(COLOUR_MAK)$(ROOT_MAKEFILE) $(MAKECMDGOALS) ...continued ($(TARGET) $(BUILD_TYPE))$(COLOUR_RST)"

###### Compile Rules ######
# Compile .cpp files
$(OBJECT_DIR)/%.o: %.cpp
	@echo "$(COLOUR_ACT)compiling: $(RULE_DEPENDENCY)$(COLOUR_RST)"
	$(CXX) $(FLAGS_CPP_WARNINGS) $(CXXFLAGS) $(DEFINES) $(DEP_FLAGS) -c $(RULE_DEPENDENCY) -o $(RULE_TARGET)
	@$(POSTCOMPILE)
# Compile .cxx files
$(OBJECT_DIR)/%.o: %.cxx
	@echo "$(COLOUR_ACT)compiling: $(RULE_DEPENDENCY)$(COLOUR_RST)"
	$(CXX) $(FLAGS_CPP_WARNINGS) $(CXXFLAGS) $(DEFINES) $(DEP_FLAGS) -c $(RULE_DEPENDENCY) -o $(RULE_TARGET)
	@$(POSTCOMPILE)
# Compile .c files
$(OBJECT_DIR)/%.o: %.c
	@echo "$(COLOUR_ACT)compiling: $(RULE_DEPENDENCY)$(COLOUR_RST)"
	$(CC) $(FLAGS_C_WARNINGS) $(CFLAGS) $(DEFINES) $(DEP_FLAGS) -c $(RULE_DEPENDENCY) -o $(RULE_TARGET)
	@$(POSTCOMPILE)

###### Object dependencies (part 2) ######
#Blank dependency target in case dependency file doesn't exist to allow
#compile rule to run as usual and create a dependency file
#Mark the dependency files as precious to Make so they won't be automatically
#deleted as intermediate files
.PRECIOUS: $(DEP_DIR)/%.d
$(DEP_DIR)/%.d: ;

# Clean - does a target clean and also cleans the depenencies
.PHONY: clean
clean: DEP_MAKE_GOAL = clean
clean: $(DEP_MAKE_DIRS)
clean:
	@echo "$(COLOUR_ACT)cleaning: $(TARGET) $(BUILD_TYPE)$(COLOUR_RST)"
	$(RM) $(CLEAN_ITEMS)

# Cleanall - cleans output dirs from the root
.PHONY: cleanall
cleanall: DEP_MAKE_GOAL = cleanall
cleanall: $(DEP_MAKE_DIRS)
cleanall:
	@echo "$(COLOUR_ACT)cleaning: all targets$(COLOUR_RST)"
	$(RM) $(CLEANALL_ITEMS)

# Create output directories
.PHONY: create_dirs
create_dirs: $(OUTPUT_DIRS)
$(OUTPUT_DIRS):
	@$(MAKE_DIR) $(RULE_TARGET)

# Print all the variables
VARS := $(sort $(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)))
.PHONY: print
print: $(VARS)
$(VARS):
	@echo "$(COLOUR_ACT)$(RULE_TARGET):$(COLOUR_RST) $($(RULE_TARGET))"

# Print specific variable
print_%:
	@echo "$(COLOUR_ACT)$*:$(COLOUR_RST) $($*)"
