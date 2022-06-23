sine:
    ;xmm0 = x;
    ;rdi = N;
    movsd   .LC0(%rip), %xmm1 ;xmm1 = 1/2
    movsd   .LC1(%rip), %xmm2 ;xmm2 = MY_PI
    addq    %rdi, %rdi    ;rdi = 2 * rdi (rdi = 2N)
    mulsd   %xmm0, %xmm1      ;xmm1 = xmm1 * xmm0 (xmm1 = 1/2 * x)
    divsd   %xmm2, %xmm1      ;xmm1 = xmm1 / MY_PI
    cvttsd2siq      %xmm1, %rax ;приведение к типу long long
                    ;и запись в rax
    pxor    %xmm1, %xmm1     ;очистка xmm1;
    cvtsi2sdq       %rax, %xmm1 ;приведение значения, лежащего по адресу rax
                    ;к типу double и запись в xmm1
    mulsd   %xmm2, %xmm1    ;xmm1 = xmm1 * MY_PI
    addsd   %xmm1, %xmm1    ;xmm1 *= 2
    subsd   %xmm1, %xmm0    ;xmm0 = xmm0 - xmm1 (x = x - xmm1)
    movapd  %xmm0, %xmm2    ;sum = x
    cmpq    $3, %rdi    ;сравнение 3 и 2N
    jle     .L1     ;если 2N <= 3 -> выход из цикла
        
    movq    .LC2(%rip), %xmm4 ;xmm4 = -1
    movapd  %xmm0, %xmm1    ;current = x
    movl    $3, %eax    ;eax = 3 (i = 3)
.L3:
    pxor    %xmm3, %xmm3    ;очистка xmm3
    xorpd   %xmm4, %xmm1    ;current *= -1
    leaq    -1(%rax), %rdx  ;rdx = адрес(rax - 1) (к значению по адресу
                ;rax - 1 обращения нет
    cvtsi2sdq       %rax, %xmm3 ;приведение к типу и запись в xmm3
    addq    $2, %rax    ;i += 2
    divsd   %xmm3, %xmm1    ;xmm1 = -current(xmm1) / i(xmm3)
    pxor    %xmm3, %xmm3    ;очистка xmm3
    cvtsi2sdq       %rdx, %xmm3 ;xmm3 = i - 1
    divsd   %xmm3, %xmm1    ;xmm1 = xmm1 / (i-1)
    mulsd   %xmm0, %xmm1    ;xmm1 = xmm1 * xmm0 (xmm1 *= x)
    mulsd   %xmm0, %xmm1    ;xmm1 = xmm1 * xmm0 (xmm1 *= x)(xmm1 - ccurrent)
    addsd   %xmm1, %xmm2    ;sum += current
    cmpq    %rdi, %rax  ;сравнение 2N и i
    jl      .L3     ;если i < 2N переход к очередной итерации цикла
.L1:
    movapd  %xmm2, %xmm0 ;retval(xmm0) = sum(xmm2)
    ret
.LC3:
    .string "sin(%lf) = %lf\n"
main:
    pushq   %rbp        ;формирование кадра стека
    pushq   %rbx        ;rbx - регистр общего назначения
    subq    $8, %rsp    ;выделяем место на стеке
    cmpl    $3, %edi    ;сравнение argc != 3 (в edi лежит argc)
    je      .L8     ;если argc == 3, то переход к L8
    xorl    %edi, %edi  ;очистка регистра edi
    call    exit        ;вызов exit
.L8: ;выполняется если argc == 3
    ;si - индекс источника
    ;di - индекс назначения
    movq    8(%rsi), %rdi   ;rdi = содержимое(rsi + 8) (rdi = argv[1])
    movl    $10, %edx   ;edx = 10;
    movq    %rsi, %rbx  ;rbx = содержимое(rsi)
    xorl    %esi, %esi  ;очистка esi
    ;strtoll выводит ошибку, если не удалось
    ;произвести конвертацию строки к числу
    ;atoll возвращает 0, если не удалось произвести конвертацию
    call    strtoll
    movq    16(%rbx), %rdi  ;rdi(n) = result(atoll(argv[1]))
    xorl    %esi, %esi  ;очистка esi
    movq    %rax, %rbp  ;rbp = rax
    call    strtod
    movq    %rbp, %rdi  ;rdi = n
    movapd  %xmm0, %xmm5    ;xmm5 = x
    call    sine    ;вызывается от xmm0 и rdi
    movl    $.LC3, %edi ;edi = -1
    movl    $2, %eax    ;eax = 2(кол-во параметров printf)
    ;xmm0 = result(sine)
    movapd  %xmm0, %xmm1    ;xmm1 = result(sine)
    movapd  %xmm5, %xmm0    ;xmm0 = x
    call    printf
    popq    %rdx        ;|
    xorl    %eax, %eax  ;|
    popq    %rbx        ;|
    popq    %rbp        ;|
    ret
.LC0: ;(2)
    .long   0
    .long   1071644672
.LC1: ;(MY_PI)
    .long   1413754136
    .long   1074340347
.LC2: ;(-1)
    .long   0
    .long   -2147483648
    .long   0
    .long   0
