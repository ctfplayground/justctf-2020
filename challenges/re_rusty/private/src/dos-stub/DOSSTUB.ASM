.486
ASSUME cs:CODE
CODE SEGMENT use16
               stub db 'This program cannot be run in DOS mode.',13,10,'$'
               align 4                        
               color  db 250                              
               align 4
               last_char db 0,0
               idx dw 0
               include FLAG.ASM
     Start:
            cld
            call clear_bufor
            mov  ax,0013h
            int  10h
            call ustaw_palete
            mov ax, 0a000h
            mov es, ax
_main:
            call sparkle
            call synch
            call draw_string  
            call draw_fire
            lea di, cs:[last_char]
            mov cs:[di], 0                  
            mov ah,01h
            int 16h
            jz _main
            mov ah, 00h
            int 16h
            lea di, cs:[flag]
            cmp al, 27
            je _exit
            cmp al, 13
            je _check
            cmp al, 8
            je _backspace
_normal:    
            mov bx, word ptr [idx]
            cmp bl, byte ptr [l]
            jae _main
            add di,word ptr[idx]     
            mov cs:[di],al
            inc [idx]
            lea di, cs:[last_char]
            mov cs:[di], '*'
            jmp _main
_backspace:
            cmp [idx],0
            jbe _main
            dec [idx]
            add di,word ptr[idx]     
            mov cs:[di],0
            jmp _main
_check:
            xor bx,bx
            push cs
            pop ds
            mov si, offset flag
            push cs
            pop es
            mov cx, [l]
_c0:
            mov di, offset decrypted_flag
            push cx
            add di,bx
            mov cx, [l]
            sub cx, bx
_c1:            
            mov al, byte ptr ds:[si]
            mov ah, byte ptr es:[di]
            xor al,ah
            mov byte ptr es:[di],al
            inc di
            loop _c1
            pop cx
            inc si
            inc bx
            loop _c0

_exit:
            mov ax,0003h
            int 10h
            mov dx, offset stub
            push cs
            pop ds
            mov si, offset flag
            mov cx, [l]
            xor bx,bx
            xor ah,ah
_add:
            lodsb
            add bx,ax
            loop _add
            cmp bx, [encoder_crc]
            jne _skip
            mov si, offset decrypted_flag
            mov cx, [l]
            xor bx,bx
            xor ah,ah
_add2:
            lodsb
            add bx,ax
            loop _add2
            cmp bx, [flag_crc]
            jne _skip
_print:
            mov dx,offset decrypted_flag
_skip:
            mov ah,09h
            int 21h
            mov ax,4c00h
            int 21h


draw_fire proc
      mov di,320
      mov cx,203*320
fire:
      call pal_sie 
      mov es:[di-320],dl
      inc di
      dec cx
jnz  fire
      ret
pal_sie:
      xor ax,ax
      mov al,es:[di]
      mov dx,ax
      mov al,es:[di+320]
      add dx,ax
      mov al,es:[di+321]
      add dx,ax
      mov al,es:[di+319]
      add dx,ax
      shr dx,2
omin_dec:
       cmp dl,1
       jbe  rys
       sub dl,2
rys:
       ret
draw_fire endp

synch   proc
        push    dx
        push    ax
        mov     dx,3dah
czek01:
        in      al,dx
        test    al,8
        jnz     czek01
czek02:
        in      al,dx
        test    al,8
        jz      czek02
        pop     ax
        pop     dx
        ret
synch endp

sparkle proc
        mov di,197*320
        mov cx,320
wstaw:
        call losuj        
        mov es:[di],dl
        mov es:[di+320],dl
        mov es:[di+640],dl
        inc di
        dec cx
jnz    wstaw
        ret

losuj:
      mov ax,cs:[rand]
      mov dx,31413
      mul dx
      add ax,13849
      mov cs:[rand],ax
      mov dx,253
      mul dx
      cmp dl, 33
      jb losuj
      ret
rand dw 12345
sparkle endp

ustaw_palete proc
      xor bl,bl
      xor bh,bh
      mov cx,64
  ustaw_czer:
      mov dx,3c8h
      mov al,bl
      out dx,al
      inc dx
      mov al,bh
      out dx,al
      xor al,al
      out dx,al
      out dx,al
      inc bl
      inc bh
  loop ustaw_czer
      mov bl,64
      xor bh,bh
      mov cx,64
  ustaw_green:
      mov dx,3c8h
      mov al,bl
      out dx,al
      inc dx
      mov al,63
      out dx,al
      mov al,bh
      out dx,al
      xor al,al
      out dx,al
      inc bl
      inc bh
  loop ustaw_green
      mov cx,63
      mov bl,128
      xor bh,bh
  ustaw_nieb:
      mov dx,3c8h
      mov al,bl
      out dx,al
      inc dx
      mov al,63
      out dx,al
      mov al,63
      out dx,al
      mov al,bh
      out dx,al
      inc bl
      inc bh
  loop ustaw_nieb
      mov cx,62
      mov bl,192
  ustaw_b:
      mov dx,3c8h
      mov al,bl
      out dx,al
      inc dx
      mov al,63
      out dx,al
      out dx,al
      out dx,al
      inc bl
  loop ustaw_b
     ret
ustaw_palete endp

draw_string proc
      push cs
      pop ds
      lea si,font_buf

      lea bp,cs:[last_char]
      mov di,32144
draw:
      xor bx,bx
      mov bl,cs:[bp]
      cmp bl,0   
      jz  end_of_draw
      sub bx,20h       
      shl bx,5    
      xor ax,ax
next_line:
      push ax
      push bx
      shl ax,1
      add bx,ax         
      mov ax,ds:[si+bx] 
      xchg ah,al
      mov cx,16
      mov dx,1000000000000000b
pixel:
      test ax,dx
      jz  omin_put
      call put_pixel
omin_put:
      inc  di
      shr  dx,1
      dec  cx
jnz  pixel
end_of_line:
      pop bx
      pop ax
      inc ax
      add di,304
      cmp ax,15
      jna next_line
      inc bp
      sub di, 16*320
      add di, 16
  jmp   draw
end_of_draw:
      ret

put_pixel:
      mov bl,cs:[color]
      mov es:[di],bl
      ret
draw_string endp
clear_bufor proc
          mov ax, 0a000h
          mov es,ax
          xor di,di
          xor ax,ax
          mov cx,16000
          rep stosd
          ret
clear_bufor endp

font_buf  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,128,3,192,3,192,3,192,3,192,3,192,3,192,1,128
db 1,128,0,0,1,192,3,192,3,128,0,0,0,0,0,0
db 14,112,14,112,14,112,14,112,14,112,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,14,56,14,56,14,56,63,254,14,56,14,56,14,56
db 14,56,63,254,14,56,14,56,14,56,0,0,0,0,0,0
db 1,192,15,248,61,206,121,198,121,192,125,192,63,248,15,254
db 1,223,1,207,97,207,113,222,31,248,1,192,0,0,0,0
db 0,0,62,15,119,30,119,60,119,120,62,240,0,0,3,192
db 7,190,15,119,30,119,60,119,120,62,0,0,0,0,0,0
db 7,192,28,240,56,120,56,120,28,240,15,224,31,192,61,192
db 120,239,120,124,120,56,60,124,15,207,0,0,0,0,0,0
db 0,240,1,224,3,192,7,128,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,112,1,224,3,192,3,192,7,128,7,128,7,128,7,128
db 7,128,3,192,3,192,1,224,0,112,0,0,0,0,0,0
db 7,0,3,192,1,224,1,224,0,240,0,240,0,240,0,240
db 0,240,1,224,1,224,3,192,7,0,0,0,0,0,0,0
db 0,0,0,0,0,0,30,24,15,48,7,224,3,192,63,254
db 3,224,7,240,14,120,28,60,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,3,192,3,192,3,192,3,192,63,252
db 3,192,3,192,3,192,3,192,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,30,0,30,0,30,0,14,0,28,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,254
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,30,0,30,0,30,0,30,0,0,0,0,0,0,0
db 0,0,0,15,0,30,0,60,0,120,0,240,1,224,3,192
db 7,128,15,0,30,0,60,0,120,0,0,0,0,0,0,0
db 3,96,14,56,28,28,60,30,60,30,60,30,60,30,60,30
db 60,30,60,30,28,28,14,56,3,96,0,0,0,0,0,0
db 1,192,7,192,31,192,3,192,3,192,3,192,3,192,3,192
db 3,192,3,192,3,192,3,192,31,248,0,0,0,0,0,0
db 7,112,28,60,60,30,24,30,0,30,0,60,0,240,3,192
db 7,0,30,0,60,6,60,14,63,124,0,0,0,0,0,0
db 7,112,28,60,60,30,24,30,0,30,0,60,0,248,0,60
db 0,30,24,30,60,30,28,60,7,112,0,0,0,0,0,0
db 0,28,0,60,0,60,0,188,1,188,3,188,7,60,14,60
db 28,60,63,190,0,60,0,60,0,126,0,0,0,0,0,0
db 63,124,60,28,60,12,60,0,60,0,63,240,0,60,0,30
db 0,30,24,30,60,30,28,60,7,112,0,0,0,0,0,0
db 7,112,30,28,60,30,60,12,60,0,63,240,62,60,60,30
db 60,30,60,30,60,30,30,60,7,112,0,0,0,0,0,0
db 63,222,56,30,48,60,0,120,0,240,0,240,1,224,1,224
db 1,224,3,192,3,192,3,192,1,192,0,0,0,0,0,0
db 7,112,30,60,60,30,60,30,60,30,30,60,15,120,30,60
db 60,30,60,30,60,30,30,60,7,112,0,0,0,0,0,0
db 7,112,30,60,60,30,60,30,60,30,60,30,30,62,7,254
db 0,30,24,30,60,30,28,60,7,112,0,0,0,0,0,0
db 0,0,0,0,3,192,3,192,3,192,3,192,0,0,0,0
db 3,192,3,192,3,192,3,192,0,0,0,0,0,0,0,0
db 0,0,0,0,3,192,3,192,3,192,3,192,0,0,0,0
db 3,192,3,192,3,192,1,192,3,128,0,0,0,0,0,0
db 0,120,0,240,1,224,3,192,7,128,15,0,30,0,15,0
db 7,128,3,192,1,224,0,240,0,120,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,63,254,0,0,0,0
db 63,254,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 30,0,15,0,7,128,3,192,1,224,0,240,0,120,0,240
db 1,224,3,192,7,128,15,0,30,0,0,0,0,0,0,0
db 15,112,56,60,120,30,48,30,0,30,0,60,0,120,0,240
db 1,192,0,0,0,224,1,224,1,192,0,0,0,0,0,0
db 0,0,7,224,28,56,51,108,102,118,110,118,110,118,110,118
db 110,118,102,118,51,124,28,0,7,240,0,0,0,0,0,0
db 3,128,3,192,1,192,5,224,4,224,12,240,12,240,12,120
db 27,248,24,60,48,60,48,30,120,63,0,0,0,0,0,0
db 62,224,30,120,30,60,30,60,30,60,30,120,30,240,30,60
db 30,30,30,30,30,30,30,60,62,240,0,0,0,0,0,0
db 7,184,30,14,60,6,120,0,120,0,120,0,120,0,120,0
db 120,0,120,0,60,6,30,14,7,184,0,0,0,0,0,0
db 125,224,60,120,60,60,60,30,60,30,60,30,60,30,60,30
db 60,30,60,30,60,60,60,120,125,224,0,0,0,0,0,0
db 62,254,30,14,30,6,30,0,30,16,30,48,30,240,30,48
db 30,16,30,0,30,6,30,14,62,254,0,0,0,0,0,0
db 62,254,30,14,30,6,30,0,30,16,30,48,30,240,30,48
db 30,16,30,0,30,0,30,0,63,0,0,0,0,0,0,0
db 7,112,30,28,60,12,120,0,120,0,120,0,120,0,120,126
db 120,60,120,60,60,60,30,60,7,112,0,0,0,0,0,0
db 126,126,60,60,60,60,60,60,60,60,60,60,61,252,60,60
db 60,60,60,60,60,60,60,60,126,126,0,0,0,0,0,0
db 31,248,3,192,3,192,3,192,3,192,3,192,3,192,3,192
db 3,192,3,192,3,192,3,192,31,248,0,0,0,0,0,0
db 0,126,0,60,0,60,0,60,0,60,0,60,0,60,0,60
db 0,60,24,60,60,60,28,120,6,224,0,0,0,0,0,0
db 126,30,60,12,60,24,60,48,60,96,60,192,61,192,61,224
db 60,240,60,240,60,120,60,60,126,126,0,0,0,0,0,0
db 63,0,30,0,30,0,30,0,30,0,30,0,30,0,30,0
db 30,0,30,0,30,6,30,14,62,254,0,0,0,0,0,0
db 120,31,60,94,30,222,15,222,39,158,51,30,48,30,48,30
db 48,30,48,30,48,30,48,30,120,63,0,0,0,0,0,0
db 120,30,60,12,30,12,47,12,55,140,51,204,49,236,48,244
db 48,120,48,60,48,28,48,12,120,4,0,0,0,0,0,0
db 6,224,28,56,56,28,120,30,120,30,120,30,120,30,120,30
db 120,30,120,30,56,28,28,56,6,224,0,0,0,0,0,0
db 125,240,60,60,60,30,60,30,60,30,60,30,60,60,61,240
db 60,0,60,0,60,0,60,0,126,0,0,0,0,0,0,0
db 6,224,28,56,56,28,120,30,120,30,120,30,120,30,120,30
db 120,30,120,30,56,252,28,56,6,238,0,0,0,0,0,0
db 125,240,60,60,60,30,60,30,60,30,60,30,60,60,61,240
db 61,192,61,224,60,240,60,120,126,30,0,0,0,0,0,0
db 7,120,30,14,60,6,60,0,62,0,31,128,3,240,0,252
db 0,62,0,30,48,30,56,60,15,112,0,0,0,0,0,0
db 123,222,115,206,99,198,3,192,3,192,3,192,3,192,3,192
db 3,192,3,192,3,192,3,192,7,224,0,0,0,0,0,0
db 126,30,60,12,60,12,60,12,60,12,60,12,60,12,60,12
db 60,12,60,12,60,12,30,24,7,112,0,0,0,0,0,0
db 126,30,60,12,60,12,30,24,30,24,30,24,15,48,15,48
db 7,176,7,160,7,128,3,192,3,192,0,0,0,0,0,0
db 252,7,120,3,120,3,120,3,120,195,60,230,61,246,61,250
db 62,252,30,60,30,60,28,28,28,28,0,0,0,0,0,0
db 120,14,56,12,28,24,14,48,7,96,3,128,3,192,1,192
db 6,224,12,112,24,56,48,28,112,30,0,0,0,0,0,0
db 124,14,60,12,30,24,15,48,7,96,7,160,3,192,3,192
db 3,192,3,192,3,192,3,192,7,224,0,0,0,0,0,0
db 127,238,112,30,96,60,0,120,0,240,1,224,3,192,7,128
db 15,0,30,0,60,6,120,14,119,254,0,0,0,0,0,0
db 7,240,7,128,7,128,7,128,7,128,7,128,7,128,7,128
db 7,128,7,128,7,128,7,128,7,240,0,0,0,0,0,0
db 0,0,120,0,60,0,30,0,15,0,7,128,3,192,1,224
db 0,240,0,120,0,60,0,30,0,15,0,0,0,0,0,0
db 15,224,1,224,1,224,1,224,1,224,1,224,1,224,1,224
db 1,224,1,224,1,224,1,224,15,224,0,0,0,0,0,0
db 3,224,7,240,15,120,30,60,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,127,254,0,0,0,0,0,0
db 15,0,7,128,3,192,1,224,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,14,224,56,56,48,60,0,60
db 7,252,30,60,60,60,60,60,14,254,0,0,0,0,0,0
db 62,0,30,0,30,0,30,0,30,240,30,60,30,30,30,30
db 30,30,30,30,30,30,30,60,62,240,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,7,112,30,28,60,12,60,0
db 60,0,60,0,60,12,30,28,7,112,0,0,0,0,0,0
db 0,124,0,60,0,60,0,60,7,188,30,60,60,60,60,60
db 60,60,60,60,60,60,30,60,7,190,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,7,96,30,56,60,60,60,60
db 63,252,60,0,60,12,30,28,7,112,0,0,0,0,0,0
db 1,240,7,156,15,12,15,0,15,0,63,224,15,0,15,0
db 15,0,15,0,15,0,15,0,31,128,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,7,190,30,60,60,60,60,60
db 60,60,60,60,30,60,7,188,0,60,24,60,28,120,7,224
db 124,0,60,0,60,0,60,0,61,224,60,120,60,60,60,60
db 60,60,60,60,60,60,60,60,126,126,0,0,0,0,0,0
db 3,192,3,192,3,192,0,0,15,192,3,192,3,192,3,192
db 3,192,3,192,3,192,3,192,31,248,0,0,0,0,0,0
db 0,60,0,60,0,60,0,0,0,124,0,60,0,60,0,60
db 0,60,0,60,0,60,0,60,0,60,48,60,56,120,14,224
db 62,0,30,0,30,0,30,0,30,14,30,24,30,48,30,96
db 30,224,30,240,30,120,30,60,62,62,0,0,0,0,0,0
db 31,192,3,192,3,192,3,192,3,192,3,192,3,192,3,192
db 3,192,3,192,3,192,3,192,31,248,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,247,120,113,206,113,206,113,206
db 113,206,113,206,113,206,113,206,251,223,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,62,224,30,120,30,60,30,60
db 30,60,30,60,30,60,30,60,63,126,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,7,112,30,60,60,30,60,30
db 60,30,60,30,60,30,30,60,7,112,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,62,240,30,60,30,30,30,30
db 30,30,30,30,30,30,30,60,30,240,30,0,30,0,63,0
db 0,0,0,0,0,0,0,0,7,190,30,60,60,60,60,60
db 60,60,60,60,60,60,30,60,7,188,0,60,0,60,0,126
db 0,0,0,0,0,0,0,0,62,112,30,220,30,12,30,0
db 30,0,30,0,30,0,30,0,63,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,15,112,60,28,60,12,31,0
db 7,224,0,248,48,60,56,60,15,112,0,0,0,0,0,0
db 15,128,7,128,7,128,7,128,63,252,7,128,7,128,7,128
db 7,128,7,128,7,134,7,142,1,216,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,62,124,30,60,30,60,30,60
db 30,60,30,60,30,60,14,60,3,190,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,62,14,30,12,15,12,15,24
db 7,152,7,176,3,208,3,192,1,224,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,252,15,120,230,120,230,61,246
db 62,250,63,124,30,60,28,28,28,12,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,63,30,15,24,7,48,3,160
db 1,192,2,224,6,240,12,120,60,126,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,60,62,24,60,24,120,12,120
db 12,112,6,240,6,224,1,224,1,192,3,192,7,128,30,0
db 0,0,0,0,0,0,0,0,63,188,56,120,48,240,1,224
db 3,192,7,128,15,12,30,28,61,252,0,0,0,0,0,0
db 0,120,1,224,3,192,3,192,3,192,7,128,31,0,7,128
db 3,192,3,192,3,192,1,224,0,120,0,0,0,0,0,0,3,192
db 3,192,3,192,3,192,3,192,3,192,0,0,3,192,3,192,3
db 192,3,192,3,192,3,192,0,0,0,0,0,0,30,0,7,128,3
db 192,3,192,3,192,1,224,0,248,1,224,3,192,3,192,3
db 192,7,128,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,62
db 14,119,142,115,206,113,238,112,124,0,0,0,0,0,0,0
db 0,0,0,0,0,0,96,219,254,216,96,217,248,219,108,219,108,219
db 252,243,108,195,108,193,248,195,108,195,108,195,108,195,108,198,102,0,0
CODE ENDS
STOSIK SEGMENT STACK 'STACK'
       db 100h dup(?)
STOSIK ENDS
END Start