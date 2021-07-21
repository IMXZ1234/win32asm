EXE = menu.exe
OBJS = menu.obj
RES = menu.res

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJS) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJS) $(RES)

.asm.obj:
	ml $(ML_FALG) $<

.rc.res:
	rc $<

clean:
	del *.obj