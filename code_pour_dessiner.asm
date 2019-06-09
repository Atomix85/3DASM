; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

extern projectVect

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main

section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

section .data

event:		times	24 dq 0

;3d coords
pt1:    db  -10,-10,-10
pt2:    db  10, -10,-10
pt3:    db  10, 10,-10
pt4:    db  -10,10,-10
pt5:    db  -10,10,10
pt6:    db  10, 10,10
pt7:    db  10,-10,10
pt8:    db  -10,-10,10

;2d coords projection
pjpt1:  dd  0,0
pjpt2:  dd  0,0
pjpt3:  dd  0,0
pjpt4:  dd  0,0
pjpt5:  dd  0,0
pjpt6:  dd  0,0
pjpt7:  dd  0,0
pjpt8:  dd  0,0

face1:  db  0,1,2,3
face2:  db  1,4,7,2
face3:  db  4,5,6,7
face4:  db  5,0,3,6
face5:  db  5,4,1,0
face6:  db  3,2,7,6


;to delete
x1:     dd  0
x2:     dd  0
y1:     dd  0
y2:     dd  0

section .text

;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0x000000	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0xFFFFFF	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:

mov cl,0

forpts:
 mov rbx,pt1
 mov al,3
 mul cl
 add rbx,rax
 mov rdi, rbx
 
 mov rbx,pjpt1
 mov al,8
 mul cl
 add rbx,rax
 mov rsi, rbx
 
 call projectVect
 inc cl
 cmp cl,8
 jb forpts
 
mov cl,0
forfaces:
 mov rbx,face1
 mov al,4
 mul cl
 add rbx,rax ; rbx = address face itérée
    
 push rcx ; empilement de rcx

 
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+1]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
 
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+1]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+2]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
  
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+2]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+3]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
  
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+3]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
  
  pop rcx
 

 
 inc cl
 cmp cl, 6
 jb forfaces



; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
	
