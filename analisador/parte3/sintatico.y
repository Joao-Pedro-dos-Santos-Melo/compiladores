%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void msg (char *);
int yyerror (char *);
int yylex ();
extern char atomo[100];
extern FILE *yyin;
extern FILE *yyout;
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO

%start programa

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho
        { fprintf(yyout, "\tINPP\n"); } 
    variaveis 
        { fprintf(yyout, "\tAMEM\tX\n"); }
    T_INICIO lista_comandos T_FIM
        { 
            fprintf(yyout, "\tDMEM\tX\n");
            fprintf(yyout, "\tFIMP\n"); 
        }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
    ;

variaveis
    : /* vario */
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_LOGICO
    | T_INTEIRO
    ;

lista_variaveis
    : T_IDENTIF lista_variaveis
    | T_IDENTIF
    ;

lista_comandos
    : /* vazio */
    | comando lista_comandos
    ;

comando
    : leitura
    | escrita
    | repeticao
    | selecao
    | atribuicao
    ;

leitura
    : T_LEIA T_IDENTIF
         {
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\tX\n");
         }
    ;

escrita
    : T_ESCREVA expressao
         {
            fprintf(yyout, "\tESCR\n");
         }
    ;

repeticao
    : T_ENQTO
         { fprintf(yyout, "Lx\tNADA\n"); }
     expressao T_FACA
         { fprintf(yyout, "\tDSVF\tLy\n"); }
     lista_comandos T_FIMENQTO
         {
            fprintf(yyout, "\tDSVS\tLx\n");
            fprintf(yyout, "Ly\tNADA\n");
         }
    ;

selecao
    : T_SE expressao T_ENTAO
         { fprintf(yyout, "\tDSVF\tLx\n"); }
     lista_comandos T_SENAO
         { 
            fprintf(yyout, "\tDSVS\tLy\n");
            fprintf(yyout, "Lx\tNADA\n"); 
         }
     lista_comandos T_FIMSE
         { fprintf(yyout, "Ly\tNADA\n"); }
    ;

atribuicao
    : T_IDENTIF T_ATRIB expressao
         { fprintf(yyout, "\tARZG\tX\n"); }
    ;

expressao
    : expressao T_VEZES expressao
         { fprintf(yyout, "\tMULT\n"); }
    | expressao T_DIV expressao
         { fprintf(yyout, "\tDIVI\n"); }
    | expressao T_MAIS expressao
         { fprintf(yyout, "\tSOMA\n"); }
    | expressao T_MENOS expressao
         { fprintf(yyout, "\tSUBT\n"); }
    | expressao T_MAIOR expressao
         { fprintf(yyout, "\tCMMA\n"); }
    | expressao T_MENOR expressao
         { fprintf(yyout, "\tCMME\n"); }
    | expressao T_IGUAL expressao
         { fprintf(yyout, "\tCMIG\n"); }
    | expressao T_E expressao
         { fprintf(yyout, "\tCONJ\n"); }
    | expressao T_OU expressao
         { fprintf(yyout, "\tDISJ\n"); }
    | termo
    ;

termo
    : T_IDENTIF
         { fprintf(yyout, "\tCRVG\tX\n"); }
    | T_NUMERO
         { fprintf(yyout, "\tCRCT\t%s\n", atomo); }
    | T_V
         { fprintf(yyout, "\tCRCT\t1\n"); }
    | T_F
         { fprintf(yyout, "\tCRCT\t0\n"); }
    | T_NAO termo
         { fprintf(yyout, "\tNEGA\n"); }
    | T_ABRE expressao T_FECHA
    ;
%%

int yyerror(char *s){
    msg(s);
}

int main (int argc, char *argv[]){
    
    char nameIn[30], nameOut[30], *p;
    if (argc < 2){
        printf("Uso:\n\t%s <nomefonte>[.simples]\n\n", argv[0]);
        return 10;
    }
    p = strstr(argv[1], ".simples");
    if (p){
        p = 0;
    }
    strcpy(nameIn, argv[1]);
    strcpy(nameOut, argv[1]);
    strcat(nameIn, ".simples");
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    yyout = fopen(nameOut, "wt");

    yyparse();
    printf("programa Ok!\n");
}