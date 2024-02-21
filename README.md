Here's a markdown table displaying the differences between EBNF, W3C EBNF, and ANTLR4 grammars:

| Feature                  | EBNF                             | W3C EBNF                          | ANTLR4                                     |
|--------------------------|----------------------------------|-----------------------------------|--------------------------------------------|
| Syntax                   | ::=, |, [], {}, etc.             | ::=, |, [], {}, etc.              | ->, |, [], {}, etc.                        |
| Rule Declaration         | RuleName ::= Expression          | RuleName ::= Expression           | RuleName: Expression ;                     |
| Grouping                 | (Expression)                     | (Expression)                      | (Expression)                               |
| Optional                 | [Expression]                     | [Expression]                      | Expression?                                |
| Zero or More             | {Expression}                     | {Expression}                      | Expression*                                |
| One or More              | Expression {Expression}          | Expression {Expression}           | Expression+                                |
| Alternatives             | Expression1 \| Expression2       | Expression1 | Expression2         | Expression1 \| Expression2                 |
| Sequence                 | Expression1 Expression2          | Expression1 Expression2           | Expression1 Expression2                    |
| Literal String           | "literal"                        | "literal"                         | 'literal'                                  |
| Character Set            | [a-zA-Z0-9]                      | [a-zA-Z0-9]                       | [a-zA-Z0-9]                                |
| Grouping & Ordering      | (Expr1, Expr2)                   | (Expr1, Expr2)                    | Expr1 Expr2                                |
| Positive Lookahead       | & Expression                     | & Expression                      | (not directly supported)                   |
| Negative Lookahead       | ! Expression                     | ! Expression                      | ~ Expression                               |
| Comments                 | // Comment                       | // Comment                        | // Comment <br> /\* Multi-line comment \*/ |
| Whitespace               | (Space \| Tab \| Newline)+       | (Space \| Tab \| Newline)+        | (WS \| '\t' \| '\n' \| '\r')+              |
| Rule Reference           | RuleName                         | RuleName                          | ruleName                                   |
| Token Definitions        | (defined separately)             | (defined separately)              | (defined within grammar using lexer rules) |
| Lexical Modes            | (not supported)                  | (not supported)                   | (Lexer modes)                              |
