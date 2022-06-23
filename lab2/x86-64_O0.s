sine:
        pushq   %rbp ;сохранили указатель кадра программы, вызвавшей подпрограмму
                        ;(поместили в стек значение в регистре rbp)
        movq    %rsp, %rbp   ;формируем указатель новго кадра
                    	    ;в регистр ebp пишем значение регистра esp
        movsd   %xmm0, -40(%rbp)    ;поместить содержимое регистра
      ;xmm0 по адресу rbp-40(x)
        movq    %rdi, -48(%rbp)     
;поместить содержимое регистра rdi по адресу rbp-48(N)
        movsd   -40(%rbp), %xmm0    ;записать в регистр xmm0 содержимое rbp-40(x)
        movsd   .LC0(%rip), %xmm1   ;записать в регистр xmm1
;разыменнованное значение
                    ;метки LC0 (константу 2)
        divsd   %xmm1, %xmm0        ;xmm0 = xmm0 / xmm1 (x = x / 2)
        movsd   .LC1(%rip), %xmm1   ;xmm1 = разыменнованное значение метки LC1
                                    ;(константа MY_PI)
        divsd   %xmm1, %xmm0        ;xmm0 = xmm0 / xmm1 (x = x / MY_PI)
        cvttsd2siq      %xmm0, %rax ;преобразование x, лежащего в xmm0 к longlong
                    			;и запись в регистр rax
        pxor    %xmm1, %xmm1        ;взаимоисключающее или MY_PI с MY_PI???
        cvtsi2sdq       %rax, %xmm1 ;преобразование к типу
        movsd   .LC1(%rip), %xmm0   ;поместить константу LC1 в регистр xmm0
        mulsd   %xmm1, %xmm0        ;умножить значение, вычеcленное ранее,
;и лежащее в xmm0
                        	;на константу MY_PI, лежащую в xmm1, запись значения
                        ;в регистр xmm0
        movapd  %xmm0, %xmm1        ;xmm1 = xmm0
        addsd   %xmm0, %xmm1        ;xmm1 = xmm1 + xmm0 (xmm1 * 2)
        movsd   -40(%rbp), %xmm0    ;xmm0 = значение лежащее по адресу rbp-40
                    ;xmm0 = x
        subsd   %xmm1, %xmm0     ;xmm0(x) = xmm0(x) - xmm1(вычесленное выражение)
        movsd   %xmm0, -40(%rbp) ;записать на адрес
  ;rbp-40 значение, лежащее в xmm0
        movsd   -40(%rbp), %xmm0    ;xmm0 = значение по адресу rbp-40(x)
        movsd   %xmm0, -8(%rbp)     ;записать по адресу rbp-8 значение ,лежащее
                    ;в xmm0 (current = x)
        movsd   -40(%rbp), %xmm0    ;xmm0 = значение по адресу rbp-40(x)
        movsd   %xmm0, -16(%rbp)    ;записать по адресу rbp-16 значение ,лежащее
                    ;в xmm0 (sum = x)
        movq    $3, -24(%rbp)      ;записать по адресу rbp-24 константу 3 (i = 3)
        jmp     .L2 ;переход к L2
.L3:
        movsd   -8(%rbp), %xmm0     ;xmm0 = current
        movq    .LC2(%rip), %xmm1   ;xmm1 = -1
        xorpd   %xmm1, %xmm0        ;xmm0 = (current) xor (-1)
        pxor    %xmm1, %xmm1 ;xmm1= xmm1(-1) pxor xmm1(-1) => 0 (чистка регистра)
        cvtsi2sdq   24(%rbp), %xmm1 ;преобразование значения,
      ; лежащего в rbp-24(i)
                     ;к типу? и запись в xmm1
        divsd   %xmm1, %xmm0        ;xmm0 = xmm0 / xmm1(xmm0 = -current / i)
        movq    -24(%rbp), %rax     ;rax = значение, лежащее по адресу rbp-24
                    ;(rax = i)
        subq    $1, %rax        ;rax = rax - 1
        pxor    %xmm1, %xmm1        ;(i pxor i)чистка регистра xmm1?
        cvtsi2sdq       %rax, %xmm1 ;преобразование значения rax к типу
                    ;и запись значения в регистр xmm1
        divsd   %xmm1, %xmm0        ;xmm0 = xmm0 / xmm1(i-1)
        mulsd   -40(%rbp), %xmm0    ;xmm0 = xmm0 * (rbp-40)(x)
        movsd   -40(%rbp), %xmm1    ;xmm1 = rbp-40(x)
        mulsd   %xmm1, %xmm0        ;xmm0 = xmm0 * xmm1(x)
        movsd   %xmm0, -8(%rbp)     ;current(rbp-8) = xmm0
        movsd   -16(%rbp), %xmm0    ;xmm0 = sum(rbp-16)
        addsd   -8(%rbp), %xmm0     ;xmm0 = xmm0+current(rbp-8)
        movsd   %xmm0, -16(%rbp)    ;sum(rbp-16) = xmm0;

        addq    $2, -24(%rbp)       ;i+=2
.L2: ;осуществление цикла
        movq    -48(%rbp), %rax     ;rax = значение по адресу rbp - 48(N)
        addq    %rax, %rax          ;умножение N на два(запись в тот же регистр)
        cmpq    %rax, -24(%rbp)     ;сравнение 2N с i
        jl      .L3 ;переход к L3 если i меньше 2N

        movsd   -16(%rbp), %xmm0    ;xmm0 = sum(rbp-16)
        movq    %xmm0, %rax     ;rax = xmm0
        ;выход из функции
        movq    %rax, %xmm0         
        popq    %rbp    ;извлечение из стека места продолжения программы
                        ;после выхода из функции
        ret
.LC3:
        .string "sin(%lf) = %lf\n"
main:
        pushq   %rbp           ;сохраняем указатель кадра вызвавшей программы
        movq    %rsp, %rbp     ;формируем указатель кадра
        subq    $32, %rsp      ;выделяем место на стеке для нашего кадра
        movl    %edi, -20(%rbp)    ;rbp-20 = argc
        movq    %rsi, -32(%rbp)    ;rbp-32 = argv
        cmpl    $3, -20(%rbp)      ;проверка argc != 3
        je      .L6        ;если argc == 3 --> переход к L6
        movl    $0, %edi       ;exit(0)
        call    exit           ;вызов подпрограммы exit
.L6:
        movq    -32(%rbp), %rax    ;rax = значение по адресу (rbp-32)
        addq    $8, %rax       ;rax + 8 (argv[1])
        movq    (%rax), %rax   ; Записать в регистр rax операнд,
                   ;который содержится в оперативной памяти по адресу метки rax
        movq    %rax, %rdi     ;поместить содержиоме регистра rax в регистр rdi
        call    atoll          ;вызов подпрограммы atoll
        movq    %rax, -8(%rbp) ;поместить значение реистра rax 
                                ;по адресу rbp-8 (n = atoll)
        movq    -32(%rbp), %rax    ;rax = значение по адресу (rbp-32)
        addq    $16, %rax      ;rax + 16 (argv[2])
        movq    (%rax), %rax       ; Записать в регистр rax операнд,
                   ;который содержится в оперативной памяти по адресу метки rax

        movq    %rax, %rdi     ;поместить содержиоме регистра rax в регистр rdi
        call    atof           ;вызов подпрограммы atof
        movq    %xmm0, %rax    ;поместить содержимое xmm0 в регистр rax
        movq    %rax, -16(%rbp)    ;x = atof
        movq    -8(%rbp), %rdx     ;rdx = n
        movq    -16(%rbp), %rax    ;rax = x
        movq    %rdx, %rdi
        movq    %rax, %xmm0
        call    sine
        movq    %xmm0, %rdx    ;rdx = sine result
        movq    -16(%rbp), %rax    ;rax = x
        movq    %rdx, %xmm1
        movq    %rax, %xmm0
        movl    $.LC3, %edi    ;поместили в edi значение метки .LC3(строку вывод)
        movl    $2, %eax       ;eax содержит кол-во параметров printf
        call    printf
        movl    $0, %eax
        leave   ;Это эквивалентно movl %ebp, %esp; popl %ebp
                ;Так мы восстанавливаем состояние стека и кадра,
                ;которые были до вызова
        ret

.LC0: ;константа (2)
        .long   0
        .long   1073741824
.LC1: ;константа (MY_PI)
        .long   1413754136
        .long   1074340347
.LC2: ;константа (-1)
        .long   0
        .long   -2147483648
        .long   0
        .long   0
