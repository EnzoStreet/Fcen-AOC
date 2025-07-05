### 1.
a)La base es el cr3 ( 0x000E4000), el primer nivel es un array de cuatro puntero a directorios de tablas de paginas
b)Para la primera es indistino, la segunda 0
c) La escritura del registro cr3 flushea el contenido de la tlb, salvo las marcadas como globales. Las que se modificaron quedaron invalidadas.
d) Son generalmente los atributos de la pagina seleccionada. Mas otros que no estan documentados (podrian ser bits lru)

### 2. El principal problema de no utilizar una tss, lo tiene con la pila. Por diseño del procesador cuando cambia el nivel de privilegio, de 3 a 0 se necesita saber que stack usar en modo kernel y sin la tss, no tiene donde encontrarlo.