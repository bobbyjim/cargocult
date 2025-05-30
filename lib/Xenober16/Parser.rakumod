#
#  THINGS TO ADD:
#
#  # control flow:
#  WHILE DO END
#  REPEAT UNTIL
#  FOR DO END
#  CASE (numeric, more like C than Oberon) END
#
#  a: char[80];												# arrays
#  a: char[80] := "Hello";									# array assignment
#  PROC myProc(...) ... END									# procedure declaration, no return value
#  FUNC myFunc(...): TYPE ... END							# function declaration, with return value
#
#  RECORD													# Record
#	  myField1: char[10];
#	  myField2: UINT16;
#  END
#
#  BITRECORD												# Record with :N bitfields
#	  myfield1: UINT8 :3;									# 3 bits
#	  myfield2: UINT8 :5;									# 5 bits
#  END
#						
#  CONST myConst := 3;  									# constant declaration
#					
#  include "filename";										# file inclusion pre-processor
#	
#  myReg := R0();  											# register fetch
#  R0(3);          											# register assignment
#  R0L(3); 	       											# register assignment (low byte)
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
	token data-division-token { 'DATA DIVISION.' }
	token working-storage-token { 'WORKING-STORAGE SECTION.' }
	token procedure-division-token { 'PROCEDURE DIVISION.' }
	token end-program-token { 'END PROGRAM.' }
	token if-token { 'IF' }
	token then-token { 'THEN' }
	token elsif-token { 'ELSIF' }
	token else-token { 'ELSE' }
	token end-token { 'END' }

	token identifier { <[a..zA..Z_]><[a..zA..Z0..9_]>* }
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
		<program-id-token> 
		<identifier>
		'.'
	}

	rule data-division {
		<data-division-token>
		<working-storage-section>
	}
	rule working-storage-section {
		<working-storage-token>
		<declaration>+
	}
	rule declaration {
		<identifier> ':' <data-type> ';'
	}
	rule procedure-division {
		<procedure-division-token>
		<statement>+
	}
	rule statement {
		<assignment> | <say> | <if-statement>
	}
	rule assignment {
		<identifier> ':=' <expression> ';'
	}
	rule say {
		'SAY' <expression> ';'
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
	
	rule statement-sequence {
		<statement>+
	}
}
