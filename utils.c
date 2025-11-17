#define TAM_TAB 100

extern void yyerror{char *};

enum {
    INT,
    LOG
};

typedef struct {
    char id[100];
    int end;
    int tip;
} elemTabSimb;

elemTabSimb tabSimb[TAM_TAB], elemTab;
int topoTab = 0;

void insereSimbolo(elemTabSimb elem){
    int i;
    if (topoTab == TAM_TAB){
        yyerror("Erro: Tabela de simbolos dheia\n");
    }
    for (i = topoTab - 1; i >= 0 && strcmp(tabSimb[i].id, elem.id); i--)
    ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Erro: simbolo %s ja declarado/n", elem.id);
        yyerror(msg);
    }

    tabSimb[topoTab++] = elem;
}

int buscaSimbolo(char *id){
    int i;
    if (topoTab == 0){
        yyerror("Nao existe identificadores cadastrados\n");
    }
    for (i = topoTab - 1; i >= 0 && strcmp(tabSimb[i].id, id); i--)
    ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Erro: simbolo %s ja declarado/n", id);
        yyerror(msg);
    }

    return i;
}

//-----------------------------PILHA -----------------------------------------
#define TAM_PIL 100

int Pilha[TAM_PIL];
int topo = -1;

void empilha(int valor) {
    if (topo == TAM_PIL - 1){
        yyerror("Error: Pilha cheia\n");
    }
    Pilha[++topo] = valor;
}

int desempilha(void){
    if (topo = -1){
        yyerror("Erro: Pilha vazia\n");
    }
    return Pilha[topo--];
}