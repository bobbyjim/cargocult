use Grammar::PrettyErrors;

unit grammar Xenober16::Grammar does Grammar::PrettyErrors;

# Override whitespace handling to include comments
token ws {
    [ \s+ | '//' [ <-[\n]> ]* ]*
}

rule TOP {
    <program-identification-division>
    <import-division>?
    <constants-division>?
    <memory-division>?
    <macro-division>?
    <data-division>?
    <enum-division>?
    <procedure-division>?
    <main-division>?
    <END-MODULE>
}

############################################################################
#
#                         TOKENS
#
############################################################################
token PROGRAM-ID          { 'MODULE IDENTIFICATION DIVISION.' }
token MODULE-ID           { 'MODULE-ID.' | 'ID:' }
token PARAMETERS          { 'PARAMETERS' | 'PARAMS:' }
token AUTHOR              { 'AUTHOR.' | 'WHO:' | 'BY:' }
token DESCRIPTION         { 'DESCRIPTION.' | 'WHAT:' | 'DESC:' }
token PURPOSE             { 'PURPOSE.' | 'WHY:' }

token IMPORT-DIVISION     { 'IMPORT DIVISION.' }
token USE                 { '-' }
token AS                  { 'AS' }

token MEMORY-DIVISION     { 'MEMORY DIVISION.' }
token AREA                { 'AREA' }
token SIZE                { 'SIZE' }
token AT                  { 'AT' }
token RAM                 { 'RAM' }
token BANK                { 'BANK' }

token MACRO-DIVISION      { 'MACRO DIVISION.' }
token META                { 'META' }
token BEGIN               { 'BEGIN' }
token CONSTANTS-DIVISION  { 'CONSTANTS DIVISION.' }
token DATA-DIVISION       { 'DATA DIVISION.' }
token ENUM                { 'ENUM' }
token ENUM-DIVISION       { 'ENUM DIVISION.' }
token PROCEDURE-DIVISION  { 'PROCEDURE DIVISION.' }
token FN                  { 'FN' }
token MAIN-DIVISION       { 'MAIN DIVISION.' }
token END-MODULE          { 'MODULE END.' }

token COMMENT_TO_EOL      { '|*' }
token END                 { 'END' }
token DOT                 { '.' }
token RANGE_OPERATOR      { '..' }
token COMMA               { ',' }
token LT                  { ';' }
token COLON               { ':' }
token IS                  { 'IS' }
token BITFIELD            { '@BITFIELD' }
token ASSIGNMENT_OPERATOR { ':=' }
token OPEN_PAREN          { '(' }
token CLOSE_PAREN         { ')' }

token IF                  { 'IF' }
token THEN                { 'THEN' | 'DO' }
token ELSIF               { 'ELSIF' }
token ELSE                { 'ELSE' }
token WHILE               { 'WHILE' }
token REPEAT              { 'REPEAT' | 'LOOP' }
token UNTIL               { 'UNTIL' }
token DO                  { 'DO' }
token FOR                 { 'FOR' }
token TO                  { 'TO' }
token CASE                { 'CASE' }
token OF                  { 'OF' | '|' }
token PIPE                { \s* '|' \s* }
token RETURN              { 'RETURN' }

token SAY                 { 'SAY' }
token ECHO                { 'ECHO' }

token identifier          { <[a..zA..Z_]> <[a..zA..Z0..9_\-]>* }
token number              { <dec-number> | <hex-number> }
token dec-number          { <digit>+ }
token hex-number          { '$' <[0..9A..Fa..f]>+ }
token string              { '"' [ <-["]> | '\\' . ]* '"' }
token rest-of-line        { [ <-[\n]>* ] }

token compare-operator    { '==' | '!=' | '>=' | '<=' | '>' | '<' }
token add-operator        { '+' | '-' }
token mul-operator        { '*' | '/' }

############################################################################
#
#                         TOP-LEVEL DIVISIONS
#
############################################################################
rule program-identification-division {
    <PROGRAM-ID>
    <module-id>
    <module-parameters>?
    <author>?
    <description>?
    <purpose>?
}

rule import-division    { <IMPORT-DIVISION> <use>+ }
rule memory-division    { <MEMORY-DIVISION> <area>+ }
rule macro-division     { <MACRO-DIVISION> <macro-declaration>+ }
rule constants-division { <CONSTANTS-DIVISION> <constant-declaration>+ }
rule data-division      { <DATA-DIVISION> <variable-declaration>+ }
rule enum-division      { <ENUM-DIVISION> <enum-declaration>+ }
rule procedure-division { <PROCEDURE-DIVISION> <procedure>+ }
rule main-division      { <MAIN-DIVISION> <statement>+ }

############################################################################
#
#                         MODULE IDENTIFICATION
#
############################################################################
rule module-id          { <MODULE-ID> <identifier> <DOT> }
rule module-parameters  { <PARAMETERS> <COLON> <parameter-decl-list> <LT> }
rule parameter-decl-list { <parameter-decl> ( <COMMA> <parameter-decl> )* }
rule parameter-decl      { <identifier> <COLON> <type> <parameter-init>? }
rule parameter-init      { <ASSIGNMENT_OPERATOR> <nested-init> }

rule author             { <AUTHOR> <identifier> <DOT> }
rule description        { <DESCRIPTION> <rest-of-line> }
rule purpose            { <PURPOSE> <rest-of-line> }

############################################################################
#
#                         IMPORTS
#
############################################################################
rule use { <USE> <identifier> <LT> }

############################################################################
#
#                         CONSTANTS
#
############################################################################
rule constant-declaration {
    <identifier> ( <COLON> <type> '=' <nested-init> | <ASSIGNMENT_OPERATOR> <nested-init> ) <LT>
}

############################################################################
#
#                         MACROS
#
############################################################################
rule macro-declaration {
    <function-like-macro> | <simple-macro>
}

rule function-like-macro {
    <META> <identifier> <OPEN_PAREN> <parameter-list>? <CLOSE_PAREN> <COLON> <type>
    <BEGIN> <statement>+ <END> <identifier> <LT>
}

rule simple-macro {
    <identifier> <COLON> <macro-type> <IS> <nested-init> <LT>
}

token macro-type { :i 'int8' | 'int16' | 'byte' | 'uint8' | 'uint16' | 'char' | 'string' }

############################################################################
#
#                         MEMORY
#
############################################################################
rule area { <AREA> <identifier> ( <ram-area> | <bank-area> ) <SIZE> <number> <LT> }
rule ram-area  { <RAM> <OPEN_PAREN> <number> <CLOSE_PAREN> }
rule bank-area { <BANK> <OPEN_PAREN> <number> <COMMA> <number> <CLOSE_PAREN> }

############################################################################
#
#                         DATA DIVISION
#
############################################################################
rule variable-declaration { 'VAR' <identifier> <COLON> <type> <area-annotation>? <variable-init>? <LT> }
rule variable-init { <ASSIGNMENT_OPERATOR> <nested-init> }

rule type {
    <array-type>
  | <builtin-type>
  | <pointer-type>
  | <inline-type>
  | <named-type>
}

rule array-type { 'array' '[' <number> ']' 'of' <type> <array-init>? }
rule array-init   { <ASSIGNMENT_OPERATOR> '{' <nested-init-list> '}' }
rule nested-init-list { <nested-init> ( <COMMA> <nested-init> )* }

token builtin-type {
    :i 'uint16' | 'uint8' | 'int16' | 'int8' |
       'string' | 'char' | 'byte'
}

rule pointer-type { '@' <record-type-identifier> }
rule named-type   { <identifier> }
rule area-annotation { <AT> <identifier> }

rule record-type-identifier { <identifier> }

rule record-type { <RECORD> <record-field>* <END> }
rule record-field { <identifier> <COLON> <type> <bitfield-annotation>? <LT> }
rule bitfield-annotation { <BITFIELD> <OPEN_PAREN> <number> <CLOSE_PAREN> }

rule enum-type { <ENUM> <identifier>? <brace-enum-members> <LT> }
rule brace-enum-members { '{' <enum-member> ( ',' <enum-member> )* '}' }
rule enum-member { <identifier> ( '=' <number> | <ASSIGNMENT_OPERATOR> <number> )? }
rule enum-declaration { <ENUM> <identifier>? <brace-enum-members> <LT> }

############################################################################
#
#                         PROCEDURE & MAIN
#
############################################################################
rule procedure {
    <FN> <identifier> <OPEN_PAREN> <parameter-list>? <CLOSE_PAREN>
    <statement>+
    <END>
}

rule parameter-list { <parameter> ( <COMMA> <parameter> )* }
rule parameter       { <identifier> <COLON> <type> }

rule statement { <keyword-statement> | <simple-statement> }

rule keyword-statement {
    <if-statement>
  | <while-loop>
  | <for-loop>
  | <repeat-loop>
  | <case-statement>
}

rule simple-statement {
    <say>
  | <echo>
  | <assignment>
  | <procedure-call>
  | <proc-return>
}

rule proc-return { <RETURN> <expression> <LT> }
rule assignment  { <designator> <ASSIGNMENT_OPERATOR> <expression> <LT> }
rule assign-target { <designator> }
rule say { <SAY> <expression> <LT> }
rule echo { <ECHO> <expression> <LT> }

############################################################################
#
#                         FLOW CONTROL
#
############################################################################
rule if-statement {
    <IF> <expression> <THEN> <statement>*
    ( <ELSIF> <expression> <THEN> <statement>* )*
    ( <ELSE> <statement>* )?
    <END>
}

rule while-loop { <WHILE> <expression> <DO> <statement>+ <END> }
rule repeat-loop { <REPEAT> <statement>+ <UNTIL> <expression> <LT> }
rule for-loop { <FOR> <identifier> ':=' <expression> <TO> <expression> <DO> <statement>+ <LT>? <END> }

rule procedure-call { <identifier> <OPEN_PAREN> <argument-list>? <CLOSE_PAREN> <LT> }
rule argument-list   { <expression> ( <COMMA> <expression> )* }

rule case-statement {
    <CASE> <comparison> <OF>
    <case-when>+
    [ <ELSE> <statement>+ ]?
    <END>
}
rule case-when      { <PIPE> <case-selector> ( <COMMA> <case-selector> )* <COLON> <statement>+ }
rule case-selector  { <range> | <number> | <designator> }

############################################################################
#
#                         EXPRESSIONS
#
############################################################################
rule nested-init { <number> | <string> | <record-init> | <enum-init> | <array-init> }
rule record-init { '{' <nested-init-list> '}' }
rule enum-init   { '{' <nested-init-list> '}' }

rule expression { <comparison> }
rule comparison { <math-sum> [ <compare-operator> <math-sum> ]* }
rule math-sum   { <math-product> [ <add-operator> <math-product> ]* }
rule math-product { <factor> [ <mul-operator> <factor> ]* }

rule factor {
      <OPEN_PAREN> <expression> <CLOSE_PAREN>
    | <ram-access>
    | <bank-access>
    | <number>
    | <string>
    | <designator>
    | '~' <factor>
}

rule ram-access  { <RAM> '[' <expression> ']' }
rule bank-access { <BANK> <OPEN_PAREN> <expression> <CLOSE_PAREN> '[' <expression> ']' }

rule qualident { [ <identifier> <DOT> ]? <identifier> }
rule designator { <qualident> <selector>* }
token selector { '[' <expression> ']' | '.' <identifier> | <OPEN_PAREN> <argument-list>? <CLOSE_PAREN> }

rule range { <number> <RANGE_OPERATOR> <number> }
