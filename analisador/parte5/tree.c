/*---------------------------------------------------------------+
|   UNIFAL - Universidade Federal de Alfenas                     |
|   Bacharelado em Ciência da Computação                         |
|   Trabalho: Construcao Arvore Sintatica e Geracao de codigo    |
|   Disciplina: Teoria de Linguagens e Compiladores              |
|   Professor: Luiz Ediardo da Silva                             |
|   Aluna: João Pedro dos Santos Melo                            |
|   Data: 28/11/2025                                             |
+----------------------------------------------------------------*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


#define VAZA 0 // nada
#define PROG 1  // INPP variaveis lista comandos FIMP
#define LEIT 2 // LEIA ARZG
#define ESCR 3 // ESCR
#define REPT 4 // NADA expressao DSVF fim DSVS NADA
#define SELE 5 // expressao DSVF comandos DSVS NADA fim NADA
#define ATRI 6 // expressao ARZG
#define MULT 7 // MULT
#define DIVI 8 // DIVI
#define MAIS 9 // SOMA
#define MENO 10// SUBT
#define CMMA 11// CMMA
#define CMME 12// CMME
#define CMIG 13// CMIG
#define CONJ 14// CNJU
#define DISJ 15// DISJ
#define ARGZ 16// Armazena variavel
#define NUME 17// CRCT (numero)
#define NAO  18// NEGA
#define VARI 19// Declaracao de variaeis 
#define LVAR 20// lista de variaveis
#define LCOM 21// lista de comandos
#define COMD 22// Comando
#define IDEN 23// CRVG
#define LOGC 24// CRCT Logica



typedef struct no *ptno;

struct no {
    char *tipo;
    char *valor;
    int cod;
    ptno filho;
    ptno irmao;
};

ptno criaNo (const char *tipo_str, const char *valor_str, int c){
    ptno n = (ptno)malloc(sizeof(struct no));
    
    if (n == NULL) { return NULL; }

    // 1. Aloca memória exata para a string tipo e copia
    n->tipo = (char *)malloc(strlen(tipo_str) + 1);
    strcpy(n->tipo, tipo_str);

    // 2. Aloca memória exata para a string valor e copia
    n->valor = (char *)malloc(strlen(valor_str) + 1);
    strcpy(n->valor, valor_str);

    n->cod = c;
    n->filho = NULL;
    n->irmao = NULL;
    return n;
}

void adicionaFilho (ptno pai, ptno filho){
    if (filho){
        filho->irmao = pai->filho;
        pai->filho = filho;
    }
}

void mostra(ptno Raiz, int nivel){
    if (Raiz == NULL){
        printf("erro no mostra\n");
        return;
    }
    ptno p;
    for(int i = 0; i < nivel; i++)
        printf("\t");
    printf("[%s|%s]\n", Raiz->tipo, Raiz->valor);
    p = Raiz->filho;
    while (p){
        mostra(p, nivel + 1);
        p = p->irmao;
    }
}

void geraNos(FILE *f, ptno Raiz){
    if (Raiz == NULL){
        printf("erro no nos\n");
        return;
    }
    ptno p;
    fprintf(f, "\tn%p [label=\"%s|%s\"]\n", Raiz, Raiz->tipo, Raiz->valor);
    p = Raiz->filho;
    while(p){
        geraNos(f, p);
        p = p->irmao;
    }
}

void geraLigacoes(FILE *f,ptno Raiz){
    if (Raiz == NULL){
        printf("erro no ligacoes\n");
        return;
    }
    ptno p;
    p = Raiz->filho;
    while(p){
        fprintf(f, "\tn%p -> n%p\n", Raiz, p);
        geraLigacoes(f, p);
        p = p->irmao;
    }
}
void geraDot(ptno Raiz, char *fileNameBase){
    if (Raiz == NULL){
        printf("erro no FOT\n");
        return;
    }

    // FILE *f = fopen("tree.dot", "wt");
    // fprintf(f, "digraph {\n");
    // fprintf(f, "\tnode [ shape=record, height = .1] ;\n");
    // geraNos(f, Raiz);
    // geraLigacoes(f, Raiz);
    // fprintf(f, "}\n");
    // fclose(f);
    // system("dot -Tpng tree.dot -o tree.png");
    // //system("eog tree.png &");//nao ta funcionando, teste
    // exit(0);
    
    // **Construção Dinâmica dos Nomes de Arquivo**
    char dotFileName[256];
    char pngCommand[512];
    
    // Nome do arquivo DOT
    sprintf(dotFileName, "%s.dot", fileNameBase); 
    
    // Comando para gerar o PNG/SVG
    // Vou usar .png conforme seu código original, mas é fácil mudar para .svg
    sprintf(pngCommand, "dot -Tpng %s -o %s.png", dotFileName, fileNameBase);
    
    FILE *f = fopen(dotFileName, "wt"); // Usa o nome dinâmico
    fprintf(f, "digraph {\n");
    fprintf(f, "\tnode [ shape=record, height = .1] ;\n");
    geraNos(f, Raiz);
    geraLigacoes(f, Raiz);
    fprintf(f, "}\n");
    fclose(f);
    
    system(pngCommand); // Executa o comando com o nome dinâmico
    //exit(0);
}

extern int contaVar;
extern int tipo;
extern int rotulo;
extern FILE *yyin, *yyout;

void geraCod(ptno p){
    if (p == NULL) return;
    ptno p1, p2, p3;
    switch (p->cod){
        case 0:
        {
            break;
        }
        case 1:
        {
            p1 = p->filho;
            p2 = p1->irmao;
            p3 = p2->irmao;
            fprintf(yyout, "\tINPP\n");
            contaVar = 0;
            printf("filho 1: tipo(%s) valor(%s) cod(%d)\n",p1->tipo, p1->valor, p1->cod);
            printf("filho 2: tipo(%s) valor(%s) cod(%d)\n",p2->tipo, p2->valor, p2->cod);
            printf("filho 3: tipo(%s) valor(%s) cod(%d)\n",p3->tipo, p3->valor, p3->cod);
            geraCod(p2);
            fprintf(yyout, "\tAMEM\t%d\n", contaVar);
            geraCod(p3);
            fprintf(yyout, "\tDMEM\t%d\n", contaVar);
            fprintf(yyout, "\tFIMP\n");
            break;
        }
        case 2: // leitura
        {    
            printf("\nEntou no 2 --------------------------\n");
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            p1 = p->filho;
            int pos = buscaSimbolo(p1->valor);
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
            break;
        }
        case 3: // escrita
        {
            printf("\nEntou no 3 --------------------------\n");
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            p1 = p->filho;
            printf("filho1  : tipo(%s) valor(%s) cod(%d)\n",p1->tipo, p1->valor, p1->cod);
            //printf("filho2  : tipo(%s) valor(%s) cod(%d)\n",p2->tipo, p2->valor, p2->cod);
            //printf("filho3  : tipo(%s) valor(%s) cod(%d)\n",p3->tipo, p3->valor, p3->cod);
            geraCod(p1);
            int tipo = desempilha();
            fprintf(yyout, "\tESCR\n");
            break;
        }
        case 4: // repeticao
        {
            printf("\nEntou no 4 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            
            fprintf(yyout, "L%d\tNADA\n", ++rotulo);
            empilha(rotulo);
            
            geraCod(p1);
            int tip = desempilha();
            if(tip != LOG){
                yyerror("Expressao na selecao tem que ser logica!\n");
            }
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo);
            
            geraCod(p2);
            int y = desempilha();
            int x = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", x);
            fprintf(yyout, "L%d\tNADA\n", y);
            break;
        }
        case 5: // selecao
        {
            printf("\nEntou no 5 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            p3 = p2->irmao;
            
            geraCod(p1);
            int tip = desempilha();
            if(tip != LOG){
                yyerror("Expressao na selecao tem que ser logica!\n");
            }
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo);

            geraCod(p2);
            int x = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
            empilha(rotulo);
            fprintf(yyout, "L%d\tNADA\n", x);

            geraCod(p3);
            int y = desempilha();
            fprintf(yyout, "L%d\tNADA\n", y);
            break;
        }
        case 6: // atribuicao
        {
            printf("\nEntou no 6 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            int pos = buscaSimbolo(p1->valor);
            empilha(pos);

            geraCod(p2);
            int tip = desempilha();
            pos = desempilha();
            if (tip != tabSimb[pos].tip){
                yyerror("Incompatibilidade de tipos na atribuicao!\n");
            }
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end); 
            break;
        }
        case 7: // Multiplicação
        {
            printf("\nEntou no 7 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tMULT\n");
            break;
        }
        case 8: // Divisao
        {
            printf("\nEntou no 8 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tDIVI\n");
            break;
        }
        case 9: // Soma
        {
            printf("\nEntou no 9 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tSOMA\n");
            break;
        }
        case 10: // Subtracao
        {
            printf("\nEntou no 10 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tSUBT\n");
            break;
        }
        case 11: // Maior
        {
            printf("\nEntou no 11 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMMA\n");
            break;
        }
        case 12: // Menor
        {
            printf("\nEntou no 12 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMME\n");
            break;
        }
        case 13: // IGUAL
        {
            printf("\nEntou no 13 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMIG\n");
            break;
        }
        case 14: // E logico
        {
            printf("\nEntou no 14 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout, "\tCONJ\n");
            break;
        }
        case 15: // OU logico
        {
            printf("\nEntou no 15 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout, "\tDISJ\n");
            break;
        }
        case 16: // Armazena variaveis
        {
            printf("\nEntou no 16 --------------------------\n");
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            strcpy(elemTab.id, p->valor);
            elemTab.tip = atoi(p->tipo);
            elemTab.end = contaVar++;
            insereSimbolo(elemTab);
            break;
        }
        case 17: // Carrega Constante numerica
        {
            printf("\nEntou no 17 --------------------------\n");
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            fprintf(yyout, "\tCRCT\t%s\n", p->valor);
            empilha(INT);
            break;
        }
        case 18: // Negacao
        {
            printf("\nEntou no 18 --------------------------\n");
            p1 = p->filho;
            geraCod(p1);
            int tip = desempilha();
            if(tip != LOG){
                yyerror("Incompatibiliadade de tipo na negacao!\n");
            }
            empilha(LOG);
            fprintf(yyout, "\tNEGA\n");
            break;
        }
        case 19: // declaracao de variaveis
        {
            printf("\nEntou no 19 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            p3 = p2->irmao;
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            //printf("filho 1: tipo(%s) valor(%s) cod(%d)\n",p1->tipo, p1->valor, p1->cod);
            //printf("filho 2: tipo(%s) valor(%s) cod(%d)\n",p2->tipo, p2->valor, p2->cod);
            //printf("filho 3: tipo(%s) valor(%s) cod(%d)\n",p3->tipo, p3->valor, p3->cod);
            printf("declaracao de variaveis filho 1\n");
            geraCod(p1);
            printf("\nEntou no 19 --------------------------\n");
            printf("declaracao de variaveis filho 2\n");
            geraCod(p2);
            printf("\nEntou no 19 --------------------------\n");
            printf("declaracao de variaveis filho 3\n");
            geraCod(p3);
            printf("\nEntou no 19 --------------------------\n");
            
            break;
        }
        case 20: // lista variaveis
        {
            printf("\nEntou no 20 --------------------------\n");
            p1 = p->filho;
            p2 = p1->irmao;
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            printf("filho 1: tipo(%s) valor(%s) cod(%d)\n",p1->tipo, p1->valor, p1->cod);
            //printf("filho 2: tipo(%s) valor(%s) cod(%d)\n",p2->tipo, p2->valor, p2->cod);
            printf("lista de variaveis filho 1\n");
            geraCod(p2);
            printf("\nEntou no 20 --------------------------\n");
            printf("lista de variaveis filho 2\n");
            geraCod(p1);
            printf("\nEntou no 20 --------------------------\n");
            
            break;
        }
        case 21: // lista de comandos
        {
            printf("\nEntou no 21 --------------------------\n");
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            p1 = p->filho;
            p2 = p1->irmao;
            geraCod(p1);
            geraCod(p2);
            break;
        }
        case 22: // Comando
        {
            printf("\nEntou no 22 --------------------------\n");
            printf("Atual  : tipo(%s) valor(%s) cod(%d)\n",p->tipo, p->valor, p->cod);
            p1 = p->filho;
            geraCod(p1);
            break;
        }
        case 23: // Carrega variavel global
        {
            printf("\nEntou no 23 --------------------------\n");
            int pos = buscaSimbolo(p->valor);
            fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end);
            empilha(tabSimb[pos].tip);
            break;
        }
        case 24: // Carrega costante Logica
        {
            printf("\nEntou no 24 --------------------------\n");
            fprintf(yyout, "\tCRCT\t%s\n", p->valor);
            empilha(LOG);
            break;
        }
    }
}