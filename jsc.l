%{
    #include "y.tab.h"
    #include "COMMON.h"
    
    void upper(char *);
%}

KEYWORD var|function|if|import|in|enum|instanceof|int|long|return|short|static|super|switch|synchronized|this|typeof|void|while|with 

DIGIT [[:digit:]]

LETTER [[:alpha:]]

SIGN \+|\-

EXP \e|\E

ID (\$|\_|{LETTER})[[:alnum:]]*

WHITESPACE ([ ]|[\t])+

NEWLINE \r|\r\n|\n

SINGLE_LINE_COMM \/\/.*[\n]
MULTI_LINE_COMM  \/\*[^\*\/]*\*\/[\n]
COMMENT {SINGLE_LINE_COMM}|{MULTI_LINE_COMM}

BOOL (TRUE|false|true|FALSE)

SINGLE_QUOTE_STR (\')[^\'](\')
DOUBLE_QUOTE_STR (\")[^\"](\")
STRING {SINGLE_QUOTE_STR}|{DOUBLE_QUOTE_STR}

INT {SIGN}?{DIGIT}+

FLOAT ({DIGIT}+\.{DIGIT}*)|(\.{DIGIT}+)|({DIGIT}+{EXP}{SIGN}{DIGIT}+)

SEPERATOR \{|\}|\(|\)|\[|\]|\;|\,

OPERATOR \+|\*|\/|\=|\-|\+\+|\-\-|\%|\+\=|\-\=|\/\=|\*\=|\%\=|\=\=|\=\=\=|\!\=|\!\=\=|\<|\>|\>\=|\<\=|\&\&|\|\||\!|\&|\||\~|\^|\>\>|\<\<

NULL (null|NULL)

%%

{NEWLINE} {
    charNum = 1;
    lineNum++;

    return NEWLINE;
}

{BOOL} {
    //insert(presentScope, yytext, "LITERAL", "BOOLEAN", lineNum, charNum, yytext);
    //printf("%s , BOOLEAN\n", yytext);
    ECHO;
    charNum += yyleng;

    return BOOL;
}

{NULL} {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    //printf("%s , NULL\n", yytext);
    ECHO;
    charNum += yyleng;

    return NULLType;
}

{COMMENT} {
    //printf("comment, %s\n", yytext);
    //fprintf(yyout, "%s", "\b");
    charNum += yyleng;
    int i;
    for (i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            charNum = 1;
            lineNum++;
        }
    }

    return COMMENT;
}

do {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return DO;
}
function  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return FUNCTION;
}
if  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return IF;
}
var  {
    //insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    fprintf(yyout, "%s", yytext);
    charNum += yyleng;
    return VAR;
}
import  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return IMPORT;
}
in  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return IN;
}
int  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return INT;
}
long  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return LONG;
}
return  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return RETURN;
}
static  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return STATIC;
}
void  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return VOID;
}
while  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return WHILE;
}
with  {
    insert(presentScope, yytext, "LITERAL", "NULL", lineNum, charNum, yytext);
    ECHO;
    charNum += yyleng;
    return WITH;
}

{ID} {
    ECHO;
    insert(presentScope, yytext, "IDENTIFIER", "ID", lineNum, charNum, "NULL");
    charNum += yyleng;
    //printf("%s, IDENTIFIER\n", yytext);
    yylval.id = strdup(yytext);
    return ID;
}

\+|\-|\! {
    yylval.sym = *(yytext);
    ECHO;
    charNum += yyleng;
    return UnaryOp;
}
\*|\/|\% {
    yylval.sym = *(yytext);
    ECHO;
    charNum += yyleng;
    return ArithmeticOp;
}
\= {
    yylval.sym = *yytext;
    ECHO;
    charNum += yyleng;
    return EQ;
}
\+\+ {
    yylval.relop = strdup(yytext);
    charNum += yyleng;
    return INC;
}
\-\- {
    yylval.relop = strdup(yytext);
    ECHO;
    charNum += yyleng;
    return DEC;
}
\+\=|\-\=|\/\=|\*\= {
    yylval.relop = strdup(yytext);
    ECHO;
    charNum += yyleng;
    return ArithmeticAssign;
}

\=\=|\!\=|\>\=|\<\=|\&\&|\|\||\>\>|\<\< {
    yylval.relop = strdup(yytext);
    ECHO;
    charNum += yyleng;
    return RELOP;
}

\<|\> {
    yylval.sym = *(yytext);
    ECHO;
    charNum += yyleng;
    return RELOP;
}

{INT} {
    //fprintf(threeadd, "%s , INTEGER\n", yytext);
    //ECHO;
    ECHO;
    charNum += yyleng;
    yylval.intVal = atoi(yytext);
    return IntLiteral;
}

{FLOAT} {
    //printf("%s , FLOAT\n", yytext);
    ECHO;
    charNum += yyleng;

    yylval.floatVal = atof(yytext);

    return FloatLiteral;
}


{STRING} {
    //insert(presentScope, yytext, "LITERAL", "STRING", lineNum, charNum, yytext);
    //printf("%s , STRING\n", yytext);
    ECHO;
    charNum += yyleng;

    return string;
}

{SEPERATOR} {
    //insert(yytext, "SEPERATOR", "NULL");
    //printf("%s , SEPERATOR\n", yytext);
    ECHO;
    charNum += yyleng;

    if (yytext[0] == '{') {
        presentScope++;
    }

    if (yytext[0] == '}') {
        presentScope--;
    }

    return *yytext;
}

{WHITESPACE} {
    //printf("whitespace %s\n", yytext);
    fprintf(yyout, "%s"," ");
    charNum += yyleng;

    //return WHITESPACE;
}


. {
    perror("Error! No pattern found\n");
    charNum += yyleng;
}
%%