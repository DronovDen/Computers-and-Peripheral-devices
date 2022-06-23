sine:
        ;параметры пришли на регистрах r0, d0
        ;d(n) - SIMD registers
        push    {r4, r5, r7, r8, r9, r10, fp, lr} ;сохраняем значения регистров на стеке
        vpush.64        {d8, d9}
        sub     sp, sp, #40     ;sp = sp - 40 (выделение места)
        add     r7, sp, #0      ;r7 указывает на вершину стека
        vstr.64 d0, [r7, #8]    ;запись по адресу r7 + 8 значения лежащего в d0
                                ;[r7 + 8] = x
        strd    r0, [r7]        ;запись по адресу r7 значения лежащего в r0
                                ;[r7] = N
        vldr.64 d17, [r7, #8]   ;d17 = x
        vmov.f64        d18, #2.0e+0 ;d18 = 2 (константа)
        vdiv.f64        d16, d17, d18   ;d16 = x / 2
        vldr.64 d17, .L5        ;d17 = MY_PI
        vdiv.f64        d18, d16, d17   ;d18 = (x/2) / MY_PI
        vmov    r0, r1, d18     ;запись в r0, r1 двух слов из d18
        bl      __aeabi_d2lz ;конвертация double в long long
        mov     r2, r0  ;r2 = r0 //
        mov     r3, r1  ;r3 = r1 //     Для чего эти махинации???
        mov     r0, r2  ;r0 = r2 //
        mov     r1, r3  ;r1 = r3 //
        bl      __aeabi_l2d     ;конвертация long в double 
        vmov    d17, r0, r1 ;d17 = r0 r1 (записали два регистра в SIMD регистр)
        vldr.64 d16, .L5        ;d16 = MY_PI
        vmul.f64        d16, d17, d16   ;d16 = d17(previous result) * MY_PI
        vadd.f64        d16, d16, d16   ;d16 = d16 * 2
        vldr.64 d17, [r7, #8] ;d17 = x
        vsub.f64        d16, d17, d16 ;d16 = x - d16 (previous result)
        vstr.64 d16, [r7, #8]   ;[r7 + 8] = result (x)
        ldrd    r2, [r7, #8]    ;r2 = x 
        strd    r2, [r7, #32]   ;запись x по адресу r7 + 32 (current = x)
        ldrd    r2, [r7, #8]    ;r2 = x
        strd    r2, [r7, #24]   ;запись x по адресу r7 + 24 (sum = x)
        mov     r2, #3  ;r2 = 3 (constant) (i = 3)
        mov     r3, #0  ;r3 = 0 (constant)
        strd    r2, [r7, #16]   ;[r7 + 16] = 3 (сохранили значение i)
        b       .L2
.L3:
        vldr.64 d16, [r7, #32] ;d16 = current
        vneg.f64        d9, d16 ;d9 = -d16 (-current)
        ldrd    r0, [r7, #16]   ;r0 = значение i (3 - на первой итерации)
        bl      __aeabi_l2d     ;конвертация long -> double
        vmov    d16, r0, r1     ;d16 = результат конвертации (i)
        vdiv.f64        d8, d9, d16 ;d8 = -current / i
        ldrd    r2, [r7, #16]   ;r2 = i(3)
        adds    r8, r2, #-1     ;r8 = i(3) - 1;
        adc     r9, r3, #-1     ;r9 = r3(flag) - 1
        mov     r0, r8          ;r0 = i - 1
        mov     r1, r9   
        bl      __aeabi_l2d     ;конвертация long -> double для выполнения последующего деления
        vmov    d16, r0, r1     ;d16 = r0 r1
        vdiv.f64        d17, d8, d16    ;d17 = -current / i / (i - 1)
        vldr.64 d16, [r7, #8]   ;d16 = x
        vmul.f64        d16, d17, d16   ;d16 = (-current / i / (i - 1)) * x
        vldr.64 d17, [r7, #8]   ;d17 = x
        vmul.f64        d16, d17, d16 ;d16 = d16 * x
        vstr.64 d16, [r7, #32]  ;current ([r7 + 32]) = d16
        vldr.64 d17, [r7, #24]  ;d17 = sum([r7 + 24])
        vldr.64 d16, [r7, #32]  ;d16 = current
        vadd.f64        d16, d17, d16   ;sum += current
        vstr.64 d16, [r7, #24]  ;[r7 + 24] = sum
        ldrd    r2, [r7, #16]   ;r2 = i
        adds    r4, r2, #2      ;r4 = i(r2) + 2
        adc     r5, r3, #0
        strd    r4, [r7, #16]   ;[r7 + 16] = r4 (new i) перезаписали значение i
.L2:
        ldrd    r2, [r7]        ;r2 = N
        adds    r10, r2, r2     ;r10 = 2 * N
        ;fp - флаг
        ;long long лежит в двух 32-битных регистрах r2 r3 (r2 - младшые биты, r3 - старшие)
        ;adc - происходит сложение с учетом того, если при сложении r2 произошел перенос
        adc     fp, r3, r3   ;fp = r3 + r3 + carry flag
        mov     r0, r10      ;r0 = 2N
        mov     r1, fp       ;r1 = (flag)
        ldrd    r2, [r7, #16]   ;r2 = 3
        cmp     r2, r0          ;сравнение i==3 и 2N
        sbcs    r3, r3, r1   ;r3 = r3 - r1 (если carry flag - set)   
        blt     .L3     ;branch lower than...
        ldrd    r2, [r7, #24]   ;r2 = sum ([r7 + 24])
        vmov    d16, r2, r3
        vmov.f64        d0, d16
        adds    r7, r7, #40
        mov     sp, r7
        vldm    sp!, {d8-d9}
        pop     {r4, r5, r7, r8, r9, r10, fp, pc}
.L5:
        .word   1413754136
        .word   1074340347
.LC0:
        .ascii  "sin(%lf) = %lf\012\000"
main:
        ;при вызове bl адрес следующей команды сохраняется в lr
        ;lr хранит в себе адрес возврата из подпрограммы (адрес следующей команды)
        ;Входные параметры сохраняются в r0, r1 (argc, argv)
        push    {r7, lr}        ;Помещаем в стек (обращение в память) r7 и LinkRegister (r13),
                                ;чтобы затем вернуть их в исходное состояние
        sub     sp, sp, #32     ;sp = sp - 32 (выделение места на стеке)
        add     r7, sp, #8      ;r7 = sp + 8
        str     r0, [r7, #4]    ;записать по адресу r7 + 4 содержимое r0 (argc)
        str     r1, [r7]        ;записать по адресу r7 содержимое r1 (argv)
        ldr     r3, [r7, #4]    ;загрузить в r3 содержимое адреса r7 + 4 (r3 = argc)
        cmp     r3, #3          ;argc == 3 ?
        beq     .L8             ;если argc = 3, то перейти к L8
        movs    r0, #0          ;если argc != 3, то r0 = 0 (код возврата)
        bl      exit            
.L8:
        ldr     r3, [r7]        ;r3 = адрес argv
        adds    r3, r3, #4      ;r3 += 4
        ldr     r3, [r3]        ;поместить в r3 содержимое, лежащее по адресу, храняещемуся в r3
                                ;r3 = argv[1]
        mov     r0, r3          ;r0 = argv[1] (для вызова подограммы atoll)
        bl      atoll           
        strd    r0, [r7, #16]   ;записать по адресу r7 + 16 результат выполнения atoll
                                ;[r7 + 16] = n
        ldr     r3, [r7]
        adds    r3, r3, #8
        ldr     r3, [r3]
        mov     r0, r3          ;r0 = argv[2]
        bl      atof
        vstr.64 d0, [r7, #8]    ;записать из d0(64 bit) в адрес r7 + 8
                                ;[r7 + 8] = x
        ldrd    r0, [r7, #16]   ;r0 = n
        vldr.64 d0, [r7, #8]    ;d0 = x
        bl      sine
        vmov.f64        d16, d0 ;загрузить из d0 в d16
        vstr.64 d16, [sp]       ;записать из d16 на адрес sp
        ldrd    r2, [r7, #8]    ;r2 = x
        movw    r0, #:lower16:.LC0
        movt    r0, #:upper16:.LC0
        bl      printf
        movs    r3, #0  ;r3 = 0 (код возврата)
        mov     r0, r3  ;r0 = r3(0)
        adds    r7, r7, #24
        mov     sp, r7
        pop     {r7, pc} ;достаем из стека начальное значение r7 (до вызова main)
                         ;и достаем адрес возврата и помещаем в pc (program counter)
                         ;pc - адрес следующей команды для исполнения
                ;пищем в pc какой-либо адрес -- аналог jump