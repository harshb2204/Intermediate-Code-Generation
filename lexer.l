%{
#include "parser.tab.h"
#include <string.h>
#include <math.h>

// ANSI color codes for terminal output
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_RESET   "\x1b[0m"
%}

%%

[0-9]+(\.[0-9]+)? { yylval.num = atof(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { 
    if (strcmp(yytext, "sin") == 0) return SIN;
    if (strcmp(yytext, "cos") == 0) return COS;
    if (strcmp(yytext, "tan") == 0) return TAN;
    if (strcmp(yytext, "sqrt") == 0) return SQRT;
    if (strcmp(yytext, "log") == 0) return LOG;
    if (strcmp(yytext, "exp") == 0) return EXP;
    if (strcmp(yytext, "abs") == 0) return ABS;
    yylval.str = strdup(yytext); return IDENTIFIER; 
}
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
"%"             { return MODULO; }
"^"             { return POWER; }
"="             { return ASSIGN; }
"("             { return LPAREN; }
")"             { return RPAREN; }
[ \t]+          ;
[\n]            { return '\n'; }
.               { printf("%sUnknown character: %s%s\n", ANSI_COLOR_RED, yytext, ANSI_COLOR_RESET); }

%%

int yywrap() {
    return 1;
}