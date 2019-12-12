bison -d carbo1607020.y
flex carbo1607020.l
gcc carbo1607020.tab.c lex.yy.c -o carboRun
carboRun
pause