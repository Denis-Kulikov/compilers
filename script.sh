#!/bin/bash

flex++ lexer.l
g++ lex.yy.cc main.cpp -o lexer
