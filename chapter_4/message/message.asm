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
hInstance       dd      ?
hWinMain        dd      ?
hWinMain1       dd      ?
hButton         dd      ?
hButton_        dd      ?
hButton1        dd      ?
hButton1_       dd      ?
hStatic         dd      ?

.const
szClassName     db      'MyClass', 0
szCaptionMain   db      'My first Window', 0
szText          db      'Win32 Assembly, Simple and powerful', 0
szButton        db      'button', 0
szStatic        db      'STATIC', 0
szStaticText    db      ' ', 0
szHexText       db      'HEX', 0
szButtonText    db      '&OK', 0
szDisplayMsg    db      'hWnd:', 09h, '%x', 0dh, 0ah, 'uMsg:', 09h, '%x', 0dh, 0ah, 'wParam:', 09h, '%x', 0dh, 0ah, 'lParam:', 09h, '%x', 0
szDisplayHex    db      '%x', 0

.data?
szBuffer        db      1024    dup(?)
dwInitialized   dd      ?
dwInitialized1  dd      ?

.code
_DisplayMessage proc    hWnd, uMsg, wParam, lParam
                ; local   @szHWnd[128]: byte
                ; local   @szUMsg[128]: byte
        mov     eax, dwInitialized
        .if     eax == TRUE
                invoke  wsprintf, offset szBuffer, offset szDisplayMsg, hWnd, uMsg, wParam, lParam
                ; invoke  MessageBox, NULL, offset szBuffer, offset szStaticText, MB_OK
                invoke  SetWindowText, hStatic, offset szBuffer
        .endif
        ret
_DisplayMessage endp

_DisplayHex     proc    dwInt
        invoke  wsprintf, offset szBuffer, offset szDisplayHex, dwInt
        invoke  MessageBox, NULL, offset szBuffer, offset szStaticText, MB_OK
        ret
_DisplayHex endp

_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
; �Ӵ��ڿؼ�������Ϣʱ�򸸴��ڷ���WM_COMMAND��Ϣ������hWndΪ�����ھ����wParamΪ�ؼ�ID(�����Ӵ���ʱ����hMenu����λ���ϣ��ɳ����趨)
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
                mov     hButton, eax
                ; ����ȷ��WM_CREATE���ĸ����ڽ���ʱ���͵ķ������в�ͨ��
                ; ��ʱ������CreateWindowExδ���أ�hWinMain��δ�����
                ; mov     ebx, hWnd
                ; .if     ebx == hWinMain
                ;         mov     hButton, eax
                ;         invoke  _DisplayHex, hWnd
                ;         invoke  _DisplayHex, hButton
                ; .elseif ebx == hWinMain1
                ;         mov     hButton1, eax
                ;         invoke  _DisplayHex, hWnd
                ;         invoke  _DisplayHex, hButton1
                ; .endif
                invoke  CreateWindowEx, NULL, \
                        offset szButton, offset szButtonText, \
                        WS_CHILD or WS_VISIBLE, \
                        10, 32, 65, 22, \
                        hWnd, 3, hInstance, NULL
                mov     hButton1, eax
                ; mov     ebx, hWnd
                ; .if     ebx == hWinMain
                ;         mov     hButton_, eax
                ;         invoke  _DisplayHex, hWnd
                ;         invoke  _DisplayHex, hButton_
                ; .elseif ebx == hWinMain1
                ;         mov     hButton1_, eax
                ;         invoke  _DisplayHex, hWnd
                ;         invoke  _DisplayHex, hButton1_
                ; .endif
                invoke  CreateWindowEx, NULL, \
                        offset szStatic, offset szStaticText, \
                        WS_CHILD or WS_VISIBLE, \
                        76, 10, 128, 128, \
                        hWnd, 2, hInstance, NULL
                mov     hStatic, eax
                mov     dwInitialized, TRUE
                ; mov     ebx, hWnd
                ; .if     ebx == hWinMain
                ;         mov     hStatic, eax
                ;         mov     dwInitialized, TRUE
                ;         invoke  _DisplayHex, hWnd
                ;         invoke  _DisplayHex, hStatic
                ; .endif
                invoke  _DisplayHex, hWnd
                invoke  _DisplayHex, hButton
                invoke  _DisplayHex, hButton1
                invoke  _DisplayHex, hStatic
        .elseif eax == WM_COMMAND
                nop
                ; invoke  _DisplayMessage, hWnd, uMsg, wParam, lParam
        .elseif eax == WM_CLOSE
                invoke  DestroyWindow, hWinMain
                invoke  DestroyWindow, hWinMain1
                invoke  PostQuitMessage, NULL
        .else
                ; invoke  _DisplayMessage, hWnd, uMsg, wParam, lParam
                invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
        .endif
        invoke  _DisplayMessage, hWnd, uMsg, wParam, lParam
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
        ; CreateWindowEx������WM_CREATE��Ϣ���ڸ���Ϣ������ɺ󷵻ء�
        ; ��Ϊoverlapped, pop-up, child��ʽ��
        ; �򻹻ᷢ�� WM_GETMINMAXINFO, WM_NCCREATE��Ϣ
        invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                offset szClassName, offset szCaptionMain, \
                WS_OVERLAPPEDWINDOW, \
                100, 100, 600, 400, \
                NULL, NULL, hInstance, NULL
        mov     hWinMain, eax
        invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                offset szClassName, offset szCaptionMain, \
                WS_OVERLAPPEDWINDOW, \
                100, 100, 600, 400, \
                NULL, NULL, hInstance, NULL
        mov     hWinMain1, eax
        invoke  ShowWindow, hWinMain, SW_SHOWNORMAL
        invoke  UpdateWindow, hWinMain
        invoke  ShowWindow, hWinMain1, SW_SHOWNORMAL
        invoke  UpdateWindow, hWinMain1
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