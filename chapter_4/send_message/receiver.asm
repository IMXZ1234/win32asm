.386
.model flat, stdcall
option casemap: none

include         windows.inc
include         user32.inc
include         kernel32.inc
includelib      user32.lib
includelib      kernel32.lib

.data?
hInstance       dd  ?
hWinMain        dd  ?
szBuffer        dd  256 dup (?)

.const
szClassName     db  'MyClass', 0
szCaptionMain   db  'My first Window', 0
szText          db  'Win32 Assembly, Simple and powerful', 0
szButton        db  'button', 0
szButtonText    db  '&OK', 0
szReceive       db  'Receive WM_SETTEXT message', 0dh, 0ah
                db  'param: %08x',  0dh, 0ah
                db  'text: "%s"', 0dh, 0ah, 0

.code
_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPs: PAINTSTRUCT
                local   @stRect: RECT
                local   @hDc
        mov     eax, uMsg
        ; 此处新增WM_SETTEXT处理代码
        .if     eax == WM_SETTEXT
                ; lParam为收到的字符串的地址，此处%x直接将地址输出，%s则输出地址指向的字符串内容
                invoke  wsprintf, addr szBuffer, addr szReceive, lParam, lParam
                invoke  MessageBox, hWnd, offset szBuffer, addr szCaptionMain, MB_OK
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
        invoke  RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
        invoke  LoadCursor, 0, IDC_ARROW
        mov     @stWndClass.hCursor, eax
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
                100, 100, 600, 400, \
                NULL, NULL, hInstance, NULL
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