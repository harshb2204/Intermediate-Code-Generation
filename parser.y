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
    int value;
    int is_temp;
    int is_constant;
    struct Symbol *next;
} Symbol;

Symbol *symbol_table = NULL;
int temp_counter = 0;

/* Function prototypes */
char* new_temp();
Symbol* find_symbol(char *name);
void add_symbol(char *name, int is_temp, int is_constant, int value);
void print_symbol_table();
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
    expr '\n' { 
        printf("Three-address code:\n%s\n", $1); 
        printf("\nSymbol Table:\n");
        print_symbol_table();
        free($1); 
        /* Reset for next input */
        symbol_table = NULL;
        temp_counter = 0;
    }
    | expr { 
        printf("Three-address code:\n%s\n", $1); 
        printf("\nSymbol Table:\n");
        print_symbol_table();
        free($1); 
        YYACCEPT; 
    }
    ;

expr:
    NUMBER { 
        $$ = new_temp(); 
        printf("%s = %d\n", $$, $1); 
        add_symbol($$, 1, 1, $1);
    }
    | expr PLUS expr { 
        $$ = new_temp(); 
        printf("%s = %s + %s\n", $$, $1, $3); 
        add_symbol($$, 1, 0, 0); /* Temp var, not constant */
        free($1); 
        free($3); 
    }
    | expr MINUS expr { 
        $$ = new_temp(); 
        printf("%s = %s - %s\n", $$, $1, $3); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr MULTIPLY expr { 
        $$ = new_temp(); 
        printf("%s = %s * %s\n", $$, $1, $3); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr DIVIDE expr { 
        $$ = new_temp(); 
        printf("%s = %s / %s\n", $$, $1, $3); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr MODULO expr { 
        $$ = new_temp(); 
        printf("%s = %s %% %s\n", $$, $1, $3); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | expr POWER expr { 
        $$ = new_temp(); 
        printf("%s = %s ^ %s\n", $$, $1, $3); 
        add_symbol($$, 1, 0, 0);
        free($1); 
        free($3); 
    }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

%%

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

void add_symbol(char *name, int is_temp, int is_constant, int value) {
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
    printf("%-10s %-10s %-10s %-10s\n", "Name", "Type", "Constant", "Value");
    printf("------------------------------------\n");
    while (current != NULL) {
        printf("%-10s %-10s %-10s ", 
            current->name, 
            current->is_temp ? "temp" : "user",
            current->is_constant ? "yes" : "no");
        
        if (current->is_constant) {
            printf("%-10d\n", current->value);
        } else {
            printf("%-10s\n", "unknown");
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
    fprintf(stderr, "Error: %s\n", s);
    free_symbol_table();
}

int main(int argc, char **argv) {
    yyparse();
    free_symbol_table();
    return 0;
}