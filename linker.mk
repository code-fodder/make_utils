include make_utils/common_colours.mk
# Note this was moved from common_rules.mk so that it could be called from the body
# of the build rule and therefore be guaranteed to be the last thing that is called.
# This is so that parallel builds will work.

###### The target rule ######
#.NOT_PARALLEL: $(OUTPUT_DIR)/$(OUTPUT_FILE)
$(OUTPUT_DIR)/$(OUTPUT_FILE):
	@echo "$(COLOUR_ACT)linking: $@$(COLOUR_RST)"
	$(CC) $(LFLAGS) $(OBJECTS) -o $(OUTPUT_DIR)/$(OUTPUT_FILE) $(LIB_DEPS)
