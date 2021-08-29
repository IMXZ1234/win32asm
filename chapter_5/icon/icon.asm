.386
.model flat, stdcall
option casemap: none

include         windows.inc
include         user32.inc
include         kernel32.inc
includelib      user32.lib
includelib      kernel32.lib


ICO_BIG         equ     1000h
ICO_SMALL       equ     1001h
CUR_2           equ     1000h
IDM_MAIN        equ     2000h
IDM_EXIT        equ     2101h
IDM_BIG         equ     2201h
IDM_SMALL       equ     2202h
IDM_CUR1        equ     2203h
IDM_CUR2        equ     2204h

.data?
hInstance       dd  ?
hWinMain        dd  ?
hMenu           dd  ?
hSubMenu        dd  ?
hIcoBig         dd  ?
hIcoSmall       dd  ?
hCur1           dd  ?
hCur2           dd  ?

.const
szClassName     db  'Menu Example', 0
szCaptionMain   db  'Menu', 0
szCursorFile    db  '1.ani', 0

.code
_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPos: POINT
                local   @hSysMenu
                local   @szBuffer[256]: byte

        mov     eax, uMsg
        .if eax == WM_CREATE
                invoke  GetSubMenu, hMenu, 1
                mov     hSubMenu, eax
                invoke  LoadIcon, hInstance, ICO_BIG
                mov     hIcoBig, eax
                invoke  LoadIcon, hInstance, ICO_SMALL
                mov     hIcoSmall, eax
                invoke  LoadCursorFromFile, szCursorFile
                mov     hCur1, eax
                invoke  LoadCursor, hInstance, CUR_2
                mov     hCur2, eax
                invoke  SendMessage, hWnd, WM_COMMAND, IDM_BIG, NULL
                invoke  SendMessage, hWnd, WM_COMMAND, IDM_CUR1, NULL
        .elseif eax == WM_COMMAND
                mov     eax, wParam
                movzx   eax, ax
                .if     eax == IDM_EXIT
                        invoke  DestroyWindow, hWinMain
                        invoke  PostQuitMessage, NULL
                .elseif eax == IDM_BIG
                        invoke  SendMessage, hWnd, WM_SETICON, ICON_BIG, hIcoBig
                        invoke  CheckMenuRadioItem, hMenu, IDM_BIG, IDM_SMALL, IDM_BIG, MF_BYCOMMAND
                .elseif eax == IDM_SMALL
                        invoke  SendMessage, hWnd, WM_SETICON, ICON_BIG, hIcoSmall
                        invoke  CheckMenuRadioItem, hMenu, IDM_BIG, IDM_SMALL, IDM_SMALL, MF_BYCOMMAND
                .elseif eax == IDM_CUR1
                        invoke  SetClassLong, hWnd, GCL_HCURSOR, hCur1
                        invoke  CheckMenuRadioItem, hMenu, IDM_CUR1, IDM_CUR2, IDM_CUR1, MF_BYCOMMAND
                .elseif eax == IDM_CUR2                        
                        invoke  SetClassLong, hWnd, GCL_HCURSOR, hCur2
                        invoke  CheckMenuRadioItem, hMenu, IDM_CUR1, IDM_CUR2, IDM_CUR2, MF_BYCOMMAND
                .endif
        .elseif eax == WM_RBUTTONDOWN
                invoke  GetCursorPos, addr @stPos
                invoke  TrackPopupMenu, hSubMenu, TPM_LEFTALIGN, @stPos.x, @stPos.y, NULL, hWnd, NULL
        .elseif eax == WM_CLOSE
                invoke  DestroyWindow, hWinMain
                invoke  PostQuitMessage, NULL
        .else
                invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
        .endif
        xor     eax, eax
        ret
_ProcWinMain    endp

_WinMain        proc
                local   @stWndClass: WNDCLASSEX
                local   @stMsg: MSG

        invoke  GetModuleHandle, NULL
        mov     hInstance, eax
        invoke  MessageBox, NULL, szCaptionMain, szCaptionMain, MB_OK
        invoke  LoadMenu, hInstance, IDM_MAIN
        mov     hMenu, eax

        invoke  RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
        
        invoke  LoadIcon, hInstance, ICO_BIG
        mov     @stWndClass.hIcon, eax
        mov     @stWndClass.hIconSm, eax
        invoke  LoadCursor, 0, IDC_ARROW
        mov     @stWndClass.hCursor, eax
        invoke  MessageBox, NULL, szCaptionMain, szCaptionMain, MB_OK

        mov     eax, hInstance
        mov     @stWndClass.hInstance, eax
        mov     @stWndClass.cbSize, sizeof WNDCLASSEX
        mov     @stWndClass.style, CS_HREDRAW or CS_VREDRAW
        mov     @stWndClass.lpfnWndProc, offset _ProcWinMain
        mov     @stWndClass.hbrBackground, COLOR_WINDOW + 1
        mov     @stWndClass.lpszClassName, offset szClassName
        invoke  RegisterClassEx, addr @stWndClass
        invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                offset szClassName, offset szCaptionMain, \
                WS_OVERLAPPEDWINDOW, \
                100, 100, 400, 300, \
                NULL, hMenu, hInstance, NULL
        mov     hWinMain, eax
        invoke  ShowWindow, hWinMain, SW_SHOWNORMAL
        invoke  UpdateWindow, hWinMain
        .while  TRUE
                invoke  GetMessage, addr @stMsg, NULL, 0, 0
                .break  .if     eax == 0
                invoke  TranslateMessage, addr @stMsg
                invoke  DispatchMessage, addr @stMsg
        .endw
        ret
_WinMain        endp

start:
        call    _WinMain
        invoke  ExitProcess, NULL
        end     start