;/*
; �ਬ�� 6
; �ணࠬ�� �஢�ન ����� �� ��室� �� ⠡���� ���ਯ�஢

.386p

include struct.ash
include macros.ash

INTNO           equ     21      ; �᫮ ����஢ � ⠡��� IDT
DSCPSIZE        equ     8       ; ࠧ��� ���ਯ��
INTSIZE         equ     4       ; ࠧ��� ����� ������ ���뢠���

TWO             equ     2
WORDLEN         equ     4       ; �᫮ ᨬ����� � ��ப� �ᥫ
prot_enable     equ     01h     ; ��� ����祭�� ���饭���� ०���
attribute       equ     07h     ; ��ਡ�� ᨬ����� �� ��࠭�
space           equ     20h     ; ��� ᨬ���� �஡���

;
; ��� 1: ������쭠� ⠡��� ���ਯ�஢ ᥣ���⮢ ��⥬�
;
GDT             segment para    public  use16   'GDT'

gdt_tab label   qword   ; ���ਯ�� *!! �ॡ��� ���樠����樨 ����

; NULL ᥫ���� GDT, ������ ���� �ᥣ�� � ���� � ⠡���
null_selec      equ     0
   dscp         <0,0,0,0,0,0>

; ᥫ���� � ᥣ����� GDT ��� � ᥣ����� ������
gdt_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <gdt_limit,0,0,DATA_ACC or DPL_0,0,0>           ;*!!

; ᥣ���� ��⥬��� ����� ����㧪� �ணࠬ��, �ᥣ�� RPL=DPL=0
code_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <code_limit,0,0,CODE_ACC or DPL_0,0,0>          ;*!!

; ᥣ���� TSS ����� ����㧪�, RPL,DPL � ���ண� ����� �������
task0_TSS_selec equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <task0_TSS_limit,0,0,TSS_ACC or DPL_0,0,0>      ;*!!

; ᥣ���� �⥪� ����� �஢�� 0, RPL=DPL=0 �ᥣ��
stk0_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <stk0_limit,0,0,DATA_ACC or DPL_0,0,0>          ;*!!

; ᥣ���� �⥪� ����� �஢�� 1, RPL=DPL=1 �ᥣ��
stk1_selec      equ     $-gdt_tab or TBL_GDT or RPL_1
   dscp         <stk1_limit,0,0,DATA_ACC or DPL_1,0,0>          ;*!!

; ᥣ���� �⥪� ����� �஢�� 2, RPL=DPL=2 �ᥣ��
stk2_selec      equ     $-gdt_tab or TBL_GDT or RPL_2
   dscp         <stk2_limit,0,0,DATA_ACC or DPL_2,0,0>          ;*!!

; ᥣ���� �⥪� ����� �஢�� 3, RPL=DPL=3 �ᥣ��
stk3_selec      equ     $-gdt_tab or TBL_GDT or RPL_3
   dscp         <stk3_limit,0,0,DATA_ACC or DPL_3,0,0>          ;*!!

; ᥣ���� ���������� 梥⭮�� ०���, RPL=0, DPL=3
video_selec     equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <CRT_SIZE-1,CRT_LOW,CRT_SEG,DATA_ACC or DPL_3,0,0>

; ᥣ���� ������ ����� ����㧪�, RPL,DPL ࠧ�襭���� ����㯠
gdata_selec     equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <gdata_limit,0,0,DATA_ACC or DPL_3,0,0>         ;*!!

; ᥣ���� ����� �ணࠬ� ��ࠡ�⪨ ���뢠���, RPL,DPL �६��� �믮������
int_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <code_limit,0,0,CODE_ACC or DPL_0,0,0>          ;*!!

; ᥫ���� � ���ਯ�� ������ � �ଠ� ॠ�쭮� ���� ������
dmy_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <0ffffh,0,0,DATA_ACC or DPL_0,0,0>              ;*!!

; ᥫ���� � ���ਯ�� ����� � �ଠ� ॠ�쭮� ���� ������
rc_selec        equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <0ffffh,0,0,CODE_ACC or DPL_0,0,0>              ;*!!

; ᥣ���� ������ ����㭨��樨 BIOS, RPL,DPL �� �ᬮ�७�� ����
bios_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <B_DATA_SIZE-1,B_DATA_ADDR,0,DATA_ACC or DPL_0,0,0>

GDT_size        equ     $-gdt_tab       ; ����� ⠡����
GDT_limit       equ     GDT_size-1

;
; ��� 1.1: ��।���� ���ਯ�� �� ⠡��楩 GDT
;
beyond_selec    equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <0ffffh,0,0,DATA_ACC or DPL_3,0,0>

GDT             ends

;
; ��� 2: ⠡��� ���ਯ�஢ ���뢠��� ��⥬�
;
IDT             segment para    public  use16   'IDT'

idt_tab         equ     $
        REPT    INTNO
; ����. ���⨫� ���뢠���, DPL ��।���� �ਢ������ ����㯠 � ������,
; �ਢ������ ��ࠡ�⪨ ���뢠��� ������ ��� DPL � ���ਯ�� �����
          dscp  <0,int_selec,0,INT_ACC or DPL_3,0,0>
        ENDM
IDT_size        equ     $-idt_tab
IDT_limit       equ     IDT_size-1
IDT             ends

;
; ������� ������ ��⥬�
;
Gdata           segment para    public  use16   'Gdata'

;
; ��� 3: ����⥫� ���ਯ���� ⠡��� ��� ����㧪� ॣ���஢
;
pGDT    label   fword
        dw      GDT_limit               ; ࠧ��� GDT
        dd      0                       ; 䨧. ������ ���� GDT
pIDT    label   fword
        dw      IDT_limit               ; ࠧ��� IDT ����. ०���
        dd      0                       ; 䨧. ������ ���� IDT
pold    label   fword
        dw      03ffh                   ; ࠧ��� IDT ॠ�쭮� ����
        dd      0                       ; 䨧. ������ ���� IDT

;
; ��� 4: ⠡��� �८�ࠧ���⥫�� ���ਯ�஢ ᥣ���⮢ GDT
;
gdt_phys_tab    label   word
        dw      task0_TSS_selec,task0_TSS       ; ᥫ����,ᥣ����� ����
        dw      stk0_selec,stk0
        dw      stk1_selec,stk1
        dw      stk2_selec,stk2
        dw      stk3_selec,stk3
        dw      code_selec,code
        dw      gdata_selec,Gdata
        dw      int_selec,code
        dw      dmy_selec,dmy
        dw      rc_selec,code
        dw      gdt_selec,gdt
gdt_tab_count   equ     ($-gdt_phys_tab)/4

;
; ��� 5: ��⥬�� ᮮ�饭��
;
msg_addr        dw      10               ; ��ப� ��砫� �뢮�� �� ��࠭
in_protected    db      'in protected mode',0
int_msg         db      'interrupt '
int_num         db      '????','H',0

;
; ������ ��� �࠭���� ॣ���஢ SS,SP,ES.
; ��� ��࠭����� ����� ��। �室�� � ���饭�� ०��.
real_ss         dw      ?
real_sp         dw      ?
real_es         dw      ?
int_mask        db      ?       ; ��� ᯠᥭ�� ��᪨ ���뢠���

Gdata_size      equ     $
Gdata_limit     equ     Gdata_size-1
Gdata           ends

;
; ��� 6: �⥪��� ᥣ����� ��� ��� �஢��� �ਢ������
;
stk0            segment para    public  use16   'stk0'
        db      100h    dup(0)
stk0_size       equ     $
stk0_limit      equ     stk0_size-1
stk0            ends

stk1            segment para    public  use16   'stk1'
        db      100h    dup(0)
stk1_size       equ     $
stk1_limit      equ     stk1_size-1
stk1            ends

stk2            segment para    public  use16   'stk2'
        db      100h    dup(0)
stk2_size       equ     $
stk2_limit      equ     stk2_size-1
stk2            ends

stk3            segment para    public  use16   'stk3'
        db      100h    dup(0)
stk3_size       equ     $
stk3_limit      equ     stk3_size-1
stk3            ends

DOS_stack       segment para    stack   'stack'
        db      100h    dup(?)
stk_DOS_size    equ     $
stk_DOS_limit   equ     stk_DOS_size-1
DOS_stack       ends
;
; ��� 7: ᥣ���� ���ﭨ� ����� TSS
;
task0_TSS       segment para    public  use16   'task0'
TSS_stack       stk0_selec,stk0_size,stk1_selec,stk1_size,stk2_selec,stk2_size
TSS_cr3         0
TSS_regs        0,0,0,0,0,0,0,0,0,stk0_size
TSS_seg         gdata_selec,code_selec,stk0_selec,gdata_selec,gdata_selec,gdata_selec
                dd      0       ; LDT
                dw      0       ; T ��� TSS �ᥣ�� 0 �� ���樠����樨
                dw      068h    ; I/O table start
task0_TSS_size  equ     $
task0_TSS_limit equ     task0_TSS_size-1
task0_TSS       ends

;
; ��� 8: ᥣ���� ������ � �ଠ� ॠ�쭮� ���� ��� ������ � DOS
;
dmy             segment para    public  use16   'dmy'
        db      128     dup(0)
dmy_size        equ     $
dmy_limit       equ     0ffffh
dmy             ends

;
; ������� ����� ��⥬�
;
code            segment para    public  use16   'code'
        assume  cs:code, ds:gdata

main    proc    far
        cli
        mov     ax,gdata
        mov     ds,ax

        mov     ax,stk0
        mov     ss,ax
        mov     sp,offset stk0_size
        sti
;
; ��� 9: ���樠������ IDT
;
        mov     ax,IDT
        mov     es,ax
        mov     di,offset idt_tab       ; DI=⠡��� ���뢠��� IDT
        mov     ax,offset int_entry     ; AX=���� �ண�. ��ࠡ. ���뢠���
                                        ; ��� ᬥ饭�� �� int_selec
        mov     cx,INTNO
fillidt:
        mov     es:[di],ax              ; ��� �室� � ���ਯ�� �맮��
        add     di,DSCPSIZE             ; ᫥�. ���ਯ�� � IDT
        add     ax,INTSIZE              ; �窠 �室� ��� ᫥�. ���뢠���
        loop    fillidt                 ; ��� ��� ���뢠��� � IDT

;
; ��� 10: ��ந� ����⥫� GDT
;
        build_gdtr      gdt,pgdt,gdt_limit

;
; ��� 11: ��ந� ����⥫� IDT
;
        build_idtr      idt,pidt,idt_limit

;
; ��� 12: ��ந� ��������� ⠡���� ���ਯ�஢ ��⥬� GDT
;
        build_dt        gdt,gdt_phys_tab,gdt_tab_count

;
; ��� 13: ���室�� � ���饭�� ०�� �� 0 �஢�� �ਢ������
;
        goto_prot       pgdt,pidt,code_selec,stk0_selec,stk0_size,Gdata_selec

;
; ��� 14: �뢮� ᮮ�饭�� � ���室� � ���饭�� ०��
;
        call    clr_disp                ; ���⨬ ��࠭

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset in_protected  ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it                 ; �뢥�� ��ப� �� ��࠭

;
; ��� 15: ����㧪� � TR TSS
;
        mov     ax,task0_TSS_selec
        ltr     ax

;
; ��� 15.1: ����㧪� ����୮�� ᥫ����
;
        mov     ax,beyond_selec         ; ᥫ���� ��� � ⠡��� GDT
        mov     es,ax                   ; �㤥� ���뢠��� ��饩 ����� (13)

;
; ��� 16: ������ ���⭮ � DOS �१ ���뢠���
;
        int     20

;
; ��� 17: ���ᨢ �祪 �室� �� ��ࠡ�⪥ ���뢠���
;
int_entry:
      REPT    INTNO
        call  disp                      ; ��楤�� ��ࠡ�⪨ ���뢠���
        iret
      ENDM

;
; ��� 18: ������ �⠭���⭮� ��ࠡ�⪨ ���뢠���
;         ������ ����� �����, �뢮��� ��� �� ��࠭
;         � �����頥��� � DOS
;
disp:
        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        pop     ax                      ; ���� ������ �� �⥪�
        sub     ax,offset int_entry
        shr     ax,TWO                  ; ax= ����� �����
        xor     esi,esi                 ; ���⨬ ���� ��ப�
        mov     si,offset int_num       ; ���� ��ப� ����� �����
        mov     cx,WORDLEN              ; �᫮ ᨬ����� � ��ப�
        call    htoa                    ; HEX->ASCII (esi,cx,eax)

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        cmp     ax,025                  ; �᫨ ��諨 �� �࠭��� ��࠭�
        ja      no_disp                 ; � �� �뢮��� ��ப�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset int_msg       ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it                 ; �뢥�� ��ப� �� ��࠭
no_disp:
;
; ��� 19: ������ � ॠ��� ०�� ������
;
        goto_real dmy_selec,code,stk0,stk0_size,Gdata

;
; ��� 20: ������ � DOS
;
        mov     ax,4c00h                ; Exit Process
        int     21h

main    endp

;
; ��楤�� �뢮�� ��ப� �� ��ᯫ�� � ���饭��� ०���
; �室:
;       DS:SI - ���� ��ப� ᨬ����� ASCIZ
;          DI - ᬥ饭�� � ����������
; ��室:
;       DS:SI - ᫥���騩 �� ��ப�� ����
;          DI - ���� ᫥���饣� ���� ��࠭�
;
disp_it         proc    near
        push    ax
        push    es

        mov     ax,video_selec          ; ᥫ���� ����������
        mov     es,ax
        mov     ah,attribute            ; ��ਡ�� ᨬ�����
        inc     di                      ; ���㣫�� �� �࠭��� ᫮��
        and     di,NOT 1
disp_loop:
        lodsb                           ; ᨬ��� �� ��ப�
        cmp     al,0                    ; ����� ��ப� ?
        jz      end_disp                ; z, ��, ������
        stosw                           ; ᨬ��� � �����������
        jmp     disp_loop               ; ������� �� ���� ��ப�
end_disp:
        pop     es
        pop     ax
        ret
disp_it         endp

;
; ��楤�� ���⪨ ��ᯫ�� � ���饭��� ०���
; �室:
; ��室:
;
clr_disp        proc    near
        push    ax
        push    cx
        push    di
        push    es

        mov     ax,video_selec          ; ᥫ���� ����������
        mov     es,ax
        mov     cx,CRT_SIZE             ; ࠧ��� ����������
        shr     cx,TWO                  ; � ᫮���
        xor     di,di
        mov     ah,attribute
        mov     al,space
        rep     stosw                   ; ���⨬ ��࠭

        pop     es
        pop     di
        pop     cx
        pop     ax
        ret
clr_disp        endp

;
; ��楤�� �८�ࠧ������ HEX->ASCII
; �室:
;       DS:ESI - ���� ��ப� ᨬ�����, CX - �� �����,
;       EAX    - �᫮ ��� �८�ࠧ������
; ��室:
;       DS:ESI - ���� ᫥���饣� �� ��ப�� ᨬ����
;
htoa_tab        db      '0123456789ABCDEF'
htoa            proc    near
        push    esi
        push    eax
        push    ebx
        push    ecx

        xor     ebx,ebx
        add     si,cx
        dec     si                      ; ��⠭�� �� ����� ��ப�
htoa_loop:
        mov     bl,al
        and     bl,0fh
        mov     bl,cs:[ebx+htoa_tab]    ; ASCII ��� ᨬ����
        mov     byte ptr [esi],bl       ; ��� � ��ப� ᨬ�����
        dec     esi                     ; �த������� � ��ப� ᨬ�����
        shr     eax,4                   ; �த������� � �᫥ �� ��ࠤ�
        loop    htoa_loop

        pop     ecx
        pop     ebx
        pop     eax
        pop     esi
        add     si,cx                   ; ��⠭�� �� ��ப��
        ret
htoa            endp

code_size       equ     $
code_limit      equ     code_size-1
code            ends
        end     main


