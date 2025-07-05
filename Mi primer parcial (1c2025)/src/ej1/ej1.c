#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C

void init_fantastruco_dir(fantastruco_t* card) {
    // 2 habilidades: sleep y wakeup
    card->__dir_entries = 2;

    // reservamos espacio para el directorio (2 punteros a directory_entry_t)
    card->__dir = malloc(sizeof(directory_entry_t*) * 2);

    // Creamos las entradas
    card->__dir[0] = create_dir_entry("sleep", sleep);
    card->__dir[1] = create_dir_entry("wakeup", wakeup);
   

}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
// fantastruco_t* summon_fantastruco() {

// }

fantastruco_t* summon_fantastruco() {
    // Reservamos memoria
    fantastruco_t* card = malloc(sizeof(fantastruco_t));
    
    // Inicializamos atributos
    card->__archetype = NULL;
    card->face_up = 1;

    // Inicializamos el directorio de habilidades
    init_fantastruco_dir(card);

    return card;
}