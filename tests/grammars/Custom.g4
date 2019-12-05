/*
 * Copyright (c) 2017-2020 Renata Hodovan, Akos Kiss.
 *
 * Licensed under the BSD 3-Clause License
 * <LICENSE.rst or https://opensource.org/licenses/BSD-3-Clause>.
 * This file may not be copied, modified, or distributed except
 * according to those terms.
 */

/*
 * This test checks several customization features:
 *  - generation of custom code both into the headers and class bodies of
 *    unlexers/unparsers,
 *  - variables in rules and actions,
 *  - adding/overwriting nodes to/in the tree being generated by
 *    unlexers/unparsers,
 *  - overriding generated and inherited methods in hand-written subclassed
 *    unlexers/unparsers.
 *
 * Notes:
 *  - Because this test generates multiple outputs files, it exercises both
 *    single-process (`-j 1`) and multi-process (`-j N`) modes of generator.
 *  - For this test, ANTLR is not invoked as the handling of
 *    variables/references in rules/actions is incompatible.
 */

// TEST-PROCESS: {grammar}.g4 -o {tmpdir}
// TEST-GENERATE: {grammar}Generator.{grammar}Generator -r start -j 1 -n 5 -o {tmpdir}/{grammar}GS%d.txt
// TEST-GENERATE: {grammar}Generator.{grammar}Generator -r start -j 2 -n 5 -o {tmpdir}/{grammar}GM%d.txt
// TEST-GENERATE: {grammar}SubclassGenerator.{grammar}SubclassGenerator -r start -j 1 -n 5 -o {tmpdir}/{grammar}SS%d.txt
// TEST-GENERATE: {grammar}SubclassGenerator.{grammar}SubclassGenerator -r start -j 2 -n 5 -o {tmpdir}/{grammar}SM%d.txt

grammar Custom;

@lexer::header {
from sys import platform as CustomLexerPlatform
}

@lexer::member {
def _custom_lexer_content(self, parent=None):
    return UnlexerRule(src=CustomLexerPlatform, parent=parent)
}

@parser::header {
from random import randint as CustomParserUniform
}

@parser::member {
def _custom_parser_uniform(self):
    return CustomParserUniform(0, 1)
}

start
  : tag
  | {self._custom_parser_uniform()}? XML tag
  ;

tag
  : '<' remember=tagname '>' CONTENT '</' tagname {current.last_child = $remember.deepcopy()} '>'
  ;

tagname
  : ID
  ;

XML
  : '<?xml>'
  ;

ID
  : [a-z]+
  ;

CONTENT
  : '<![CDATA[' {self._custom_lexer_content(parent=current)} ']]>'
  ;
