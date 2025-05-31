#
#  THINGS TO ADD:
#
#  Negative numbers.
#
#  # control flow:
#  CASE (numeric, more like C than Oberon) END
#
#  a: char[80];												# arrays
#  a: char[80] := "Hello";									# array assignment
#  PROC myProc(...) ... END									# procedure declaration, no return value
#  FUNC myFunc(...): TYPE ... END							# function declaration, with return value
#
#  RECORD													# Record
#	  myField1: char[10];
#	  myBitField1: UINT16 :3;
#	  myBitField2: UINT16 :5;
#	  myField2: INT16;
#  END
#  myRec: myRecord;											# record variable declaration	
#  myRec: myRecord := { myField1: "Hello", myField2: 1234 };	# record variable assignment
#  myRec.myField1 := "World";								# record field assignment
#  myRec.myBitField1 := 5;									# record bit field assignment
#  myRec.myField2 := 1234;									# record field assignment
#  myRec.myField1 := myRec.myField2;						# record field assignment
#  myRec.myField1 := myRec.myBitField1;						# record field assignment

#  CONST myConst := 3;  									# constant declaration
#					
#  include "filename";										# file inclusion pre-processor
#	
#  myReg := \R0;  											# register fetch
#  \R0   := 12000; 											# register assignment
#  \R0L  := 3;    											# register assignment (low byte)
#
#  ASM "inline assembly";
#  ASM
#     block of assembly code
#     some more assembly code
#  END
#
#  # not sure how to handle these yet, but they are important:
#  myVar: PTR TO myRecord := PTR(bank: 3, addr: $A000);   	# banked pointer declaration
#  myVar: myRecord := PTR(bank: 3, addr: $A000);   			# or is this better?
#  myVar: PTR TO myRecord AT $0300;                       	# golden RAM pointer decl (no bank)
#  myVar: myRecord AT $0300;                                # or is this better?
#	
#  BANK <N> SECTION.                                      	# or, implicitly banked variables declared here
#     myVar: myRecord AT $A000;            		        	# banked auto-pointer declaration (bank in section decl)??
#


grammar Xenober16::Parser {
	rule TOP {
		<identification-division>
		<data-division>?
		<procedure-division>?
		<end-program-token>
	}

	rule comment { ('//' | '#') <-[^\n]>* \n }
	
	token identification-token { 'IDENTIFICATION DIVISION.' }
	token program-id-token { 'PROGRAM-ID.' }
	token program-date-token { 'PROGRAM-DATE.' }
	token designed-by-token { 'DESIGNED-BY.' }

	token data-division-token { 'DATA DIVISION.' }
	token working-storage-token { 'WORKING-STORAGE SECTION.' }
	token procedure-division-token { 'PROCEDURE DIVISION.' }
	token end-program-token { 'END PROGRAM.' }
	token if-token { 'IF' }
	token then-token { 'THEN' }
	token elsif-token { 'ELSIF' }
	token else-token { 'ELSE' }
	token while-token { 'WHILE' }
	token do-token { 'DO' }
	token repeat-token { 'REPEAT' }
	token until-token { 'UNTIL' }
	token for-token { 'FOR' }
	token to-token { 'TO' }
	token by-token { 'BY' }
	token case-token { 'CASE' }
	token of-token { 'OF' }
	token say-token { 'SAY' }
	token end-token { 'END' }
	token semicolon { ';' }
	token dot { '.' }
	token colon { ':' }
	token pipe { '|' }
	token comma { ',' }

	token identifier { <[a..zA..Z_]><[a..zA..Z0..9_]>* }
	#
	#  We don't handle negative numbers yet.
	#
	token number { <digit-string> | <hex-string> }
	token digit-string { <[0..9]>+ }
	token hex-string   { '$' <[0..9A..Fa..f]>+ }	
	token string-literal { '"' [ <-["]> | '\\' . ]* '"' }
	token data-type { (INT8|UINT8|INT16|UINT16|INT32|UINT32|CHAR|STRING) }
	token add-op { '+' | '-' }
	token mul-op { '*' | '/' | '%' }
	token compare-op { '==' | '<' | '>' | '<=' | '>=' | '!=' }

	rule identification-division {
		<identification-token>
		<program-id>
	}

	rule program-id   { <program-id-token> <identifier> <dot> }
	rule program-date { <program-date-token> <identifier> <dot> }
	rule designed-by  { <designed-by-token> <identifier> <dot> }

	rule data-division {
		<data-division-token>
		<working-storage-section>
	}
	rule working-storage-section {
		<working-storage-token>
		<declaration>+
	}
	rule declaration {
		<identifier> <colon> <data-type> <semicolon>
	}
	rule procedure-division {
		<procedure-division-token>
		<statement>+
	}
	rule statement {
		<assignment> 
		| <say> 
		| <if-statement> 
		| <while-statement>
		| <repeat-statement>
		| <for-statement>
		| <case-statement>
	}
	rule assignment {
		<identifier> ':=' <expression> <semicolon>
	}
	rule say {
		<say-token> <expression> <semicolon>
	}
	rule expression {
		<compare-expr> | <string-literal> | <arith-expr>
	}

	rule arith-expr {
		<term> [ <add-op> <term> ]*
	}

	rule term {
		<factor> [ <mul-op> <factor> ]*
	}

	rule factor {
		<number> | <identifier> | '(' <arith-expr> ')'
	}

	rule compare-expr {
		<arith-expr> <compare-op> <arith-expr>
	}

#
# 	Xenober-16 control flow statements
#
	rule statement-sequence {
		<statement>+
	}

	rule if-statement {
		<if-token> <expression> <then-token> <statement-sequence>
		[ <elsif-clause> ]*
		[ <else-clause> ]?
		<end-token>
	}

	rule elsif-clause {
		<elsif-token> <expression> <then-token> <statement-sequence>
	}

	rule else-clause {
		<else-token> <statement-sequence>
	}

	rule while-statement {
		<while-token> <expression> <do-token> <statement-sequence> <end-token>
	}

	rule repeat-statement {
		<repeat-token> <statement-sequence> <until-token> <expression> <semicolon> <end-token>
	}

	rule for-statement {
		<for-token> <identifier> ':=' <expression> <to-token> <expression>
		[ <by-token> <expression> ]? 
		<do-token> <statement-sequence> <end-token>
	}

	rule case-statement {
		<case-token> <expression> <of-token> 
		<case-element>+ 
		[ <else-token> <statement-sequence> ]?
		<end-token>
	}

	rule case-element {
		<case-label>+ % ',' <colon> <statement-sequence> <pipe>
	}

	rule case-label {
		<expression>
	}
}
