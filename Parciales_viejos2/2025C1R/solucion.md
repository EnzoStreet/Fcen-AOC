# Modificación de estructuras:

## sched.c:

```c
#define MAX_SHARED_PAGES 1024

typedef enum {
  TASK_SLOT_FREE,
  TASK_RUNNABLE,
  TASK_PAUSED,
  TASK_BUSCANDO_PAREJA,
  TASK_CORTANDO_PAREJA
} task_state_t;

typedef struct {
  int16_t selector;
  task_state_t state;

  bool lider = false;
  uint8_t pareja = NULL;

  vaddr_t shared[MAX_SHARED_PAGES];   // Array de direcciones virtuales solicitadas
  uint8_t shared_count = 0;
} sched_entry_t;

```

## tss.c:

```c
uint32_t task_selector_to_cr3(uint16_t selector){
    uint16_t index = selector >> 3; //Sacamos atributos
    gdt_entry_t* taskDescriptor = &gdt[index]; //Indexamos en la GDT
    tss_t* tss = (tss_t*) ((taskDescriptor->base_15_0) |
                            (taskDescriptor->base_23_16 << 16) |
                            (taskDescriptor->base_31_24 << 24));
    return tss->cr3;
}
```

## mmu.c:

```c
#define ON_DEMAND_MEM_START_VIRT_PAREJAS 0xC0C00000

static paddr_t next_free_copule_page = AREA_LIBRE_TAREAS;

paddr_t mmu_next_free_copule_page() {
    paddr_t current_page = next_free_copule_page;
    next_free_copule_page += PAGE_SIZE;
    return current_page;
}

bool page_fault_handler(vaddr_t virt) {
    print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);

    if(ON_DEMAND_MEM_START_VIRTUAL <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL){
        uint32_t cr3 = rcr3();
        mmu_map_page(cr3,virt,0x3000000,MMU_P|MMU_U|MMU_W);
        return true;
    }

    if(ON_DEMAND_MEM_START_VIRT_PAREJAS <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL){
        paddr_t phys = mmu_next_free_copule_page();
        zero_page(phys);
        uint32_t cr3 = rcr3();

        uint8_t pareja = sched_tasks[current_task].pareja;
        uint16_t selector_pareja = sched_tasks[pareja].selector;
        uint32_t cr3_pareja = task_selector_to_cr3(selector_pareja);

        if (es_lider(current_task)) {
            mmu_map_page(cr3, virt, phys, MMU_P | MMU_U | MMU_W);
            mmu_map_page(cr3_pareja, virt, phys, MMU_P | MMU_U);
        } 

        else {
            mmu_map_page(cr3, virt, phys, MMU_P | MMU_U);
            mmu_map_page(cr3_pareja, virt, phys, MMU_P | MMU_U | MMU_W);
        }

        uint8_t count = sched_tasks[current_task].shared_count;
        sched_tasks[current_task].shared[count] = virt;
        sched_tasks[current_task].count++;

        uint8_t count_pareja = sched_tasks[pareja].shared_count;
        sched_tasks[pareja].shared[count_pareja] = virt;
        sched_tasks[pareja].count++;

        return true;
    }

    return false;
}
```


# Crear pareja:

Primero registro la nueva tarea en idt.c

```c
IDT_ENTRY3(90)
```

Luego tengo que definir su rutina de atención en isr.asm y su handler

```asm
extern crear_pareja
global _isr90

_isr90:
    pushad

    call crear_pareja

    call sched_next_task
    mov word [sched_task_selector], ax
    jmp far [sched_task_offset]

    popad
    iret
```

Handler de crear_pareja()

```c
void crear_pareja() {
    if (pareja_de_actual() == NULL) {
        sched_tasks[current_task].state = TASK_BUSCANDO_PAREJA;
    }
    return;
}
```

# Juntarse con:

```c
IDT_ENTRY3(91)
```

Para definir esta isr, establezco que el parametro se me pasa por EAX.

```asm
extern juntarse_con
global _isr91

_isr91:
    pushad

    push eax
    call juntarse_con
    sub esp, 4

    popad
    iret
```

Handler de juntarse_con()

```c
int juntarse_con(int id_tarea) {
    if (pareja_de_actual() == NULL) {
        if (aceptando_pareja(id_tarea)) {
            conformar_pareja(id_tarea);
            return 0;
        }
    }
    return 1;
}
```

# Abandonar pareja:

```c
IDT_ENTRY3(92)
```

Luego tengo que definir su rutina de atención en isr.asm y su handler

```asm
extern abandonar_pareja
global _isr92

_isr92:
    pushad

    call abandonar_pareja

    popad
    iret
```

```c
void abandonar_pareja() {
    if (pareja_de_actual() != NULL) {
        if (es_lider(current_task)) {
            sched_tasks[current].state = TASK_CORTANDO_PAREJA;
        } else {
            romper_pareja();
        }
    }
    return;
}
```

# Auxiliares:

```c
task_id pareja_de_actual() {
    return sched_tasks[current_task].pareja;
}

bool es_lider(task_id tarea) {
    return sched_tasks[tarea].lider;
}

bool aceptando_pareja(task_id tarea) {
    return sched_tasks[tarea].state == TASK_BUSCANDO_PAREJA;
}

void conformar_pareja(task_id tarea) {
    uint32_t cr3 = rcr3();

    sched_tasks[tarea].lider = true;
    sched_tasks[tarea].pareja = current_task;
    sched_tasks[tarea].state = TASK_RUNNABLE;
    sched_tasks[tarea].shared_count = 0;

    sched_tasks[current_task].pareja = tarea;
    sched_tasks[current_task].shared_count = 0;

    return;
}

void romper_pareja() {
    if (pareja_actual() != NULL) {
        uint32_t cr3 = rcr3();

        uint8_t lider = sched_tasks[current_task].pareja;
        uint16_t selector_lider = sched_tasks[lider].selector;
        uint32_t cr3_lider = task_selector_to_cr3(selector_lider);

        sched_tasks[current_task].pareja = NULL;
        sched_tasks[lider].pareja = NULL;
        // En ambos casos desmapeo las paginas correspondientes pero quedan las direcciones como basura en el array shared
        // Caso en el que ambas quieren cortar
        if (sched_tasks[lider].state == TASK_CORTANDO_PAREJA) {

            sched_tasks[lider].lider = false;
            sched_tasks[lider].state = TASK_RUNNABLE;

            for (uint8_t i = 0; i < sched_tasks[lider].shared_count; i++) {
                mmu_unmap_page(cr3, sched_tasks[current_task].shared[i]);
                mmu_unmap_page(cr3_lider, sched_tasks[lider].shared[i]);
            }
        } 
        // Caso en el que corta solo la no lider
        else {
            for (uint8_t i = 0; i < sched_tasks[lider].shared_count; i++) {
                mmu_unmap_page(cr3, sched_tasks[current_task].shared[i]);
            }
        }
    }
}
```

# Uso de memoria de las parejas:

```c
uint32_t uso_de_memoria_de_las_parejas() {
    uint32_t uso_total = 0;

    for (uint8_t i = 0; i < MAX_TASKS; i++) {
        if (es_lider(i)) {
            uso_total += sched_tasks[i].shared_count;
        }
    }
    return uso_total * PAGE_SIZE;
}
```