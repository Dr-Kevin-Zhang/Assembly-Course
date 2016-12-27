;PROG0406
.MODEL SMALL	;定义内存模式为小模式
.386	;选择处理器
.STACK 512	;定义堆栈段及其尺寸为512 B
.DATA	;数据段开始
;数据在此处定义
.CODE	;代码段开始
.STARTUP	;加载后的程序入口点
;代码在此处定义
.EXIT	;返回DOS或父程序
END	;整个程序结束