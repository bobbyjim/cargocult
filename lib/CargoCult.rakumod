unit module CargoCult;

grammar CargoCultGrammar is export {
    rule TOP {
        ^ <statement>+ % <.ws> $
    }
    rule statement {
        <var-decl>
    }
    rule var-decl {
        'var' <identifier> ':' <type> ';'
    }
    token identifier {
        <!keyword> \w+
    }
    token type {
        'uint8' | 'uint16' | 'int8' | 'int16'
    }

    token keyword {
        'var' | 'uint8' | 'int16' | 'uint16' | 'int32'
    }
}

class CargoCultActions is export {
    method TOP($/) {
        make $<statement>».ast;
    }
    method statement($/) {
        make $<var-decl>.ast;
    }
    method var-decl($/) {
        make { type => ~$<type>, name => ~$<identifier> };
    }
}
