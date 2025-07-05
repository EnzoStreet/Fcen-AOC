extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
; r/rdi = void*    card ; Vale asumir que card siempre es al menos un card_t*
; r/rsi = char*    habilidad
invocar_habilidad:
	
	;prologo:
		push rbp
		mov rbp, rsp
		push r15
		push r14
		push r13
		push r12
		push rbx
		sub rsp, 8

		mov r13, rdi ;card/actual
		mov r12, rsi ;habilidad

	.while: ;se fija que actual no sea null

		xor rbx, rbx ; i = 0

		cmp r13, 0  ;actual !=? NULL
		je .epilogo ;si es null termino
		
		xor r14, r14
		mov r14w, word [r13 + FANTASTRUCO_ENTRIES_OFFSET] ;actual->entries

	.for:
		cmp rbx, r14 ;i<?actual->entries
		jae .subir_arquetipo

		mov r15, [r13 + FANTASTRUCO_DIR_OFFSET] ;actual->__dir
		mov r15, [r15 + rbx*8] ;actual->__dir[i]

		mov rdi, r15 ;entrada->ability_name??
		mov rsi, r12 ;habilidad
		call strcmp 

		cmp rax, 0
		je .encontrado ;strcmp(entrada->ability_name, habilidad) ==? 0
		
		inc rbx ;i++
		jmp .for

	.subir_arquetipo:
		mov r13, [r13 + FANTASTRUCO_ARCHETYPE_OFFSET] ;actual = (actual->__archetype);
		jmp .while

	.encontrado: 
		mov rdi, r13
		mov rax, [r15 + DIRENTRY_PTR_OFFSET] ;entrada->ability_ptr
		call rax ;funcion(actual)

	.epilogo:
		add rsp, 8
		pop rbx	
		pop r12
		pop r13
		pop r14
		pop r15
		pop rbp
		ret 
