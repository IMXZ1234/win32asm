# ���Ʊ� Windows������32λ������Գ������ ���׳���

�ִ�Ĵ��룬��ԭ�������������ͳ���ṹ����ϸ΢���죬������һ�µġ�

# ԭ����������

���ӣ�https://pan.baidu.com/s/1ETo1ZEUkJkPxThtqRQtPNA 

��ȡ�룺f1ue

# ʹ��ָ��

�����ԭ�� *��2�� ׼����̻���* �����д󲿷�������Ȼ���ã��ڴ������²��䣺
1. ��Ŀά������nmake��Visual Studio���߰��У������ٷ���վ����Visual Studio��<br>����Visual Studio 2019 Community�汾��nmake.exe���ڵ�Ŀ¼Ϊ:<br>*C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30037\bin\Hostx64\x86*

2. ���н���ÿ�α���ǰ����Var.bat������ʱ����������ʵ�ʲ����ϲ���ֱ����������ϵͳ�����������÷��㣺<br>���������������� �˵���-->�����(�ڹ�������)-->ϵͳ����-->�߼�ϵͳ����(�Ҳ�)-->��������<br>��ͼ��ϵͳ�������½���<br>
(1) lib��Ŀ��·��Ϊmasm��װĿ¼�µ�libĿ¼ (*C:\masm32\lib*)<br>
(2) include��Ŀ��·��Ϊmasm��װĿ¼�µ�includeĿ¼ (*C:\masm32\include*)<br>
![lib_include.png](https://github.com/IMXZ1234/win32asm/blob/master/bin_include.png)<br>
��ͼ��path��Ŀ����ӣ�<br>
(1) masm��װĿ¼�µ�binĿ¼·�������а���rc.exe, link.exe, ml.exe (*C:\masm32\bin*)<br>
(2) nmake.exe����Ŀ¼·�� (*C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30037\bin\Hostx64\x86*)<br>
![path.png](https://github.com/IMXZ1234/win32asm/blob/master/path.png)<br>
ע����nmake.exe����Ŀ¼·����Ҳ����Visual Studio���߰��Դ���rc.exe, link.exe, ml.exe����������Ҫʹ�õ���MASM32 SDK�Դ���rc.exe, link.exe, ml.exe������ر�֤ (1) masm��װĿ¼�µ�binĿ¼·�� �� (2) nmake.exe����Ŀ¼·�� ����path��Ŀ�н�Ϊ��ǰ��λ�ã�<br>
������ú�������У�cd�������⹤��Ŀ¼(��*./chapter_4/first_window*)������nmakeָ�����ɱ�����������exe�ļ���

3. ���ڱ������ӹ����о���ʹ��cmd.exe���������Ҽ��˵�������ڵ�ǰĿ¼������cmd����ÿ�ζ���Ҫcd����ǰĿ¼������ ���cmd���Ҽ��˵�.reg ���������ӡ�

����������

�������ʻ�ӭͨ��������ϵ�ң�IMXZ123@sjtu.edu.cn