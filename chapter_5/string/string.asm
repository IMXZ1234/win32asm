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
IDC_CUSTOMTEXT1 equ     101
IDC_CUSTOMTEXT2 equ     102

.const
szTitleError    db      'ERROR', 0
szTitleString   db      'STRING', 0
szLdStrErr      db      'String resource with ID: %d does not exist.', 0

.data?
hInstance       dd      ?
hWinMain        dd      ?
dwTranslated    dd      ?
dwLanguage      dd      ?

.code
_GetString      proc    uses ebx, _dwID, _lpBuffer, _dwSize
                local   @szBuffer[128]: byte

        mov     eax, _dwID
        add     eax, dwLanguage
        mov     ebx, eax
        invoke  LoadString, hInstance, eax, _lpBuffer, _dwSize
        test    eax, eax
        jnz     @F
        invoke  wsprintf, addr @szBuffer, offset szLdStrErr, ebx
        invoke  MessageBox, hWinMain, addr @szBuffer, offset szTitleError, MB_OK
        xor     eax, eax
@@:     
        ret
_GetString      endp


_ProcDlgMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @szBuffer[256]: byte

        mov     eax, uMsg
        .if eax == WM_CLOSE
                invoke  EndDialog, hWnd, NULL
        .elseif eax == WM_INITDIALOG
                invoke  LoadIcon, hInstance, ICO_MAIN
                invoke  SendMessage, hWnd, WM_SETICON, ICON_BIG, eax
                mov     eax, hWnd
                mov     hWinMain, eax
        .elseif eax == WM_COMMAND
                mov     eax, wParam
                movzx   eax, ax
                .if     eax == IDOK
                        invoke  GetDlgItemInt, hWnd, IDC_CUSTOMTEXT1, offset dwTranslated, FALSE
                        mov     ebx, eax
                        invoke  GetDlgItemInt, hWnd, IDC_CUSTOMTEXT2, offset dwTranslated, FALSE
                        mov     dwLanguage, eax
                        invoke  _GetString, ebx, addr @szBuffer, sizeof @szBuffer
                        .if     eax != 0
                                invoke  MessageBox, hWnd, addr @szBuffer, offset szTitleString, MB_OK
                        .endif
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