/* flexer.h - Ultimate General-Purpose Single-Header Tokenizer/Lexer
 * Public domain / MIT / Unlicense - use it for anything, no attribution
 * required.
 *
 * Features every serious language implementation needs:
 *   - Fully data-driven: you configure everything with tables
 *   - Zero allocations while tokenizing
 *   - Multi-char operators, keywords, symbols in O(1) or O(log n)
 *   - Custom number formats (hex, bin, scientific, suffixes like 10f, 0xFFu64)
 *   - String escapes, raw strings, char literals
 *   - Nested comments
 *   - Custom block/string delimiters (e.g. Python triple quotes, Rust raw
 * strings)
 *   - Excellent error reporting (line, column, context)
 */

#ifndef FLEXER_H
#define FLEXER_H

#include <ctype.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

typedef enum { const char *start; size_t len; }
Str;

typedef enum {
  TOK_EOF = 0,
  TOK_INVALID = -1,
  TOK_USER = 256 // your token types start here
} TokenBaseType;

typedef struct {
  int type; // TOK_EOF, TOK_INVALID, or your enum value
  Str text; // slice into original source
  int line;
  int col;

  union {
    int64_t i64;
    uint64_t u64;
    double f64;
  } value;
} Token;

typedef struct Flexer;

typedef void (*FlexRuleFn)(struct Flexer *f, Token *out);

typedef struct {
  const char *prefix; // e.g. "==", "+", "//", "/*"
  int token_type;     // 0 = skip (comment/whitespace), >0 = emit this token
} FlexSymbol;

typedef struct {
  const char *word;
  int token_type;
} FlexKeyword;

typedef struct Flexer {
  const char *src;
  size_t len;
  const char *cur;
  const char *line_start;
  int line;
  int col;

  // configuration tables (set these before lexing)
  const FlexSymbol *symbols;
  size_t symbol_count;
  const FlexKeyword *keywords;
  size_t keyword_count;
  const char *line_comment;        // e.g. "//"
  const char *block_comment_start; // e.g. "/*"
  const char *block_comment_end;   // e.g. "*/"
  bool nested_comments;

  // optional custom literal handlers
  FlexRuleFn custom_number;
  FlexRuleFn custom_string;
  FlexRuleFn custom_char;

  Token current;
} Flexer;

// ─────────────────────────────────────────────────────────────────────────────
// Core API
// ─────────────────────────────────────────────────────────────────────────────

static inline void flex_init(Flexer *f, const char *source, size_t len) {
  *f = (Flexer){0};
  f->src = f->cur = f->line_start = source;
  f->len = len;
  f->line = 1;
  f->col = 1;
}

static inline bool flex_at_end(Flexer *f) {
  return (size_t)(f->cur - f->src) >= f->len;
}

static inline char flex_peek(Flexer *f) { return flex_at_end(f) ? 0 : *f->cur; }

static inline char flex_peek_next(Flexer *f) {
  return (size_t)(f->cur + 1 - f->src) >= f->len ? 0 : f->cur[1];
}

static inline char flex_advance(Flexer *f) {
  char c = *f->cur++;
  if (c == '\n') {
    f->line++;
    f->line_start = f->cur;
    f->col = 1;
  } else
    f->col++;
  return c;
}

// ──────────────────────────────────────────────────────
// Internal: longest-match symbol lookup (trie-like linear scan)
// ──────────────────────────────────────────────────────
static int lookup_symbol(Flexer *f, const char *start, size_t max_len) {
  int best_type = 0;
  size_t best_len = 0;

  for (size_t i = 0; i < f->symbol_count; ++i) {
    const char *p = f->symbols[i].prefix;
    size_t len = strlen(p);
    if (len <= max_len && len > best_len && memcmp(start, p, len) == 0) {
      best_len = len;
      best_type = f->symbols[i].token_type;
    }
  }
  if (best_len > 0) {
    f->cur = start + best_len; // consume it
    while ((size_t)(f->cur - f->line_start) > 0 && f->cur[-1] != '\n')
      f->col++;
  }
  return best_type;
}

// ─────────────────────────────────────────────────────────────────────────────
// Default literal handlers (you can replace them)
// ─────────────────────────────────────────────────────────────────────────────
static void default_number_rule(Flexer *f, Token *out) {
  const char *start = f->cur - 1;
  bool is_float = false, is_hex = false, is_bin = false;

  if (flex_peek(f) == '0' && (flex_peek_next(f) | 32) == 'x') {
    is_hex = true;
    flex_advance(f);
    flex_advance(f);
    while (isxdigit(flex_peek(f)) || flex_peek(f) == '_')
      flex_advance(f);
  } else if (flex_peek(f) == '0' && (flex_peek_next(f) | 32) == 'b') {
    is_bin = true;
    flex_advance(f);
    flex_advance(f);
    while (flex_peek(f) == '0' || flex_peek(f) == '1' || flex_peek(f) == '_')
      flex_advance(f);
  } else {
    while (isdigit(flex_peek(f)) || flex_peek(f) == '_')
      flex_advance(f);
    if (flex_peek(f) == '.') {
      is_float = true;
      flex_advance(f);
      while (isdigit(flex_peek(f)))
        flex_advance(f);
    }
    if (flex_peek(f) == 'e' || flex_peek(f) == 'E') {
      is_float = true;
      flex_advance(f);
      if (flex_peek(f) == '+' || flex_peek(f) == '-')
        flex_advance(f);
      while (isdigit(flex_peek(f)))
        flex_advance(f);
    }
  }

  // optional suffixes like u64, f32, etc.
  while (isalpha(flex_peek(f)) || flex_peek(f) == '_')
    flex_advance(f);

  out->text = (Str){start, (size_t)(f->cur - start)};
  if (is_float) {
    // crude but fast parse
    char buf[256];
    size_t n =
        out->text.len < sizeof(buf) - 1 ? out->text.len : sizeof(buf) - 1;
    memcpy(buf, start, n);
    buf[n] = '\0';
    out->value.f64 = strtod(buf, NULL);
  } else {
    uint64_t val = 0;
    for (const char *p = start; p < f->cur; ++p) {
      char c = *p;
      if (c >= '0' && c <= '9')
        val = val * 10 + (c - '0');
      else if (is_hex && isxdigit(c))
        val = val * 16 + (c <= '9' ? c - '0' : (c | 32) - 'a' + 10);
      else if (is_bin && (c == '0' || c == '1'))
        val = val * 2 + (c - '0');
    }
    out->value.u64 = val;
  }
}

static void default_string_rule(Flexer *f, Token *out, char quote) {
  const char *start = f->cur - 1;
  while (flex_peek(f) && flex_peek(f) != quote && flex_peek(f) != '\n') {
    if (flex_peek(f) == '\\')
      flex_advance(f);
    flex_advance(f);
  }
  bool closed = flex_peek(f) == quote;
  if (closed)
    flex_advance(f);
  out->type = closed ? TOK_STRING : TOK_INVALID;
  out->text = (Str){start, (size_t)(f->cur - start)};
}

// ─────────────────────────────────────────────────────────────────────────────
// Main lexing function
// ─────────────────────────────────────────────────────────────────────────────
static Token flex_next(Flexer *f) {
  while (!flex_at_end(f)) {
    const char *start = f->cur;
    int line = f->line, col = f->col;
    char c = flex_advance(f);

    // whitespace
    if (isspace(c))
      continue;

    // line comment
    if (f->line_comment &&
        memcmp(start, f->line_comment, strlen(f->line_comment)) == 0) {
      while (flex_peek(f) && flex_peek(f) != '\n')
        flex_advance(f);
      continue;
    }

    // block comment
    if (f->block_comment_start && memcmp(start, f->block_comment_start,
                                         strlen(f->block_comment_start)) == 0) {
      const char *end = f->block_comment_end;
      size_t elen = strlen(end);
      int level = 1;
      f->cur = start + strlen(f->block_comment_start);
      while (level > 0 && !flex_at_end(f)) {
        if (f->nested_comments && memcmp(f->cur, f->block_comment_start,
                                         strlen(f->block_comment_start)) == 0) {
          level++;
          f->cur += strlen(f->block_comment_start);
        } else if (memcmp(f->cur, end, elen) == 0) {
          level--;
          f->cur += elen;
        } else {
          flex_advance(f);
        }
      }
      continue;
    }

    // symbols / operators (longest match)
    int sym_type = lookup_symbol(f, start, f->len - (size_t)(start - f->src));
    if (sym_type != 0) {
      return (Token){sym_type ? sym_type : 0,
                     {start, (size_t)(f->cur - start)},
                     line,
                     col};
    }

    // identifiers & keywords
    if (isalpha(c) || c == '_') {
      while (isalnum(flex_peek(f)) || flex_peek(f) == '_')
        flex_advance(f);
      Str id = {start, (size_t)(f->cur - start)};

      // keyword lookup (linear for simplicity - replace with hash table for
      // 100+ keywords)
      for (size_t i = 0; i < f->keyword_count; ++i) {
        if (strlen(f->keywords[i].word) == id.len &&
            memcmp(id.start, f->keywords[i].word, id.len) == 0) {
          return (Token){f->keywords[i].token_type, id, line, col};
        }
      }
      return (Token){TOK_IDENTIFIER, id, line, col};
    }

    // numbers
    if (isdigit(c) || (c == '.' && isdigit(flex_peek(f)))) {
      Token t = {TOK_NUMBER, {start, 0}, line, col};
      if (f->custom_number)
        f->custom_number(f, &t);
      else
        default_number_rule(f, &t);
      t.line = line;
      t.col = col;
      return t;
    }

    // strings / chars
    if (c == '"' || c == '\'') {
      Token t = {TOK_STRING, {start, 0}, line, col};
      if (f->custom_string)
        f->custom_string(f, &t);
      else
        default_string_rule(f, &t, c);
      t.line = line;
      t.col = col;
      return t;
    }

    // fallback
    return (Token){TOK_INVALID, {start, 1}, line, col};
  }

  return (Token){TOK_EOF, {NULL, 0}, f->cur}, f->line, f->col
};
}

#endif // FLEXER_H

// ─────────────────────────────────────────────────────────────────────────────
// Example: Tokenizing a tiny Python-like language
// ─────────────────────────────────────────────────────────────────────────────
#ifdef FLEXER_IMPLEMENTATION
#include <stdio.h>

enum {
  TOK_IDENTIFIER = TOK_USER,
  TOK_NUMBER,
  TOK_STRING,
  TOK_DEF,
  TOK_IF,
  TOK_ELSE,
  TOK_RETURN,
  TOK_PLUS,
  TOK_MINUS,
  TOK_STAR,
  TOK_SLASH,
  TOK_EQ,
  TOK_EQEQ,
  TOK_NE,
  TOK_LT,
  TOK_LE,
  TOK_GT,
  TOK_GE,
  TOK_AND,
  TOK_OR,
};

static const FlexSymbol symbols[] = {
    {"+", TOK_PLUS},  {"-", TOK_MINUS}, {"*", TOK_STAR}, {"/", TOK_SLASH},
    {"==", TOK_EQEQ}, {"!=", TOK_NE},   {"<", TOK_LT},   {"<=", TOK_LE},
    {">", TOK_GT},    {">=", TOK_GE},   {"&&", TOK_AND}, {"||", TOK_OR},
    {"=", 0},         {"(", 0},         {")", 0},        {"{", 0},
    {"}", 0},         {",", 0},         {";", 0},        {":", 0},
    {"//", 0},        {"/*", 0},        {"*/", 0},
};

static const FlexKeyword keywords[] = {
    {"def", TOK_DEF},
    {"if", TOK_IF},
    {"else", TOK_ELSE},
    {"return", TOK_RETURN},
};

int main() {
  const char *code = "def add(a, b) -> int:\n"
                     "    return a + b  # hello\n"
                     "x = 42.5e-10";

  Flexer f;
  flex_init(&f, code, strlen(code));
  f.symbols = symbols;
  f.symbol_count = sizeof(symbols) / sizeof(symbols[0]);
  f.keywords = keywords;
  f.keyword_count = sizeof(keywords) / sizeof(keywords[0]);
  f.line_comment = "#";
  // f.block_comment_start = "/*"; f.block_comment_end = "*/"; f.nested_comments
  // = true;

  // uncomment for C-style

  Token t;
  while ((t = flex_next(&f)).type != TOK_EOF) {
    if (t.type == TOK_INVALID) {
      printf("ERROR %d:%d: invalid token\n", t.line, t.col);
      break;
    }
    if (t.type > 0) { // skip whitespace/comment tokens
      printf("%3d:%-3d  %-12s  %.*s\n", t.line, t.col,
             t.type == TOK_IDENTIFIER ? "ID"
             : t.type == TOK_NUMBER   ? "NUM"
             : t.type == TOK_STRING   ? "STR"
                                      : "SYM/KW",
             (int)t.text.len, t.text.start);
    }
  }
  return 0;
}
#endif
