use Grammar::Tracer;

grammar Xenober16::Parser {

rule TOP { 
	^ 
	<identification-division>
	<import-division>?
	<macro-division>?
	<memory-division>?
	<data-division>?
	<code-division>
	<end-module> 
	$ 
}

rule identification-division { 
	'MODULE IDENTIFICATION DIVISION.' 
	<module-id>
	<metadata-line>*
}

rule metadata-line {
	<parameters-line> | <author-line> | <date-line> | <description-line> | <license-line>
}

rule module-id 			{ 'MODULE-ID:' <identifier> }
rule parameters-line	{ 'PARAMETERS:' <param-decl>+ % ',' ';' }
rule author-line 		{ 'AUTHOR:' <text-line> }
rule date-line 			{ 'DATE:' <text-line> }
rule description-line 	{ 'DESCRIPTION:' <text-line> }
rule license-line 		{ 'LICENSE:' <text-line> }

token text-line { <-[\n]>+ }

rule param-decl { <identifier> ':' <type-name> [ ':=' <expression> ]? }

rule end-module {
	'END MODULE.' 
}

rule import-division {
	'IMPORT DIVISION.' 
	<import-decl>+
}

rule import-decl {
	'USE' <identifier> [ 'AS' <identifier> ]? ';'
}

rule macro-division {
	'MACRO DIVISION.' 
	<macro-decl>+
}

rule macro-decl {
	'META' <identifier> 
	[ '(' <param-decl-list>? ')' ]? 
	[ ':' <type-name> ]? 
	<macro-body>
}

rule macro-body {
	'BEGIN' <statement>* 'END' <identifier> ';'
}

rule memory-division {
	'MEMORY DIVISION.' 
	<storage-section>+
}

rule storage-section {
	<golden-ram-section> | <banked-ram-section>
}

rule golden-ram-section {
	'GOLDEN RAM SECTION.' 
	<area-decl>+
}

rule banked-ram-section {
	'BANKED RAM SECTION.' 
	<banked-area-decl>+
}

rule area-decl {
	'AREA(' <memory-value> ')' <identifier> 'AT' <memory-value> ';'
}

rule banked-area-decl {
	'AREA(' <memory-value> ')' <identifier> 'AT' <memory-value> 'BANK' <memory-value> ';'
}

rule memory-value {
	<hex-location> | <int-location>
}

token hex-location { ['0x'|'$'] <[0..9a..fA..F]>+ }
token int-location { <[0..9]>+ }

rule data-division {
	'DATA DIVISION.' 
	<working-storage-section>
}

rule working-storage-section {
	'WORKING-STORAGE SECTION.' 
	<var-decl>*
}

rule var-decl {
	<regular-var-decl> | <overlay-decl>
}
rule overlay-decl {
	'OVERLAY' <identifier> ':' <type-name> 'IN' <identifier> [ '+' <memory-value> ] ';'
}

rule regular-var-decl {
	<identifier> ':' <type-name> [ ':=' <expression>] ';' 
}

token identifier  { <[a..zA..Z_]><[a..zA..Z0..9_]>* }
rule type-name    { 'INT16'       }
rule expression   { <string-literal> | <int-literal> | <identifier> }
token int-literal { '-'?<[0..9]>+ }
token string-literal { '"' <-["]>* '"' }

rule code-division {
	'CODE DIVISION.' 
	<proc-decl>*
	<statement>+
}

rule statement {
	<control-statement> | <statement-singleton>
}

rule control-statement {
	<if-statement> | <while-statement> | <for-statement>
}

rule if-statement { 
	'IF' <expression> 'THEN' <statement>* 
	<elsif-clause>*
	['ELSE' <statement>*]?
	'END' ';'
}
rule elsif-clause {
	'ELSIF' <expression> 'THEN' <statement>*
}
rule while-statement {
	'WHILE' <expression> 'DO' <statement>* 'END' ';'
}
rule for-statement {
	'FOR' <identifier> 'IN' <expression> 'DO' <statement>* 'END' ';'
}

token statement-singleton {
	<say-statement> | <return-statement> | <call-statement>
}

rule say-statement {
	'SAY' <expression> ';'
}

rule return-statement {
	'RETURN' <expression>? ';'
}

rule call-statement {
	'CALL' <identifier> '(' [ <expression>+ % ',' ]? ')' ';'
}

rule proc-decl {
    'PROC' <identifier> 
    '(' <param-decl-list>? ')' 
    [ ':' <type-name> ]? 
    <proc-body>
}

rule param-decl-list {
	<param-decl>+ % ',' 
}

rule proc-body {
    'BEGIN' <statement>* 'END' <identifier> ';'
}

} # END OF PARSER.RAKUMOD