// pdfmeta.c
// Cross-platform PDF metadata CLI with --table and --json outputs.
// Page counting via object scan (/Type /Page) with fallback to /Count in /Pages.
// No memmem dependency; includes a portable replacement.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#ifdef _WIN32
#include <sys/types.h>
#include <sys/stat.h>
#define stat _stat64
#else
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

typedef struct {
    const char *file;
    long long size_bytes;
    char size_human[64];
    int pages;
    char title[256];
    char author[256];
    char subject[256];
    char creator[256];
    char producer[256];
    char creation_date[128];
    char mod_date[128];
    char keywords[256];
} PdfMeta;

/* ---------- Portable helpers ---------- */

static void human_size(long long size, char *buf, size_t buflen) {
    const char *units[] = {"B","KB","MB","GB","TB"};
    int i = 0; double s = (double)size;
    while (s >= 1024 && i < 4) { s /= 1024; i++; }
    snprintf(buf, buflen, "%.2f %s", s, units[i]);
}

static unsigned char *read_file(const char *path, size_t *out_len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return NULL; }
    long len = ftell(f);
    if (len < 0) { fclose(f); return NULL; }
    rewind(f);
    unsigned char *buf = (unsigned char*)malloc((size_t)len);
    if (!buf) { fclose(f); return NULL; }
    size_t n = fread(buf, 1, (size_t)len, f);
    fclose(f);
    if (out_len) *out_len = n;
    return buf;
}

// Portable replacement for memmem
static void *portable_memmem(const void *haystack, size_t haystacklen,
                             const void *needle, size_t needlelen) {
    if (needlelen == 0) return (void*)haystack;
    if (haystacklen < needlelen) return NULL;

    const unsigned char *h = (const unsigned char*)haystack;
    const unsigned char *n = (const unsigned char*)needle;

    unsigned char first = n[0];
    for (size_t i = 0; i + needlelen <= haystacklen; i++) {
        if (h[i] == first && memcmp(h + i, n, needlelen) == 0) {
            return (void*)(h + i);
        }
    }
    return NULL;
}

// Alias memmem to the portable one (we don't rely on platform memmem at all)
#define memmem portable_memmem

static const unsigned char* skip_ws(const unsigned char *p, const unsigned char *end) {
    while (p < end) {
        unsigned char c = *p;
        if (c==' '||c=='\t'||c=='\r'||c=='\n'||c=='\f') p++;
        else break;
    }
    return p;
}

static int match_name(const unsigned char *p, const unsigned char *end, const char *name) {
    size_t nlen = strlen(name);
    if (p >= end || *p != '/') return 0;
    p++; // after '/'
    for (size_t i=0; i<nlen && p<end; i++, p++) {
        if ((unsigned char)name[i] != *p) return 0;
    }
    if (p>=end) return 1;
    unsigned char c=*p;
    if (c=='/'||c==' '||c=='\t'||c=='\r'||c=='\n'||c=='>'||c=='<'||c=='('||c==')') return 1;
    return 0;
}

/* ---------- Page counting ---------- */

static int region_has_type_page(const unsigned char *start, const unsigned char *end) {
    const unsigned char *p = start;
    while (p < end) {
        p = skip_ws(p, end);
        if (p >= end) break;
        if (*p == '/') {
            if (match_name(p, end, "Type")) {
                p += 1 + strlen("Type");
                p = skip_ws(p, end);
                // Look ahead for "/Page" within a small window
                const unsigned char *q = p;
                size_t window = (size_t)(end - p);
                if (window > 4096) window = 4096;
                const unsigned char *lim = p + window;
                while (q < lim) {
                    q = skip_ws(q, lim);
                    if (q >= lim) break;
                    if (*q == '/' && match_name(q, lim, "Page")) {
                        return 1;
                    }
                    q++;
                }
            }
        }
        p++;
    }
    return 0;
}

static int count_pages_obj_blocks(const unsigned char *buf, size_t n) {
    int pages = 0;
    const unsigned char *p = buf, *end = buf + n;
    while (p < end) {
        const unsigned char *obj = (const unsigned char*)memmem(p, (size_t)(end - p), " obj", 4);
        if (!obj) break;
        const unsigned char *block_end = (const unsigned char*)memmem(obj, (size_t)(end - obj), "endobj", 6);
        if (!block_end) break;
        if (region_has_type_page(obj, block_end)) pages++;
        p = block_end + 6;
    }
    return pages;
}

static int count_pages_by_count(const unsigned char *buf, size_t n) {
    int maxCount = 0;
    const unsigned char *p = buf, *end = buf + n;
    while (p < end) {
        const unsigned char *pages = (const unsigned char*)memmem(p, (size_t)(end - p), "/Type /Pages", 12);
        if (!pages) break;
        const unsigned char *block_end = (const unsigned char*)memmem(pages, (size_t)(end - pages), "endobj", 6);
        if (!block_end) block_end = end;
        const unsigned char *q = pages;
        while (q < block_end) {
            const unsigned char *cnt = (const unsigned char*)memmem(q, (size_t)(block_end - q), "/Count", 7);
            if (!cnt) break;
            cnt += 7;
            cnt = skip_ws(cnt, block_end);
            int sign = 1; if (cnt < block_end && *cnt=='-') { sign = -1; cnt++; }
            int val = 0; while (cnt < block_end && isdigit(*cnt)) { val = val*10 + (*cnt - '0'); cnt++; }
            val *= sign;
            if (val > maxCount) maxCount = val;
            q = cnt;
        }
        p = block_end;
    }
    return maxCount;
}

static int extract_page_count_robust(const char *path) {
    size_t n = 0;
    unsigned char *buf = read_file(path, &n);
    if (!buf || n == 0) { free(buf); return -1; }

    int by_obj = count_pages_obj_blocks(buf, n);
    int by_cnt = count_pages_by_count(buf, n);
    free(buf);

    if (by_obj > 0) return by_obj;
    if (by_cnt > 0) return by_cnt;
    return -1;
}

/* ---------- Info dictionary (heuristic scan) ---------- */

static void scan_literal(const char *line, const char *key, char *dst, size_t dsz) {
    const char *p = strstr(line, key);
    if (!p) return;
    p += strlen(key);
    while (*p == ' ' || *p == '\t') p++;
    if (*p != '(') return;
    p++;
    size_t i = 0;
    while (*p && *p != ')' && i + 1 < dsz) {
        dst[i++] = *p++;
    }
    dst[i] = '\0';
}

static void extract_info(FILE *f, PdfMeta *m) {
    rewind(f);
    char buf[4096];
    while (fgets(buf, sizeof(buf), f)) {
        scan_literal(buf, "/Title", m->title, sizeof(m->title));
        scan_literal(buf, "/Author", m->author, sizeof(m->author));
        scan_literal(buf, "/Subject", m->subject, sizeof(m->subject));
        scan_literal(buf, "/Creator", m->creator, sizeof(m->creator));
        scan_literal(buf, "/Producer", m->producer, sizeof(m->producer));
        scan_literal(buf, "/CreationDate", m->creation_date, sizeof(m->creation_date));
        scan_literal(buf, "/ModDate", m->mod_date, sizeof(m->mod_date));
        scan_literal(buf, "/Keywords", m->keywords, sizeof(m->keywords));
    }
}

/* ---------- Output ---------- */

static void print_table(const PdfMeta *m) {
    printf("+---------------+-------------------------------------------+\n");
    printf("| Field         | Value                                     |\n");
    printf("+---------------+-------------------------------------------+\n");
    printf("| File          | %s\n", m->file);
    printf("| Size          | %lld bytes (%s)\n", m->size_bytes, m->size_human);
    printf("| Pages         | %d\n", m->pages);
    printf("| Title         | %s\n", m->title[0] ? m->title : "(none)");
    printf("| Author        | %s\n", m->author[0] ? m->author : "(none)");
    printf("| Subject       | %s\n", m->subject[0] ? m->subject : "(none)");
    printf("| Creator       | %s\n", m->creator[0] ? m->creator : "(none)");
    printf("| Producer      | %s\n", m->producer[0] ? m->producer : "(none)");
    printf("| CreationDate  | %s\n", m->creation_date[0] ? m->creation_date : "(none)");
    printf("| ModDate       | %s\n", m->mod_date[0] ? m->mod_date : "(none)");
    printf("| Keywords      | %s\n", m->keywords[0] ? m->keywords : "(none)");
    printf("+---------------+-------------------------------------------+\n");
}

static void print_json_str(const char *label, const char *value, int comma) {
    // naive JSON; escaping not handled
    printf("  \"%s\": \"%s\"%s\n", label, value ? value : "", comma ? "," : "");
}

static void print_json(const PdfMeta *m) {
    printf("{\n");
    print_json_str("file", m->file, 1);
    printf("  \"size_bytes\": %lld,\n", m->size_bytes);
    print_json_str("size_human", m->size_human, 1);
    printf("  \"pages\": %d,\n", m->pages);
    print_json_str("title", m->title[0] ? m->title : "", 1);
    print_json_str("author", m->author[0] ? m->author : "", 1);
    print_json_str("subject", m->subject[0] ? m->subject : "", 1);
    print_json_str("creator", m->creator[0] ? m->creator : "", 1);
    print_json_str("producer", m->producer[0] ? m->producer : "", 1);
    print_json_str("creation_date", m->creation_date[0] ? m->creation_date : "", 1);
    print_json_str("mod_date", m->mod_date[0] ? m->mod_date : "", 1);
    print_json_str("keywords", m->keywords[0] ? m->keywords : "", 0);
    printf("}\n");
}

/* ---------- CLI ---------- */

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s file.pdf [--table|--json]\n", argv[0]);
        return 1;
    }

    const char *path = argv[1];
    int mode_table = 0, mode_json = 0;
    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], "--table") == 0) mode_table = 1;
        else if (strcmp(argv[i], "--json") == 0) mode_json = 1;
    }

    struct stat st;
    if (stat(path, &st) != 0) { perror("stat"); return 1; }

    PdfMeta meta;
    memset(&meta, 0, sizeof(meta));
    meta.file = path;
    meta.size_bytes = (long long)st.st_size;
    human_size(meta.size_bytes, meta.size_human, sizeof(meta.size_human));

    FILE *f = fopen(path, "rb");
    if (!f) { perror("fopen"); return 1; }
    extract_info(f, &meta);
    fclose(f);

    meta.pages = extract_page_count_robust(path);

    if (mode_json) print_json(&meta);
    else if (mode_table) print_table(&meta);
    else {
        printf("File: %s\n", meta.file);
        printf("Size: %lld bytes (%s)\n", meta.size_bytes, meta.size_human);
        printf("Pages: %d\n", meta.pages);
        printf("Title: %s\n", meta.title[0] ? meta.title : "(none)");
        printf("Author: %s\n", meta.author[0] ? meta.author : "(none)");
        printf("Subject: %s\n", meta.subject[0] ? meta.subject : "(none)");
        printf("Creator: %s\n", meta.creator[0] ? meta.creator : "(none)");
        printf("Producer: %s\n", meta.producer[0] ? meta.producer : "(none)");
        printf("CreationDate: %s\n", meta.creation_date[0] ? meta.creation_date : "(none)");
        printf("ModDate: %s\n", meta.mod_date[0] ? meta.mod_date : "(none)");
        printf("Keywords: %s\n", meta.keywords[0] ? meta.keywords : "(none)");
    }

    return 0;
}
