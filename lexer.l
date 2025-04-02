%{
#include "parser.tab.h"
%}

%%

[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
"%"             { return MODULO; }
"^"             { return POWER; }
"("             { return LPAREN; }
")"             { return RPAREN; }
[ \t]+          ;
[\n]            { return '\n'; }
.               { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}