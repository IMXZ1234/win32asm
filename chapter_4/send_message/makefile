SENDEREXE = sender.exe
SENDEROBJ = sender.obj
RECEIVEREXE = receiver.exe
RECEIVEROBJ = receiver.obj

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

# 最终目标文件包含多个可以像这样写
# all出现在第一行，被视为最终目标，即便它其实不是一个文件
all: $(SENDEREXE) $(RECEIVEREXE)

$(SENDEREXE): $(SENDEROBJ)
	link $(LINK_FLAG) /out:$(SENDEREXE) $(SENDEROBJ)

$(RECEIVEREXE): $(RECEIVEROBJ)
	link $(LINK_FLAG) /out:$(RECEIVEREXE) $(RECEIVEROBJ)

.asm.obj:
	ml $(ML_FLAG) $<

clean:
	del *.obj