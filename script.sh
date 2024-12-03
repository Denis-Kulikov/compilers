#!/bin/bash

bison -d -o parser.tab.c cpp-parser.y
flex -o lexer.c lexer.l
g++ parser.tab.c lexer.c parser.cpp -g -o parser -lfl
