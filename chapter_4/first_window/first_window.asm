.386
.model flat, stdcall
option casemap: none

include         windows.inc
include         gdi32.inc
include         user32.inc
include         kernel32.inc
includelib      gdi32.lib
includelib      user32.lib
includelib      kernel32.lib

.data?
hInstance       dd  ?
hWinMain        dd  ?

.const
; 字符串注意不要遗漏最后的0
szClassName     db  'MyClass', 0
szCaptionMain   db  'My first Window', 0
szText          db  'Win32 Assembly, Simple and powerful', 0
szButton        db  'button', 0
szButtonText    db  '&OK', 0

.code
; 交给Windows的回调函数需要保证ebx edi esi在调用前后保持不变
_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPs: PAINTSTRUCT
                local   @stRect: RECT
                local   @hDc
        ; uMsg指出消息类型
        mov     eax, uMsg
        ; 窗口客户区绘制
        .if     eax == WM_PAINT
                invoke  BeginPaint, hWnd, addr @stPs
                mov     @hDc, eax
                invoke  GetClientRect, hWnd, addr @stRect
                invoke  DrawText, @hDc, addr szText, -1, addr @stRect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
                invoke  EndPaint, hWnd, addr @stPs
        ; 窗口建立
        .elseif eax == WM_CREATE
                invoke  CreateWindowEx, NULL, \
                        offset szButton, offset szButtonText, \
                        WS_CHILD or WS_VISIBLE, \
                        10, 10, 65, 22, \
                        hWnd, 1, hInstance, NULL
        ; 用户关闭窗口操作
        .elseif eax == WM_CLOSE
                invoke  DestroyWindow, hWinMain
                invoke  PostQuitMessage, NULL
        .else
                invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
        .endif
        ; 注意不要遗漏eax清零，告诉Windows成功完成处理
        xor     eax, eax
        ret
_ProcWinMain    endp

_WinMain        proc
                local   @stWndClass: WNDCLASSEX
                local   @stMsg: MSG

        ; 模块句柄
        invoke  GetModuleHandle, NULL
        mov     hInstance, eax
        ; 结构体清零
        invoke  RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
        invoke  LoadCursor, 0, IDC_ARROW
        mov     @stWndClass.hCursor, eax
        mov     eax, hInstance
        mov     @stWndClass.hInstance, eax
        mov     @stWndClass.cbSize, sizeof WNDCLASSEX
        mov     @stWndClass.style, CS_HREDRAW or CS_VREDRAW
        ; 注册窗口类时指定对应的窗口过程
        mov     @stWndClass.lpfnWndProc, offset _ProcWinMain
        mov     @stWndClass.hbrBackground, COLOR_WINDOW + 1
        mov     @stWndClass.lpszClassName, offset szClassName
        ; 注册窗口类
        ; 注意同一窗口类的窗口都具有相同的窗口过程
        invoke  RegisterClassEx, addr @stWndClass
        ; 创建窗口
        invoke  CreateWindowEx, WS_EX_CLIENTEDGE, \
                offset szClassName, offset szCaptionMain, \
                WS_OVERLAPPEDWINDOW, \
                100, 100, 600, 400, \
                NULL, NULL, hInstance, NULL
        mov     hWinMain, eax
        invoke  ShowWindow, hWinMain, SW_SHOWNORMAL
        invoke  UpdateWindow, hWinMain
        ; 消息循环
        .while  TRUE
                invoke  GetMessage, addr @stMsg, NULL, 0, 0
                .break  .if     eax == 0
                invoke  TranslateMessage, addr @stMsg
                invoke  DispatchMessage, addr @stMsg
        .endw
        ret
_WinMain        endp

start:
        ; 程序开始执行位置
        call    _WinMain
        invoke  ExitProcess, NULL
        end     start