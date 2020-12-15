%{
#include <string.h>
#include <stdio.h>
#include "syntaxe.h"


int lineNumber = 0;
char identif[25];
char value[250];
FILE *f;
%}


nbr [0-9]
identif [a-zA-Z_][0-9a-zA-Z_]*
text [A-Za-z0-9_,; \n\t\+\-]
lettre [A-Za-z]


%%


"{"					{ ECHO; fprintf(f,"%s",yytext); return START;		}
"}"					{ ECHO; fprintf(f,"%s\n",yytext); return END;			}
"("					{ ECHO;return PARS;		}
")"					{ ECHO;  return PARE;		}
"["					{ ECHO;  return BRAS;		}
"]"					{ ECHO;  return BRAE;		}
","					{ ECHO;  return COMMA;		}
";"					{ ECHO;   return ENDL;		}
"int"  				{ ECHO; fprintf(f,"%s ",yytext); return INTD; 		}
"float"  			{ ECHO; fprintf(f,"%s ",yytext); return FLOATD; 		}
"char"  			{ ECHO; fprintf(f,"%s ",yytext); return CHARD;		}
start               { ECHO;  return MAIN;		}
func                { ECHO; return FUNC;        }
({nbr}+|[-]{nbr}+)			{ ECHO;  strcpy(value,yytext); return INT; 		}
"-"?{nbr}+"."{nbr}+	{ ECHO; fprintf(f,"%s",yytext); strcpy(value,yytext); return FLOAT; 		}
"\""{text}+"\""   	{ ECHO; strncpy(value,yytext+1,strlen(yytext)-2); return STRING;		}
"'"{lettre}"'"  	{ ECHO; fprintf(f,"%s",yytext); value[0]=yytext[1]; return CHAR;		}
"+"      			{ ECHO; fprintf(f,"%s",yytext); return PLUS; 		}
"-"     			{ ECHO; fprintf(f,"%s",yytext); return MOIN; 		}
"*"    				{ ECHO; fprintf(f,"%s",yytext); return FOIS; 		}
"/"     			{ ECHO; fprintf(f,"%s",yytext); return SUR; 		}
"="					{ ECHO;  return AFFECT;		}
"!="    			{ ECHO; fprintf(f," %s ",yytext); return DIFF; 		}
">"	    			{ ECHO; fprintf(f," %s ",yytext); return SUP; 		}
"<"					{ ECHO; fprintf(f," %s ",yytext); return INF; 		}
"=="    			{ ECHO; fprintf(f," %s ",yytext); return EGAL; 		}
algo				{ ECHO; fprintf(f,"%s",yytext); return PROG;		}
for					{ ECHO; fprintf(f,"%s",yytext); return FOR; 		}
while   			{ ECHO; fprintf(f,"%s",yytext); return WHILE; 		}
if      			{ ECHO; fprintf(f,"%s",yytext); return IF; 			}
else    			{ ECHO; fprintf(f,"%s",yytext); return ELSE; 		}
return  			{ ECHO; fprintf(f,"%s",yytext); return RETURN; 		}
print				{ ECHO;  return PRINT;		}
scan				{ ECHO;  return SCAN;		}
{identif}			{ ECHO; strcpy(identif,yytext); return IDENTIF;		}
"/*"{text}+"*/" 	{ ECHO; fprintf(f,"%s",yytext); return COMMENT; 	}
"\n"				{ ECHO; fprintf(f,"%s",yytext); lineNumber++;}



%%
int yywrap(void) {
    return 1;
}