%{
#include "sintatico.h"
#include <stdlib.h>

// Definições de Estrutura (Copiadas de tree.c)
typedef struct no *ptno;
struct no {
    char tipo;
    int valor;
    ptno filho;
    ptno irmao;
};

// Declaração do YYSTYPE
#define YYSTYPE ptno

// Declarações Externas para as funções (Implementação está no sintatico.c via include)
extern ptno criaNo (char tipo, int valor); 
extern void adicionaFilho (ptno pai, ptno filho);


char atomo[100];
void yyerror(char *);
   /*void msg(char *);
   int nLin = 1;*/
%}

identificador  [a-zA-Z]([a-zA-Z0-9])*
numero         [0-9]+
espaco         [ \t\r]+
novalinha      [\n]

%x coment

%%

programa    { return T_PROGRAMA; }
inicio      { return T_INICIO; }
fimprograma { return T_FIM; }

leia        { return T_LEIA; }
escreva     { return T_ESCREVA; }

se          { return T_SE; }
entao       { return T_ENTAO; }
senao       { return T_SENAO; }
fimse       { return T_FIMSE; }

enquanto    { return T_ENQTO; }
faca        { return T_FACA; }
fimenquanto { return T_FIMENQTO; }

"+"         { return T_MAIS; }
"-"         { return T_MENOS; }
"*"         { return T_VEZES; }
div         { return T_DIV; }

">"         { return T_MAIOR; }
"<"         { return T_MENOR; }
"="         { return T_IGUAL; }

e           { return T_E; }
ou          { return T_OU; }
nao         { return T_NAO; }

"<-"        { return T_ATRIB; }
"("         { return T_ABRE; }
")"         { return T_FECHA;}

inteiro     { return T_INTEIRO; }
logico      { return T_LOGICO; }
V           { return T_V; }
F           { return T_F; }


"//".*            /* nada */
"/*"              BEGIN(coment);
<coment>"*/"      BEGIN(INITIAL);
<coment>.	      /* nada */
<coment>\n        ++yylineno;

{identificador} {
   strcpy (atomo, yytext);
   return T_IDENTIF;
}
{numero}        {
   strcpy (atomo, yytext);
   yylval = criaNo('n', atoi(yytext));
   return T_NUMERO;
}
{espaco}        /* nao faz nada */
{novalinha}     ++yylineno;


.               msg("ERRO - SIMBOLO NAO RECONHECIDO!\n");

%%

int yywrap(void) { return 1; }

void msg (char *s) {
   printf("\n%d: %s\n\n", yylineno, s);
   exit(10);
}