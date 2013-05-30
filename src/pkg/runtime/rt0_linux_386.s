// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// 这是每个 linux 386 go 程序的入口
//
// "TEXT" 是一个 procedure，相当于定义了一个函数；
// 其中：
//  1）_rt0_386_linux 是 procedure 的名字，
//  2）SB 是 plan9 汇编定义的 pseudo-register，即：the "static base" register，它指向程序地址空间的的开始处，
//      因此，对全局数据或历程(procedure)的引用会写成相对于 SB 的偏移；
//      所有对外部的引用必须相对于 PC(the virtual program counter) 或者 SB，
//  3）第2个参数 7 可选；Go 源码中这个参数都是 7
//  4）最后一个参数用于在栈上预分配存储空间的字节数；有些CPU架构会出现负数。
TEXT _rt0_386_linux(SB),7,$8
    // MOVL 用于赋值的汇编指令，L => Long Word 表示 32 位；
    //  MOVQ 中的 Q => Quad Word 表示 64 位
    // SP 是本地栈指针，保存自动变量(automatic variables)
	MOVL	8(SP), AX
	LEAL	12(SP), BX
	MOVL	AX, 0(SP)
	MOVL	BX, 4(SP)
    // CALL 调用，进行 setup VDSO，详细见其历程注释
	CALL	runtime·linux_setup_vdso(SB)
    // CALL main 历程
	CALL	main(SB)
    // 软中断
	INT	$3

TEXT main(SB),7,$0
    // 跳转到 _rt0_386 历程
	JMP	_rt0_386(SB)

TEXT _fallback_vdso(SB),7,$0
	INT	$0x80
	RET

// DATA 标识这是一个数据段，有两个参数：
//  1) 存放数据元素的地址，包括它的大小
//  2) 数据元素的值
//
// 这里 "/4" 表示 该当前元素占用多少字节，即 _fallback_vdso 占用的字节
DATA	runtime·_vdso(SB)/4, $_fallback_vdso(SB)
// 定义全局符号（全局变量）
//  runtime·_vdso 表示全局符号的名称；
//  $4 表示该全局符号占用的内存字节数
GLOBL	runtime·_vdso(SB), $4

