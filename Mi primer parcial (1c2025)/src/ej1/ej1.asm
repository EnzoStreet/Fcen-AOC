extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
; r/rdi = fantastruco_t*     card
init_fantastruco_dir:
	
	;prologo:
		push rbp
		mov rbp, rsp ;armo mi stack frame
		push r12 ;pusheo los no volatiles porq tengo un llamado a funcion y no quiero que se rompan los otros
		push r13 ;queda alineada

	;main:
		mov r12, rdi ;preservo el rdi, se me romperia desp de malloc
		mov r13, 2
		mov [r12 + FANTASTRUCO_ENTRIES_OFFSET], r13 ;card->__dir_entries = 2;
		
		mov rdi, 8 ;rdi = sizeof(directory_entry_t*)
		shl rdi, 1 ;rdi * 2
		call malloc ;malloc(sizeof(directory_entry_t*) * 2);
		;en rax quedo el puntero al directorio de habilidades
		mov [r12 + FANTASTRUCO_DIR_OFFSET], rax ;card->__dir = malloc;

		mov rdi, sleep_name
		mov rsi, sleep
		call create_dir_entry 

		mov r13, [r12 + FANTASTRUCO_DIR_OFFSET] ;r13=card->__dir 
		mov [r13], rax  ;card->__dir[0] = create-dir

		mov rdi, wakeup_name
		mov rsi, wakeup
		call create_dir_entry

		mov r13, [r12 + FANTASTRUCO_DIR_OFFSET ] ;r13=card->__dir 
		mov [r13 + 8], rax  ;card->__dir[1] = create-dir

	;epilogo:
		pop r13
		pop r12
		pop rbp
		ret 

; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
	;prologo:
		push rbp
		mov rbp, rsp ;armo mi stack frame
		push r12 ;pusheo los no volatiles porq tengo un llamado a funcion y no quiero que se rompan los otros
		push r13 

		mov rdi, FANTASTRUCO_SIZE
		call malloc 
		mov r12, rax ;me guardo una copia de la res

		mov r13, 0
		mov [r12 + FANTASTRUCO_ARCHETYPE_OFFSET], r13 ;card->__archetype = NULL;
		mov r13, 1
		mov byte [r12 + FANTASTRUCO_FACEUP_OFFSET], r13b;card->face_up = 1;

		mov rdi, r12 
		call init_fantastruco_dir

		mov rax, r12

	;epilogo:
		pop r13
		pop r12
		pop rbp
		ret 