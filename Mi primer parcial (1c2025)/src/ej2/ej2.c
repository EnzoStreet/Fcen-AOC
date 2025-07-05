#include "ej2.h"

#include <string.h>


void invocar_habilidad(void* carta, char* habilidad) {
    card_t* actual = (card_t*) carta;

    while (actual != NULL) {
        for (int i = 0; i < actual->__dir_entries; i++) {
            directory_entry_t* entrada = actual->__dir[i];
            if (strcmp(entrada->ability_name, habilidad) == 0) {
                ability_function_t* funcion = (ability_function_t*)(entrada->ability_ptr);
                funcion(actual); // ejecutar con el puntero donde se encontró
                return;
            }
        }
        // No encontrada, avanzar al arquetipo
        actual = (card_t*)(actual->__archetype);
    }

    // No se encontró: no se hace nada
}
