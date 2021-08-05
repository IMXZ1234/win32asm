EXE = first_window.exe
OBJS = first_window.obj

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJS)
	link $(LINK_FLAG) /out:$(EXE) $(OBJS)

.asm.obj:
	ml $(ML_FLAG) $<

clean:
	del *.obj