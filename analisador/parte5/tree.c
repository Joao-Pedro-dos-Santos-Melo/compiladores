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
#define IDEN 16// CRVG
#define NUME 17// CRCT (numero V F)
#define NAO 18 // NEGA
#define VARI 19// AMEM



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
            break;
        case 1:
            p1 = p->filho;
            p2 = p1->irmao;
            p3 = p2->irmao;
            fprintf(yyout, "\tINPP\n");
            contaVar = 0;
            geraCod(p2);
            geraCod(p3);
            fprintf(yyout, "\tFIMP\n");
            break;
        case 2:
            p1 = p->filho;
            int pos = buscaSimbolo(p1->valor);
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
            break;
        case 3:
            int tipo = desempilha();
            fprintf(yyout, "\tESCR\n");
            break;
        
    }
}