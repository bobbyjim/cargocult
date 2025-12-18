use Grammar::PrettyErrors;

unit grammar Xenober16::Grammar does Grammar::PrettyErrors;

rule TOP {
      <program-identification-division>
      <import-division>?
      <constants-division>?
      <memory-division>?
      <macro-division>?
      <data-division>?
      <procedure-division>?
      <main-division>?
      <END-MODULE> 
}

############################################################################
#
#                         TOKENS
#
#  Tokens are ratchets for PEG to hang onto.
#
############################################################################
token PROGRAM-ID                    { 'MODULE IDENTIFICATION DIVISION.' }
    token MODULE-ID                 { 'MODULE-ID.'      | 'ID:' }
    token AUTHOR                    { 'AUTHOR.'         | 'WHO:' | 'BY:' }
    token DESCRIPTION               { 'DESCRIPTION.'    | 'WHAT:' | 'DESC:'}
    token PURPOSE                   { 'PURPOSE.'        | 'WHY:' }
token IMPORT-DIVISION               { 'IMPORT DIVISION.' }
    token USE                       { '-' }
    token AS                        { 'AS' }     
token MEMORY-DIVISION               { 'MEMORY DIVISION.' }
    token AREA                      { 'AREA' }
    token SIZE                      { 'SIZE' }
    token RAM                       { 'RAM' }
    token BANK                      { 'BANK' }
token MACRO-DIVISION                { 'MACRO DIVISION.' }
token CONSTANTS-DIVISION            { 'CONSTANTS DIVISION.' }
token DATA-DIVISION                 { 'DATA DIVISION.' }
    token AT                        { 'AT' }
    token RECORD                    { 'RECORD' }
    token ENUM                      { 'ENUM' }
token PROCEDURE-DIVISION            { 'PROCEDURE DIVISION.' }
    token PROC                      { 'PROC' }
token MAIN-DIVISION                 { 'MAIN DIVISION.' }
token END-MODULE                    { 'MODULE END.' }

token COMMENT_TO_EOL                { '|*'  }
token END                           { 'END' }
token DOT                           { '.' }
token RANGE_OPERATOR                { '..' }
token COMMA                         { ',' }
token LT                            { ';' }
token COLON                         { ':' }
token IS                            { 'IS' }
token BITFIELD                      { '@BITFIELD' }
token ASSIGNMENT_OPERATOR           { ':=' }
token OPEN_PAREN                    { '(' }
token CLOSE_PAREN                   { ')' }

token IF                            { 'IF' }      
token THEN                          { 'THEN' | 'DO' }
token ELSIF                         { 'ELSIF' }
token ELSE                          { 'ELSE' }
token WHILE                         { 'WHILE' }
token REPEAT                        { 'REPEAT' | 'LOOP' }
token UNTIL                         { 'UNTIL' }
token DO                            { 'DO' }
token CASE                          { 'CASE' }
token OF                            { 'OF' | '|' }
token PIPE                          { \s* '|' \s* }
token RETURN                        { 'RETURN' }

token SAY                           { 'SAY' }
token ECHO                          { 'ECHO' }
###############################################################
#
#                         DIVISION
#
###############################################################
rule program-identification-division {
    <PROGRAM-ID>
    <module-id>
    <author>?
    <description>?
    <purpose>?
}

rule import-division    { <IMPORT-DIVISION>     <use>+ }
rule memory-division    { <MEMORY-DIVISION>     <area>+ } 
rule macro-division     { <MACRO-DIVISION>      <macro-declaration>+ }
rule constants-division { <CONSTANTS-DIVISION>  <constant-declaration>+ }
rule data-division      { <DATA-DIVISION>       <variable-declaration>+ }
rule procedure-division { <PROCEDURE-DIVISION>  <procedure>+ } 
rule main-division      { <MAIN-DIVISION>       <statement>+ }

rule module-id          { <MODULE-ID>           <identifier>    <DOT> }
rule author             { <AUTHOR>              <identifier>    <DOT> }
rule description        { <DESCRIPTION>         <rest-of-line>  }
rule purpose            { <PURPOSE>             <rest-of-line>  }

###############################################################
#
#                         IMPORTS
#
###############################################################
rule use                { <USE>                 <identifier>    <LT> }

###############################################################
#
#                         CONSTANTS
#
###############################################################
rule constant-declaration {
    <identifier> <COLON> <type> '=' <constant-value> <LT>
}

rule constant-value {
    <number> | <string>
}

###############################################################
#
#                         MACROS
#
###############################################################
rule macro-declaration {
    <identifier> <COLON> <macro-type> <IS> <simple-expression> <LT>
}

token macro-type { :i 'int8' | 'int16' | 'byte' | 'uint8' | 'uint16' | 'char' | 'string' }

###############################################################
#
#                         AREA
#
###############################################################
rule area {
    <AREA> <identifier> ( <ram-area> | <bank-area> ) <SIZE> <number> <LT>
}

rule ram-area  {  <RAM> <OPEN_PAREN> <number> <CLOSE_PAREN>    }
rule bank-area {  <BANK> <OPEN_PAREN> <number> <COMMA> <number> <CLOSE_PAREN> }

###############################################################
#
#                        DATA DIVISION
#
#   Note the pointer indicator (@) is only allowed for record types.
#   Example:
#       myPointer : @MyRecordType;
#
###############################################################
rule variable-declaration {
    <identifier> <COLON> <type> <area-annotation>? <LT>
}

rule type {
    :i 'int8' | 'int16' |
       'byte' | 'uint8' | 'uint16' |
       'char' | 'string' |
       'array' '[' <number> ']' 'of' <type> |
       '@' <record-type-identifier> |            # pointers are references only to records
       <record-type>  |                          # inline record definition
       <enum-type>
}

# Named record reference for pointers
rule record-type-identifier {
    <identifier>    # must match an existing record type name
}

rule area-annotation {
    <AT> <identifier> #Reference to the area name
}

# Inline record definition
rule record-type {
    <RECORD> <record-field>* <END>
}

rule record-field {
    <identifier> <COLON> <type> <bitfield-annotation>? <LT>
}

rule bitfield-annotation {
    <BITFIELD> <OPEN_PAREN> <number> <CLOSE_PAREN>
}

rule enum-type {
   <ENUM> <identifier>+ <END>
}

###############################################################
#
#                      PROC and MAIN
#
###############################################################
rule procedure {
    <PROC> <identifier> <OPEN_PAREN> <parameter-list>? <CLOSE_PAREN>
    <statement>+
    <END>
}

rule parameter-list {
    <parameter> ( <COMMA> <parameter> )*
}

rule parameter {
    <identifier> <COLON> <type>
}

rule proc-block {
    <statement>* 
    <proc-return>
    <END>
}

rule statement {
    <assignment> 
    | <say> 
    | <echo>
    | <if-statement> 
    | <while-loop> 
    | <repeat-loop>
    | <case-statement>
    | <procedure-call>
}

rule proc-return {
    <RETURN> <expression> 
}

rule assignment {
    <qualident> <ASSIGNMENT_OPERATOR> <expression> <LT>
}

rule say {
    <SAY> <simple-expression> <LT>
}

rule echo {
    <ECHO> <expression> <LT>
}

###############################################################
#
#                         FLOW CONTROL
#
###############################################################
rule if-statement {
    <IF> <expression> 
    <THEN> <statement>*
    ( <ELSIF> <expression> <THEN> <statement>* )*  # Zero or more ELSIF clauses
    ( <ELSE> <statement>*)?
    <END>
}

rule while-loop {
    <WHILE> <expression> <DO> <statement>+
    (<ELSIF> <expression> <DO> <statement>+)*  # Zero or more ELSIF clauses
    <LT>? <END>
}

rule repeat-loop {
    <REPEAT> <statement>+ <UNTIL> <expression> <LT>?
}

rule procedure-call {
    <identifier> <OPEN_PAREN> <argument-list>? <CLOSE_PAREN> <LT>
}

rule argument-list {
    <expression> ( <COMMA> <expression> )*
}

rule case-statement {
    <CASE> <comparison> <OF>
    <case-when>+
    [ <ELSE> <statement>+ ]?
    <END>
}

rule case-when {
    <PIPE> <case-selector>+ % ',' <COLON> <statement>+
}

rule case-selector {
    <range> | <number> | <qualident>
}

###############################################################
#
#                         COMMON
#
###############################################################
rule expression             { <string> | <comparison>                                           }
rule comparison             { <sum> ( <compare-operator> <sum> )*                               }
rule sum                    { <product> ( <[+-]> <product> )*                                   }
rule product                { <factor> ( <[*/]> <factor> )*                                     }
rule factor                 { <number> | <qualident> | <OPEN_PAREN> <expression> <CLOSE_PAREN>  }
rule simple-expression      { <string> | <number> | <qualident> | <arithmetic-expression>       }
rule arithmetic-expression  { <sum>                                                             }

token compare-operator { '==' | '!=' | '>=' | '<=' | '>' | '<' }

rule qualident {
    <identifier> ( <DOT> <identifier> )*     #  For field access
}

token identifier {    <[a..zA..Z_]> <[a..zA..Z0..9_\-]>* }
token number     {    <dec-number> | <hex-number>      }
token dec-number {    <digit>+                         }
token hex-number {    '$' <[0..9A..Fa..f]>+            }
token string     {    '"' [ <-["]> | '\\' . ]* '"'     }
token rest-of-line {    [ <-[\n]>* ] }

rule range { 
    <number> <RANGE_OPERATOR> <number>
}
