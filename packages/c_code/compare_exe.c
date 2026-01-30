#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>

#define MAX_LDD_OUTPUT 8192

// Human-readable size
void human_readable_size(long long bytes, char* buf, size_t bufsize) {
    if (bytes < 0) {
        snprintf(buf, bufsize, "Error");
        return;
    }
    const char* units[] = {"bytes", "KB", "MB", "GB"};
    int unit = 0;
    double size = (double)bytes;
    while (size >= 1024.0 && unit < 3) {
        size /= 1024.0;
        unit++;
    }
    if (unit == 0) {
        snprintf(buf, bufsize, "%lld %s", bytes, units[unit]);
    } else {
        snprintf(buf, bufsize, "%.2f %s", size, units[unit]);
    }
}

// Get ldd output
char* get_ldd_output(const char* filename) {
    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "ldd \"%s\" 2>&1", filename);
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return strdup("Error: popen failed");

    char* output = malloc(MAX_LDD_OUTPUT);
    if (!output) {
        pclose(pipe);
        return strdup("Error: malloc failed");
    }
    output[0] = '\0';

    char buffer[512];
    while (fgets(buffer, sizeof(buffer), pipe)) {
        strncat(output, buffer, MAX_LDD_OUTPUT - strlen(output) - 1);
    }
    pclose(pipe);

    // Trim trailing newlines/spaces
    size_t len = strlen(output);
    while (len > 0 && (output[len-1] == '\n' || output[len-1] == '\r' || output[len-1] == ' ')) {
        output[--len] = '\0';
    }
    return output;
}

// Get file size
long long get_file_size(const char* filename) {
    struct stat st;
    return (stat(filename, &st) == 0) ? st.st_size : -1;
}

// Print separator
void print_separator(const int* widths, int num_cols) {
    printf("+");
    for (int i = 0; i < num_cols; i++) {
        for (int j = 0; j < widths[i] + 2; j++) printf("-");
        printf("+");
    }
    printf("\n");
}

// Print cell: left-aligned, padded
void print_cell(const char* text, int width) {
    if (text && strlen(text) > 0) {
        printf(" %-*s |", width, text);
    } else {
        printf(" %-*s |", width, "");
    }
}

int main(int argc, char* argv[]) {
    if (argc < 3 || (argc - 1) % 2 != 0) {
        fprintf(stderr, "Usage: %s <binary1> \"<label1>\" <binary2> \"<label2>\" ...\n", argv[0]);
        fprintf(stderr, "Example: %s ./app \"Rust Release\" ./app_go \"Go Static\"\n", argv[0]);
        return 1;
    }

    int num_binaries = (argc - 1) / 2;
    const char* files[num_binaries];
    const char* labels[num_binaries];

    for (int i = 0; i < num_binaries; i++) {
        files[i]  = argv[1 + i*2];
        labels[i] = argv[2 + i*2];
    }

    const char* headers[] = {"File", "Label", "Size (bytes)", "Size (human)", "LDD Output"};
    int num_cols = 5;
    int widths[5] = {20, 15, 12, 12, 50};

    char temp[128];

    // Calculate max widths
    for (int i = 0; i < num_binaries; i++) {
        widths[0] = strlen(files[i])  > widths[0] ? strlen(files[i])  : widths[0];
        widths[1] = strlen(labels[i]) > widths[1] ? strlen(labels[i]) : widths[1];

        long long size = get_file_size(files[i]);
        snprintf(temp, sizeof(temp), "%lld", size >= 0 ? size : -1LL);
        widths[2] = strlen(temp) > widths[2] ? strlen(temp) : widths[2];

        human_readable_size(size, temp, sizeof(temp));
        widths[3] = strlen(temp) > widths[3] ? strlen(temp) : widths[3];

        char* ldd = get_ldd_output(files[i]);
        char* ldd_copy = strdup(ldd);
        char* line = strtok(ldd_copy, "\n");
        while (line) {
            int len = strlen(line);
            widths[4] = len > widths[4] ? len : widths[4];
            line = strtok(NULL, "\n");
        }
        free(ldd_copy);
        free(ldd);
    }

    // Minimum widths
    int min_widths[] = {20, 15, 12, 12, 50};
    for (int i = 0; i < num_cols; i++) {
        if (widths[i] < min_widths[i]) widths[i] = min_widths[i];
    }

    // Header
    print_separator(widths, num_cols);
    printf("|");
    for (int i = 0; i < num_cols; i++) {
        print_cell(headers[i], widths[i]);
    }
    printf("\n");
    print_separator(widths, num_cols);

    // Data rows
    for (int i = 0; i < num_binaries; i++) {
        long long size = get_file_size(files[i]);
        char* ldd_full = get_ldd_output(files[i]);

        char bytes_str[32];
        snprintf(bytes_str, sizeof(bytes_str), "%lld", size >= 0 ? size : -1LL);

        char human_str[32];
        if (size < 0) {
            snprintf(human_str, sizeof(human_str), "Error: %s", strerror(errno));
        } else {
            human_readable_size(size, human_str, sizeof(human_str));
        }

        char** ldd_lines = NULL;
        int num_lines = 0;

        if (strstr(ldd_full, "not a dynamic executable") || strstr(ldd_full, "statically linked")) {
            ldd_lines = malloc(sizeof(char*));
            ldd_lines[0] = strdup(strlen(ldd_full) ? ldd_full : "statically linked");
            num_lines = 1;
        } else if (strlen(ldd_full) == 0) {
            ldd_lines = malloc(sizeof(char*));
            ldd_lines[0] = strdup("N/A");
            num_lines = 1;
        } else {
            char* copy = strdup(ldd_full);
            char* token = strtok(copy, "\n");
            while (token) {
                ldd_lines = realloc(ldd_lines, (num_lines + 1) * sizeof(char*));
                ldd_lines[num_lines++] = strdup(token);
                token = strtok(NULL, "\n");
            }
            free(copy);
        }

        // Print first line with metadata
        printf("|");
        print_cell(files[i], widths[0]);
        print_cell(labels[i], widths[1]);
        print_cell(bytes_str, widths[2]);
        print_cell(human_str, widths[3]);
        print_cell(num_lines > 0 ? ldd_lines[0] : "", widths[4]);
        printf("\n");

        // Print remaining LDD lines with blank first columns
        for (int l = 1; l < num_lines; l++) {
            printf("|");
            print_cell("", widths[0]);
            print_cell("", widths[1]);
            print_cell("", widths[2]);
            print_cell("", widths[3]);
            print_cell(ldd_lines[l], widths[4]);
            printf("\n");
        }

        // If no LDD lines, still print one empty continuation? No — only if needed
        if (num_lines == 0) {
            printf("|");
            print_cell("", widths[0]);
            print_cell("", widths[1]);
            print_cell("", widths[2]);
            print_cell("", widths[3]);
            print_cell("N/A", widths[4]);
            printf("\n");
        }

        // Free lines
        for (int l = 0; l < num_lines; l++) free(ldd_lines[l]);
        if (ldd_lines) free(ldd_lines);
        free(ldd_full);

        print_separator(widths, num_cols);
    }

    return 0;
}
