.386
.model flat, stdcall
option casemap: none

include         C:\masm32\include\windows.inc
include         C:\masm32\include\gdi32.inc
include         C:\masm32\include\user32.inc
include         C:\masm32\include\kernel32.inc
includelib      C:\masm32\lib\gdi32.lib
includelib      C:\masm32\lib\user32.lib
includelib      C:\masm32\lib\kernel32.lib

.data?
hInstance       dd  ?
hWinMain        dd  ?

.const
szClassName     db  'MyClass', 0
szCaptionMain   db  'My first Window', 0
szText          db  'Win32 Assembly, Simple and powerful', 0
szButton        db  'button', 0
szButtonText    db  '&OK', 0

.code
_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPs: PAINTSTRUCT
                local   @stRect: RECT
                local   @hDc
        mov     eax, uMsg
        .if     eax == WM_PAINT
                invoke  BeginPaint, hWnd, addr @stRect
                mov     @hDc, eax
                invoke  GetClientRect, hWnd, addr @stRect
                invoke  DrawText, @hDc, addr szText, -1, addr @stRect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
                invoke  EndPaint, hWnd, addr @stPs
        .elseif eax == WM_CREATE
                invoke  CreateWindowEx, NULL, \
                        offset szButton, offset szButtonText, \
                        WS_CHILD or WS_VISIBLE, \
                        10, 10, 65, 22, \
                        hWnd, 1, hInstance, NULL
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