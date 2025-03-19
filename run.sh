#!/bin/bash

#cleanup
rm y.* lex.yy.c lex_out*

#run flex/bison and dependencies
flex ./jsc.l
yacc -d -v -t -g ./jsc.yacc

echo "------------------------------"
gcc ./lex.yy.c y.tab.c hash.c -lfl -o jsc -g && ./jsc inJs.js

echo
echo "------------------------------"
echo "Printing the file"
echo

cat lex_out.txt
