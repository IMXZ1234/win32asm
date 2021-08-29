.386
.model flat, stdcall
option casemap: none

include         windows.inc
include         user32.inc
include         kernel32.inc
includelib      user32.lib
includelib      kernel32.lib

.data?
hWnd       dd  ?
szBuffer   dd  256 dup (?)

.const
szCaption       db  'SendMessage', 0
szStart         db  'Press OK to start SendMessage, param: %08x', 0
szReturn        db  'SendMessage returned', 0
szDestClass     db  'MyClass', 0
szText          db  'Text send to other window', 0
szNotFound      db  'Receive Message Window not found', 0

.code
start:
        invoke  FindWindow, addr szDestClass, NULL
        .if     eax
                mov     hWnd, eax
                invoke  wsprintf, addr szBuffer, addr szStart, addr szText
                invoke  MessageBox, NULL, offset szBuffer, offset szCaption, MB_OK
                invoke  SendMessage, hWnd, WM_SETTEXT, 0, addr szText
                invoke  MessageBox, NULL, offset szReturn, offset szCaption, MB_OK
        .else
                invoke  MessageBox, NULL, offset szNotFound, offset szCaption, MB_OK
        .endif
        invoke  ExitProcess, NULL
        end     start