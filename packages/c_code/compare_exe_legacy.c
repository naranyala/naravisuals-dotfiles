#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>

#define MAX_LDD_OUTPUT 4096  // Buffer size for ldd output (adjust if needed)
#define COL_WIDTH_FILE 30    // Column widths for table formatting
#define COL_WIDTH_SIZE 15
#define COL_WIDTH_LDD  60

// Function to capture ldd output
char* get_ldd_output(const char* filename) {
    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "ldd \"%s\" 2>&1", filename);  // Handle errors via stderr redirect

    FILE* pipe = popen(cmd, "r");
    if (!pipe) return strdup("Error: popen failed");

    char* output = malloc(MAX_LDD_OUTPUT);
    if (!output) {
        pclose(pipe);
        return strdup("Error: memory allocation failed");
    }
    output[0] = '\0';

    char buffer[256];
    while (fgets(buffer, sizeof(buffer), pipe) != NULL) {
        strncat(output, buffer, MAX_LDD_OUTPUT - strlen(output) - 1);
    }

    pclose(pipe);
    return output;
}

// Function to get file size
long long get_file_size(const char* filename) {
    struct stat st;
    if (stat(filename, &st) == 0) {
        return st.st_size;
    }
    return -1;  // Error
}

// Function to print a horizontal separator
void print_separator() {
    printf("+");
    for (int i = 0; i < COL_WIDTH_FILE; i++) printf("-");
    printf("+");
    for (int i = 0; i < COL_WIDTH_SIZE; i++) printf("-");
    printf("+");
    for (int i = 0; i < COL_WIDTH_LDD; i++) printf("-");
    printf("+\n");
}

// Function to print a row (handles multi-line ldd)
void print_row(const char* file, long long size, const char* ldd) {
    // Print file and size in first line
    printf("| %-30s | %-15lld |", file, size >= 0 ? size : -1);

    // Print ldd, handling multi-line by printing subsequent lines below
    char* ldd_copy = strdup(ldd);
    char* line = strtok(ldd_copy, "\n");
    if (line) {
        printf(" %-60s |\n", line);
    } else {
        printf(" %-60s |\n", "N/A");
    }

    // Print additional ldd lines (indented for table alignment)
    while ((line = strtok(NULL, "\n")) != NULL) {
        printf("| %-30s | %-15s | %-60s |\n", "", "", line);
    }

    free(ldd_copy);
    print_separator();
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file1> <file2> ... <fileN>\n", argv[0]);
        return 1;
    }

    // Print table header
    print_separator();
    printf("| %-30s | %-15s | %-60s |\n", "File", "Size (bytes)", "LDD Output");
    print_separator();

    // Process each file
    for (int i = 1; i < argc; i++) {
        const char* file = argv[i];
        long long size = get_file_size(file);
        char* ldd = get_ldd_output(file);

        if (size == -1) {
            char err[256];
            snprintf(err, sizeof(err), "Error: %s", strerror(errno));
            print_row(file, -1, err);
        } else if (strstr(ldd, "not a dynamic executable") || strstr(ldd, "Error")) {
            print_row(file, size, ldd);
        } else {
            print_row(file, size, ldd);
        }

        free(ldd);
    }

    return 0;
}
