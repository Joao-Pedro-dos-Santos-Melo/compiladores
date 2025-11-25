%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.c"
#include "tree.c"

/*void msg (char *);
int yyerror (char *);
int yylex ();
extern char atomo[100];
extern FILE *yyin;
extern FILE *yyout;*/

extern void yyerror(char *);
extern int yylex();
extern char atomo[100];
extern FILE *yyin, *yyout;

int contaVar = 0;
int tipo;
int rotulo = 0;
ptno Raiz;
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
        { 
            fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
            empilha(contaVar);
        }
    T_INICIO lista_comandos T_FIM
        { 
            Raiz = $4;

            int conta = desempilha();
            fprintf(yyout, "\tDMEM\t%d\n", conta);
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
    : T_LOGICO { tipo = LOG; }
    | T_INTEIRO { tipo = INT; }
    ;

lista_variaveis
    : lista_variaveis
        T_IDENTIF
        {
            strcpy(elemTab.id, atomo);
            elemTab.tip = tipo;
            elemTab.end = contaVar++;
            insereSimbolo(elemTab);
        }
        | T_IDENTIF
        {
            strcpy(elemTab.id, atomo);
            elemTab.tip = tipo;
            elemTab.end = contaVar++;
            insereSimbolo(elemTab);
        }
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
            int pos = buscaSimbolo(atomo);
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
         }
    ;

escrita
    : T_ESCREVA expressao
         {
            int tipo = desempilha();
            fprintf(yyout, "\tESCR\n");
         }
    ;

repeticao
    : T_ENQTO
         { 
            fprintf(yyout, "L%d\tNADA\n", ++rotulo);
            empilha(rotulo);
         }
     expressao T_FACA
         { 
            int tip = desempilha();
            if(tip != LOG){
                yyerror("Expressao na selecao tem que ser logica!\n");
            }
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo);
         }
     lista_comandos T_FIMENQTO
         {
            int y = desempilha();
            int x = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", x);
            fprintf(yyout, "L%d\tNADA\n", y);
         }
    ;

selecao
    : T_SE expressao T_ENTAO
         { 
            int tip = desempilha();
            if(tip != LOG){
                yyerror("Expressao na selecao tem que ser logica!\n");
            }
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo);
         }
     lista_comandos T_SENAO
         { 
            int x = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
            empilha(rotulo);
            fprintf(yyout, "L%d\tNADA\n", x); 
         }
     lista_comandos T_FIMSE
         { 
            int y = desempilha();
            fprintf(yyout, "L%d\tNADA\n", y);
         }
    ;

atribuicao
    : T_IDENTIF
    {
        ptno no_id = criaNo('i', 0); // Nó para o Identificador
        $$ = no_id;

        int pos = buscaSimbolo(atomo);
        empilha(pos);
    } 
     T_ATRIB expressao
    { 
        ptno n = criaNo('=', 0);
        adicionaFilho(n, $1); 
        adicionaFilho(n, $3); 
        $$ = n;

        int tip = desempilha();
        int pos = desempilha();
        if (tip != tabSimb[pos].tip){
            yyerror("Incompatibilidade de tipos na atribuicao!\n");
        }
        fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end); 
    }
    ;

expressao
    : expressao T_VEZES expressao
         { 
            ptno n = criaNo('*', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tMULT\n"); 
         }
    | expressao T_DIV expressao
         { 
            ptno n = criaNo('/', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tDIVI\n"); 
         }
    | expressao T_MAIS expressao
         { 
            ptno n = criaNo('+', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tSOMA\n"); 
         }
    | expressao T_MENOS expressao
         { 
            ptno n = criaNo('-', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tSUBT\n");
         }
    | expressao T_MAIOR expressao
         { 
            ptno n = criaNo('>', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMMA\n");
         }
    | expressao T_MENOR expressao
         { 
            ptno n = criaNo('<', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMME\n");
         }
    | expressao T_IGUAL expressao
         { 
            ptno n = criaNo('=', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMIG\n");
         }
    | expressao T_E expressao
         { 
            ptno n = criaNo('&', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout, "\tCONJ\n"); 
         }
    | expressao T_OU expressao
         { 
            ptno n = criaNo('OU', 0);
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout, "\tDISJ\n");
         }
    | termo
    ;

termo
    : T_IDENTIF
         { 
            $$ = criaNo('id', 0);
            int pos = buscaSimbolo(atomo);
            fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end);
            empilha(tabSimb[pos].tip);
         }
    | T_NUMERO
         { 
            $$ = criaNo('n', atoi(atomo));
            fprintf(yyout, "\tCRCT\t%s\n", atomo);
            empilha(INT);
         }
    | T_V
         { 
            $$ = criaNo('V', atoi(atomo));
            fprintf(yyout, "\tCRCT\t1\n");
            empilha(LOG);
         }
    | T_F
         { 
            $$ = criaNo('F', atoi(atomo));
            fprintf(yyout, "\tCRCT\t0\n"); 
            empilha(LOG);
        }
    | T_NAO termo
         { 
            $$ = criaNo('NAO', atoi(atomo));
            int tip = desempilha();
            if(tip != LOG){
                yyerror("Incompatibiliadade de tipo na negacao!\n");
            }
            empilha(LOG);
            fprintf(yyout, "\tNEGA\n");
         }
    | T_ABRE expressao T_FECHA
    ;
%%

void yyerror(char *s){
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
        *p = 0;
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