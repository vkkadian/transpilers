grammar SPARQL;

sparqlQuery: prologue? (selectQuery | constructQuery | describeQuery | askQuery | federatedQuery) valuesClause? ;
prologue: (baseDecl | prefixDecl)*;

baseDecl: 'BASE' IRI_REF;
prefixDecl: 'PREFIX' PNAME_NS IRI_REF;

selectQuery: 'SELECT' (DISTINCT | REDUCED)? (var | '(' expression 'AS' var ')')* datasetClause* whereClause? solutionModifier?;

constructQuery: 'CONSTRUCT' (constructTemplate datasetClause* whereClause? solutionModifier?);

describeQuery: 'DESCRIBE' (varOrIRIref | '*')* datasetClause* whereClause? solutionModifier?;

askQuery: 'ASK' datasetClause* whereClause? solutionModifier?;

federatedQuery: 'SELECT' (DISTINCT | REDUCED)? (var | '(' expression 'AS' var ')')* datasetClause* whereClause? solutionModifier? serviceGraphPattern+;

serviceGraphPattern: 'SERVICE' SILENT? iri '{' groupGraphPattern '}';

datasetClause: 'FROM' (defaultGraphClause | namedGraphClause);
defaultGraphClause: sourceSelector;
namedGraphClause: 'NAMED' sourceSelector;

sourceSelector: iri;

whereClause: 'WHERE' groupGraphPattern;

solutionModifier: (orderClause | limitOffsetClauses);
limitOffsetClauses: (limitClause offsetClause?) | (offsetClause limitClause?);
limitClause: 'LIMIT' INTEGER;
offsetClause: 'OFFSET' INTEGER;
orderClause: 'ORDER' 'BY' orderCondition+;

groupGraphPattern: '{' (triplesBlock | groupGraphPatternSub) '}';
groupGraphPatternSub: groupGraphPattern | (groupGraphPatternSub ('UNION' groupGraphPatternSub)+);

triplesBlock: triplesSameSubject ('.' triplesBlock)?;
triplesSameSubject: varOrTerm propertyListNotEmpty | triplesNode propertyList;

propertyList: propertyListNotEmpty?;

propertyListNotEmpty: verb objectList (';' verb objectList)*;

verb: varOrIRIref | 'a';

objectList: object (';' object)*;

triplesNode: collection | blankNodePropertyList;
blankNodePropertyList: '[' propertyList ']';
collection: '(' object* ')';

triples: subject predicateObjectList?;
subject: varOrTerm | triplesNode;

predicateObjectList: verb objectList;

object: varOrTerm | triplesNode;

varOrTerm: var | graphTerm;
var: VAR1 | VAR2;
graphTerm: iri | rdfLiteral | numericLiteral | booleanLiteral | blankNode | NIL;

expression: conditionalOrExpression;

conditionalOrExpression: conditionalAndExpression ('||' conditionalAndExpression)*;

conditionalAndExpression: valueLogical ('&&' valueLogical)*;

valueLogical: relationalExpression;

relationalExpression: numericExpression (EQUALS | NOT_EQUALS | LESS | GREATER | LESS_OR_EQ | GREATER_OR_EQ | 'IN' '(' expression (',' expression)* ')' | 'NOT' 'IN' '(' expression (',' expression)* ')')? numericExpression;

numericExpression: additiveExpression (PLUS | MINUS additiveExpression)*;

additiveExpression: multiplicativeExpression (MULTIPLY | DIVIDE multiplicativeExpression)*;

multiplicativeExpression: unaryExpression (POWER unaryExpression)*;

unaryExpression: '!'? primaryExpression;

primaryExpression: brackettedExpression | builtInCall | iriOrFunction | rdfLiteral | numericLiteral | booleanLiteral | var;

brackettedExpression: '(' expression ')';

builtInCall: aggregate | regexExpression | substringExpression | strReplaceExpression | existsFunc | notExistsFunc | BOUND '(' var ')';

aggregate: 'COUNT' '(' 'DISTINCT'? ( '*' | expression ) ')';

regexExpression: 'REGEX' '(' expression ',' expression (',' expression)? ')';

substringExpression: 'SUBSTR' '(' expression ',' expression (',' expression)? ')';

strReplaceExpression: 'REPLACE' '(' expression ',' expression ',' expression (',' expression)? ')';

existsFunc: 'EXISTS' groupGraphPattern;
notExistsFunc: 'NOT' 'EXISTS' groupGraphPattern;

iriOrFunction: iri argList?;

argList: NIL | '(' expression ( ',' expression )* ')';

rdfLiteral: STRING_LITERAL_QUOTE ('^^' iri | LANGTAG)?;

numericLiteral: INTEGER | DECIMAL | DOUBLE;

booleanLiteral: 'true' | 'false';

iri: IRI_REF | prefixedName;

prefixedName: PNAME_LN | PNAME_NS;

VAR1: '?' [A-Za-z0-9]+;
VAR2: '$' [A-Za-z0-9]+;

INTEGER: [0-9]+;
DECIMAL: [0-9]* '.' [0-9]+;
DOUBLE: (DECIMAL | INTEGER) EXPONENT;
EXPONENT: [eE] [+\-]? [0-9]+;

STRING_LITERAL_QUOTE: '"' (ESC | ~["\\\n\r])* '"';
LANGTAG: '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*;

NIL: '(' WS* ')' ;
ANON: '[' WS* ']' ;
IRI_REF: '<' (~[<>"{}|^`\] | UCHAR)* '>';

PNAME_NS: PN_PREFIX? ':';
PNAME_LN: PNAME_NS PN_LOCAL;

VARNAME: VAR1 | VAR2;

WS: [ \t\n\r]+ -> skip;
COMMENT: ('#' ~[\r\n]* [\r\n]) -> skip;

UCHAR: '\\u' HEX HEX HEX HEX | '\\U' HEX HEX HEX HEX HEX HEX HEX HEX;
HEX: [0-9A-Fa-f];

ESC: '\\' ([tnrbf"'\\] | UCHAR);

INTEGER: [0-9]+;

DECIMAL: [0-9]* '.' [0-9]+;

DOUBLE: (DECIMAL | INTEGER) EXPONENT;

EXPONENT: [eE] [+\-]? [0-9]+;

STRING_LITERAL_QUOTE: '"' (ESC | ~["\\\n\r])* '"';

LANGTAG: '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*;

NIL: '(' WS* ')' ;

ANON: '[' WS* ']' ;

IRIREF: '<' (~[<>"{}|^`\] | UCHAR)* '>';

PNAME_NS: PN_PREFIX? ':';

PNAME_LN: PNAME_NS PN_LOCAL;

VARNAME: VAR1 | VAR2;

PN_CHARS_BASE: [A-Z] | [a-z] | [\u00C0-\u00D6] | [\u00D8-\u00F6] | [\u00F8-\u02FF] | [\u0370-\u037D] | [\u037F-\u1FFF] | [\u200C-\u200D] | [\u2070-\u218F] | [\u2C00-\u2FEF] | [\u3001-\uD7FF] | [\uF900-\uFDCF] | [\uFDF0-\uFFFD] | [\U00010000-\U000EFFFF];

PN_CHARS_U: PN_CHARS_BASE | '_';

PN_CHARS: PN_CHARS_U | '-' | [0-9] | '\u00B7' | [\u0300-\u036F] | [\u203F-\u2040];

PN_PREFIX: PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)?;

PNAME_NS: PN_PREFIX? ':';

PN_LOCAL: (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))?;

PNAME_LN: PNAME_NS PN_LOCAL;

PLX: PERCENT | PN_LOCAL_ESC;

PERCENT: '%' [0-9] [0-9];

PN_LOCAL_ESC: '\\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%' | PN_CHARS | PLX);

# SPARQL Update grammar extensions
update: (load | clear | drop | add | move | copy | create | insert | delete) WS* ;

load: 'LOAD' WS+ iri WS* into?;

clear: ('CLEAR' WS+ graphRef) | ('CLEAR' WS+ (DEFAULT | SILENT | NAMED) WS* graphRef);

drop: ('DROP' WS+ (DEFAULT | SILENT | NAMED) WS* graphRef);

add: ('ADD' WS+ (DEFAULT | SILENT | NAMED) WS* graphOrDefault) 'TO' WS* graphOrDefault;

move: ('MOVE' WS+ (DEFAULT | SILENT | NAMED) WS* graphOrDefault) 'TO' WS* graphOrDefault;

copy: ('COPY' WS+ (DEFAULT | SILENT | NAMED) WS* graphOrDefault) 'TO' WS* graphOrDefault;

create: ('CREATE' WS+ (SILENT | NAMED) WS* graphRef);

insert: ('INSERT' WS+ (DATA | SILENT | INTO) WS* quadData | 'INSERT' WS+ (SILENT | INTO) WS* (GRAPH | DEFAULT) WS+ graphRef WS* quadPattern);

delete: ('DELETE' WS+ (DATA | SILENT | WHERE) WS* quadData | 'DELETE' WS+ (SILENT | WHERE) WS* (GRAPH | DEFAULT) WS+ graphRef WS* quadPattern);

graphOrDefault: 'GRAPH' WS* iri | 'DEFAULT' | 'NAMED' | 'ALL';

graphRef: 'GRAPH' WS* iri | 'DEFAULT' | 'NAMED';

quadData: '{' WS* (quads | WS+)? '}';
quadPattern: '{' WS* (quads | WS+)? '}';

quads: quadPattern | triplesBlock;
quad: triplesBlock (WS+ graphRef)? '.'?;

WS: [ \t\n\r]+ -> skip;

COMMENT: ('#' ~[\r\n]* [\r\n]) -> skip;

UCHAR: '\\u' HEX HEX HEX HEX | '\\U' HEX HEX HEX HEX HEX HEX HEX HEX;

HEX: [0-9A-Fa-f];

ESC: '\\' ([tnrbf"'\\] | UCHAR);

INTEGER: [0-9]+;

DECIMAL: [0-9]* '.' [0-9]+;

DOUBLE: (DECIMAL | INTEGER) EXPONENT;

EXPONENT: [eE] [+\-]? [0-9]+;

STRING_LITERAL_QUOTE: '"' (ESC | ~["\\\n\r])* '"';

LANGTAG: '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*;

NIL: '(' WS* ')' ;

ANON: '[' WS* ']' ;

IRIREF: '<' (~[<>"{}|^`\] | UCHAR)* '>';

PNAME_NS: PN_PREFIX? ':';

PNAME_LN: PNAME_NS PN_LOCAL;

VARNAME: VAR1 | VAR2;

PN_CHARS_BASE: [A-Z] | [a-z] | [\u00C0-\u00D6] | [\u00D8-\u00F6] | [\u00F8-\u02FF] | [\u0370-\u037D] | [\u037F-\u1FFF] | [\u200C-\u200D] | [\u2070-\u218F] | [\u2C00-\u2FEF] | [\u3001-\uD7FF] | [\uF900-\uFDCF] | [\uFDF0-\uFFFD] | [\U00010000-\U000EFFFF];

PN_CHARS_U: PN_CHARS_BASE | '_';

PN_CHARS: PN_CHARS_U | '-' | [0-9] | '\u00B7' | [\u0300-\u036F] | [\u203F-\u2040];

PN_PREFIX: PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)?;

PNAME_NS: PN_PREFIX? ':';

PN_LOCAL: (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))?;

PNAME_LN: PNAME_NS PN_LOCAL;

PLX: PERCENT | PN_LOCAL_ESC;

PERCENT: '%' [0-9] [0-9];

PN_LOCAL_ESC: '\\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%' | PN_CHARS | PLX);
