%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex();
void yyerror(const char *s);

/* Symbol table structure */
typedef struct Symbol {
    char *name;
    double value;
    int is_temp;
    int is_constant;
    struct Symbol *next;
} Symbol;

Symbol *symbol_table = NULL;
int temp_counter = 0;

/* Function prototypes */
char* new_temp();
Symbol* find_symbol(char *name);
void add_symbol(char *name, int is_temp, int is_constant, double value);
void print_symbol_table();
void free_symbol_table();

// ANSI color codes for terminal output
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#define ANSI_BOLD         "\x1b[1m"

// Constants
#define PI 3.141592653589793
#define E 2.718281828459045
%}

%union {
    double num;
    char* str;
}

%token <num> NUMBER
%token <str> IDENTIFIER
%token PLUS MINUS MULTIPLY DIVIDE MODULO POWER ASSIGN
%token LPAREN RPAREN
%token SIN COS TAN SQRT LOG EXP ABS

%type <str> expr

/* Precedence declarations from lowest to highest */
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right POWER
%left ASSIGN

%%

input:
    /* empty */
    | input line
    ;

line:
    expr '\n' { 
        printf("\n%sThree-address code:%s\n", ANSI_BOLD ANSI_COLOR_BLUE, ANSI_COLOR_RESET);
        printf("%s%s%s\n", ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET); 
        printf("\n%sSymbol Table:%s\n", ANSI_BOLD ANSI_COLOR_BLUE, ANSI_COLOR_RESET);
        print_symbol_table();
        free($1);
        free_symbol_table();
        temp_counter = 0;
    }
    | IDENTIFIER ASSIGN expr '\n' {
        printf("\n%sAssignment:%s\n", ANSI_BOLD ANSI_COLOR_BLUE, ANSI_COLOR_RESET);
        printf("%s%s%s = %s%s%s\n", ANSI_COLOR_GREEN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($1, 0, 0, 0);
        printf("\n%sSymbol Table:%s\n", ANSI_BOLD ANSI_COLOR_BLUE, ANSI_COLOR_RESET);
        print_symbol_table();
        free($1); 
        free($3);
        free_symbol_table();
        temp_counter = 0;
    }
    | expr { 
        printf("\n%sThree-address code:%s\n", ANSI_BOLD ANSI_COLOR_BLUE, ANSI_COLOR_RESET);
        printf("%s%s%s\n", ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET); 
        printf("\n%sSymbol Table:%s\n", ANSI_BOLD ANSI_COLOR_BLUE, ANSI_COLOR_RESET);
        print_symbol_table();
        free($1);
        free_symbol_table();
        temp_counter = 0;
        YYACCEPT; 
    }
    ;

expr:
    NUMBER { 
        $$ = new_temp(); 
        printf("%s%s%s = %s%g%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_GREEN, $1, ANSI_COLOR_RESET); 
        add_symbol($$, 1, 1, $1);
    }
    | IDENTIFIER {
        if (strcmp($1, "PI") == 0) {
            $$ = new_temp();
            printf("%s%s%s = %s%g%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_GREEN, PI, ANSI_COLOR_RESET);
            add_symbol($$, 1, 1, PI);
        } else if (strcmp($1, "E") == 0) {
            $$ = new_temp();
            printf("%s%s%s = %s%g%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_GREEN, E, ANSI_COLOR_RESET);
            add_symbol($$, 1, 1, E);
        } else {
            $$ = strdup($1);
            add_symbol($1, 0, 0, 0);
        }
    }
    | expr PLUS expr { 
        $$ = new_temp(); 
        printf("%s%s%s = %s%s%s + %s%s%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr MINUS expr { 
        $$ = new_temp(); 
        printf("%s%s%s = %s%s%s - %s%s%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr MULTIPLY expr { 
        $$ = new_temp(); 
        printf("%s%s%s = %s%s%s * %s%s%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr DIVIDE expr { 
        Symbol *right = find_symbol($3);
        if (right && right->is_constant && right->value == 0) {
            printf("%sError: Division by zero!%s\n", ANSI_COLOR_RED, ANSI_COLOR_RESET);
            $$ = new_temp();
            printf("%s%s%s = %s%s%s / %s%s%s %s(Error: Division by zero)%s\n", 
                ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, 
                ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, 
                ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET,
                ANSI_COLOR_RED, ANSI_COLOR_RESET);
            add_symbol($$, 1, 0, 0);
        } else {
            $$ = new_temp(); 
            printf("%s%s%s = %s%s%s / %s%s%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET); 
            add_symbol($$, 1, 0, 0);
        }
        free($1); 
        free($3); 
    }
    | expr MODULO expr { 
        $$ = new_temp(); 
        printf("%s%s%s = %s%s%s %% %s%s%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr POWER expr { 
        $$ = new_temp(); 
        printf("%s%s%s = %s%s%s ^ %s%s%s\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $1, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | SIN LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = sin(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | COS LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = cos(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | TAN LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = tan(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | SQRT LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = sqrt(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | LOG LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = log(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | EXP LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = exp(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | ABS LPAREN expr RPAREN {
        $$ = new_temp();
        printf("%s%s%s = abs(%s%s%s)\n", ANSI_COLOR_YELLOW, $$, ANSI_COLOR_RESET, ANSI_COLOR_CYAN, $3, ANSI_COLOR_RESET);
        add_symbol($$, 1, 0, 0);
        free($3);
    }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

%%

/* Rest of the functions remain exactly the same as in your original code */

char* new_temp() {
    char* temp = (char*)malloc(10 * sizeof(char));
    sprintf(temp, "t%d", temp_counter++);
    return temp;
}

Symbol* find_symbol(char *name) {
    Symbol *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void add_symbol(char *name, int is_temp, int is_constant, double value) {
    Symbol *existing = find_symbol(name);
    if (existing != NULL) {
        /* Update existing symbol */
        existing->is_constant = is_constant;
        if (is_constant) {
            existing->value = value;
        }
        return;
    }
    
    /* Create new symbol */
    Symbol *new_symbol = (Symbol*)malloc(sizeof(Symbol));
    new_symbol->name = strdup(name);
    new_symbol->is_temp = is_temp;
    new_symbol->is_constant = is_constant;
    new_symbol->value = value;
    new_symbol->next = symbol_table;
    symbol_table = new_symbol;
}

void print_symbol_table() {
    Symbol *current = symbol_table;
    printf("%s%-10s %-10s %-10s %-10s%s\n", ANSI_BOLD, "Name", "Type", "Constant", "Value", ANSI_COLOR_RESET);
    printf("%s------------------------------------%s\n", ANSI_COLOR_MAGENTA, ANSI_COLOR_RESET);
    while (current != NULL) {
        printf("%s%-10s%s %s%-10s%s %s%-10s%s ", 
            ANSI_COLOR_GREEN, current->name, ANSI_COLOR_RESET,
            ANSI_COLOR_CYAN, current->is_temp ? "temp" : "user", ANSI_COLOR_RESET,
            ANSI_COLOR_YELLOW, current->is_constant ? "yes" : "no", ANSI_COLOR_RESET);
        
        if (current->is_constant) {
            printf("%s%-10g%s\n", ANSI_COLOR_RED, current->value, ANSI_COLOR_RESET);
        } else {
            printf("%s%-10s%s\n", ANSI_COLOR_RED, "unknown", ANSI_COLOR_RESET);
        }
        
        current = current->next;
    }
}

void free_symbol_table() {
    Symbol *current = symbol_table;
    while (current != NULL) {
        Symbol *next = current->next;
        free(current->name);
        free(current);
        current = next;
    }
    symbol_table = NULL;
}

void yyerror(const char *s) {
    fprintf(stderr, "%sError: %s%s\n", ANSI_COLOR_RED, s, ANSI_COLOR_RESET);
    free_symbol_table();
}

int main(int argc, char **argv) {
    yyparse();
    free_symbol_table();
    return 0;
}