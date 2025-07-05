Buenas noches! Tu segundo parcial está aprobado ya que cumple con las condiciones de aprobación. Además, la parte práctica está para promoción. Quedan pendientes de revisión tus respuestas teóricas para definir el acceso a la instancia de promoción.



A continuación te dejo mis correcciones. Quedo a disposición por cualquier consulta o aclaración que necesites.



Corrección segundo parcial @nicorec21

Falta un poco de detalle en algunos puntos de la implementación pero la idea está muy completa y no veo errores conceptuales



void\* malloco(size\_t\* size)

&nbsp;Construye un array que vive en el espacio de memoria del kernel

&nbsp;Los elementos del array son structs con atributos similiares a: task\_id, base\_virtual\_address, size, to\_be\_freed

&nbsp;Crea una entrada de nivel 3 en la IDT

&nbsp;La función obtiene la tarea de TR (o algún otro mecanismo equivalente)

&nbsp;La función recorre la tabla y acumula los size de los elementos que le correspondan a la tarea (o algún otro mecanismo equivalente)

&nbsp;Si no se pasa de los 4 MB incluyendo el size pasado por parámetro, crea un registro nuevo en la tabla

&nbsp;Para eso busca una dirección virtual mayor a las del último bloque reservado por la tarea, que permita la definición de páginas contiguas para el size pedido

&nbsp;En caso de no existir una dirección virtual que cumpla con las condiciones, devuelve NULL

Page Fault Handler

&nbsp;Usa la direccion virtual que provocó la excepción de CR2 y la tarea del TR

&nbsp;Recorre la tabla y por cada elemento que correspoda a la tarea evalua si la dir virtual pertenece o no al bloque definido por base\_virtual\_address y size

Si ocurre un page fault dentro del área pedible por malloco, hace el mappeo aunque la dirección puntual no haya sido pedida aún (debería fallar).

&nbsp;Si está dentro de algún bloque, procede a mapear la página que corresponde a la dirección accedida y luego a inicializarla en cero

Idem anterior

&nbsp;Si no está dentro de ningún bloque, la tarea se elimina del scheduler, se marcan to\_be\_freed todos los elementos que corresponden a ella, y se salta a la próxima tarea.

No salta a la próxima tarea (falta devolver bool correcto en page\_fault\_handler). En ningún otro momento del parcial muestra como hacer el salto a otra tarea.

void chau(void\* ptr)

&nbsp;Crea una entrada de nivel 3 en la IDT

&nbsp;Obtiene la tarea de TR (o mecanismo equivalente)

&nbsp;Recorre la tabla en busca de aquella que corresponda a la tarea y tenga base\_virtual\_address == ptr y se setea to\_be\_freed

Tarea especial

&nbsp;Define una entrada en la gdt para la tss de esta tarea

&nbsp;Recorre la tabla en un loop infinito y desmappea todas las páginas que pertenezcan a bloques que tengan to\_be\_freed seteado

Ojo que el orden de estas lineas debería estar invertido:



task\_memory\_usage\[i].start\_mallocos\[j] = 0; 

virt = task\_memory\_usage\[i].start\_mallocos\[j];

Scheduler

Falta detalle implementativo pero la idea es clara.



&nbsp;Modifica sched\_next\_task para que lleve cuenta de los ticks del reloj y retorne el task\_id de la tarea especial cada 100 ticks

Cuenta que lo haría pero no muestra como. En general se entiende que lo sabe hacer por el resto del parcial.

&nbsp;Define una constante con el id de la tarea especial para poder identificarla en el scheduler

Nunca aclara la diferencia entre las tareas de usuario y esta (que es nivel 0, como lograr que sea nivel 0 (config de tss))

&nbsp;Define una variable para contar los 100 clocks

Cuenta que lo haría, no cómo lo haría

