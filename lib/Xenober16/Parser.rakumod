unit grammar Xenober16::Parser;

rule TOP { 
	^ <identification-division>  <end-module> $ 
}

rule identification-division {
	'MODULE' 'IDENTIFICATION' 'DIVISION.' 
	<module-id>
}

rule module-id {
	'ID.' <identifier> '.' 
}

rule end-module {
	'END' 'MODULE.' 
}

token identifier { <[a..zA..Z_]><[a..zA..Z0..9_]>* }
