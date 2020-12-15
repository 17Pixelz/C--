%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

extern FILE* yyin; //file pointer by default points to terminal
int yylex(void); // defini dans lexiqueL.c, utilise par yyparse()
void yyerror(const char * msg); // definie dans syntaxe.y, utilise parnotre code pour .
int lineNumber;
char identif[25];
char value[250];


typedef struct var var;
struct var 
{ 
	char	*identif;
	char	*value;
	int		type;
	var 	*adresse;
	int		origin;
	var *next; 
};

typedef struct func func;
struct func
{ 
	char	*identif;
	int		paramN;
	char	**param;
	func 	*adresse;
	func	*next; 
}; 


void yyerror( const char * msg){
	printf("\nline %d : %s\n", lineNumber, msg);
}

void createFunc(func** head, char *identif, int pN, char vars[][20]) 
{ 
    func* new_var = (func*) malloc(sizeof(func)); 
    new_var->identif  = (char*)malloc(sizeof(char)*strlen(identif));
	strcpy(new_var->identif,identif);
	new_var->paramN = pN;
	new_var->param = (char**)malloc(sizeof(char*)*pN);
	for (int i = 0; i < pN; i++){
		new_var->param[i] = (char*)malloc(sizeof(char)*strlen(vars[i]) + 1);
		strcpy(new_var->param[i],vars[i]);
	}
	new_var->adresse = new_var;
    new_var->next = (*head); 
    (*head)    = new_var; 
}

void	testReturn(int a, int b)
{
	if (a != b)
	{
		yyerror("returning the wrong type\n");
		exit(-7);
	}
}

int isDeclaredf(func* head, char *identif) 
{ 
    func* current = head;  
    while (current != NULL) 
    { 
        if (strcmp(current->identif,identif) == 0) 
            return -1;
        current = current->next; 
    } 
    return 0; 
} 

int		isToken(char *s,char t[][8]){
	int i;
	for(i=0;i<8;i++)
		if (strcmp(s,t[i]) == 0)
			return -1;
	return 0;
}




void		isUsablef(func* head,char *identif){
	if (isDeclaredf(head,identif) == 0)
	{
		yyerror("Using a non declared function\n");
		exit(-1);
	}
}

int			isParaEqual(func *node,char *s,int pN)
{
	while (node != NULL) 
  { 
     if (strcmp(node->identif,s) == 0)
	 {
		 if (node->paramN == pN)
			 return 0;
		 else
			 return -1;
	 }
     node = node->next; 
  } 
	return -1;
 }

void printFuncs(func *node) 
{ 
  while (node != NULL) 
  { 
     printf(" %s ", node->identif); 
     node = node->next; 
  } 
}

int		funcTest(char *s,func **head, int pN, char vars[][20], char t[][8]){
	if (isToken(s,t) == -1)
	{
		yyerror("Declaring a functions with a token name\n");
		exit(-1);
	}
	if (isDeclaredf(*head,s) == -1)
	{
		yyerror("Declaring two functions with the same name\n");
		exit(-2);
	}
	createFunc(head,s,pN,vars);
}



void createIdentif(var** head, char *identif, int type,int origin) 
{ 
    var* new_var = (var*) malloc(sizeof(var)); 
    new_var->identif  = (char*)malloc(sizeof(char)*strlen(identif));
	strcpy(new_var->identif,identif);
	new_var->value = NULL;
	new_var->adresse = new_var;
	new_var->type = type;
    new_var->next = (*head); 
	new_var->origin = origin;
    (*head)    = new_var; 
} 


int isDeclared(var* head, char *identif, int origin) 
{ 
    var* current = head;  
    while (current != NULL) 
    { 
        if (strcmp(current->identif,identif) == 0 && current->origin == origin) 
            return -1;
        current = current->next; 
    } 
    return 0; 
} 

void		isNotNull(var* head,char *identif)
{
	var* current = head;  
    while (current != NULL) 
    { 
        if (strcmp(current->identif,identif) == 0) 
            if (current->value == NULL)
			{
				yyerror("Using a non initialised variable\n");
				exit(-5);
			}
        current = current->next; 
    } 
}


void		isUsable(var* head,char *identif,int origin){
	if (isDeclared(head,identif,origin) == 0)
	{
		yyerror("Using a non declared variable\n");
		exit(-1);
	}
}

void printVars(var *node) 
{ 
  while (node != NULL) 
  { 
     printf(" %s ", node->value); 
     node = node->next; 
  } 
}

void initialiser(var *head, char *identif)
{
	var* current = head;  
    while (current != NULL) 
    { 
        if (strcmp(current->identif,identif) == 0) 
        {
		    current->value = (char*)malloc(sizeof(char)+1);
			strcpy(current->value,"1");
        }
		current = current->next; 
    } 
}


char *giveValue(var *head, char *identif)
{
	var* current = head;  
	
    while (current != NULL) 
    { 
        if (strcmp(current->identif,identif) == 0 && current->value != NULL) 
			return current->value;
		current = current->next; 
    } 
	yyerror("Using a non initialised variable\n");
	exit(-6);
}

int		identifTest(char *s,char t[][8],var **head, int type,int origin){
	if (isToken(s,t) == -1)
	{
		yyerror("Declaring a variable with a token name\n");
		exit(-1);
	}
	if (isDeclared(*head,s,origin	) == -1)
	{
		yyerror("Declaring two variables with the same name\n");
		exit(-2);
	}
	createIdentif(head,s,type,origin);
}



void freeVars(var* head)
{
   var* tmp;

   while (head != NULL)
    {
       tmp = head;
       head = head->next;
       free(tmp);
    }
	free(head);
}

void freeFuncs(func* head)
{
   func* tmp;

   while (head != NULL)
    {
       tmp = head;
       head = head->next;
       free(tmp);
    }
	free(head);
}





int return_type( var* head,char *indentif){
int type ;

var* current = head;  
    while (current != NULL) 
    { 
        if (strcmp(current->identif,identif) == 0) {
            
			type=current->type;
			
           }
		   
		   current = current->next;
    } 
	
	return type;


}



void affect_test( var* head,char *identif1, int type,char *autre){
  
  int autre_type=return_type(head,autre); 
  int mon_type;
var* current = head; 
		if(type==-1){   
		     
				while (current != NULL) 
				   { 
					if (strcmp(current->identif,identif1) == 0 ) {
						
						mon_type=current->type;
						if(mon_type != autre_type){yyerror("type error ");
							exit(-1);
						  }
						
					 }
					   
					   current = current->next;
			     } 
			
		}
		else {
				while (current != NULL) 
				   { 
					if (strcmp(current->identif,identif1) == 0 ) {
						
						mon_type=current->type;
						if(mon_type !=type){yyerror("type error");
							exit(-1);
						  }
						
					 }
					   
					   current = current->next;
			     } 
			
		
			
		}


}


























char autre[50];
char partie1[200],partie2[200];
char text[256];
int rang=0;char compa[256];
char identif1[100];
char lvalue[25];
char value[250];
int tp;
char tokens[8][8] = {"if","else","var","for","while","return","in","func"};
var *head = NULL;
func *fhead = NULL;
int type;
FILE *f;
char fname[40];
int pn=0;
char args[15][20];
int type_return = -1;
FILE *f;
char temp_identif[50];

%}

%token START END
%token IDENTIF
%token BRAS BRAE COMMA PARS PARE
%token INT FLOAT CHAR STRING
%token INTD FLOATD CHARD
%token PLUS MOIN FOIS SUR AFFECT
%token ENDL
%token DIFF SUP INF EGAL
%token FOR WHILE
%token IF ELSE
%token COMMENT
%token RETURN
%token PRINT
%token PROG MAIN
%token FUNC
%token SCAN


%left PLUS MOIN
%left FOIS SUR
%left NEG

%start program
%%

/*		outils		*/
type	:		
		INTD 	{type=0;}
	|	FLOATD	{type=1;}
	|	CHARD	{type=2;}
;
expr	:
		IDENTIF {fprintf(f,"%s",identif);type=-1;strcpy(autre,identif);} {if(type_return==-1){isUsable(head,identif,0);giveValue(head,identif);}else{isUsable(head,identif,1);}}
	|	INT { fprintf(f,"%s",value);type=0;}
	|	FLOAT {type=1;}
	|	CHAR {type=2;}
	|	STRING {type=3;}
;
comp 	: 		
		EGAL
	|	SUP
	|	INF 
	|	DIFF 
;
cond 	: 		
	expr comp expr
;
exprarith:
		expr
	| 	exprarith PLUS exprarith 
	| 	exprarith MOIN exprarith 
	| 	exprarith FOIS exprarith 
	| 	exprarith SUR exprarith 
	| 	MOIN exprarith %prec NEG 
	| 	PARS {  fprintf(f,"(");} exprarith PARE {fprintf(f,")");}
;
param	:		
		declarationparam COMMA {fprintf(f,",");strcpy(args[pn++],identif);} param
	|	declarationparam {strcpy(args[pn++],identif);}
	|
;
declarationparam	:		
		type IDENTIF { if(type_return==-1){identifTest(identif,tokens,&head,type,0);}else{identifTest(identif,tokens,&head,type,1);} fprintf(f,"%s",identif);}
	|	type IDENTIF  BRAS INT BRAE { fprintf(f,"%s [ %s]",identif,value);if(type_return==-1){identifTest(identif,tokens,&head,type,0);}else{identifTest(identif,tokens,&head,type,1);}}
;
passparam:	
		expr COMMA {fprintf(f,",");pn++;} passparam
	|	expr {pn++;}
;





expr2 : IDENTIF {  isUsable(head,identif,0);giveValue(head,identif); tp=return_type(head,identif);
		
		
		switch (tp){
			
				case 0 :strcat(partie1," %d ");
				break;
				
				case 1 :strcat(partie1," %f ");
				break;
			
				case 2 :strcat(partie1," %c ");
				break;
			
				case 3 :strcat(partie1," %s ");
				break;
			} 
			strcat(partie2,","); strcat(partie2,identif); }

| STRING {  strcat(partie1,value); strcat(partie1,"  ");}
			 			
;











/*		Debut du programme		*/
program	:
		PROG IDENTIF { strcat(identif,".c");f=fopen(identif,"w");fprintf(f,"#include <stdio.h>\n\n\n");} MAIN {fprintf(f,"void main()");} START listInstr END {freeVars(head);freeFuncs(fhead);fclose(f);}
	|	PROG IDENTIF {strcat(identif,".c");f=fopen(identif,"w");fprintf(f,"#include <stdio.h>\n\n\n");} functions MAIN {fprintf(f,"void main()");} START listInstr END {freeVars(head);freeFuncs(fhead);fclose(f);}
;

functions	:		
		functions FUNC type {type_return=type;} IDENTIF {fprintf(f,"%s",identif);} {strcpy(fname,identif);} PARS {  fprintf(f,"(");}param PARE {fprintf(f,")");}{funcTest(fname,&fhead,pn,args,tokens);pn=0;} START listInstr END 
	|	FUNC type {type_return=type;} IDENTIF {fprintf(f,"%s",identif);} {strcpy(fname,identif);} PARS {  fprintf(f,"(");} param PARE {fprintf(f,")");} {funcTest(fname,&fhead,pn,args,tokens);pn=0} START listInstr END
;



/*		la structure generale du programme		*/
listInstr:		
		listInstr instr
	|	instr
;


/*		l'ensemble des instructions du programme		*/
instr 	:		
		declaration ENDL {fprintf(f,";");}
	|	affectation	ENDL {initialiser(head,lvalue);fprintf(f,";");}
	|	boucle
	|	ifelse
	|	commentaire
	|	returnit {testReturn(type,type_return);type_return=-1;}
	|	callfunction
	|  {fprintf(f,"\tprintf( ");} PRINT PARS   printf  { strcat(partie1,"\""); fprintf(f," \"%s %s ",partie1,partie2);fprintf(f,");\n"); strcpy(partie1," ");strcpy(partie2," ");} PARE  ENDL  
	
	|  SCAN PARS IDENTIF {  isUsable(head,identif,0); fprintf(f,"scanf(\" ");} PARE ENDL    {tp=return_type(head,identif);
		
		
		switch (tp){
			
				case 0 : strcpy(temp_identif,"%d");fprintf(f," %s \", %s) ;",temp_identif,identif);
				break;
				
				case 1 :strcpy(temp_identif,"%f");fprintf(f," %s \", %s); ",temp_identif,identif);
				break;
			
				case 2 :strcpy(temp_identif,"%c");fprintf(f," %s \", %s) ;",temp_identif,identif);
				break;
			
				case 3 :strcpy(temp_identif,"%s");fprintf(f," %s \", %s); ",temp_identif,identif);
				break;
			} 
		}
	
;


/*		la declaration des variables		*/
declaration	:		
		type identifiants
	|	type	tableaus
;
identifiants:		
		IDENTIF {if(type_return==-1){identifTest(identif,tokens,&head,type,0);}else{identifTest(identif,tokens,&head,type,1);} fprintf(f,"%s",identif);}
	|	IDENTIF COMMA { fprintf(f,"%s ,",identif); if(type_return==-1){identifTest(identif,tokens,&head,type,0);}else{identifTest(identif,tokens,&head,type,1);}}  identifiants
;
tableaus	:		
		IDENTIF  BRAS INT BRAE { fprintf(f,"%s [%s] ",identif,value); if(type_return==-1){identifTest(identif,tokens,&head,type,0);}else{identifTest(identif,tokens,&head,type,1);}}
	|	IDENTIF  BRAS INT BRAE COMMA { fprintf(f,"%s [%s] , ",identif,value);if(type_return==-1){identifTest(identif,tokens,&head,type,0);}else{identifTest(identif,tokens,&head,type,1);}} tableaus
;



/*		l'affectation des valeurs a les variables		*/
affectation	:		
		IDENTIF {fprintf(f,"%s",identif); strcpy(identif1,identif);} AFFECT  {fprintf(f,"=");strcpy(lvalue,identif);} exprarith  { affect_test(head,identif1,type,autre);   }
	|	IDENTIF {  strcpy(lvalue,identif);} BRAS INT BRAE AFFECT {fprintf(f,"%s [ %s ] =",identif,value);} exprarith	
;

/*		Les boucles		*/
boucle		:		
		FOR PARS {  fprintf(f,"(");} IDENTIF {fprintf(f,"%s",identif);} ENDL {fprintf(f,";");} cond ENDL {fprintf(f,";");} affectation PARE {fprintf(f,")");} START listInstr END
	|	WHILE PARS {  fprintf(f,"(");} cond PARE { fprintf(f,")");}START listInstr END
;



/*		ifelse			*/
ifelse		:		
		if
	|	if ELSE START listInstr END
;

if			:
		IF PARS {  fprintf(f,"(");}cond PARE {fprintf(f,")");} START listInstr END
;


/*		commentaire		*/
commentaire	:		
		COMMENT
;

/*		return			*/
returnit		:		
		RETURN expr ENDL {fprintf(f,";");}
;


/*		l'appelle du fonction		*/
callfunction:
		IDENTIF  PARS  {fprintf(f,"%s (",identif);strcpy(fname,identif);isUsablef(fhead,fname);} passparam {isParaEqual(fhead,fname,pn);pn=0;} PARE   {fprintf(f,");");} ENDL;

	


printf: expr2  COMMA printf 

| expr2 

;


%%

int main(int argc,char ** argv){

if(argc>1) yyin=fopen(argv[1],"r"); // v�rifier r�sultat !!!
lineNumber=1;
if(!yyparse())
	printf("Expression correct\n");

return(0);

}