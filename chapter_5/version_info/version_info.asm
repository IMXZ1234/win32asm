.386
.model flat, stdcall
option casemap: none

include         windows.inc
include         winver.inc
include         user32.inc
include         kernel32.inc
includelib      winver.lib
includelib      user32.lib
includelib      kernel32.lib

ICO_MAIN        equ     1000h
DLG_MAIN        equ     1

.const
szFile          db      "C:\coding\win32assembly\win32asm\chapter_5\version_info\version_info.exe", 0
szVarInfoLang   db      "\VarFileInfo\Translation", 0
szVarInfoStr    db      "\StringFileInfo\%s\%s", 0

.data?
hInstance       dd      ?
dwLen           dd      ?
lpBuffer        dd      ?
dbBuffer        db      4096    dup(?)
szBuffer        db      4096    dup(?)


.code
_ProcDlgMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPos: POINT
                local   @hSysMenu

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
        invoke  GetFileVersionInfo, offset szFile, NULL, sizeof dbBuffer, offset dbBuffer
        invoke  VerQueryValue, offset dbBuffer, offset szVarInfoLang, offset lpBuffer, offset dwLen
        mov     eax, lpBuffer
        mov     eax, [eax]
        ror     eax, 16
        invoke  wsprintf, offset szBuffer, offset 
        invoke  ExitProcess, NULL
        end     start