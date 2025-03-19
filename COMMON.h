#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <libiberty/libiberty.h>


struct NODE* get_element(struct NODE*, char*);
void rehash();
void init_table();
int hashCode(char*);
int insert(int, char*, char*, char*, int, int, char*);
int find(char*);
void display();
char* isKeyword(char*);
void upper(char*);
void addKeywords();
char* itoa(int, int);

//structure for each symbol table entry
struct NODE{
    int scope;
    char name[64];
    char type[32];
    char attribute[32];
    int line;
    int charnum;
    char value[64];
    struct NODE* next;
};

//structure for each cell of Symbol Table
struct SymTabCell{
    struct NODE* head;
    struct NODE* tail;
};

struct SymTabCell* SymTable;

extern int presentSize ;
extern int maxSize;
extern float loadFactor;
extern int presentScope ;
extern int bracks;
extern int lineNum;
extern int charNum ;