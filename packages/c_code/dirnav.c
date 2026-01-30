#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <sys/stat.h>
#include <sys/types.h>

#ifdef _WIN32
    #include <windows.h>
    #include <shlobj.h>     // for SHGetFolderPathA and CSIDL_PROFILE
    #include <direct.h>     // for _chdir() and _mkdir()
    #define chdir _chdir
    #define mkdir _mkdir
    #ifndef PATH_MAX        // Only define if not already defined
        #define PATH_MAX MAX_PATH
    #endif
    #define PATH_SEPARATOR "\\"
#else
    #include <unistd.h>
    #include <dirent.h>
    #define PATH_SEPARATOR "/"
#endif

#define MAX_PATHS 100
#define MAX_LEN PATH_MAX

// Cross-platform path normalization
void normalize_path(char *path) {
    #ifdef _WIN32
    // Convert forward slashes to backslashes on Windows
    for (char *p = path; *p; p++) {
        if (*p == '/') *p = '\\';
    }
    #else
    // Convert backslashes to forward slashes on Unix-like systems
    for (char *p = path; *p; p++) {
        if (*p == '\\') *p = '/';
    }
    #endif
}

// Cross-platform home directory detection
const char* get_home_dir() {
    static char home[PATH_MAX];

    // Try environment variables in order of preference
    const char *env_vars[] = {"DIRNAV_HOME", "HOME", "USERPROFILE", "HOMEDRIVE", NULL};

    for (int i = 0; env_vars[i]; i++) {
        const char *value = getenv(env_vars[i]);
        if (value && *value) {
            #ifdef _WIN32
            if (strcmp(env_vars[i], "HOMEDRIVE") == 0) {
                // Combine HOMEDRIVE + HOMEPATH on Windows
                const char *homepath = getenv("HOMEPATH");
                if (homepath) {
                    snprintf(home, sizeof(home), "%s%s", value, homepath);
                    return home;
                }
            }
            #endif
            return value;
        }
    }

    // Fallback for Windows using simpler method
    #ifdef _WIN32
    const char *userprofile = getenv("USERPROFILE");
    if (userprofile) return userprofile;

    const char *homedrive = getenv("HOMEDRIVE");
    const char *homepath = getenv("HOMEPATH");
    if (homedrive && homepath) {
        snprintf(home, sizeof(home), "%s%s", homedrive, homepath);
        return home;
    }
    #endif

    // Ultimate fallback
    #ifdef _WIN32
    return "C:\\";
    #else
    return "/tmp";
    #endif
}

// Resolve store file location
const char* get_store_file() {
    static char path[PATH_MAX];
    const char *custom = getenv("DIRNAV_STORE");
    if (custom) {
        strncpy(path, custom, sizeof(path) - 1);
        path[sizeof(path) - 1] = '\0';
        normalize_path(path);
        return path;
    }

    const char *home = get_home_dir();
    snprintf(path, sizeof(path), "%s%s.dirnav_store", home, PATH_SEPARATOR);
    normalize_path(path);
    return path;
}

// Ensure directory exists for store file
void ensure_store_dir() {
    const char *store_file = get_store_file();
    char dir[PATH_MAX];
    strncpy(dir, store_file, sizeof(dir) - 1);
    dir[sizeof(dir) - 1] = '\0';

    // Remove filename part
    char *last_sep = strrchr(dir, *PATH_SEPARATOR);
    if (last_sep) *last_sep = '\0';

    #ifdef _WIN32
    _mkdir(dir);
    #else
    mkdir(dir, 0755);
    #endif
}

// Load paths from file
int load_paths(char dir_store[MAX_PATHS][MAX_LEN]) {
    FILE *f = fopen(get_store_file(), "r");
    if (!f) return 0;

    int count = 0;
    while (count < MAX_PATHS && fgets(dir_store[count], MAX_LEN, f)) {
        dir_store[count][strcspn(dir_store[count], "\n")] = 0; // strip newline
        normalize_path(dir_store[count]);
        count++;
    }
    fclose(f);
    return count;
}

// Save paths to file
void save_paths(char dir_store[MAX_PATHS][MAX_LEN], int dir_count) {
    ensure_store_dir();

    FILE *f = fopen(get_store_file(), "w");
    if (!f) {
        perror("Failed to save store");
        return;
    }
    for (int i = 0; i < dir_count; i++) {
        fprintf(f, "%s\n", dir_store[i]);
    }
    fclose(f);
}

// Add path with validation
void add_path(char dir_store[MAX_PATHS][MAX_LEN], int *dir_count, const char *path) {
    if (*dir_count >= MAX_PATHS) {
        printf("❌ Store is full!\n");
        return;
    }

    // Validate path exists
    #ifdef _WIN32
    if (_access(path, 0) != 0) {
    #else
    if (access(path, F_OK) != 0) {
    #endif
        printf("⚠️  Warning: Path doesn't exist: %s\n", path);
    }

    strncpy(dir_store[*dir_count], path, MAX_LEN - 1);
    dir_store[*dir_count][MAX_LEN - 1] = '\0';
    normalize_path(dir_store[*dir_count]);
    (*dir_count)++;
    save_paths(dir_store, *dir_count);
    printf("✅ Path added: %s\n", path);
}

// List paths with better formatting
void list_paths(char dir_store[MAX_PATHS][MAX_LEN], int dir_count) {
    if (dir_count == 0) {
        printf("No paths stored yet.\n");
        return;
    }
    printf("📂 Stored paths:\n");
    for (int i = 0; i < dir_count; i++) {
        printf("[%d] %s\n", i, dir_store[i]);
    }
}

// Remove path
void remove_path(char dir_store[MAX_PATHS][MAX_LEN], int *dir_count, int index) {
    if (index < 0 || index >= *dir_count) {
        printf("❌ Invalid index!\n");
        return;
    }
    printf("🗑️ Removing: %s\n", dir_store[index]);
    for (int i = index; i < *dir_count - 1; i++) {
        strncpy(dir_store[i], dir_store[i + 1], MAX_LEN);
    }
    (*dir_count)--;
    save_paths(dir_store, *dir_count);
}

// Navigate (print path for shell to use)
void navigate(char dir_store[MAX_PATHS][MAX_LEN], int dir_count, int index) {
    if (index < 0 || index >= dir_count) {
        fprintf(stderr, "❌ Invalid index!\n");
        return;
    }
    printf("%s\n", dir_store[index]);
}

// Search with case-insensitive option
void search_paths(char dir_store[MAX_PATHS][MAX_LEN], int dir_count, const char *keyword) {
    int found = 0;
    char keyword_lower[256];
    strncpy(keyword_lower, keyword, sizeof(keyword_lower) - 1);
    keyword_lower[sizeof(keyword_lower) - 1] = '\0';

    // Convert keyword to lowercase for case-insensitive search
    for (char *p = keyword_lower; *p; p++) {
        *p = tolower(*p);
    }

    for (int i = 0; i < dir_count; i++) {
        char path_lower[MAX_LEN];
        strncpy(path_lower, dir_store[i], sizeof(path_lower) - 1);
        path_lower[sizeof(path_lower) - 1] = '\0';

        for (char *p = path_lower; *p; p++) {
            *p = tolower(*p);
        }

        if (strstr(path_lower, keyword_lower) != NULL) {
            printf("[%d] %s\n", i, dir_store[i]);
            found = 1;
        }
    }
    if (!found) {
        printf("🔍 No match found for '%s'\n", keyword);
    }
}

// Help
void print_help() {
    printf("Usage: dirnav [command] [options]\n");
    printf("Commands:\n");
    printf("  --add <path>       Add a directory path\n");
    printf("  --list             List stored paths\n");
    printf("  --rm <index>       Remove path at index\n");
    printf("  --nav <index>      Print path at index (use with cd)\n");
    printf("  --search <keyword> Search paths by keyword\n");
    printf("  --help             Show this help message\n");
    printf("\nEnvironment variables:\n");
    printf("  DIRNAV_STORE       Custom store file location\n");
    printf("  DIRNAV_HOME        Custom home directory\n");
}

int main(int argc, char *argv[]) {
    char dir_store[MAX_PATHS][MAX_LEN];
    int dir_count = load_paths(dir_store);

    if (argc < 2) {
        print_help();
        return 1;
    }

    if (strcmp(argv[1], "--help") == 0) {
        print_help();
    } else if (strcmp(argv[1], "--add") == 0 && argc >= 3) {
        add_path(dir_store, &dir_count, argv[2]);
    } else if (strcmp(argv[1], "--list") == 0) {
        list_paths(dir_store, dir_count);
    } else if (strcmp(argv[1], "--rm") == 0 && argc >= 3) {
        remove_path(dir_store, &dir_count, atoi(argv[2]));
    } else if (strcmp(argv[1], "--nav") == 0 && argc >= 3) {
        navigate(dir_store, dir_count, atoi(argv[2]));
    } else if (strcmp(argv[1], "--search") == 0 && argc >= 3) {
        search_paths(dir_store, dir_count, argv[2]);
    } else {
        printf("❌ Unknown command\n");
        print_help();
    }

    return 0;
}
