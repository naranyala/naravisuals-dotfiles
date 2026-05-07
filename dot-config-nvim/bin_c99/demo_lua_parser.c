// lua_tokens.h  –  put this in your project or directly in main.c

#define FLEXER_IMPLEMENTATION
#include "flexer.h"

typedef enum {
  T_EOF = TOK_EOF,
  T_INVALID = TOK_INVALID,

  // Lua reserves (keywords)
  T_AND = TOK_USER,
  T_BREAK,
  T_DO,
  T_ELSE,
  T_ELSEIF,
  T_END,
  T_FALSE,
  T_FOR,
  T_FUNCTION,
  T_GOTO,
  T_IF,
  T_IN,
  T_LOCAL,
  T_NIL,
  T_NOT,
  T_OR,
  T_REPEAT,
  T_RETURN,
  T_THEN,
  T_TRUE,
  T_UNTIL,
  T_WHILE,

  // Lua loves these
  T_CONCAT, // ..
  T_DOTS,   // ...
  T_EQ,     // ==
  T_GE,     // >=
  T_LE,     // <=
  T_NE,     // ~=
  T_SHL,    // <<
  T_SHR,    // >>

  T_NUMBER,
  T_STRING,
  T_NAME, // identifier

  // punctuation that Lua uses
  T_LPAREN = '(',
  T_RPAREN = ')',
  T_LBRACE = '{',
  T_RBRACE = '}',
  T_LBRACKET = '[',
  T_RBRACKET = ']',
  T_SEMI = ';',
  T_COLON = ':',
  T_COMMA = ',',
  T_DOT = '.',
  T_HASH = '#',
} LuaToken;

static const FlexKeyword lua_keywords[] = {
    {"and", T_AND},     {"break", T_BREAK},   {"do", T_DO},
    {"else", T_ELSE},   {"elseif", T_ELSEIF}, {"end", T_END},
    {"false", T_FALSE}, {"for", T_FOR},       {"function", T_FUNCTION},
    {"goto", T_GOTO},   {"if", T_IF},         {"in", T_IN},
    {"local", T_LOCAL}, {"nil", T_NIL},       {"not", T_NOT},
    {"or", T_OR},       {"repeat", T_REPEAT}, {"return", T_RETURN},
    {"then", T_THEN},   {"true", T_TRUE},     {"until", T_UNTIL},
    {"while", T_WHILE},
};

static const FlexSymbol lua_symbols[] = {
    // operators (longest match wins automatically)
    {"..", T_CONCAT},
    {"...", T_DOTS},
    {"==", T_EQ},
    {"~=", T_NE},
    {">=", T_GE},
    {"<=", T_LE},
    {">>", T_SHR},
    {"<<", T_SHL},
    {"+", 0},
    {"-", 0},
    {"*", 0},
    {"/", 0},
    {"//", 0},
    {"%", 0},
    {"^", 0},
    {"&", 0},
    {"|", 0},
    {"~", 0},
    {"#", T_HASH},
    {"=", 0},
    {">", 0},
    {"<", 0},
    {"(", T_LPAREN},
    {")", T_RPAREN},
    {"{", T_LBRACE},
    {"}", T_RBRACE},
    {"[", T_LBRACKET},
    {"]", T_RBRACKET},
    {";", T_SEMI},
    {":", T_COLON},
    {",", T_COMMA},
    {".", T_DOT},

    // comments – token_type = 0 means “skip”
    {"--", 0},
};

// Custom handler for Lua long brackets [===[ ... ]===]
static void lua_long_string_rule(Flexer *f, Token *out) {
  const char *start = f->cur - 1; // points at the opening '['
  int level = 0;

  // count opening '='s
  while (flex_peek(f) == '=') {
    flex_advance(f);
    level++;
  }
  if (flex_peek(f) != '[') {
    // not a long bracket → fall back to normal string (shouldn’t happen)
    default_string_rule(f, out, '[');
    return;
  }
  flex_advance(f); // consume the second '['

  const char *content_start = f->cur;

  // find matching closing bracket
  while (1) {
    if (flex_at_end(f)) {
      out->type = T_INVALID;
      out->text = (Str){start, (size_t)(f->cur - start)};
      return;
    }
    if (flex_peek(f) == ']') {
      const char *p = f->cur;
      flex_advance(f);
      int eqs = 0;
      while (flex_peek(f) == '=') {
        flex_advance(f);
        eqs++;
      }
      if (flex_peek(f) == ']' && eqs == level) {
        flex_advance(f); // consume closing ']'
        out->type = T_STRING;
        out->text = (Str){start, (size_t)(f->cur - start)};
        return;
      }
      // not the closing one → continue searching
      f->cur = p; // rewind the single ']'
    }
    flex_advance(f);
  }
}

int main() {
  const char *lua_code =
      "local function fib(n)\n"
      "  if n < 2 then return n end\n"
      "  return fib(n-1) + fib(n-2)\n"
      "end\n"
      "\n"
      "--[=[ this is a \n"
      "     multi-line comment with [=[ nested ]=] brackets ]=]\n"
      "print([[Hello \"Lua\" world!]] .. [[raw string]])\n";

  Flexer f;
  flex_init(&f, lua_code, strlen(lua_code));

  f.symbols = lua_symbols;
  f.symbol_count = sizeof(lua_symbols) / sizeof(lua_symbols[0]);
  f.keywords = lua_keywords;
  f.keyword_count = sizeof(lua_keywords) / sizeof(lua_keywords[0]);
  f.line_comment = "--";
  f.nested_comments = true; // Lua allows nested --[[ ]]

  // Enable Lua long strings/comments on both [ and ] when they appear after --
  // or alone
  f.custom_string =
      lua_long_string_rule; // handles [[ ... ]], [=[ ... ]=], etc.
  // normal "..." and '...' are still handled by default_string_rule
  // automatically

  Token t;
  const char *names[] = {
      [T_NAME] = "NAME", [T_NUMBER] = "NUMBER", [T_STRING] = "STRING"};

  while ((t = flex_next(&f)).type != T_EOF) {
    if (t.type <= 0)
      continue; // skip whitespace/comments

    const char *name = "UNKNOWN";
    if (t.type >= TOK_USER && t.type < TOK_USER + 1000) {
      if (t.type == T_NAME)
        name = "NAME";
      else if (t.type == T_NUMBER)
        name = "NUMBER";
      else if (t.type == T_STRING)
        name = "STRING";
      else
        name = "KEYWORD/OP";
    } else if (t.type < 128) {
      name = "PUNCT";
    }

    printf("%3d:%-3d  %-12s  %.*s\n", t.line, t.col, name, (int)t.text.len,
           t.text.start);
  }
}
