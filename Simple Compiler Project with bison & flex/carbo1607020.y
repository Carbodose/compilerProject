%{
	#include<stdio.h>
	#include<ctype.h>
	#include<string.h>
	#include<stdlib.h>
	#include<math.h>
	
	char *varList[1001];		//store all the pointers containing location of var names

	int numOfVar=0;

	float realData[1001];		//actual data that the var contains

	char *strData[1001];

	char varType[1001];			//store type info about those vars

	float switchOn = 0.0;
	float switchVal = 0.0;
	float switchDone = 0.0;
	int indexOf(char *);
%}

/* bison declares */
%union
   {
           char *text;
           int  ival;
           float fval;
   };

%token <text> DEFREAL STRING DEFSTRING DEFCHAR VAR
%token <fval> CHAR REALNUM NUM GCD FACTORIAL


%token STRSHOW IF ELSE MAIN START END SWITCH CASE DEFAULT FOR SHOW SIN COS TAN LOG LOG10 GE LE EE
%nonassoc IFX
%nonassoc ELSE
%nonassoc SWITCH
%nonassoc CASE
%nonassoc DEFAULT
%right '='
%left '<' '>'
%left '+' '-'
%left '*' '/'
%left '^'


%type <fval> cstatement statement expression switchDefault

/* Grammar rules and actions follow.  */

%%

program: MAIN '(' ')' START cstatement END
	 ;

cstatement: /* NULL */

	| cstatement statement
	;

statement: ';'			
	| declare ';'		{ printf("declared (%d) %s\n",numOfVar,varList[numOfVar]); }

	| expression ';'	{ printf("value of expression: %f\n", $1); $$=$1;}

	| VAR '=' expression ';' { 
			int index = indexOf($1);
			if(index){
				if(varType[index]=='r'||varType[index]=='c'){
					realData[index] = $3;
					//printf("Assigned :  %f\t\n",$3);
					$$=$3;
				}
			}
		}
	| VAR '=' STRING ';' { 
			int index = indexOf($1);
			if(index){
				if(varType[index]=='s'){
					strData[index] = $3;
					//printf("Assigned value of the string: %s\t\n",$3);
					// $$=$3;
				}
			}
		} 
	| FOR '(' NUM '<' NUM ',' NUM ')' START expression END {
			int i;
			for(i=$3 ; i<$5 ; i+=$7) {printf("iteration= %d expression value: %f\n", i,$10);}									
		}
	| FOR '(' NUM '>' NUM ',' NUM ')' START expression END {
			int i;
			for(i=$3 ; i>$5 ; i+=$7) {printf("iteration= %d expression value: %f\n", i,$10);}									
		}
	| FOR '(' NUM LE NUM ',' NUM ')' START expression END {
			int i;
			for(i=$3 ; i<=$5 ; i+=$7) {printf("iteration= %d expression value: %f\n", i,$10);}									
		}
	| FOR '(' NUM GE NUM ',' NUM ')' START expression END {
			int i;
			for(i=$3 ; i<=$5 ; i+=$7) {printf("iteration= %d expression value: %f\n", i,$10);}									
		}
	| SWITCH '(' expression ')' { switchVal = $3; switchOn = 1.0; }
	| switchBody

	| IF '(' expression ')' START expression ';' END %prec IFX {
			if($3){
				printf("\nvalue of expression in IF: %f\n",$6);
			}
			else{
				printf("condition value zero in IF block\n");
			}
		}
	| IF '(' expression ')' START expression ';' END ELSE START expression ';' END {
			if($3){
				printf("value of expression in IF: %f\n",$6);
			}
			else{
				printf("value of expression in ELSE: %f\n",$11);
			}
		}
	| SHOW '(' expression ')' ';' {
			printf("Showing value : %f\n",$3);
			$$ = $3;
		}
	| SHOW '(' STRING ')' ';' {
			printf("\n\n%s\n\n",$3);
		}
	| STRSHOW '(' VAR ')' ';' {
		int index = indexOf($3);
			if(index){
				if(varType[index]=='s') 
					printf("Showing value : %s\n",strData[index]);
				if(varType[index]=='c')
					printf("Showing value : %c\n",(int)realData[index]);
			}
		}
	;
switchBody	:	START switchBegin  END	{switchOn == 0.0;}
switchBegin   : switchCase
	| switchCase switchDefault
    ;
switchCase   : switchCase switchCase
	| CASE expression ':' expression ';' {
			//printf("ccc %f ",switchVal);
			if(switchOn == 1.0){
				if(switchVal == $2){
					printf("Value of this switch case is= %f",$4);
					switchDone = 1.0;
				}
			}
		}
	;
switchDefault   : DEFAULT ':' expression ';' {
			// printf("ddd %f ",switchVal);
			if(switchOn == 1.0){
				if(switchDone == 0.0){
					printf("Value of this switch case is= %f",$3);
				}
				switchVal = 0.0;
				switchDone = 0.0;
			}
		}
	;
declare : DEFREAL { numOfVar++; varList[numOfVar]=$1; varType[numOfVar]='r'; }
		| DEFSTRING { numOfVar++; varList[numOfVar]=$1; varType[numOfVar]='s'; }
		| DEFCHAR { numOfVar++; varList[numOfVar]=$1; varType[numOfVar]='c'; }
	;
expression: NUM			{ $$ = $1; 	}

	| REALNUM			{ $$ = $1; 	}

	| CHAR			{ $$ = $1; 	}

	| VAR	{ 
			int index = indexOf($1);
			if(index){
				if(varType[index]=='r'||varType[index]=='c') $$ = realData[index];
				if(varType[index]=='s') $$ = (float)index;
				//if(varType[index]=='r') $$ = realData[index];
				}
			}
	| expression '+' expression	{ $$ = $1 + $3; }
	| expression '-' expression	{ $$ = $1 - $3; }
	| expression '*' expression	{ $$ = $1 * $3; }
	| expression '/' expression	{ if($3){
				     					$$ = $1 / $3;
				  					}
				  					else{
										$$ = 0;
										printf("\ndivision by zero\t");
				  					} 	
				    			}
	| expression '%' expression	{ if($3){
				     					$$ = (int)$1 % (int)$3;
				  					}
				  					else{
										$$ = 0;
										printf("\nMOD by zero\t");
				  					} 	
				    			}
	| expression '^' expression	{ $$ = pow($1 , $3);}
	| expression '>' expression	{ $$ = $1 > $3; }
	| expression '<' expression	{ $$ = $1 < $3; }
	| expression GE expression	{ $$ =  $1 >= $3; }
	| expression LE expression	{ $$ =  $1 <= $3; }
	| expression EE expression	{ $$ =  $1 == $3; }
	| '(' expression ')'		{ $$ = $2;	}
	| SIN expression 			{$$=sin($2*3.1416/180);}
    | COS expression 			{$$=cos($2*3.1416/180);}
    | TAN expression 			{$$=tan($2*3.1416/180);}
    | LOG10 expression 			{$$=(log($2*1.0)/log(10.0));}
	| LOG expression 			{$$=(log($2));}
	| GCD '(' NUM ',' NUM ')'	{
				int i,x,y,gcd=1;
				x = (int)$3;
				y = (int)$5;
				if(x*y == 0){
					if(x!=0) gcd=x;
					else if(y!=0) gcd=y;
					else printf("[Error] GCD of 0 and 0 is undefined.\n");
				} else {
					int temp=y;
					while (y != 0)
					{
						temp = y;
						y = x % y;
						x = temp;
					}
					gcd=x;
				}
				$$ = (float)gcd;
		}
	| FACTORIAL '(' NUM ')' 	{
			int c,n,f=1;
			n = (int)$3;
			for (c = 1; c <= n; c++)f=f*c;
			$$ = (float)f;
		}
	;
%%

yyerror(char *s){
	printf( "%s\n", s);
}

int indexOf(char * candidate){
	if(numOfVar>=1){
		int i=1;
		for(i=1;i<=numOfVar;i++){
			if(strcmp(candidate,varList[i])==0) return i;
		}
	}
	return 0;
}
