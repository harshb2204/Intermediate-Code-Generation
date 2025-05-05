# Mathematical Expression Parser

A command-line tool that parses mathematical expressions, generates three-address code, and maintains a symbol table. Built using Lex and Yacc (Flex and Bison).

## Features

- Parses mathematical expressions with support for:
  - Basic arithmetic operations (+, -, *, /, %, ^)
  - Mathematical functions (sin, cos, tan, sqrt, log, exp, abs)
  - Constants (PI, E)
  - Variables and assignments
- Generates three-address code for expressions
- Maintains a symbol table with information about:
  - Variable names
  - Temporary variables
  - Constant values
  - Variable types
- Color-coded terminal output for better readability
- Error handling for invalid expressions and division by zero

## Prerequisites

- Flex (Lex)
- Bison (Yacc)
- GCC compiler
- Make (optional)

## Building the Project

1. Generate the parser:
```bash
bison -d parser.y
```

2. Generate the lexer:
```bash
flex lexer.l
```

3. Compile the project:
```bash
gcc -o math_parser parser.tab.c lex.yy.c -lm
```

Or use the provided Makefile:
```bash
make
```

## Usage

Run the program:
```bash
./math_parser
```

Enter mathematical expressions at the prompt. Examples:
```
2 + 3 * 4
sin(PI/2)
x = 5 + 3
sqrt(16)
```

The program will display:
- The three-address code representation
- The current symbol table
- Any errors or warnings

## Example Output

```
Enter expression: 2 + 3 * 4

Three-address code:
t0 = 2
t1 = 3
t2 = 4
t3 = t1 * t2
t4 = t0 + t3

Symbol Table:
Name       Type       Constant   Value
t0         temp       yes        2
t1         temp       yes        3
t2         temp       yes        4
t3         temp       no         unknown
t4         temp       no         unknown
```

## Error Handling

The parser handles various error cases:
- Division by zero
- Invalid characters
- Syntax errors
- Unknown identifiers

Error messages are displayed in red for better visibility.


