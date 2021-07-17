# nmake工具的描述文件例子
# 宏定义
# 文件
EXE = Test.exe
OBJS = viewpe.obj
RES = rsrc.res

# 编译链接选项
LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

# 定义依赖关系和执行命令
$(EXE): $(OBJS) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJS) $(RES)
$(OBJS): Common.inc
y.obj: y.inc

# 定义汇编编译和资源编译默认规则
.asm.obj:
	ml $(ML_FALG) $<
.rc.res:
	rc $<

# 清除临时文件
clean:
	del *.obj
	del *.res