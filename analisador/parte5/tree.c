#include <stdlib.h>
#include <stdio.h>
#include <string.h>
typedef struct no *ptno;

struct no {
    char *tipo;
    char *valor;
    ptno filho;
    ptno irmao;
};

ptno criaNo (const char *tipo_str, const char *valor_str){
    ptno n = (ptno)malloc(sizeof(struct no));
    
    if (n == NULL) { return NULL; }

    // 1. Aloca memória exata para a string tipo e copia
    n->tipo = (char *)malloc(strlen(tipo_str) + 1);
    strcpy(n->tipo, tipo_str);

    // 2. Aloca memória exata para a string valor e copia
    n->valor = (char *)malloc(strlen(valor_str) + 1);
    strcpy(n->valor, valor_str);

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
void geraDot(ptno Raiz){
    if (Raiz == NULL){
        printf("erro no FOT\n");
        return;
    }
    FILE *f = fopen("tree.dot", "wt");
    fprintf(f, "digraph {\n");
    fprintf(f, "\tnode [ shape=record, height = .1] ;\n");
    geraNos(f, Raiz);
    geraLigacoes(f, Raiz);
    fprintf(f, "}\n");
    fclose(f);
    system("dot -Tpng tree.dot -o tree.png");
    //system("eog tree.png &");//nao ta funcionando, teste
    exit(0);
}