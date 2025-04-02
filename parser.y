%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int yylex();
void yyerror(const char *s);

int temp_counter = 0;

char* new_temp() {
    char* temp = (char*)malloc(10 * sizeof(char));
    sprintf(temp, "t%d", temp_counter++);
    return temp;
}
%}

%union {
    int num;
    char* str;
}

%token <num> NUMBER
%token PLUS MINUS MULTIPLY DIVIDE MODULO POWER
%token LPAREN RPAREN

%type <str> expr

/* Precedence declarations from lowest to highest */
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right POWER

%%

input:
    /* empty */
    | input line
    ;

line:
    expr '\n' { printf("%s\n", $1); free($1); }
    | expr { printf("%s\n", $1); free($1); YYACCEPT; }
    ;

expr:
    NUMBER { $$ = new_temp(); printf("%s = %d\n", $$, $1); }
    | expr PLUS expr { $$ = new_temp(); printf("%s = %s + %s\n", $$, $1, $3); free($1); free($3); }
    | expr MINUS expr { $$ = new_temp(); printf("%s = %s - %s\n", $$, $1, $3); free($1); free($3); }
    | expr MULTIPLY expr { $$ = new_temp(); printf("%s = %s * %s\n", $$, $1, $3); free($1); free($3); }
    | expr DIVIDE expr { $$ = new_temp(); printf("%s = %s / %s\n", $$, $1, $3); free($1); free($3); }
    | expr MODULO expr { $$ = new_temp(); printf("%s = %s %% %s\n", $$, $1, $3); free($1); free($3); }
    | expr POWER expr { $$ = new_temp(); printf("%s = %s ^ %s\n", $$, $1, $3); free($1); free($3); }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    yyparse();
    return 0;
}