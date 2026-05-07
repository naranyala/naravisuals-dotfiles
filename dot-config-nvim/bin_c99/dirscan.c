#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>
#include <unistd.h>

/**
 * Check if a path is a directory
 * @param path Path to check
 * @return 1 if directory, 0 otherwise
 */
int is_directory(const char *path) {
    struct stat path_stat;
    if (stat(path, &path_stat) != 0) {
        return 0;  // stat failed
    }
    return S_ISDIR(path_stat.st_mode);
}

/**
 * Calculate directory size recursively
 * @param path Directory path to calculate size for
 * @return Size in bytes
 */
off_t get_directory_size(const char *path) {
    DIR *dir;
    struct dirent *entry;
    struct stat statbuf;
    off_t size = 0;
    char full_path[1024];
    
    dir = opendir(path);
    if (dir == NULL) {
        return 0;
    }
    
    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        
        snprintf(full_path, sizeof(full_path), "%s/%s", path, entry->d_name);
        
        if (stat(full_path, &statbuf) == 0) {
            if (S_ISDIR(statbuf.st_mode)) {
                size += get_directory_size(full_path);  // Recursive call
            } else {
                size += statbuf.st_size;
            }
        }
    }
    
    closedir(dir);
    return size;
}

/**
 * Format size in human-readable format (KB, MB, GB)
 * @param size Size in bytes
 * @return Human-readable size string
 */
const char* format_size(off_t size) {
    static char size_str[64];
    double size_d = (double)size;
    
    if (size < 1024) {
        snprintf(size_str, sizeof(size_str), "%lld bytes", (long long)size);
    } else if (size < 1024 * 1024) {
        snprintf(size_str, sizeof(size_str), "%.2f KB", size_d / 1024.0);
    } else if (size < 1024 * 1024 * 1024) {
        snprintf(size_str, sizeof(size_str), "%.2f MB", size_d / (1024.0 * 1024.0));
    } else {
        snprintf(size_str, sizeof(size_str), "%.2f GB", size_d / (1024.0 * 1024.0 * 1024.0));
    }
    
    return size_str;
}

/**
 * Scan directory and list all subdirectories with sizes
 * @param dirpath Directory path to scan
 */
void scan_directories(const char *dirpath) {
    DIR *dir;
    struct dirent *entry;
    
    // Open directory
    dir = opendir(dirpath);
    if (dir == NULL) {
        perror("Error opening directory");
        return;
    }
    
    // Print header in key-value format
    printf("[\n");
    
    int first = 1;  // Flag to handle comma formatting
    
    // Read directory entries
    while ((entry = readdir(dir)) != NULL) {
        // Skip current directory (.) and parent (..)
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        
        // Build full path
        char full_path[1024];
        snprintf(full_path, sizeof(full_path), "%s/%s", dirpath, entry->d_name);
        
        // Check if it's a directory
        if (is_directory(full_path)) {
            off_t size = get_directory_size(full_path);
            
            // Add comma before entries (except first)
            if (!first) {
                printf(",\n");
            }
            first = 0;
            
            // Print in key-value format (JSON-like)
            printf("  {\n");
            printf("    \"location\": \"%s\",\n", full_path);
            printf("    \"folder_size\": \"%s\"\n", format_size(size));
            printf("  }");
        }
    }
    
    printf("\n]\n");
    closedir(dir);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <directory_path>\n", argv[0]);
        return 1;
    }
    
    const char *dirpath = argv[1];
    
    // Validate directory exists
    if (!is_directory(dirpath)) {
        fprintf(stderr, "Error: '%s' is not a directory\n", dirpath);
        return 1;
    }
    
    scan_directories(dirpath);
    
    return 0;
}
