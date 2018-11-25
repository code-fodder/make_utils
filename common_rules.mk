# -MMD is a compiler flag which tells the compiler to generate the dependacy lists for each object.
#CFLAGS += -MMD
# Add the include paths
CFLAGS += $(INC_PATHS) $(FLAGS_STD)
# include the auto generated dependecies targets
-include $(DEPS)

#auto-dependency generation (part 1)
#see: http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
#GCC flags to create the temporary .Td dependency file containing all header files
#that the object depends on and empty targets for each one so that if the
#header file is missing Make doesn't crash
DEP_FLAGS = -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td
#Command to rename the temporary dependency file to a permanent .d
#dependency file. Done seperately so that failures during compilation
#won't corrupt the dependency file. Touch the object, to correct its date
POSTCOMPILE = @mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d && touch $@

# build
.PHONY: build
build: LIB_DEP_DIR_GOAL = build
build: build_header $(LIB_DEP_PROJECT_DIRS) $(OUTPUT_DIR)/$(OUTPUT_FILE)

.PHONY: build_header
build_header:
	@echo "$(GREEN)Building: $(OUTPUT_DIR)/$(OUTPUT_FILE)$(NC) : $(YELLOW)$(LIB_DEP_PROJECT_DIRS)$(NC)" \

# The target build
#$(OUTPUT_DIR)/$(OUTPUT_FILE): $(LIB_DEP_TARGETS) $(OUTPUT_DIRS) $(OBJECTS)
$(OUTPUT_DIR)/$(OUTPUT_FILE): $(OUTPUT_DIRS) $(OBJECTS)
	@echo "$(GREEN)Linking: $@$(NC)"
	$(CC) $(LFLAGS) $(OBJECTS) -o $(OUTPUT_DIR)/$(OUTPUT_FILE)
	@echo build complete

# Specific rules to run on the library dependency directorys
.PHONY: $(LIB_DEP_PROJECT_DIRS)
$(LIB_DEP_PROJECT_DIRS):
	@echo "$(YELLOW)Processing dependency: '$@'$(NC)"
	@cd $@ && $(MAKE) target_$(TARGET) $(BUILD_TYPE) $(LIB_DEP_DIR_GOAL)
	@echo "$(CYAN)$(CURDIR) - make $(MAKECMDGOALS) ($(TARGET) $(BUILD_TYPE))$(NC)"

# DEP2 ideas
# pattern rule?  - Works, but how do we get the $(LIB_DEP_INCS) part into the rule?
#$(LIB_DEP_INCS)%: 
#	@echo "$(GREEN)building dependency: $@$(NC)"
$(LIB_DEP_TARGETS):
	@echo "$(YELLOW)Processing dependency: '$@'$(NC)"
	@cd $(subst lib/,./,$(dir $@)) && $(MAKE) target_$(TARGET) $(BUILD_TYPE) build

# Compile .cpp files
$(OBJECT_DIR)/%.o: %.cpp
	@echo "$(GREEN)compiling $(RULE_DEPENDENCY)$(NC)"
	$(CXX) $(FLAGS_CPP_WARNINGS) $(CFLAGS) $(DEFINES) $(DEP_FLAGS) -c $(RULE_DEPENDENCY) -o $(RULE_TARGET)
	@$(POSTCOMPILE)
# Compile .cxx files
$(OBJECT_DIR)/%.o: %.cxx
	@echo "$(GREEN)compiling $(RULE_DEPENDENCY)$(NC)"
	$(CXX) $(FLAGS_CPP_WARNINGS) $(CFLAGS) $(DEFINES) $(DEP_FLAGS) -c $(RULE_DEPENDENCY) -o $(RULE_TARGET)
	@$(POSTCOMPILE)
# Compile .c files
$(OBJECT_DIR)/%.o: %.c
	@echo "$(GREEN)compiling $(RULE_DEPENDENCY)$(NC)"
	$(CC) $(FLAGS_C_WARNINGS) $(CFLAGS) $(DEFINES) $(DEP_FLAGS) -c $(RULE_DEPENDENCY) -o $(RULE_TARGET)
	@$(POSTCOMPILE)

#auto-dependency generation (part 2)
#Blank dependency target in case dependency file doesn't exist to allow
#compile rule to run as usual and create a dependency file
$(DEP_DIR)/%.d: ;
#Mark the dependency files as precious to Make so they won't be automatically
#deleted as intermediate files
.PRECIOUS: $(DEP_DIR)/%.d
#Include the dependency files
include $(wildcard $(DEP_DIR)/*.d)

#.PHONY: project_deps $(PROJECT_DEPS)
#project_deps: $(PROJECT_DEPS)
#$(PROJECT_DEPS):
#	$(MAKE) $(MAKECMDGOALS) -C $(RULE_TARGET)

# Clean - does a target clean and also cleans the depenencies
.PHONY: clean
clean: LIB_DEP_DIR_GOAL = clean
clean: $(LIB_DEP_PROJECT_DIRS)
clean:
	@echo "$(GREEN)cleaning target: $(TARGET) $(BUILD_TYPE)$(NC)"
#	@echo "$(GREEN)$(RM) $(CLEAN_ITEMS)$(NC)"
	$(RM) $(CLEAN_ITEMS)

# Cleanall - cleans output dirs from the root
.PHONY: cleanall
cleanall: LIB_DEP_DIR_GOAL = cleanall
cleanall: $(LIB_DEP_PROJECT_DIRS)
cleanall:
	@echo "$(GREEN)cleaning all targets$(NC)"
#	@echo "$(GREEN)$(RM) $(CLEANALL_ITEMS)$(NC)"
	$(RM) $(CLEANALL_ITEMS)

# Create output directories
.PHONY: create_dirs
create_dirs: $(OUTPUT_DIRS)
$(OUTPUT_DIRS):
	@$(MAKE_DIR) $(RULE_TARGET)

# Print the variables
VARS := $(sort $(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)))
.PHONY: print_start print
print: print_start $(VARS)
	@echo "------------------------------------------"
print_start:
	@echo "------------------------------------------"
	@printf "%-30s " "Variable"
	@echo "Value"
	@echo "------------------------------------------"
$(VARS):
	@printf "%-30s " $(RULE_TARGET)
	@echo "$($(RULE_TARGET))"

