#include <stdio.h>

// Объявляем внешние функции, генерируемые Flex и Bison
extern FILE *yyin;
extern int yyparse();


int main(int argc, char **argv) {
    // Проверяем, был ли передан файл как аргумент
    if (argc < 2) {
        printf("Использование: %s <файл>\n", argv[0]);
        return 1;
    }

    // Открываем файл для лексического анализа
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Не удалось открыть файл: %s\n", argv[1]);
        return 1;
    }

    // Запускаем синтаксический анализ
    yyparse();

    // Закрываем файл после завершения анализа
    fclose(yyin);

    return 0;
}
