%{
    #include "COMMON.h"
    extern FILE* yyin;
    extern FILE* yyout;
    FILE* threeadd;
    FILE* optimised;

    int yylex(void);
    void yyerror(const char *);

    int yydebug=1;
%}

%token string 

%token <intVal> IntLiteral
%token <floatVal> FloatLiteral
%token <relop> RELOP ArithmeticAssign INC DEC
%token <sym> UnaryOp EQ ArithmeticOp
%token <id> ID BOOL NULLType BREAK CASE INT FLOAT CHAR CLASS CONST COMMENT CONTINUE DEFAULT DELETE DO DOUBLE ELSE FOR FUNCTION GOTO IF IMPORT IN INSTANCEOF LONG NEW RETURN STATIC SUPER SYNCHRONIZED THIS VAR VOID WHILE WITH NEWLINE

%type <sym> unaryOps arithmeticOps 
%type <relop> relop singleArithmetic
%type <id> identifierName Identifier BooleanLiteral NullLiteral reservedWord keyword futureReservedWord
%type <exprAtts> singleExpression

%left '*' '/'
%left '+' '-' ','
%define parse.error verbose

%union{

    int intVal;
    char* id;    
    float floatVal;
    char sym;
    char* relop;
    
    struct{
        int value;
        char* name;
    }exprAtts;
}

%%
program
    : 
    | sourceElements 
    ;

sourceElements
    : sourceElement
    | sourceElements sourceElement  
    ;

sourceElement
    : statement
    | functionDeclaration
    ;

statement
    : block
    | variableStatement
    | emptyStatement
    | expressionStatement
    | ifStatement
    | iterationStatement
    | continueStatement
    | breakStatement
    | returnStatement
    | withStatement
    | COMMENT
    ;

block
    : OpenBrace CloseBrace
    | OpenBrace statementList CloseBrace
    ;

statementList
    : statement
    | statementList statement
    ;

variableStatement
    : VAR variableDeclarationList
    ;

variableDeclarationList
    : variableDeclaration
    | variableDeclarationList Comma variableDeclaration
    ;

variableDeclaration
    : Identifier eos {
        fprintf(threeadd, "%s = 0\n", $1);
        fprintf(optimised, "%s = 0\n", $1);
    }
    | Identifier initialiser {
        fprintf(threeadd, "%s = %s\n", $<id>1, $<exprAtts>2.name);
        if($<exprAtts>2.value < -100)
            fprintf(optimised, "%s = %s\n", $<id>1, $<exprAtts>2.name);
        else
            fprintf(optimised, "%s = %d\n", $<id>1, $<exprAtts>2.value);
    }
    ;

initialiser
    : EQ singleExpression {
        $<exprAtts>$.name = $2.name;
        $<exprAtts>$.value = $2.value;
    }
    ;

emptyStatement
    : SemiColon
    ;

expressionStatement
    : expressionSequence
    ;

ifStatement
    : IF OpenParen singleExpression {fprintf(threeadd, "ifFalse %s goto L1\n", $3.name); fprintf(optimised, "ifFalse %s goto L1\n", $3.name);} CloseParen statement eos {fprintf(threeadd, "L1:\n"); fprintf(optimised, "L1:\n");}
    | IF OpenParen expressionSequence CloseParen statement ELSE statement 
    ;

iterationStatement
    : DO statement WHILE OpenParen expressionSequence CloseParen eos                                                 
    | WHILE OpenParen singleExpression { fprintf(threeadd, "L2: ifFalse %s goto L4\n", $3.name); fprintf(optimised, "L2: ifFalse %s goto L4\n", $3.name); } CloseParen statement { fprintf(threeadd, "goto L2\nL4:\n");fprintf(optimised, "goto L2\nL4:\n"); }
    | FOR OpenParen expressionSequence SemiColon expressionSequence SemiColon expressionSequence CloseParen statement
    ;

continueStatement
    : CONTINUE eos
    ;

breakStatement
    : BREAK eos
    ;

returnStatement
    : RETURN expressionSequence eos
    | RETURN eos;
    ;

withStatement
    : WITH OpenParen expressionSequence CloseParen statement
    ;


functionDeclaration
    : FUNCTION Identifier OpenParen CloseParen {fprintf(threeadd, "FUNCTION BEGIN %s\n", $<id>2); fprintf(optimised, "FUNCTION BEGIN %s\n", $<id>2); } functionBody { fprintf(threeadd, "FUNCTION %s END\n", $<id>2); fprintf(optimised, "FUNCTION %s END\n", $<id>2); }
    | FUNCTION Identifier OpenParen formalParameterList CloseParen functionBody
    ;

functionCall
    : FUNCTION OpenParen CloseParen eos 
    | FUNCTION OpenParen formalParameterList CloseParen eos
    ;

formalParameterList
    : Identifier {$<id>$ = $1;}
    | formalParameterList Comma Identifier
    ;

functionBody
    : OpenBrace sourceElements CloseBrace
    ;

arguments
    : OpenParen CloseParen
    | OpenParen expressionSequence CloseParen
    ;
    
expressionSequence
    : expressionSequence Comma singleExpression eos
    | singleExpression eos 
    ;

singleExpression
    : functionCall
    | singleExpression OpenBracket expressionSequence CloseBracket
    | singleExpression Dot identifierName
    | singleExpression arguments
    | singleExpression singleArithmetic
    | DELETE singleExpression eos
    | VOID singleExpression eos
    | singleArithmetic singleExpression eos { /*fprintf(threeadd, "t2 = %s + 1\n%s = t1\n", $2);*/
        /*$<intVal>$ = ++ $<intVal>2;*/ }
    | unaryOps singleExpression eos { /*$<intVal>$ = + $<intVal>2;*/ }
    | singleExpression arithmeticOps singleExpression eos { //fprintf(threeadd, "t1 = %s %c %s\n", $1.name, $<sym>2, $3.name);
    char* str1 = strdup($1.name);
    str1[strlen(str1)] = $<sym>2;
    str1[strlen(str1) + 1] = '\0';
    str1 = strcat(str1, $3.name);
        $$.name =  strdup(str1);
        if($1.value<-100 || $3.value<-100){
            $$.name =  strdup(str1);
           fprintf(stderr, "t1 = %s %c %s\n", $1.name, $<sym>2, $3.name);
        }
        else{
            $$.value = $1.value + $3.value;
            //fprintf(optimised, "t1 = %d\n", $$.value);
        }
    }   
    | singleExpression relop singleExpression eos { fprintf(threeadd, "t0 = %s %c %s\n", $1.name, $<sym>2, $3.name);
        $$.name =  strdup("t0");
        if($1.value<-100 || $3.value<-100)
            fprintf(optimised, "t0 = %s %c %s\n", $1.name, $<sym>2, $3.name);
        else{
            $$.value = $1.value > $3.value;
            //fprintf(optimised, "t0 = %d\n", $$.value);
        }
            
    }
    | singleExpression IN singleExpression eos
    | singleExpression INSTANCEOF singleExpression eos
    | singleExpression QuestionMark singleExpression Colon singleExpression eos
    | singleExpression assignmentOperator singleExpression eos
    | THIS
    | Identifier {$$.name = $<id>1;}
    | literal {
        $$.value = $<intVal>1;
        asprintf(&$$.name, "%d", $<intVal>1 );
    }
    | OpenParen expressionSequence CloseParen
    ;

literal
    : NullLiteral {$<id>$ = $1;}
    | BooleanLiteral
    | StringLiteral
    | IntLiteral  {$<intVal>$ = $1; /*fprintf(threeadd, "%c\n", $1);*/}
    | FloatLiteral {$<floatVal>$ = $1;}
    ;

StringLiteral
    : string
    ;

reservedWord
    : keyword
    | futureReservedWord
    | NullLiteral
    | BooleanLiteral
    ;

keyword
    : BREAK
    | DO
    | INSTANCEOF
    | CASE
    | ELSE
    | NEW
    | VAR
    | RETURN
    | VOID
    | CONTINUE
    | FOR
    | WHILE
    | FUNCTION
    | THIS
    | WITH
    | DEFAULT
    | IF
    | DELETE
    | IN
    ;

NullLiteral
    : NULLType { $$ = "NULL"; }
    ;

BooleanLiteral
    : BOOL  { $$ = $1; }
    ;

Identifier
    : ID {$$ = $1;}
    ;

eos
    : SemiColon
    | NEWLINE
    | CloseBrace
    ;

identifierName
    : Identifier {$$ = $1;}
    | reservedWord
    ;

futureReservedWord
    : CLASS
    | SUPER
    | CONST
    | IMPORT
    | STATIC
    ;

singleArithmetic
    : INC   { $$ = $1; }
    | DEC   { $$ = $1; }
    ;

unaryOps
    :UnaryOp { $$ = $1; }
    ;

arithmeticOps
    : unaryOps { $$ = $1; }
    | ArithmeticOp { $$ = $1; }
    ;

relop
    : RELOP { $$ = $1; }
;

assignmentOperator
    : ArithmeticAssign { $<relop>$ = $1; }
    | EQ { $<sym>$ = $1; }
    ;

OpenBracket                
    : '['
;

CloseBracket               
    : ']'
;

OpenParen                  
    : '('
;

CloseParen                 
    : ')'
;

OpenBrace                  
    : '{'
;

CloseBrace                 
    : '}'
;

SemiColon                  
    : ';'
;

Comma                      
    : ','
;

QuestionMark               
    : '?'
;

Colon                      
    : ':'
;

Dot                        
    : '.'
;
          
%%

int main(int argc, char* argv[])
{
    yyin = fopen(argv[1], "r");
    yyout = fopen("lex_out.txt", "w");
    threeadd = fopen("threeAddr.txt", "w");
    optimised = fopen("optimised.txt", "w");
    init_table();
	yyparse();
    fprintf(yyout, "%s", "\n");
    display();
    return 0;
}

void yyerror(s)
    const char *s;
{
    printf("\n-------error at-----\nline %d, char %d\n%s\n", lineNum, charNum , s);
}