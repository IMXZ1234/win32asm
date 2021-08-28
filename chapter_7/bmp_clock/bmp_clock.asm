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

CLOCK_SIZE      equ     150

ICO_MAIN        equ     100
IDC_MAIN        equ     100
IDC_MOVE        equ     101
IDB_BACK1       equ     100
IDB_CIRCLE1     equ     101
IDB_MASK1       equ     102
IDB_BACK2       equ     103
IDB_CIRCLE2     equ     104
IDB_MASK2       equ     105
ID_TIMER        equ     1
IDM_BACK1       equ     100
IDM_BACK2       equ     101
IDM_CIRCLE1     equ     102
IDM_CIRCLE2     equ     103
IDM_EXIT        equ     104


.data?
hInstance       dd      ?
hWinMain        dd      ?
hCursorMain     dd      ?
hCursorMove     dd      ?
hMenu           dd      ?
hBmpBack        dd      ?
hBmpClock       dd      ?
; 缓存的钟面背景
hDCBack         dd      ?
; 缓存的叠加上指针的钟面
hDCClock        dd      ?
dwNowBack       dd      ?
dwNowCircle     dd      ?

.const
szClassName     db      'Clock', 0
_dwPara180      dw      180
dwRadius        dw      CLOCK_SIZE/2
szMenuBack1     db      '使用背景1(&A)', 0
szMenuBack2     db      '使用背景2(&B)', 0
szMenuCircle1   db      '使用边框1(&C)', 0
szMenuCircle2   db      '使用边框2(&D)', 0
szMenuExit      db      '退出(&X)', 0



.code
_CalcX          proc    _dwDegree, _dwRadius
                local   @dwReturn

        fild    dwRadius
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

        fild    dwRadius
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

_DrawLine       proc    _hDC, _dwDegree, _dwRadius
                local   @dwX1, @dwY1, @dwX2, @dwY2

                invoke  _CalcX, _dwDegree, _dwRadius
                mov     @dwX1, eax
                invoke  _CalcY, _dwDegree, _dwRadius
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

_CreateClockPic proc uses eax ecx
                local   @stTime: SYSTEMTIME

        ; hDCBack为当前背景画布与时钟边框图片结合后的缓存钟面背景
        ; 避免每次重画指针都重新叠加背景画布和时钟边框
        invoke  BitBlt, hDCClock, 0, 0, CLOCK_SIZE, CLOCK_SIZE, hDCBack, 0, 0, SRCCOPY
        invoke  GetLocalTime, addr @stTime
        ; 画秒针
        invoke  CreatePen, PS_SOLID, 1, 0
        invoke  SelectObject, hDCClock, eax
        invoke  DeleteObject, eax
        movzx   eax, @stTime.wSecond
        mov     ecx, 360/60
        mul     ecx
        invoke  _DrawLine, hDCClock, eax, 15
        ; 画分针
        invoke  CreatePen, PS_SOLID, 2, 0
        invoke  SelectObject, hDCClock, eax
        invoke  DeleteObject, eax
        movzx   eax, @stTime.wMinute
        mov     ecx, 360/60
        mul     ecx
        invoke  _DrawLine, hDCClock, eax, 15
        ; 画时针
        invoke  CreatePen, PS_SOLID, 3, 0
        invoke  SelectObject, hDCClock, eax
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
        invoke  _DrawLine, hDCClock, eax, 30

        invoke  GetStockObject, NULL_PEN
        invoke  SelectObject, hDCClock, eax
        invoke  DeleteObject, eax
        ret
_CreateClockPic endp


_CreateBackground       proc
                local   @hDC, @hDCCircle, @hDCMask
                local   @hBmpBack, @hBmpCircle, @hBmpMask

        invoke  GetDC, hWinMain
        mov     @hDC, eax
        invoke  CreateCompatibleDC, @hDC
        mov     hDCBack, eax
        invoke  CreateCompatibleDC, @hDC
        mov     hDCClock, eax
        invoke  CreateCompatibleDC, @hDC
        mov     @hDCCircle, eax
        invoke  CreateCompatibleDC, @hDC
        mov     @hDCMask, eax
        invoke  CreateCompatibleBitmap, @hDC, CLOCK_SIZE, CLOCK_SIZE
        mov     hBmpBack, eax
        invoke  CreateCompatibleBitmap, @hDC, CLOCK_SIZE, CLOCK_SIZE
        mov     hBmpClock, eax
        invoke  ReleaseDC, hWinMain, @hDC

        invoke  LoadBitmap, hInstance, dwNowBack
        mov     @hBmpBack, eax
        invoke  LoadBitmap, hInstance, dwNowCircle
        mov     @hBmpCircle, eax
        mov     eax, dwNowCircle
        ; Mask的资源ID恰比Circle资源ID大1
        inc     eax
        invoke  LoadBitmap, hInstance, eax
        mov     @hBmpMask, eax
        invoke  SelectObject, hDCBack, hBmpBack
        invoke  SelectObject, hDCClock, hBmpClock
        invoke  SelectObject, @hDCCircle, @hBmpCircle
        invoke  SelectObject, @hDCMask, @hBmpMask
        ; 以背景画布图片填充
        invoke  CreatePatternBrush, @hBmpBack
        push    eax
        invoke  SelectObject, hDCBack, eax
        invoke  PatBlt, hDCBack, 0, 0, CLOCK_SIZE, CLOCK_SIZE, PATCOPY
        invoke  DeleteObject, eax
        ; 画钟面
        ; 使用Mask清除将要画时钟边框处的背景
        invoke  BitBlt, hDCBack, 0, 0, CLOCK_SIZE, CLOCK_SIZE, @hDCMask, 0, 0, SRCAND
        invoke  BitBlt, hDCBack, 0, 0, CLOCK_SIZE, CLOCK_SIZE, @hDCCircle, 0, 0, SRCPAINT

        invoke  DeleteDC, @hDCCircle
        invoke  DeleteDC, @hDCMask
        invoke  DeleteObject, @hBmpBack
        invoke  DeleteObject, @hBmpCircle
        invoke  DeleteObject, @hBmpMask
        ret
_CreateBackground       endp

_DeleteBackground       proc

        invoke  DeleteDC, hDCBack
        invoke  DeleteDC, hDCClock
        invoke  DeleteObject, hBmpBack
        invoke  DeleteObject, hBmpClock
        ret
_DeleteBackground       endp

_Init           proc
                local   @hBmpBack, @hBmpCircle

                invoke  CreatePopupMenu
                mov     hMenu, eax
                invoke  AppendMenu, hMenu, 0, IDM_BACK1, offset szMenuBack1
                invoke  AppendMenu, hMenu, 0, IDM_BACK2, offset szMenuBack2
                invoke  AppendMenu, hMenu, MF_SEPARATOR, 0,  NULL
                invoke  AppendMenu, hMenu, 0, IDM_CIRCLE1, offset szMenuCircle1
                invoke  AppendMenu, hMenu, 0, IDM_CIRCLE2, offset szMenuCircle2
                invoke  AppendMenu, hMenu, MF_SEPARATOR, 0,  NULL
                invoke  AppendMenu, hMenu, 0, IDM_EXIT, offset szMenuExit
                invoke  CheckMenuRadioItem, hMenu, IDM_BACK1, IDM_BACK2, IDM_BACK1, NULL
                invoke  CheckMenuRadioItem, hMenu, IDM_CIRCLE1, IDM_CIRCLE2, IDM_CIRCLE1, NULL

                invoke  CreateEllipticRgn, 0, 0, CLOCK_SIZE+1, CLOCK_SIZE+1
                push    eax
                invoke  SetWindowRgn, hWinMain, eax, TRUE
                pop     eax
                invoke  DeleteObject, eax
                invoke  SetWindowPos, hWinMain, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOSIZE
                mov     dwNowBack, IDB_BACK1
                mov     dwNowCircle, IDB_CIRCLE1
                invoke  _CreateBackground
                invoke  _CreateClockPic
                invoke  SetTimer, hWinMain, ID_TIMER, 1000, NULL
                ret
_Init           endp

_Quit           proc
        
        invoke  KillTimer, hWinMain, ID_TIMER
        invoke  DestroyWindow, hWinMain
        invoke  PostQuitMessage, NULL
        invoke  _DeleteBackground
        invoke  DestroyMenu, hMenu
        ret
_Quit           endp

_ProcWinMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam
                local   @stPs: PAINTSTRUCT
                local   @hDC
                local   @stPos: POINT

        mov     eax, uMsg
        .if     eax == WM_TIMER
                ; 1秒重画一次钟面，即在钟面背景上叠加绘制指针
                invoke  _CreateClockPic
                invoke  InvalidateRect, hWnd, NULL, FALSE
        .elseif eax == WM_PAINT
                invoke  BeginPaint, hWnd, addr @stPs
                mov     @hDC, eax
                mov     eax, @stPs.rcPaint.right
                sub     eax, @stPs.rcPaint.left
                mov     ecx, @stPs.rcPaint.bottom
                sub     ecx, @stPs.rcPaint.top
                ; 复制缓存的钟面图片到显示DC
                ; 若1秒多次收到WM_PAINT不必重复计算
                invoke  BitBlt, @hDC, @stPs.rcPaint.left, @stPs.rcPaint.top, eax, ecx, hDCClock, @stPs.rcPaint.left, @stPs.rcPaint.top, SRCCOPY
                invoke  EndPaint, hWnd, addr @stPs
        .elseif eax == WM_CREATE
                mov     eax, hWnd
                mov     hWinMain, eax
                invoke  _Init
        .elseif eax == WM_COMMAND
                mov     eax, wParam
                .if     ax == IDM_BACK1
                        mov     dwNowBack, IDB_BACK1
                        invoke  CheckMenuRadioItem, hMenu, IDM_BACK1, IDM_BACK2, IDM_BACK1, NULL
                .elseif ax == IDM_BACK2
                        mov     dwNowBack, IDB_BACK2
                        invoke  CheckMenuRadioItem, hMenu, IDM_BACK1, IDM_BACK2, IDM_BACK2, NULL
                .elseif ax == IDM_CIRCLE1
                        mov     dwNowCircle, IDB_CIRCLE1
                        invoke  CheckMenuRadioItem, hMenu, IDM_CIRCLE1, IDM_CIRCLE2, IDM_CIRCLE1, NULL
                .elseif ax == IDM_CIRCLE2
                        mov     dwNowCircle, IDB_CIRCLE2
                        invoke  CheckMenuRadioItem, hMenu, IDM_CIRCLE1, IDM_CIRCLE2, IDM_CIRCLE2, NULL
                .elseif ax == IDM_EXIT
                        invoke  _Quit
                        xor     eax, eax
                        ret
                .endif
                ; 选定的背景画布或时钟边框改变则重新计算画布、边框叠加后的背景缓存
                invoke  _DeleteBackground
                invoke  _CreateBackground
                invoke  _CreateClockPic
                invoke  InvalidateRect, hWnd, NULL, FALSE
        .elseif eax == WM_CLOSE
                invoke  _Quit
        .elseif eax == WM_RBUTTONDOWN
                invoke  GetCursorPos, addr @stPos
                invoke  TrackPopupMenu, hMenu, TPM_LEFTALIGN, @stPos.x, @stPos.y, NULL, hWnd, NULL
        .elseif eax == WM_LBUTTONDOWN
                invoke  SetCursor, hCursorMove
                invoke  UpdateWindow, hWnd
                invoke  ReleaseCapture
                invoke  SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0
                invoke  SetCursor, hCursorMain
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
        invoke  LoadCursor, hInstance, IDC_MOVE
        mov     hCursorMove, eax
        invoke  LoadCursor, hInstance, IDC_MAIN
        mov     hCursorMain, eax
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
        invoke  CreateWindowEx, NULL, \
                offset szClassName, offset szClassName, \
                WS_POPUP or WS_SYSMENU, \
                100, 100, CLOCK_SIZE, CLOCK_SIZE, \
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