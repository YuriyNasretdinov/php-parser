%{
// Copyright (c) 2011 CZ.NIC z.s.p.o. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// blame: jnml, labs.nic.cz

package scanner

import (
    "fmt"
    "bytes"
    "github.com/cznic/golex/lex"
)

const (
	INITIAL = iota
	PHP
	STRING
	STRING_VAR
	STRING_VAR_INDEX
	STRING_VAR_NAME
	PROPERTY
	HEREDOC_END
	NOWDOC
	HEREDOC
	BACKQUOTE
)

var heredocLabel []lex.Char

func isValidFirstVarNameRune(r rune) bool {
    return r >= 'A' && r <= 'Z' || r == '_' || r >= 'a' && r <= 'z' || r >= '\u007f' && r <= 'ÿ'
}

func (l *Lexer) Lex(lval Lval) int {
    l.Comments = nil
    c := l.Enter()

%}

%s PHP STRING STRING_VAR STRING_VAR_INDEX STRING_VAR_NAME PROPERTY HEREDOC_END NOWDOC HEREDOC BACKQUOTE

%yyb last == '\n' || last = '\0'
%yyt l.getCurrentState()
%yyc c
%yyn c = l.Next()
%yym l.Mark()
%optioncase-insensitive

LNUM            [0-9]+
DNUM            ([0-9]*"."[0-9]+)|([0-9]+"."[0-9]*)
HNUM            0x[0-9a-fA-F]+
BNUM            0b[01]+
EXPONENT_DNUM   (({LNUM}|{DNUM})[eE][+-]?{LNUM})
VAR_NAME        [a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*
OPERATORS       [;:,.\[\]()|\/\^&\+-*=%!~$<>?@]
NEW_LINE        (\r|\n|\r\n)

%%
    c = l.Rule0()

<INITIAL>[ \t\n\r]+
<INITIAL>.
    tb := []lex.Char{}

    for {
        if c == -1 {
            tb = l.Token();
            break;
        }

        if '?' == rune(c) {
            tb = l.Token();
            if (len(tb) < 2 || tb[len(tb)-1].Rune != '<') {
                c = l.Next()
                continue;
            }

            tb = l.ungetChars(1)
            break;
        }

        c = l.Next()
    }

    lval.Token(l.newToken(tb, "T_INLINE_HTML"))
    return T_INLINE_HTML

<INITIAL>\<\?php([ \t]|{NEW_LINE})              l.begin(PHP);
<INITIAL>\<\?                                   l.begin(PHP);
<INITIAL>\<\?=                                  l.begin(PHP);lval.Token(l.newToken(l.Token(), "T_ECHO")); return T_ECHO;

<PHP>[ \t\n\r]+
<PHP>\?\>{NEW_LINE}?                            l.begin(INITIAL);lval.Token(l.newToken(l.Token(), ";")); return Rune2Class(';');
<PHP>[;][ \t\n\r]*\?\>{NEW_LINE}?               l.begin(INITIAL);lval.Token(l.newToken(l.Token(), ";")); return Rune2Class(';');

<PHP>{DNUM}|{EXPONENT_DNUM}                     lval.Token(l.newToken(l.Token(), "T_DNUMBER")); return T_DNUMBER
<PHP>{BNUM}
    tb := l.Token()
    i:=2
    BNUMFOR:for {
        if i > len(tb)-1 {
            break BNUMFOR;
        }
        switch tb[i].Rune {
            case '0': i++;
            default: break BNUMFOR;
        }
    }
    if len(tb) - i < 64 {
        lval.Token(l.newToken(l.Token(), "T_LNUMBER")); return T_LNUMBER
    } else {
        lval.Token(l.newToken(l.Token(), "T_DNUMBER")); return T_DNUMBER
    }
<PHP>{LNUM}
    if len(l.Token()) < 20 {
        lval.Token(l.newToken(l.Token(), "T_LNUMBER")); return T_LNUMBER
    } else {
        lval.Token(l.newToken(l.Token(), "T_DNUMBER")); return T_DNUMBER
    }
<PHP>{HNUM}
    tb := l.Token()
    i:=2
    HNUMFOR:for {
        if i > len(tb)-1 {
            break HNUMFOR;
        }
        switch tb[i].Rune {
            case '0': i++;
            default: break HNUMFOR;
        }
    }
    length := len(tb) - i
    if length < 16 || (length == 16 && tb[i].Rune <= '7') {
        lval.Token(l.newToken(l.Token(), "T_LNUMBER")); return T_LNUMBER
    } else {
        lval.Token(l.newToken(l.Token(), "T_DNUMBER")); return T_DNUMBER
    }

<PHP>abstract                                   lval.Token(l.newToken(l.Token(), "T_ABSTRACT")); return T_ABSTRACT
<PHP>array                                      lval.Token(l.newToken(l.Token(), "T_ARRAY")); return T_ARRAY
<PHP>as                                         lval.Token(l.newToken(l.Token(), "T_AS")); return T_AS
<PHP>break                                      lval.Token(l.newToken(l.Token(), "T_BREAK")); return T_BREAK
<PHP>callable                                   lval.Token(l.newToken(l.Token(), "T_CALLABLE")); return T_CALLABLE
<PHP>case                                       lval.Token(l.newToken(l.Token(), "T_CASE")); return T_CASE
<PHP>catch                                      lval.Token(l.newToken(l.Token(), "T_CATCH")); return T_CATCH
<PHP>class                                      lval.Token(l.newToken(l.Token(), "T_CLASS")); return T_CLASS
<PHP>clone                                      lval.Token(l.newToken(l.Token(), "T_CLONE")); return T_CLONE
<PHP>const                                      lval.Token(l.newToken(l.Token(), "T_CONST")); return T_CONST
<PHP>continue                                   lval.Token(l.newToken(l.Token(), "T_CONTINUE")); return T_CONTINUE
<PHP>declare                                    lval.Token(l.newToken(l.Token(), "T_DECLARE")); return T_DECLARE
<PHP>default                                    lval.Token(l.newToken(l.Token(), "T_DEFAULT")); return T_DEFAULT
<PHP>do                                         lval.Token(l.newToken(l.Token(), "T_DO")); return T_DO
<PHP>echo                                       lval.Token(l.newToken(l.Token(), "T_ECHO")); return T_ECHO
<PHP>else                                       lval.Token(l.newToken(l.Token(), "T_ELSE")); return T_ELSE
<PHP>elseif                                     lval.Token(l.newToken(l.Token(), "T_ELSEIF")); return T_ELSEIF
<PHP>empty                                      lval.Token(l.newToken(l.Token(), "T_EMPTY")); return T_EMPTY
<PHP>enddeclare                                 lval.Token(l.newToken(l.Token(), "T_ENDDECLARE")); return T_ENDDECLARE
<PHP>endfor                                     lval.Token(l.newToken(l.Token(), "T_ENDFOR")); return T_ENDFOR
<PHP>endforeach                                 lval.Token(l.newToken(l.Token(), "T_ENDFOREACH")); return T_ENDFOREACH
<PHP>endif                                      lval.Token(l.newToken(l.Token(), "T_ENDIF")); return T_ENDIF
<PHP>endswitch                                  lval.Token(l.newToken(l.Token(), "T_ENDSWITCH")); return T_ENDSWITCH
<PHP>endwhile                                   lval.Token(l.newToken(l.Token(), "T_ENDWHILE")); return T_ENDWHILE
<PHP>eval                                       lval.Token(l.newToken(l.Token(), "T_EVAL")); return T_EVAL
<PHP>exit|die                                   lval.Token(l.newToken(l.Token(), "T_EXIT")); return T_EXIT
<PHP>extends                                    lval.Token(l.newToken(l.Token(), "T_EXTENDS")); return T_EXTENDS
<PHP>final                                      lval.Token(l.newToken(l.Token(), "T_FINAL")); return T_FINAL
<PHP>finally                                    lval.Token(l.newToken(l.Token(), "T_FINALLY")); return T_FINALLY
<PHP>for                                        lval.Token(l.newToken(l.Token(), "T_FOR")); return T_FOR
<PHP>foreach                                    lval.Token(l.newToken(l.Token(), "T_FOREACH")); return T_FOREACH
<PHP>function|cfunction                         lval.Token(l.newToken(l.Token(), "T_FUNCTION")); return T_FUNCTION
<PHP>global                                     lval.Token(l.newToken(l.Token(), "T_GLOBAL")); return T_GLOBAL
<PHP>goto                                       lval.Token(l.newToken(l.Token(), "T_GOTO")); return T_GOTO
<PHP>if                                         lval.Token(l.newToken(l.Token(), "T_IF")); return T_IF
<PHP>isset                                      lval.Token(l.newToken(l.Token(), "T_ISSET")); return T_ISSET
<PHP>implements                                 lval.Token(l.newToken(l.Token(), "T_IMPLEMENTS")); return T_IMPLEMENTS
<PHP>instanceof                                 lval.Token(l.newToken(l.Token(), "T_INSTANCEOF")); return T_INSTANCEOF
<PHP>insteadof                                  lval.Token(l.newToken(l.Token(), "T_INSTEADOF")); return T_INSTEADOF
<PHP>interface                                  lval.Token(l.newToken(l.Token(), "T_INTERFACE")); return T_INTERFACE
<PHP>list                                       lval.Token(l.newToken(l.Token(), "T_LIST")); return T_LIST
<PHP>namespace                                  lval.Token(l.newToken(l.Token(), "T_NAMESPACE")); return T_NAMESPACE
<PHP>private                                    lval.Token(l.newToken(l.Token(), "T_PRIVATE")); return T_PRIVATE
<PHP>public                                     lval.Token(l.newToken(l.Token(), "T_PUBLIC")); return T_PUBLIC
<PHP>print                                      lval.Token(l.newToken(l.Token(), "T_PRINT")); return T_PRINT
<PHP>protected                                  lval.Token(l.newToken(l.Token(), "T_PROTECTED")); return T_PROTECTED
<PHP>return                                     lval.Token(l.newToken(l.Token(), "T_RETURN")); return T_RETURN
<PHP>static                                     lval.Token(l.newToken(l.Token(), "T_STATIC")); return T_STATIC
<PHP>switch                                     lval.Token(l.newToken(l.Token(), "T_SWITCH")); return T_SWITCH
<PHP>throw                                      lval.Token(l.newToken(l.Token(), "T_THROW")); return T_THROW
<PHP>trait                                      lval.Token(l.newToken(l.Token(), "T_TRAIT")); return T_TRAIT
<PHP>try                                        lval.Token(l.newToken(l.Token(), "T_TRY")); return T_TRY
<PHP>unset                                      lval.Token(l.newToken(l.Token(), "T_UNSET")); return T_UNSET
<PHP>use                                        lval.Token(l.newToken(l.Token(), "T_USE")); return T_USE
<PHP>var                                        lval.Token(l.newToken(l.Token(), "T_VAR")); return T_VAR
<PHP>while                                      lval.Token(l.newToken(l.Token(), "T_WHILE")); return T_WHILE
<PHP>yield[ \t\n\r]+from[^a-zA-Z0-9_\x80-\xff]  lval.Token(l.newToken(l.Token(), "T_YIELD_FROM")); return T_YIELD_FROM
<PHP>yield                                      lval.Token(l.newToken(l.Token(), "T_YIELD")); return T_YIELD
<PHP>include                                    lval.Token(l.newToken(l.Token(), "T_INCLUDE")); return T_INCLUDE
<PHP>include_once                               lval.Token(l.newToken(l.Token(), "T_INCLUDE_ONCE")); return T_INCLUDE_ONCE
<PHP>require                                    lval.Token(l.newToken(l.Token(), "T_REQUIRE")); return T_REQUIRE
<PHP>require_once                               lval.Token(l.newToken(l.Token(), "T_REQUIRE_ONCE")); return T_REQUIRE_ONCE
<PHP>__CLASS__                                  lval.Token(l.newToken(l.Token(), "T_CLASS_C")); return T_CLASS_C
<PHP>__DIR__                                    lval.Token(l.newToken(l.Token(), "T_DIR")); return T_DIR
<PHP>__FILE__                                   lval.Token(l.newToken(l.Token(), "T_FILE")); return T_FILE
<PHP>__FUNCTION__                               lval.Token(l.newToken(l.Token(), "T_FUNC_C")); return T_FUNC_C
<PHP>__LINE__                                   lval.Token(l.newToken(l.Token(), "T_LINE")); return T_LINE
<PHP>__NAMESPACE__                              lval.Token(l.newToken(l.Token(), "T_NS_C")); return T_NS_C
<PHP>__METHOD__                                 lval.Token(l.newToken(l.Token(), "T_METHOD_C")); return T_METHOD_C
<PHP>__TRAIT__                                  lval.Token(l.newToken(l.Token(), "T_TRAIT_C")); return T_TRAIT_C
<PHP>__halt_compiler                            lval.Token(l.newToken(l.Token(), "T_HALT_COMPILER")); return T_HALT_COMPILER
<PHP>\([ \t]*array[ \t]*\)                      lval.Token(l.newToken(l.Token(), "T_ARRAY_CAST")); return T_ARRAY_CAST
<PHP>\([ \t]*(bool|boolean)[ \t]*\)             lval.Token(l.newToken(l.Token(), "T_BOOL_CAST")); return T_BOOL_CAST
<PHP>\([ \t]*(real|double|float)[ \t]*\)        lval.Token(l.newToken(l.Token(), "T_DOUBLE_CAST")); return T_DOUBLE_CAST
<PHP>\([ \t]*(int|integer)[ \t]*\)              lval.Token(l.newToken(l.Token(), "T_INT_CAST")); return T_INT_CAST
<PHP>\([ \t]*object[ \t]*\)                     lval.Token(l.newToken(l.Token(), "T_OBJECT_CAST")); return T_OBJECT_CAST
<PHP>\([ \t]*string[ \t]*\)                     lval.Token(l.newToken(l.Token(), "T_STRING_CAST")); return T_STRING_CAST
<PHP>\([ \t]*unset[ \t]*\)                      lval.Token(l.newToken(l.Token(), "T_UNSET_CAST")); return T_UNSET_CAST
<PHP>new                                        lval.Token(l.newToken(l.Token(), "T_NEW")); return T_NEW
<PHP>and                                        lval.Token(l.newToken(l.Token(), "T_LOGICAL_AND")); return T_LOGICAL_AND
<PHP>or                                         lval.Token(l.newToken(l.Token(), "T_LOGICAL_OR")); return T_LOGICAL_OR
<PHP>xor                                        lval.Token(l.newToken(l.Token(), "T_LOGICAL_XOR")); return T_LOGICAL_XOR
<PHP>\\                                         lval.Token(l.newToken(l.Token(), "T_NS_SEPARATOR")); return T_NS_SEPARATOR
<PHP>\.\.\.                                     lval.Token(l.newToken(l.Token(), "T_ELLIPSIS")); return T_ELLIPSIS
<PHP>::                                         lval.Token(l.newToken(l.Token(), "T_PAAMAYIM_NEKUDOTAYIM")); return T_PAAMAYIM_NEKUDOTAYIM // T_DOUBLE_COLON
<PHP>&&                                         lval.Token(l.newToken(l.Token(), "T_BOOLEAN_AND")); return T_BOOLEAN_AND
<PHP>\|\|                                       lval.Token(l.newToken(l.Token(), "T_BOOLEAN_OR")); return T_BOOLEAN_OR
<PHP>&=                                         lval.Token(l.newToken(l.Token(), "T_AND_EQUAL")); return T_AND_EQUAL
<PHP>\|=                                        lval.Token(l.newToken(l.Token(), "T_OR_EQUAL")); return T_OR_EQUAL
<PHP>\.=                                        lval.Token(l.newToken(l.Token(), "T_CONCAT_EQUAL")); return T_CONCAT_EQUAL
<PHP>\*=                                        lval.Token(l.newToken(l.Token(), "T_MUL_EQUAL")); return T_MUL_EQUAL
<PHP>\*\*=                                      lval.Token(l.newToken(l.Token(), "T_POW_EQUAL")); return T_POW_EQUAL
<PHP>[/]=                                       lval.Token(l.newToken(l.Token(), "T_DIV_EQUAL")); return T_DIV_EQUAL
<PHP>\+=                                        lval.Token(l.newToken(l.Token(), "T_PLUS_EQUAL")); return T_PLUS_EQUAL
<PHP>-=                                         lval.Token(l.newToken(l.Token(), "T_MINUS_EQUAL")); return T_MINUS_EQUAL
<PHP>\^=                                        lval.Token(l.newToken(l.Token(), "T_XOR_EQUAL")); return T_XOR_EQUAL
<PHP>%=                                         lval.Token(l.newToken(l.Token(), "T_MOD_EQUAL")); return T_MOD_EQUAL
<PHP>--                                         lval.Token(l.newToken(l.Token(), "T_DEC")); return T_DEC
<PHP>\+\+                                       lval.Token(l.newToken(l.Token(), "T_INC")); return T_INC
<PHP>=>                                         lval.Token(l.newToken(l.Token(), "T_DOUBLE_ARROW")); return T_DOUBLE_ARROW
<PHP>\<=\>                                      lval.Token(l.newToken(l.Token(), "T_SPACESHIP")); return T_SPACESHIP
<PHP>\!=|\<\>                                   lval.Token(l.newToken(l.Token(), "T_IS_NOT_EQUAL")); return T_IS_NOT_EQUAL
<PHP>\!==                                       lval.Token(l.newToken(l.Token(), "T_IS_NOT_IDENTICAL")); return T_IS_NOT_IDENTICAL
<PHP>==                                         lval.Token(l.newToken(l.Token(), "T_IS_EQUAL")); return T_IS_EQUAL
<PHP>===                                        lval.Token(l.newToken(l.Token(), "T_IS_IDENTICAL")); return T_IS_IDENTICAL
<PHP>\<\<=                                      lval.Token(l.newToken(l.Token(), "T_SL_EQUAL")); return T_SL_EQUAL
<PHP>\>\>=                                      lval.Token(l.newToken(l.Token(), "T_SR_EQUAL")); return T_SR_EQUAL
<PHP>\>=                                        lval.Token(l.newToken(l.Token(), "T_IS_GREATER_OR_EQUAL")); return T_IS_GREATER_OR_EQUAL
<PHP>\<=                                        lval.Token(l.newToken(l.Token(), "T_IS_SMALLER_OR_EQUAL")); return T_IS_SMALLER_OR_EQUAL
<PHP>\*\*                                       lval.Token(l.newToken(l.Token(), "T_POW")); return T_POW
<PHP>\<\<                                       lval.Token(l.newToken(l.Token(), "T_SL")); return T_SL
<PHP>\>\>                                       lval.Token(l.newToken(l.Token(), "T_SR")); return T_SR
<PHP>\?\?                                       lval.Token(l.newToken(l.Token(), "T_COALESCE")); return T_COALESCE
<PHP>(#|[/][/])
    tb := l.Token()

    for {
        if c == -1 {
            break
        }

        tb = append(tb, l.Last)

        switch c {
            case '\r':
                c = l.Next()
                if c == '\n' {
                    continue
                }
                
            case '\n':

            case '?':
                c = l.Next()
                if c == '>' {
                    l.ungetChars(1)
                    tb = tb[:len(tb)-1]
                    break
                }
                continue

            default:
                c = l.Next()
                continue
        }

        break;
    }

    l.addComment(tb)

<PHP>([/][*])|([/][*][*])
    tb := l.Token()
    is_doc_comment := false
    if len(tb) > 2 {
        is_doc_comment = true
        l.PhpDocComment = ""
    }

    for {
        if c == -1 {
            break; // TODO: Unterminated comment starting line %d
        }

        if l.Prev.Rune == '*' && l.Last.Rune == '/' {
            c = l.Next()
            break;
        }

        c = l.Next()
    }

    if is_doc_comment {
        l.PhpDocComment = string(l.TokenBytes(nil))
        l.addComment(l.Token())
    } else {
        l.addComment(l.Token())
    }

<PHP>{OPERATORS}                                lval.Token(l.newToken(l.Token(), string(rune(l.TokenBytes(nil)[0])))); return Rune2Class(rune(l.TokenBytes(nil)[0]))

<PHP>\{                                         l.pushState(PHP); lval.Token(l.newToken(l.Token(), "{")); return Rune2Class(rune(l.TokenBytes(nil)[0]))
<PHP>\}                                         l.popState();     lval.Token(l.newToken(l.Token(), "}")); return Rune2Class(rune(l.TokenBytes(nil)[0])); l.PhpDocComment = ""
<PHP>\${VAR_NAME}                               lval.Token(l.newToken(l.Token(), "T_VARIABLE")); return T_VARIABLE
<PHP>{VAR_NAME}                                 lval.Token(l.newToken(l.Token(), "T_STRING")); return T_STRING

<PHP>->                                         l.begin(PROPERTY);lval.Token(l.newToken(l.Token(), "T_OBJECT_OPERATOR")); return T_OBJECT_OPERATOR;
<PROPERTY>[ \t\n\r]+
<PROPERTY>->                                    lval.Token(l.newToken(l.Token(), "T_OBJECT_OPERATOR")); return T_OBJECT_OPERATOR;
<PROPERTY>{VAR_NAME}                            l.begin(PHP);lval.Token(l.newToken(l.Token(), "T_STRING")); return T_STRING;
<PROPERTY>.                                     l.ungetChars(1);l.begin(PHP)

<PHP>[\']([^\\\']*([\\].)*)*[\']                lval.Token(l.newToken(l.Token(), "T_CONSTANT_ENCAPSED_STRING")); return T_CONSTANT_ENCAPSED_STRING;

<PHP>`                                          l.begin(BACKQUOTE); lval.Token(l.newToken(l.Token(), "`")); return Rune2Class(rune(l.TokenBytes(nil)[0]))
<BACKQUOTE>`                                    l.begin(PHP); lval.Token(l.newToken(l.Token(), "`")); return Rune2Class(rune(l.TokenBytes(nil)[0]))

<PHP>[b]?\<\<\<[ \t]*({VAR_NAME}|([']{VAR_NAME}['])|(["]{VAR_NAME}["])){NEW_LINE}
    tb := l.Token()
    binPrefix := 0
    if tb[0].Rune == 'b' {
        binPrefix = 1
    }
    
    lblFirst := 3 + binPrefix
    lblLast := len(tb)-2
    if tb[lblLast].Rune == '\r' {
        lblLast--
    }

    for {
        if tb[lblFirst].Rune == ' ' || tb[lblFirst].Rune == '\t' {
            lblFirst++
            continue
        }

        break
    }

    heredocToken := make([]lex.Char, lblLast - lblFirst + 1)
    copy(heredocToken, tb[lblFirst:lblLast+1])

    switch tb[lblFirst].Rune {
        case '\'' : 
            lblFirst++
            lblLast--
            l.begin(NOWDOC)
        case '"' : 
            lblFirst++
            lblLast--
            l.begin(HEREDOC)
        default:
            l.begin(HEREDOC)
    }

    heredocLabel = make([]lex.Char, lblLast - lblFirst + 1)
    copy(heredocLabel, tb[lblFirst:lblLast+1])
    
    ungetCnt := len(heredocLabel)
    searchLabelAhead := []lex.Char{}
    for i := 0; i < len(heredocLabel); i++ {
        if c == -1 {
            break;
        }
        searchLabelAhead = append(searchLabelAhead, l.Lookahead())
        c = l.Next()
    }

    if bytes.Equal(l.charsToBytes(heredocLabel), l.charsToBytes(searchLabelAhead)) && ';' == rune(c) {
        ungetCnt++
        c = l.Next()
        if '\n' == rune(c) || '\r' == rune(c) {
            l.begin(HEREDOC_END)
        }
    }

    l.ungetChars(ungetCnt)

    lval.Token(l.newToken(heredocToken, "T_START_HEREDOC"));
    return T_START_HEREDOC

<NOWDOC>.|[ \t\n\r]
    searchLabel := []byte{}
    tb := []lex.Char{}
    
    for {
        if c == -1 {
            break;
        }

        if '\n' == rune(c) || '\r' == rune(c) {
            if bytes.Equal(append(l.charsToBytes(heredocLabel), ';'), searchLabel) {
                l.begin(HEREDOC_END)
                tb = l.ungetChars(len(heredocLabel)+1)
                break;
            }

            if bytes.Equal(l.charsToBytes(heredocLabel), searchLabel) {
                l.begin(HEREDOC_END)
                tb = l.ungetChars(len(heredocLabel))
                break;
            }
            
            searchLabel = []byte{}
        } else {
            searchLabel = append(searchLabel, byte(rune(c)))
        }

        c = l.Next()
    }

    lval.Token(l.newToken(tb, "T_ENCAPSED_AND_WHITESPACE"))
    return T_ENCAPSED_AND_WHITESPACE

<HEREDOC_END>{VAR_NAME}\;                       l.begin(PHP);lval.Token(l.newToken(l.ungetChars(1), "T_END_HEREDOC")); return T_END_HEREDOC
<HEREDOC_END>{VAR_NAME}                         l.begin(PHP);lval.Token(l.newToken(l.Token(), "T_END_HEREDOC")); return T_END_HEREDOC

<PHP>[b]?[\"]
    binPrefix := l.Token()[0].Rune == 'b'

    beginString := func() int {
        cnt := 1; if (binPrefix) {cnt = 2}
        
        l.ungetChars(len(l.Token())-cnt)
        chars := l.Token()[:cnt]
        l.pushState(STRING)

        lval.Token(l.newToken(chars, `"`)); return Rune2Class('"')
    }

    F:for {
        if c == -1 {
            break;
        }

        switch c {
            case '"' : 
                c = l.Next();
                lval.Token(l.newToken(l.Token(), "T_CONSTANT_ENCAPSED_STRING")); return T_CONSTANT_ENCAPSED_STRING
                break F;
            
            case '$':
                c = l.Next();
                if rune(c) == '{' || c >= 'A' && c <= 'Z' || c == '_' || c >= 'a' && c <= 'z' || c >= '\u007f' && c <= 'ÿ' {
                    return beginString()
                    break F;
                } 
                l.ungetChars(0)
            
            case '{':
                c = l.Next();
                if rune(c) == '$' {
                    return beginString()
                    break F;
                } 
                l.ungetChars(0)

            case '\\':
                c = l.Next();
        }

        c = l.Next()
    }

<STRING>\"                                  l.popState(); lval.Token(l.newToken(l.Token(), `"`)); return Rune2Class(l.Token()[0].Rune)
<STRING,HEREDOC,BACKQUOTE>\{\$              lval.Token(l.newToken(l.ungetChars(1), "T_CURLY_OPEN")); l.pushState(PHP); return T_CURLY_OPEN
<STRING,HEREDOC,BACKQUOTE>\$\{              l.pushState(STRING_VAR_NAME); lval.Token(l.newToken(l.Token(), "T_DOLLAR_OPEN_CURLY_BRACES")); return T_DOLLAR_OPEN_CURLY_BRACES
<STRING,HEREDOC,BACKQUOTE>\${VAR_NAME}      l.ungetChars(len(l.Token()));l.pushState(STRING_VAR)
<STRING>.|[ \t\n\r]
    currentChar := l.Prev
    tb := []lex.Char{currentChar}
    for {
        switch currentChar.Rune {
            case '$':
                if c == '{' || isValidFirstVarNameRune(rune(c)) {
                    l.ungetChars(1)
                    lval.Token(l.newToken(tb[:len(tb)-1], "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                }

            case '{':
                if rune(c) == '$' {
                    l.ungetChars(1)
                    lval.Token(l.newToken(tb[:len(tb)-1], "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                }

            case '\\':
                currentChar := l.Last
                tb = append(tb, currentChar)
                c = l.Next();
        }

        if rune(c) == '"' {
            lval.Token(l.newToken(l.Token(), "T_ENCAPSED_AND_WHITESPACE"));
            return T_ENCAPSED_AND_WHITESPACE
        }

        currentChar = l.Last
        tb = append(tb, currentChar)
        c = l.Next()

        if c == -1 {
            break;
        }
    }

<BACKQUOTE>.|[ \t\n\r]
    currentChar := l.Prev
    tb := []lex.Char{currentChar}

    for {
        switch currentChar.Rune {
            case '$':
                if c == '{' || isValidFirstVarNameRune(rune(c)) {
                    l.ungetChars(1)
                    lval.Token(l.newToken(tb[:len(tb)-1], "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                }

            case '{':
                if rune(c) == '$' {
                    l.ungetChars(1)
                    lval.Token(l.newToken(tb[:len(tb)-1], "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                }

            case '\\':
                currentChar := l.Last
                tb = append(tb, currentChar)
                c = l.Next();
        }

        if rune(c) == '`' {
            lval.Token(l.newToken(l.Token(), "T_ENCAPSED_AND_WHITESPACE"));
            return T_ENCAPSED_AND_WHITESPACE
        }

        currentChar = l.Last
        tb = append(tb, currentChar)
        c = l.Next()

        if c == -1 {
            break;
        }
    }

<HEREDOC>.|[ \t\n\r]
    searchLabel := []byte{}
    tb := []lex.Char{}
    
    for {
        if c == -1 {
            break;
        }

        nls := 0

        switch c {
            case '\r':
                nls = 1
                c := l.Next()

                if c != '\n' {
                    nls = 0
                    l.ungetChars(0)
                }

                fallthrough

            case '\n':
                if bytes.Equal(append(l.charsToBytes(heredocLabel), ';'), searchLabel) { 
                    l.begin(HEREDOC_END)
                    tb = l.ungetChars(len(heredocLabel)+1+nls)
                    lval.Token(l.newToken(tb, "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                }

                if bytes.Equal(l.charsToBytes(heredocLabel), searchLabel) { 
                    l.begin(HEREDOC_END)
                    tb = l.ungetChars(len(heredocLabel)+nls)
                    lval.Token(l.newToken(tb, "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                }
                
                searchLabel = []byte{}
            
            case '$':
                c = l.Next();
                if rune(c) == '{' || isValidFirstVarNameRune(rune(c)) {
                    tb = l.ungetChars(1)
                    lval.Token(l.newToken(tb, "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                } 
                l.ungetChars(0)
            
            case '{':
                c = l.Next();
                if rune(c) == '$' {
                    tb = l.ungetChars(1)
                    lval.Token(l.newToken(tb, "T_ENCAPSED_AND_WHITESPACE"));
                    return T_ENCAPSED_AND_WHITESPACE
                } 
                l.ungetChars(0)

            case '\\':
                c = l.Next();
                if c == '\n' || c == '\r' {
                    l.ungetChars(0)
                }
            
            default:
                searchLabel = append(searchLabel, byte(rune(c)))
        }

        c = l.Next()
    }

<STRING_VAR>\${VAR_NAME}                    lval.Token(l.newToken(l.Token(), "T_VARIABLE")); return T_VARIABLE
<STRING_VAR>->{VAR_NAME}                    lval.Token(l.newToken(l.ungetChars(len(l.Token())-2), "T_OBJECT_OPERATOR")); return T_OBJECT_OPERATOR
<STRING_VAR>{VAR_NAME}                      l.popState();lval.Token(l.newToken(l.Token(), "T_STRING")); return T_STRING
<STRING_VAR>\[                              l.pushState(STRING_VAR_INDEX);lval.Token(l.newToken(l.Token(), "[")); return Rune2Class(rune(l.TokenBytes(nil)[0]))
<STRING_VAR>.|[ \t\n\r]                     l.ungetChars(1);l.popState()

<STRING_VAR_INDEX>{LNUM}|{HNUM}|{BNUM}      lval.Token(l.newToken(l.Token(), "T_NUM_STRING")); return T_NUM_STRING
<STRING_VAR_INDEX>\${VAR_NAME}              lval.Token(l.newToken(l.Token(), "T_VARIABLE")); return T_VARIABLE
<STRING_VAR_INDEX>{VAR_NAME}                lval.Token(l.newToken(l.Token(), "T_STRING")); return T_STRING
<STRING_VAR_INDEX>\]                        l.popState(); l.popState();lval.Token(l.newToken(l.Token(), "]")); return Rune2Class(rune(l.TokenBytes(nil)[0]))
<STRING_VAR_INDEX>[ \n\r\t\\'#]             l.popState(); l.popState();lval.Token(l.newToken(l.Token(), "T_ENCAPSED_AND_WHITESPACE")); return T_ENCAPSED_AND_WHITESPACE
<STRING_VAR_INDEX>{OPERATORS}               lval.Token(l.newToken(l.Token(), string(rune(l.TokenBytes(nil)[0])))); return Rune2Class(rune(l.TokenBytes(nil)[0]))
<STRING_VAR_INDEX>.                         lval.Token(l.newToken(l.Token(), ".")); return Rune2Class(rune(l.TokenBytes(nil)[0]))

<STRING_VAR_NAME>{VAR_NAME}[\[\}]           l.popState();l.pushState(PHP);lval.Token(l.newToken(l.ungetChars(1), "T_STRING_VARNAME")); return T_STRING_VARNAME
<STRING_VAR_NAME>.                          l.ungetChars(1);l.popState();l.pushState(PHP)

%%
    if c, ok := l.Abort(); ok { return int(c) }
    goto yyAction
}