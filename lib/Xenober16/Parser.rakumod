unit grammar Xenober16::Parser;

rule TOP { 
	^ <identification-division>  
	<data-division>? 
	<code-division>? 
	<end-module> $ 
}

rule identification-division { 
	'MODULE IDENTIFICATION DIVISION.' 
	<module-id>
	<parameters-line>?
	<author-line>?
	<date-line>?
	<description-line>?
	<license-line>?
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

rule data-division {
	'DATA DIVISION.' 
	<constant-storage-section>?
	<working-storage-section>?
}

rule constant-storage-section {
	'CONSTANT-STORAGE SECTION.' 
	<const-decl>*
}

rule working-storage-section {
	'WORKING-STORAGE SECTION.' 
	<var-decl>*
}

rule code-division {
	'CODE DIVISION.' 
	<statement>*
}

rule const-decl {
	<identifier> ':=' <expression> ';' 
}

rule var-decl {
	<identifier> ':' <type-name> [ ':=' <expression>] ';' 
}

token identifier  { <[a..zA..Z_]><[a..zA..Z0..9_]>* }
rule type-name    { 'INT16'       }
rule expression   { <int-literal> | <identifier> }
token int-literal { '-'?<[0..9]>+ }


rule statement {
	<say-statement>
}

rule say-statement {
	'SAY' <expression> ';'
}
