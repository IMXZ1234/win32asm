EXE = dc_copy.exe
OBJS = dc_copy.obj

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJS)
	link $(LINK_FLAG) /out:$(EXE) $(OBJS)

.asm.obj:
	ml $(ML_FLAG) $<

clean:
	del *.obj