#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h> // Needed for stat() function

// Maximum path length is often 4096, but 1024 is used for simplicity
#define MAX_PATH 1024

// Function prototype
void walk_directory(const char *path);

int main() {
  // Start walking from the current directory
  walk_directory(".");
  return 0;
}

void walk_directory(const char *path) {
  DIR *dir;
  struct dirent *entry;
  struct stat statbuf; // Structure to hold file status information

  // 1. Open the directory
  if ((dir = opendir(path)) == NULL) {
    perror("opendir failed");
    return;
  }

  // 2. Loop through entries
  while ((entry = readdir(dir)) != NULL) {
    char full_path[MAX_PATH];

    // Skip the special entries '.' (current directory) and '..' (parent
    // directory)
    if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
      continue;
    }

    // Construct the full path for the current entry
    snprintf(full_path, sizeof(full_path), "%s/%s", path, entry->d_name);

    // Get file status/type (optional but useful for robust checking)
    if (stat(full_path, &statbuf) == -1) {
      perror("stat failed");
      continue;
    }

    // Check if the entry is a Directory
    if (S_ISDIR(statbuf.st_mode)) {
      printf("[DIR]: %s\n", full_path);

      // 3. RECUSION: Call the function for the subdirectory
      walk_directory(full_path);

      // Check if the entry is a Regular File
    } else if (S_ISREG(statbuf.st_mode)) {
      printf("[FILE]: %s\n", full_path);
    }
  }

  // 4. Close the directory stream
  closedir(dir);
}
