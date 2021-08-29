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
IDC_HEX         equ     1001
IDC_DEC         equ     1002

.data?
hInstance       dd      ?
hWinMain        dd      ?
dwOption        dd      ?
lpOldProcEdit   dd      ?

.const
szFmtDecToHex   db      '%08X', 0
szFmtHexToDec   db      '%u', 0
szAllowedChar   db      '0123456789ABCDEFabcdef', 08h

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
                                ; a~z转换为A~Z
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

_HexToDec       proc
                local   @szBuffer[512]: byte

        invoke  GetDlgItemText, hWinMain, IDC_HEX, addr @szBuffer, sizeof @szBuffer
        lea     esi, @szBuffer
        cld
        xor     eax, eax
        mov     ebx, 16
        .while  TRUE
                movzx   ecx, byte ptr [esi]
                inc     esi
                .break  .if     ! ecx
                .if     cl > '9'
                        ; cl = cl - 'A' + 10
                        sub     cl, 'A' - 0ah
                .else
                        sub     cl, '0'
                .endif
                mul     ebx
                add     eax, ecx
        .endw
        invoke  wsprintf, addr @szBuffer, addr szFmtHexToDec, eax
        invoke  SetDlgItemText, hWinMain, IDC_DEC, addr @szBuffer
        ret
_HexToDec       endp

_DecToHex       proc
                local   @szBuffer[512]: byte

                invoke  GetDlgItemInt, hWinMain, IDC_DEC, NULL, FALSE
                invoke  wsprintf, addr @szBuffer, addr szFmtDecToHex, eax
                invoke  SetDlgItemText, hWinMain, IDC_HEX, addr @szBuffer
                ret
_DecToHex       endp

_ProcDlgMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPos: POINT
                local   @hSysMenu
                local   @szBuffer[256]: byte

        mov     eax, uMsg
        .if eax == WM_CLOSE
                invoke  EndDialog, hWnd, NULL
        .elseif eax == WM_INITDIALOG
                mov     eax, hWnd
                mov     hWinMain, eax
                invoke  SendDlgItemMessage, hWnd, IDC_HEX, EM_LIMITTEXT, 8, 0
                invoke  SendDlgItemMessage, hWnd, IDC_DEC, EM_LIMITTEXT, 10, 0
                invoke  GetDlgItem, hWnd, IDC_HEX
                invoke  SetWindowLong, eax, GWL_WNDPROC, addr _ProcEdit
                mov     lpOldProcEdit, eax
        .elseif eax == WM_COMMAND
                mov     eax, wParam
                .if     ! dwOption
                        mov     dwOption, TRUE
                        .if     ax == IDC_HEX
                                invoke  _HexToDec
                        .elseif ax == IDC_DEC
                                invoke  _DecToHex
                        .endif
                        mov     dwOption, FALSE
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