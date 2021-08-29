.386
.model flat, stdcall
option casemap: none

include         windows.inc
include         user32.inc
include         kernel32.inc
includelib      user32.lib
includelib      kernel32.lib


ICO_MAIN        equ     1000
DLG_MAIN        equ     1000

.data?
hInstance       dd      ?
hWinMain        dd      ?
lpOldProcEdit   dd      ?

.const
szAllowedChar   db      '0123456789ABCDEFabcdef', 08h
szClass         db      'HexEdit', 0
szEditClass     db      'EDIT', 0

.code
_ProcEdit       proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPos: POINT
                local   @hSysMenu
                local   @szBuffer[256]: byte

        mov     eax, uMsg
        .if     eax == WM_CHAR
                mov     eax, wParam
                mov     edi, offset szAllowedChar
                mov     ecx, sizeof szAllowedChar
                repnz   scasb
                .if     ZERO?
                        .if     al > '9'
                                ; A~Z:41h~5Ah, a~z:61h~7Ah
                                ; a~z×ª»»ÎªA~Z
                                and     al, not 20h
                        .endif
                        invoke  CallWindowProc, lpOldProcEdit, hWnd, uMsg, eax, lParam
                        ret
                .endif
        .else
                invoke  CallWindowProc, lpOldProcEdit, hWnd, uMsg, wParam, lParam
                ret
        .endif
        xor     eax, eax
        ret
_ProcEdit       endp

_SuperClass     proc
                local   @stWC: WNDCLASSEX
        
        mov     @stWC.cbSize, sizeof @stWC
        invoke  GetClassInfoEx, NULL, addr szEditClass, addr @stWC
        mov     eax, @stWC.lpfnWndProc
        mov     lpOldProcEdit, eax
        mov     @stWC.lpfnWndProc, offset _ProcEdit
        mov     eax, hInstance
        mov     @stWC.hInstance, eax
        mov     @stWC.lpszClassName, offset szClass
        invoke  RegisterClassEx, addr @stWC
        ret
_SuperClass     endp

_ProcDlgMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam

        mov     eax, uMsg
        .if eax == WM_CLOSE
                invoke  EndDialog, hWnd, NULL
        .else
                mov     eax, FALSE
                ret
        .endif
        mov     eax, TRUE
        ret
_ProcDlgMain    endp

start:
        invoke  GetModuleHandle, NULL
        mov     hInstance, eax
        invoke  _SuperClass
        invoke  DialogBoxParam, hInstance, DLG_MAIN, NULL, offset _ProcDlgMain, NULL
        invoke  ExitProcess, NULL
        end     start