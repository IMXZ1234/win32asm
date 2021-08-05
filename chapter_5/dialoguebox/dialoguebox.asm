.386
.model flat, stdcall
option casemap: none

include         C:\masm32\include\windows.inc
include         C:\masm32\include\user32.inc
include         C:\masm32\include\kernel32.inc
includelib      C:\masm32\lib\user32.lib
includelib      C:\masm32\lib\kernel32.lib


ICO_MAIN        equ     1000h
DLG_MAIN        equ     1

.data?
hInstance       dd  ?

.code
_ProcDlgMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPos: POINT
                local   @hSysMenu
                local   @szBuffer[256]: byte

        mov     eax, uMsg
        .if eax == WM_CLOSE
                invoke  EndDialog, hWnd, NULL
        .elseif eax == WM_INITDIALOG
                invoke  LoadIcon, hInstance, ICO_MAIN
                invoke  SendMessage, hWnd, WM_SETICON, ICON_BIG, eax
        .elseif eax == WM_COMMAND
                mov     eax, wParam
                movzx   eax, ax
                .if     eax == IDOK
                        invoke  EndDialog, hWnd, NULL
                .endif
        .else
                mov     eax, FALSE
                ret
        .endif
        ; 此处与窗口过程正好相反，处理完成返回TRUE， 交给系统处理返回FALSE
        mov     eax, TRUE
        ret
_ProcDlgMain    endp

start:
        invoke  GetModuleHandle, NULL
        mov     hInstance, eax
        invoke  DialogBoxParam, hInstance, DLG_MAIN, NULL, offset _ProcDlgMain, NULL
        invoke  ExitProcess, NULL
        end     start