
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
	token if-token { 'IF' :i }
	token then-token { 'THEN' :i }
	token elsif-token { 'ELSIF' :i }
	token else-token { 'ELSE' :i }
	token end-token { 'END' :i }

	token identifier { <[a..zA..Z_]><[a..zA..Z0..9_]>* }
	token literal { <[0..9]>+ 	}
	token string-literal { '"' [ <-["]> | '\\' . ]* '"' }
	token data-type { 'INT8' :i | 'UINT8' :i | 'INT16' :i | 'UINT16' :i | 'INT32' :i | 'UINT32' :i | 'STRING' :i }
	token add-op { '+' | '-' }
	token mul-op { '*' | '/' | '%' }

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
		<string-literal> | <arith-expr>
	}

	rule arith-expr {
		<term> [ <add-op> <term> ]*
	}

	rule term {
		<factor> [ <mul-op> <factor> ]*
	}

	rule factor {
		<literal> | <identifier> | '(' <arith-expr> ')'
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
