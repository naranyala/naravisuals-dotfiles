#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef _WIN32
    #include <windows.h>
    #include <sys/stat.h>
#else
    #include <sys/stat.h>
    #include <unistd.h>
    #include <pwd.h>
    #include <grp.h>
#endif

// Convert bytes to human-friendly string
void human_size(long long size, char *buf, size_t buf_size) {
    const char *units[] = {"B", "KB", "MB", "GB", "TB"};
    int i = 0;
    double s = (double)size;
    while (s >= 1024 && i < 4) {
        s /= 1024;
        i++;
    }
    snprintf(buf, buf_size, "%.2f %s", s, units[i]);
}

// Count lines in file
long count_lines(const char *filepath) {
    FILE *fp = fopen(filepath, "r");
    if (!fp) return -1;
    long lines = 0;
    int ch;
    while ((ch = fgetc(fp)) != EOF) {
        if (ch == '\n') lines++;
    }
    fclose(fp);
    return lines;
}

// Format time
void format_time(time_t t, char *buf, size_t buf_size) {
    struct tm *tm_info = localtime(&t);
    if (tm_info)
        strftime(buf, buf_size, "%Y-%m-%d %H:%M:%S", tm_info);
    else
        snprintf(buf, buf_size, "N/A");
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filepath> [--json|--table]\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *filepath = argv[1];
    int json_output = 0;
    if (argc >= 3 && strcmp(argv[2], "--json") == 0) {
        json_output = 1;
    }

    long long filesize = 0;
    char hsize[32];
    long lines = -1;
    char mtimebuf[64] = "N/A";
    char atimebuf[64] = "N/A";
    char ctimebuf[64] = "N/A";
    char perms[16] = "---";

#ifdef _WIN32
    struct _stat st;
    if (_stat(filepath, &st) != 0) {
        perror("stat");
        return EXIT_FAILURE;
    }
    filesize = (long long)st.st_size;
    format_time(st.st_mtime, mtimebuf, sizeof(mtimebuf));
    format_time(st.st_atime, atimebuf, sizeof(atimebuf));
    format_time(st.st_ctime, ctimebuf, sizeof(ctimebuf));

    perms[0] = (st.st_mode & _S_IREAD) ? 'r' : '-';
    perms[1] = (st.st_mode & _S_IWRITE) ? 'w' : '-';
    perms[2] = (st.st_mode & _S_IEXEC) ? 'x' : '-';

#else
    struct stat st;
    if (stat(filepath, &st) != 0) {
        perror("stat");
        return EXIT_FAILURE;
    }
    filesize = (long long)st.st_size;
    format_time(st.st_mtime, mtimebuf, sizeof(mtimebuf));
    format_time(st.st_atime, atimebuf, sizeof(atimebuf));
    format_time(st.st_ctime, ctimebuf, sizeof(ctimebuf));

    perms[0] = (st.st_mode & S_IRUSR) ? 'r' : '-';
    perms[1] = (st.st_mode & S_IWUSR) ? 'w' : '-';
    perms[2] = (st.st_mode & S_IXUSR) ? 'x' : '-';
#endif

    human_size(filesize, hsize, sizeof(hsize));
    lines = count_lines(filepath);

    if (json_output) {
        // JSON output
        printf("{\n");
        printf("  \"file\": \"%s\",\n", filepath);
        printf("  \"size_bytes\": %lld,\n", filesize);
        printf("  \"size_human\": \"%s\",\n", hsize);
        if (lines >= 0)
            printf("  \"lines\": %ld,\n", lines);
        else
            printf("  \"lines\": null,\n");
        printf("  \"last_modified\": \"%s\",\n", mtimebuf);
        printf("  \"last_accessed\": \"%s\",\n", atimebuf);
        printf("  \"last_changed\": \"%s\",\n", ctimebuf);
        printf("  \"permissions\": \"%s\"", perms);

#ifndef _WIN32
        printf(",\n  \"inode\": %lu,\n", (unsigned long)st.st_ino);
        printf("  \"device_id\": %lu,\n", (unsigned long)st.st_dev);
        printf("  \"owner_uid\": %u,\n", st.st_uid);
        printf("  \"group_gid\": %u,\n", st.st_gid);
        printf("  \"hard_links\": %lu\n", (unsigned long)st.st_nlink);
#else
        printf("\n");
#endif
        printf("}\n");
    } else {
        // Table output (default)
        printf("+----------------+----------------------------------+\n");
        printf("| %-14s | %-32s |\n", "File", filepath);
        printf("+----------------+----------------------------------+\n");
        printf("| %-14s | %-32lld |\n", "Size (bytes)", filesize);
        printf("| %-14s | %-32s |\n", "Size (human)", hsize);
        if (lines >= 0)
            printf("| %-14s | %-32ld |\n", "Lines", lines);
        else
            printf("| %-14s | %-32s |\n", "Lines", "N/A");
        printf("| %-14s | %-32s |\n", "Last modified", mtimebuf);
        printf("| %-14s | %-32s |\n", "Last accessed", atimebuf);
        printf("| %-14s | %-32s |\n", "Last changed", ctimebuf);
        printf("| %-14s | %-32s |\n", "Permissions", perms);

#ifndef _WIN32
        printf("| %-14s | %-32lu |\n", "Inode", (unsigned long)st.st_ino);
        printf("| %-14s | %-32lu |\n", "Device ID", (unsigned long)st.st_dev);
        printf("| %-14s | %-32u |\n", "Owner UID", st.st_uid);
        printf("| %-14s | %-32u |\n", "Group GID", st.st_gid);
        printf("| %-14s | %-32lu |\n", "Hard links", (unsigned long)st.st_nlink);
#endif

        printf("+----------------+----------------------------------+\n");
    }

    return EXIT_SUCCESS;
}
