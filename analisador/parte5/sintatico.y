%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.c"
#include "tree.c"

#define YYSTYPE ptno

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
    variaveis 
    T_INICIO lista_comandos T_FIM
        { 
            ptno n = criaNo("Programa", "");
            adicionaFilho(n, $4);
            adicionaFilho(n, $2);
            adicionaFilho(n, $1);
            Raiz = n;
            geraDot(Raiz);
        }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
    {
        ptno n = criaNo("Identificador", atomo);
        $$ = n;
    }
    ;

variaveis
    : /* vario */{ $$ = NULL; }
    | declaracao_variaveis
    {
        ptno n = criaNo("Declaracao de Variaveis", "");
        adicionaFilho(n, $1);
        $$ = $1;
    }
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    {
        ptno n = criaNo("Declaracao de Variaveis", "");
        adicionaFilho(n, $3);
        adicionaFilho(n, $2);
        adicionaFilho(n, $1);
        $$ = n;
    }
    | tipo lista_variaveis
    {
        ptno n = criaNo("Declaracao de Variaveis", "");
        adicionaFilho(n, $2);
        adicionaFilho(n, $1);
        $$ = n;
    }
    ;

tipo
    : T_LOGICO { $$ = criaNo("Tipo", "Logico"); }
    | T_INTEIRO { $$ = criaNo("Tipo", "Inteiro"); }
    ;

lista_variaveis
    : lista_variaveis T_IDENTIF
        {
            ptno n = $1;
            ptno y = criaNo("Lista Variaveis", "");
            ptno x = criaNo("Identificador", atomo);
            adicionaFilho(y, n);
            adicionaFilho(y, x);
            $$ = y;
        }
        | T_IDENTIF
        {
            ptno n = criaNo("Lista Variaveis", "");
            ptno x = criaNo("Identificador", atomo);
            adicionaFilho(n, x);
            $$ = n;
        }
    ;

lista_comandos
    : /* vazio */ { $$ = NULL; }
    | comando lista_comandos
    {
        ptno n = criaNo("Lista Comandos", "");
        adicionaFilho(n, $2);
        adicionaFilho(n, $1);
        $$ = n;
    }
    ;

comando
    : leitura { $$ = $1; }
    | escrita { $$ = $1; }
    | repeticao { $$ = $1; }
    | selecao { $$ = $1; }
    | atribuicao { $$ = $1; }
    ;

leitura
    : T_LEIA T_IDENTIF
         {
            ptno nid = criaNo("Identificador", atomo);
            ptno n = criaNo("Leitura", "");
            adicionaFilho(n, nid);
            $$ = n;
         }
    ;

escrita
    : T_ESCREVA expressao
         {
            ptno n = criaNo("Escrita", "");
            adicionaFilho(n, $2);
            $$ = n;
         }
    ;

repeticao
    : T_ENQTO expressao T_FACA lista_comandos T_FIMENQTO
         {
            ptno n = criaNo("Repeticao", ""); // Nó de While
            adicionaFilho(n, $4);    // Filhos: 1) Lista de Comandos
            adicionaFilho(n, $2);    //         2) Expressão Condicional
            $$ = n;
         }
    ;

selecao
    : T_SE expressao T_ENTAO lista_comandos T_SENAO lista_comandos T_FIMSE
         { 
            ptno n = criaNo("Selecao", "");
            adicionaFilho(n, $6); // 3º filho (Else)
            adicionaFilho(n, $4); // 2º filho (Then)
            adicionaFilho(n, $2); // 1º filho (Condição)
            $$ = n;
         }
    ;

atribuicao
    : identificador_no T_ATRIB expressao
    { 
        ptno n = criaNo("Atribuicao", "");
        //ptno n2 = $1;
        adicionaFilho(n, $3); 
        adicionaFilho(n, $1); 
        $$ = n;

    }
    ;

identificador_no
    : T_IDENTIF{
        $$ = criaNo("Identificador", atomo);
    };

expressao
    : expressao T_VEZES expressao
         { 
            ptno n = criaNo("Multiplicao", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_DIV expressao
         { 
            ptno n = criaNo("Divisao", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_MAIS expressao
         { 
            ptno n = criaNo("Soma", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_MENOS expressao
         { 
            ptno n = criaNo("Subtracao", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_MAIOR expressao
         { 
            ptno n = criaNo("Maior", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_MENOR expressao
         { 
            ptno n = criaNo("Menor", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_IGUAL expressao
         { 
            ptno n = criaNo("Igual", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_E expressao
         { 
            ptno n = criaNo("&", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | expressao T_OU expressao
         { 
            ptno n = criaNo("OU", "");
            adicionaFilho(n, $3);
            adicionaFilho(n, $1);
            $$ = n;
         }
    | termo {$$ = $1; }
    ;

termo
    : T_IDENTIF
         { 
            // 1. Cria o nó para o Identificador
            ptno n = criaNo("Identificador", atomo);
            $$ = n; // Propaga o nó para o próximo nível
         }
    | T_NUMERO
         { 
            // 1. Cria o nó para o literal numérico
            ptno n = criaNo("Identificador", atomo); 
            $$ = n; // Propaga o nó para o próximo nível
         }
    | T_V
         { 
            $$ = criaNo("V", "");
         }
    | T_F
         { 
            $$ = criaNo("F", "");
        }
    | T_NAO termo
         { 
            ptno n = criaNo("NAO", "");
            adicionaFilho(n, $2);
            $$ = n;
         }
    | T_ABRE expressao T_FECHA
    {
        $$ = $2; // Propaga o nó da expressão interna
    }
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