EXE = icon.exe
OBJS = icon.obj
RES = icon.res

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
	del *.res
	del *.exe