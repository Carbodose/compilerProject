%{
	#include<stdio.h>
	#include<ctype.h>
	#include<string.h>
	#include<time.h>
	#include<stdlib.h>
	#include "carbo1607020.tab.h"
	
	char *p;
	char *q;
%}

alpha [a-zA-Z]
digit [0-9]
alphanum [a-zA-Z0-9_:,-]
header					"connect"[ ]*+[^\n]+[.h][ ]*
ws						[ \n\t]*
singleLineComment		[ ]*[/][/].*
multiLineComment		[ ]*[/][#](.|\n)*[#][/]	
dataType				"INTG"|"REAL"
%%

{header}  		{}
SWITCH			{ return SWITCH; }
SHOW			{ return SHOW; }
STRSHOW			{ return STRSHOW; }
CASE			{ return CASE;  } 
IF				{ return IF;   }
ELSE			{ return ELSE; }
DEFAULT			{ return DEFAULT; }
"{{"			{ return START;  }
"}}"			{ return END;	}
FOR				{ return FOR;}
SIN				{ return SIN;}
COS				{ return COS;}
TAN				{ return TAN;}
LOG				{ return LOG;}
LOG10			{ return LOG10;}
GCD				{ return GCD;}
FACTORIAL		{ return FACTORIAL;}


[>][=]				{return GE;}
[<][=]				{return LE;}
[=][=]				{return EE;}
[-+/*<>=,():;%^]     {yylval.ival = yytext[0];	return *yytext;	}
"main"	   { return MAIN; }
{digit}+			{ yylval.fval = (float)atoi(yytext); return NUM; }
{digit}*[.]{digit}+	{ yylval.fval = atof(yytext); return REALNUM; }
[']{alphanum}[']	{yylval.fval = (float)yytext[1];	return CHAR;}

["]{alphanum}*["] 	{	p=(char *)calloc(strlen(yytext)-1,sizeof(char));
                	strcpy(p,&yytext[0]);
                	yylval.text=p;
					return STRING; }

"REAL"[ ]{alpha}+	{
						p=(char *)calloc(strlen(yytext)-4,sizeof(char));
						strcpy(p,&yytext[5]);
						yylval.text=p;
						//printf("%s\n",p);
						return DEFREAL;
					}

"STRING"[ ]{alpha}+ 	{
							p=(char *)calloc(strlen(yytext)-6,sizeof(char));
							strcpy(p,&yytext[7]);
							yylval.text=p;
							//printf("**insidelexdecl %s **\n",p);
							return DEFSTRING;
						}
"CHAR"[ ]{alpha}+ 	{
						p=(char *)calloc(strlen(yytext)-4,sizeof(char));
						strcpy(p,&yytext[5]);
						yylval.text=p;
						return DEFCHAR;
					}

{alpha}+  			{	p=(char *)calloc(strlen(yytext)+1,sizeof(char));
					strcpy(p,&yytext[0]);
					yylval.text=p;
					//printf("**insidelex call %s **\n",p);
					return VAR; }
					
{singleLineComment}		{}
{multiLineComment}		{}
[ ]*	    			{}
[\n]*					{}
[\t]*					{}
.						{printf("%s --> invalid\n",yytext);}


%%
int yywrap()
{
	return 1;
}

int main()
{
	//freopen("inCarbo.txt","r",stdin);
	freopen("tempCarbo.txt","r",stdin);
	freopen("outCarbo.txt","w",stdout);
	yyparse();
    
	return 0;
}