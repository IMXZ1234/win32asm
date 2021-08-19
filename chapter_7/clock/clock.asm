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

ICO_MAIN        equ     1000h
ID_TIMER        equ     1

.data?
hInstance       dd      ?
hWinMain        dd      ?
dwCenterX       dd      ?
dwCenterY       dd      ?
dwRadius        dd      ?

.const
szClassName     db      'Clock', 0

.code
_CalcClockParam proc
                local   @stRect:RECT

        invoke  GetClientRect, hWinMain, addr @stRect
        mov     eax, @stRect.right
        sub     eax, @stRect.left
        mov     ecx, @stRect.bottom
        sub     ecx, @stRect.top

        .if     ecx > eax
                mov     edx, eax
                sub     ecx, eax
                shr     ecx, 1
                mov     dwCenterX, 0
                mov     dwCenterY, ecx
        .else
                mov     edx, ecx
                sub     eax, ecx
                shr     eax, 1
                mov     dwCenterX, eax
                mov     dwCenterY, 0
        .endif
        shr     edx, 1
        mov     dwRadius, edx
        add     dwCenterX, edx
        add     dwCenterY, edx
        ret
_CalcClockParam endp

_dwPara180      dw      180
_CalcX          proc    _dwDegree, _dwRadius
                local   @dwReturn

        fild    dwCenterX
        fild    _dwDegree
        fldpi
        fmul
        fild    _dwPara180
        fdivp   st(1), st
        fsin
        fild    _dwRadius
        fmul
        fadd
        fistp   @dwReturn
        mov     eax, @dwReturn
        ret
_CalcX          endp

_CalcY          proc    _dwDegree, _dwRadius
                local   @dwReturn
        fild    dwCenterY
        fild    _dwDegree
        fldpi
        fmul
        fild    _dwPara180
        fdivp   st(1), st
        fcos
        fild    _dwRadius
        fmul
        fsubp   st(1), st
        fistp   @dwReturn
        mov     eax, @dwReturn
        ret
_CalcY          endp

_DrawDot        proc    _hDC, _dwDegreeInc, _dwRadius
                local   @dwNowDegree, @dwR
                local   @dwX, @dwY
        
        mov     @dwNowDegree, 0
        mov     eax, dwRadius
        sub     eax, 10
        mov     @dwR, eax
        .while  @dwNowDegree <= 360
                finit
                invoke  _CalcX, @dwNowDegree, @dwR
                mov     @dwX, eax
                invoke  _CalcY, @dwNowDegree, @dwR
                mov     @dwY, eax

                mov     eax, @dwX
                mov     ebx, eax
                mov     ecx, @dwY
                mov     edx, ecx
                sub     eax, _dwRadius
                add     ebx, _dwRadius
                sub     ecx, _dwRadius
                add     edx, _dwRadius
                invoke  Ellipse, _hDC, eax, ecx, ebx, edx

                mov     eax, _dwDegreeInc
                add     @dwNowDegree, eax
        .endw
        ret
_DrawDot        endp

_DrawLine       proc    _hDC, _dwDegree, _dwRadiusAdjust
                local   @dwR
                local   @dwX1, @dwY1, @dwX2, @dwY2

                mov     eax, dwRadius
                sub     eax, _dwRadiusAdjust
                mov     @dwR, eax
                invoke  _CalcX, _dwDegree, @dwR
                mov     @dwX1, eax
                invoke  _CalcY, _dwDegree, @dwR
                mov     @dwY1, eax
                add     _dwDegree, 180
                invoke  _CalcX, _dwDegree, 10
                mov     @dwX2, eax
                invoke  _CalcY, _dwDegree, 10
                mov     @dwY2, eax
                invoke  MoveToEx, _hDC, @dwX1, @dwY1, NULL
                invoke  LineTo, _hDC, @dwX2, @dwY2
                ret
_DrawLine       endp

_ShowTime       proc    uses eax ecx, _hWnd, _hDC
                local   @stTime: SYSTEMTIME

        invoke  GetLocalTime, addr @stTime
        invoke  _CalcClockParam

        invoke  GetStockObject, BLACK_BRUSH
        invoke  SelectObject, _hDC, eax
        invoke  _DrawDot, _hDC, 360/12, 3
        invoke  _DrawDot, _hDC, 360/60, 1
        ; 画秒针
        invoke  CreatePen, PS_SOLID, 1, 0
        invoke  SelectObject, _hDC, eax
        invoke  DeleteObject, eax
        movzx   eax, @stTime.wSecond
        mov     ecx, 360/60
        mul     ecx
        invoke  _DrawLine, _hDC, eax, 15
        ; 画分针
        invoke  CreatePen, PS_SOLID, 2, 0
        invoke  SelectObject, _hDC, eax
        invoke  DeleteObject, eax
        movzx   eax, @stTime.wMinute
        mov     ecx, 360/60
        mul     ecx
        invoke  _DrawLine, _hDC, eax, 15
        ; 画时针
        invoke  CreatePen, PS_SOLID, 3, 0
        invoke  SelectObject, _hDC, eax
        invoke  DeleteObject, eax
        movzx   eax, @stTime.wHour
        .if     eax >= 12
                sub     eax, 12
        .endif
        mov     ecx, 360/12
        mul     ecx
        ; 由分钟产生的在一格内的时针偏移量 60min->30deg
        movzx   ecx, @stTime.wMinute
        shr     ecx, 1
        add     eax, ecx
        invoke  _DrawLine, _hDC, eax, 30

        invoke  GetStockObject, NULL_PEN
        invoke  SelectObject, _hDC, eax
        invoke  DeleteObject, eax
        ret
_ShowTime       endp


_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPs: PAINTSTRUCT

        mov     eax, uMsg
        .if     eax == WM_TIMER
                invoke  InvalidateRect, hWnd, NULL, TRUE
        .elseif eax == WM_PAINT
                invoke  BeginPaint, hWnd, addr @stPs
                invoke  _ShowTime, hWnd, eax
                invoke  EndPaint, hWnd, addr @stPs
        .elseif eax == WM_CREATE
                invoke  SetTimer, hWnd, ID_TIMER, 1000, NULL
        .elseif eax == WM_CLOSE
                invoke  KillTimer, hWnd, ID_TIMER
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
        invoke  LoadIcon, hInstance, ICO_MAIN
        mov     @stWndClass.hIcon, eax
        mov     @stWndClass.hIconSm, eax
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
                offset szClassName, offset szClassName, \
                WS_OVERLAPPEDWINDOW, \
                100, 100, 250, 270, \
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