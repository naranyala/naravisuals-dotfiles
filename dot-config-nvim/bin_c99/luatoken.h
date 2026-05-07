
#include <string.h>

#ifndef LUATOKEN_H
#define LUATOKEN_H

/*
    luatoken.h — Minimal Lua-like tokenizer (single-header)

    Features:
      - Identifiers
      - Keywords: if, then, end, function, local, return
      - Numbers (integer only)
      - Strings: "text" or 'text'
      - Operators: = + - * / ( ) { } , .
      - Comments: -- line comment
      - Whitespace skipping
*/

#ifdef __cplusplus
extern "C" {
#endif

/* ============================
      TOKEN DEFINITIONS
   ============================ */

typedef enum {
  LTOK_EOF = 0,
  LTOK_IDENT,
  LTOK_NUMBER,
  LTOK_STRING,

  LTOK_KW_IF,
  LTOK_KW_THEN,
  LTOK_KW_END,
  LTOK_KW_FUNCTION,
  LTOK_KW_LOCAL,
  LTOK_KW_RETURN,

  LTOK_EQ,
  LTOK_PLUS,
  LTOK_MINUS,
  LTOK_STAR,
  LTOK_SLASH,
  LTOK_LPAREN,
  LTOK_RPAREN,
  LTOK_LBRACE,
  LTOK_RBRACE,
  LTOK_COMMA,
  LTOK_DOT,

  LTOK_UNKNOWN
} ltok_kind;

typedef struct {
  ltok_kind kind;
  char text[128];
} ltoken;

/* ================
      STATE
   ================ */

typedef struct {
  const char *src;
  const char *cur;
  ltoken tok;
} ltok_state;

/* ============================
      INTERNAL HELPERS
   ============================ */

static int lt_is_ident_start(char c) {
  return (c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'));
}

static int lt_is_ident_char(char c) {
  return lt_is_ident_start(c) || (c >= '0' && c <= '9');
}

/* ============================
      INITIALIZE
   ============================ */

static void ltok_init(ltok_state *S, const char *source) {
  S->src = source;
  S->cur = source;
  S->tok.kind = LTOK_UNKNOWN;
  S->tok.text[0] = 0;
}

/* ============================
      MAIN TOKENIZER
   ============================ */

static void ltok_next(ltok_state *S) {
  const char *c = S->cur;

again:
  /* skip whitespace */
  while (*c == ' ' || *c == '\t' || *c == '\n' || *c == '\r')
    c++;

  /* EOF */
  if (*c == '\0') {
    S->tok.kind = LTOK_EOF;
    S->tok.text[0] = 0;
    S->cur = c;
    return;
  }

  /* comments */
  if (c[0] == '-' && c[1] == '-') {
    c += 2;
    while (*c && *c != '\n')
      c++;
    goto again;
  }

  /* identifier / keyword */
  if (lt_is_ident_start(*c)) {
    char buf[128];
    int i = 0;

    while (lt_is_ident_char(*c) && i < 127)
      buf[i++] = *c++;
    buf[i] = 0;

    /* keywords */
    if (!strcmp(buf, "if")) {
      S->tok.kind = LTOK_KW_IF;
    } else if (!strcmp(buf, "then")) {
      S->tok.kind = LTOK_KW_THEN;
    } else if (!strcmp(buf, "end")) {
      S->tok.kind = LTOK_KW_END;
    } else if (!strcmp(buf, "function")) {
      S->tok.kind = LTOK_KW_FUNCTION;
    } else if (!strcmp(buf, "local")) {
      S->tok.kind = LTOK_KW_LOCAL;
    } else if (!strcmp(buf, "return")) {
      S->tok.kind = LTOK_KW_RETURN;
    } else {
      S->tok.kind = LTOK_IDENT;
      strcpy(S->tok.text, buf);
    }

    S->cur = c;
    return;
  }

  /* number (integer only) */
  if (*c >= '0' && *c <= '9') {
    char buf[128];
    int i = 0;

    while (*c >= '0' && *c <= '9' && i < 127)
      buf[i++] = *c++;
    buf[i] = 0;

    S->tok.kind = LTOK_NUMBER;
    strcpy(S->tok.text, buf);
    S->cur = c;
    return;
  }

  /* string (no escape sequences) */
  if (*c == '"' || *c == '\'') {
    char quote = *c++;
    char buf[128];
    int i = 0;

    while (*c && *c != quote && i < 127)
      buf[i++] = *c++;
    if (*c == quote)
      c++;
    buf[i] = 0;

    S->tok.kind = LTOK_STRING;
    strcpy(S->tok.text, buf);
    S->cur = c;
    return;
  }

  /* single-char operators */
  char ch = *c++;
  ltok_kind k = LTOK_UNKNOWN;

  switch (ch) {
  case '=':
    k = LTOK_EQ;
    break;
  case '+':
    k = LTOK_PLUS;
    break;
  case '-':
    k = LTOK_MINUS;
    break;
  case '*':
    k = LTOK_STAR;
    break;
  case '/':
    k = LTOK_SLASH;
    break;
  case '(':
    k = LTOK_LPAREN;
    break;
  case ')':
    k = LTOK_RPAREN;
    break;
  case '{':
    k = LTOK_LBRACE;
    break;
  case '}':
    k = LTOK_RBRACE;
    break;
  case ',':
    k = LTOK_COMMA;
    break;
  case '.':
    k = LTOK_DOT;
    break;
  default:
    k = LTOK_UNKNOWN;
    break;
  }

  S->tok.kind = k;
  S->tok.text[0] = ch;
  S->tok.text[1] = 0;
  S->cur = c;
}

/* ============================
      UTIL FOR PRINTING
   ============================ */

#ifndef LUATOKEN_NO_PRINT
#include <stdio.h>

static const char *ltok_name(ltok_kind k) {
  switch (k) {
  case LTOK_EOF:
    return "EOF";
  case LTOK_IDENT:
    return "IDENT";
  case LTOK_NUMBER:
    return "NUMBER";
  case LTOK_STRING:
    return "STRING";
  case LTOK_KW_IF:
    return "KW_IF";
  case LTOK_KW_THEN:
    return "KW_THEN";
  case LTOK_KW_END:
    return "KW_END";
  case LTOK_KW_FUNCTION:
    return "KW_FUNCTION";
  case LTOK_KW_LOCAL:
    return "KW_LOCAL";
  case LTOK_KW_RETURN:
    return "KW_RETURN";
  case LTOK_EQ:
    return "EQ";
  case LTOK_PLUS:
    return "PLUS";
  case LTOK_MINUS:
    return "MINUS";
  case LTOK_STAR:
    return "STAR";
  case LTOK_SLASH:
    return "SLASH";
  case LTOK_LPAREN:
    return "LPAREN";
  case LTOK_RPAREN:
    return "RPAREN";
  case LTOK_LBRACE:
    return "LBRACE";
  case LTOK_RBRACE:
    return "RBRACE";
  case LTOK_COMMA:
    return "COMMA";
  case LTOK_DOT:
    return "DOT";
  default:
    return "UNKNOWN";
  }
}

static void ltok_print(const ltoken *t) {
  if (t->kind == LTOK_IDENT || t->kind == LTOK_NUMBER ||
      t->kind == LTOK_STRING || t->kind == LTOK_UNKNOWN) {
    printf("%s('%s')\n", ltok_name(t->kind), t->text);
  } else {
    printf("%s\n", ltok_name(t->kind));
  }
}

#endif /* LUATOKEN_NO_PRINT */

#ifdef __cplusplus
}
#endif

#endif /* LUATOKEN_H */
