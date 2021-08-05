EXE = control.exe
OBJS = control.obj
RES = control.res

LINK_FLAG = /subsystem:windows
ML_FLAG = /coff /c
# RC_FLAG = /i C:\masm32\include$(RC_FLAG) 

$(EXE): $(OBJS) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJS) $(RES)

.asm.obj:
	ml $(ML_FLAG) $<

.rc.res:
	rc $<

clean:
	del *.obj