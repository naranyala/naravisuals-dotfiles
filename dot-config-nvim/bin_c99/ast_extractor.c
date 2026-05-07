#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tree_sitter/api.h> // Requires the tree-sitter C header

// Define the external function for the language parser (e.g., C)
extern TSLanguage *tree_sitter_c(void);

// --- Main Execution ---

// Example usage: ./ast_extractor <file_path> <line> <column>
int main(int argc, char *argv[]) {
  if (argc != 4) {
    fprintf(stderr, "Usage: %s <file_path> <line> <column>\n", argv[0]);
    return 1;
  }

  const char *file_path = argv[1];
  int target_line = atoi(argv[2]);
  int target_column = atoi(argv[3]);

  // 1. Read the file content
  // (Actual file reading code omitted for brevity, assume 'source_code' is
  // available)
  char *source_code = "int main() { int local_var = 10; return local_var; }";
  unsigned int source_code_len = strlen(source_code);

  // 2. Initialize and parse with Tree-sitter
  TSParser *parser = ts_parser_new();
  ts_parser_set_language(parser, tree_sitter_c());

  TSTree *tree =
      ts_parser_parse_string(parser, NULL, source_code, source_code_len);
  TSNode root_node = ts_tree_root_node(tree);

  // 3. Find the node at the target cursor position
  TSPoint point = {.row = target_line, .column = target_column};
  TSNode target_node =
      ts_node_descendant_for_point_range(root_node, point, point);

  // 4. Traverse the AST to find symbols in the current scope
  // (This part is complex: it involves traversing up to the function/block
  // and then down to find all variable_declarations/function_declarations)

  // Simplistic example: Print the type and text of the immediate target node
  const char *node_type = ts_node_type(target_node);
  uint32_t start_byte = ts_node_start_byte(target_node);
  uint32_t end_byte = ts_node_end_byte(target_node);

  char node_text[1024]; // Buffer
  strncpy(node_text, source_code + start_byte, end_byte - start_byte);
  node_text[end_byte - start_byte] = '\0';

  // 5. Output symbols (ideally as JSON for easy Lua parsing)
  printf("{\n");
  printf("  \"type\": \"%s\",\n", node_type);
  printf("  \"text\": \"%s\"\n", node_text);
  // In a real utility, you'd list all local symbols:
  // printf("  \"symbols\": [\"local_var\", \"main\"...]\n");
  printf("}\n");

  // 6. Cleanup
  ts_tree_delete(tree);
  ts_parser_delete(parser);
  return 0;
}
