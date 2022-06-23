;встривание тела функции в код
sine:
        vmov.f64        d16, #5.0e-1 ;d16 = 0.5
        push    {r3, r4, r5, r6, r7, lr} ;сохранение значений регистров
        mov     r6, r0 ;r6 = x(r0)
        vmul.f64        d16, d0, d16 ;d16 = x(d0) * 0.5(d16)
        vpush.64        {d8, d9, d10, d11} ;сохранение значений регистров
        vldr.64 d8, .L8  ;d8 = MY_PI
        mov     r7, r1 ;r7 = N (r1)
        vmov.f64        d9, d0 ;d9 = x
        vdiv.f64        d16, d16, d8 ;d16 = (x * 0.5) / MY_PI
        vmov    r0, r1, d16 ;unpack SIMD register
        bl      __aeabi_d2lz
        bl      __aeabi_l2d
        vmov    d16, r0, r1 

        adds    r6, r6, r6 ;r6 = 2 * N
        vmul.f64        d16, d16, d8 ;d16 = ((x * 0.5) / MY_PI) * MY_PI
        adcs    r7, r7, r7
        cmp     r6, #4 ;сравнение 2 * N с 4
        sbcs    r3, r7, #0
        vadd.f64        d16, d16, d16 ;d16 *= 2;
        vsub.f64        d9, d9, d16 ;d9 (x) = x - (((x * 0.5) / MY_PI) * 2) * MY_PI
        blt     .L4 ;if 2N < 4 -> goto L4
        vmov.f64        d10, d9 ;sum = x
        vmov.f64        d16, d9 ;current = x
        movs    r4, #3  ;r4 = 3
        movs    r5, #0 ;r5 = 0
.L3:
        vneg.f64        d8, d16 ;d8 = -current
        mov     r0, r4  ;r0 = 3
        mov     r1, r5  ;r1 = 0
        bl      __aeabi_l2d
        vmov    d16, r0, r1 ;d16 = 3, 0
        subs    r3, r4, #1 ;r3 = i(3) - 1
        vdiv.f64        d11, d8, d16 ;d11 = -current / i(d16)
        sbc     r1, r5, #0 ;r1 = r5 - 0
        mov     r0, r3 ;r0 = (i - 1)
        bl      __aeabi_l2d
        vmov    d16, r0, r1 ;d16 = (i - 1), 0
        adds    r4, r4, #2 ;i(r4) += 2
        adc     r5, r5, #0
        cmp     r4, r6 ;comparison i and 2N
        sbcs    r3, r5, r7
        vdiv.f64        d16, d11, d16 ;d16 = (-current / i(d16)) / (i - 1)
        vmul.f64        d16, d16, d9 ;d16 = (-current / i(d16)) / (i - 1) * x
        vmul.f64        d16, d16, d9 ;current (d16) = (-current / i(d16)) / (i - 1) * x * x
        vadd.f64        d10, d10, d16 ;sum = sum + current
        blt     .L3 ;if i < 2N --> goto .L3
        vmov.f64        d0, d10 ;d0 = sum

        vldm    sp!, {d8-d11}
        pop     {r3, r4, r5, r6, r7, pc}
.L4:
        vmov.f64        d10, d9 ;sum = x
        vmov.f64        d0, d10 ;d10 = sum(x)
        vldm    sp!, {d8-d11}
        pop     {r3, r4, r5, r6, r7, pc}
.L8:
        .word   1413754136
        .word   1074340347
.LC0:
        .ascii  "sin(%lf) = %lf\012\000"
main:
        push    {r4, r5, r6, r7, lr} ;Помещаем в стек регистры r4 - r7 и LinkRegister (r13),
                                     ;чтобы затем вернуть их в исходное состояние
        cmp     r0, #3  ;r0(argc) == 3 ?
        vpush.64        {d8, d9, d10, d11, d12} ;помещаем в стек регистры d8 - d12
        sub     sp, sp, #12 ;наращивание стека
        beq     .L11    ;если argc = 3, то переходим к L11
        movs    r0, #0 ;если argc != 3, то выход с кодом 0
        bl      exit
.L11:
        mov     r5, r1 ;r5 = r1(argv)
        movs    r2, #10 ;r2 =10
        mov     r4, r0 ;r4 = argc (3)
        ldr     r0, [r1, #4] ;r0 = argv[1]
        movs    r1, #0  ;r1 = 0
        vldr.64 d10, .L17 ;d10 = MY_PI - заранее подготовили константу
        bl      strtoll
        mov     r7, r0  ;r7(n) = result of strtoll
        mov     r6, r1  ;r6 = r1(0)
        ldr     r0, [r5, #8] ;r0 = [r5 + 8] (argv[2])
        movs    r1, #0  ;r1 = 0
        bl      strtod  ;x - r0(result of strtod)
        vmov.f64        d16, #5.0e-1 ;d16 = 0.5 (constant) - заранее подготовили константу
        vmov.f64        d9, d0 ;d9 = x
        vmul.f64        d16, d0, d16 ;d16 = x * 0.5
        vdiv.f64        d16, d16, d10 ;d16 = (x * 0.5) / MY_PI
        vmov    r0, r1, d16 ;распаковали в два регистра
        bl      __aeabi_d2lz    ;convert double to long
        bl      __aeabi_l2d     ;convert long to double
        vmov    d16, r0, r1     ;d16 = r0 r1
        adds    r7, r7, r7 ;i = 2 * N
        vmul.f64        d10, d16, d10 ;d10 = d16 ((x * 0.5) / MY_PI) * MY_PI
        adcs    r6, r6, r6 
        cmp     r7, #4 ;сравнение 2N с 4
        sbcs    r3, r6, #0
        vadd.f64        d10, d10, d10 ;d10 *= 2
        vsub.f64        d10, d9, d10    ;d10 = x - d10
        blt     .L14    ;если 2N < 4 то в основной цикл не зайдем --> выход из подпрограммы
        vmov.f64        d11, d10 ;sum(d11) = x(d10)
        vmov.f64        d16, d10 ;current (d16) = x(d10)
        movs    r5, #0  ;r5 = 0
.L13:
        vneg.f64        d8, d16 ;d8 = -current
        mov     r0, r4 ;r0 = 3
        mov     r1, r5
        bl      __aeabi_l2d
        vmov    d16, r0, r1 ;d16 = 3, 0
        subs    r3, r4, #1 ;r3 = i(3) - 1
        vdiv.f64        d12, d8, d16 ;d12 = -current / i(d16)
        sbc     r1, r5, #0
        mov     r0, r3 ;r0 = (i - 1)
        bl      __aeabi_l2d
        vmov    d16, r0, r1 ;d16 = (i - 1), 0
        adds    r4, r4, #2 ;i(r4) += 2
        adc     r5, r5, #0
        cmp     r4, r7 ;comparison i and 2N
        sbcs    r3, r5, r6
        vdiv.f64        d16, d12, d16 ;d16 = (-current / i(d16)) / (i - 1)
        vmul.f64        d16, d16, d10 ;d16 = (-current / i(d16)) / (i - 1) * x
        vmul.f64        d16, d10, d16 ;current (d16) = (-current / i(d16)) / (i - 1) * x * x
        vadd.f64        d11, d11, d16 ;sum = sum + current
        blt     .L13 ;if i < 2N --> goto .L3
.L12:
        vmov    r2, r3, d9 ;{r2, r3} = x - параметры функции printf
        vstr.64 d11, [sp]
        movw    r0, #:lower16:.LC0
        movt    r0, #:upper16:.LC0
        bl      printf
        ;завершение программы
        movs    r0, #0
        add     sp, sp, #12
        vldm    sp!, {d8-d12}
        pop     {r4, r5, r6, r7, pc}
.L14:
        vmov.f64        d11, d10 ;sum(d11) = x(d10) т.к в основной цикл функции не заходим,
                                 ;но вернуть sum необходимо
        b       .L12
.L17:
        .word   1413754136
        .word   1074340347