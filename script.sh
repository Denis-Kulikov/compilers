#!/bin/bash

bison -Wcounterexamples -d -o parser.tab.c parser.y
flex -o lexer.c lexer.l
g++ parser.tab.c lexer.c -o calc -lfl
