INCLUDE Irvine32.inc
main	EQU start@0
.stack 4096
BulletHit proto,aPosX:byte,aPosY:byte,bPosX:byte,bPosY:byte ;;;;;;待修改

DetectShoot proto								;偵測射擊 直接使用 呼叫BulletShoot
BulletShoot proto,planeX:word,planeY:word		;友方射擊 呼叫BulletMove
BulletMove proto								;友方子彈移動 呼叫DetectMove
DetectMove proto								;偵測移動 直接使用 呼叫MovRight,MovLeft
MovRight proto									;右移
MovLeft proto									;左移
AllyRevive proto								;友方復活

EnemyMove proto  									;敵方移動
EnemyAttack proto,enemyX:word,enemyY:word 			;敵方射擊 呼叫AttackMove
AttackMove proto 									;敵方子彈移動
EnemyRevive proto									;敵方復活

.data

allyPlaneUp BYTE (4)DUP(20h),2Fh,2Bh,5Ch,(4)DUP(20h)
allyPlaneMid1 BYTE (2)DUP(20h),2Fh,2Dh,7Ch,20h,7Ch,2Dh,5Ch,(2)DUP(20h)
allyPlaneMid2 BYTE 2Fh,(2)DUP(2Dh),7Ch,(3)DUP(20h),7Ch,(2)DUP(2Dh),5Ch
allyPlaneDown BYTE (2)DUP(20h),2Fh,2Dh,7Ch,3Dh,7Ch,2Dh,5Ch,(2)DUP(20h)
;飛機樣式
allyAttr WORD 11 DUP(0Bh)						;飛機顏色
allyDisAttr WORD 11 DUP (00h)					;飛機消失顏色
allyPosition COORD <40,25>						;飛機初始位置
allyCondition byte 1							;飛機狀態 1為活著,0為死掉復活中

allyHealth byte ?								;飛機生命
allyScore word ?								;飛機得分

bullet byte '8'									;子彈樣式
bulletPos COORD <?,?>							;子彈位置
bulletAttr word 0Bh								;子彈顏色
bulletDisappearAttr word 00h					;子彈消失顏色


enemyTop BYTE ' ',3 DUP('_')
enemyBody BYTE 1 DUP('-\+/-')
enemyBottom BYTE 1 DUP('  *')
;敵人飛機樣式
enemyAttr word 5 DUP(0Ch)						;敵人飛機顏色
enemyDisappearAttr word 5 DUP(00h)				;敵人飛機消失顏色
enemyPosition COORD <60,0>						;敵人飛機初始位置
enemyCondition byte 1							;敵人飛機狀態 1為活著,0為被擊落

Attack byte '.'									;敵人子彈樣式
AttackPos COORD <?,?>							;敵人子彈位置
AttackAttr word 0Ah								;敵人子彈顏色
AttackDisappearAttr word 0						;敵人子彈消失顏色

outputHandle DWORD 0 						;CONSOLE 控制ID
bytesWritten DWORD ?						;回傳
count DWORD 0								;回傳
cellsWritten DWORD ?						;;;;;;待修改

input byte ?									;變數偵測是否按S
inputMov byte ?									;變數偵測是否按I P
inputQuit byte ?								;變數偵測是否按ESC

.code
main proc

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    call Clrscr

	;繪製初始友軍
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3										;y軸調回初始位置

	;繪製初始敵人
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyAttr,
		sizeof enemyTop,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyTop,
		sizeof enemyTop,
		enemyPosition,
		ADDR count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyAttr,
		sizeof enemyBody,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyBody,
		sizeof enemyBody,
		enemyPosition,
		ADDR count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyAttr,
		sizeof enemyBottom,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		ADDR count

	sub enemyPosition.Y, 2										;y軸調回初始位置

control:
	.if input==VK_ESCAPE										;esc強制結束
		jmp theend
	.endif

	.IF enemyPosition.Y!=22
		INVOKE EnemyMove										;呼叫敵人移動
		INVOKE EnemyAttack,enemyPosition.X,enemyPosition.Y		;呼叫敵人射擊
	.ENDIF
	invoke DetectShoot											;偵測射擊
	invoke DetectMove											;偵測移動
	jmp control													;迴圈讓敵人下移

theend:
INVOKE AllyRevive												;呼叫閃爍結束
	call WaitMsg
exit
main endp

;友方偵測射擊
DetectShoot proc
    INVOKE Sleep,15
    call ReadKey
    mov input,al
.IF input=='s'
    INVOKE BulletShoot,allyPosition.X,allyPosition.Y
.endif
	ret
DetectShoot endp

;友方子彈射擊
BulletShoot proc,
	planeX:word,
	planeY:word  						;傳入allyPosition

    mov ax,planeX
    mov dx,planeY
	add ax,5 							;座標移動到子彈該出現的位置
	sub dx,1   							;同上
    mov bulletPos.X,ax
    mov bulletPos.Y,dx

bulletup:
	.IF bulletPos.Y!=0
		INVOKE BulletMove  			 	;子彈向上移動
		jmp bulletup					;迴圈讓直到子彈飛到底
	.ELSE
		jmp endshoot
	.ENDIF
endshoot:
    ret
BulletShoot endp

;友方子彈移動
BulletMove proc
	;子彈繪製
	INVOKE WriteConsoleOutputAttribute,
       outputHandle,
       offset bulletAttr,
       lengthof bulletAttr,
       bulletPos,
	   offset count
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       offset bullet,
       lengthof bullet,
       bulletPos,
	   offset bytesWritten

	INVOKE Sleep,50
	invoke DetectMove					;子彈在飛的同時，偵測移動

	;子彈消失
    INVOKE WriteConsoleOutputAttribute,
      outputHandle,
      offset bulletDisappearAttr,
      lengthof bulletDisappearAttr,
      bulletPos,
	  offset count
    INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       offset bullet,
       lengthof bullet,
       bulletPos,
	   offset bytesWritten

    dec bulletPos.Y						;子彈座標上移一格
    ret
BulletMove endp

;腳色復活閃爍，無法射擊移動
AllyRevive proc uses ecx
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    call Clrscr

    mov allyCondition,0;				;沒用到
	mov ecx,3

blink:
	push ecx
    ;飛機繪製
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3					;y軸調回初始位置
	invoke Sleep,300						;延遲閃爍

	;飛機結束擦除
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3					;y軸調回初始位置

	invoke DetectShoot
	invoke DetectMove

    invoke Sleep,300
       pop ecx
       dec ecx
    .IF ecx!=0
        jmp blink							;閃爍迴圈三次
    .ENDIF

    mov allyCondition,1						;沒用到
    ret
AllyRevive endp

;偵測移動
DetectMove proc
    INVOKE Sleep,15
    call ReadKey
    mov inputMov,al
.if inputMov=='i'
    INVOKE MovLeft
.elseif inputMov=='p'
    INVOKE MovRight
.endif
    ret
DetectMove endp
;;;;;;;;;;;;;;;;;;;

;向右移動
MovRight proc
	;擦掉原處
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	INC allyPosition.X

	;重新繪製
L5:	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3

    ret
MovRight endp

;向左移動
MovLeft proc
	;擦掉原處
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	DEC allyPosition.X

	;重新繪製
L5:	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

    sub allyPosition.Y,3

	ret
MovLeft endp

;敵方移動
EnemyMove proc
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyDisappearAttr,
		sizeof enemyTop,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyTop,
		sizeof enemyTop,
		enemyPosition,
		ADDR count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyDisappearAttr,
		sizeof enemyBody,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyBody,
		sizeof enemyBody,
		enemyPosition,
		ADDR count
	inc enemyPosition.Y    ; next line
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyDisappearAttr,
		sizeof enemyBottom,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		ADDR count

	invoke DetectShoot
	invoke DetectMove
	dec enemyPosition.Y

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyAttr,
		sizeof enemyTop,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyTop,
		sizeof enemyTop,
		enemyPosition,
		ADDR count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyAttr,
		sizeof enemyBody,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyBody,
		sizeof enemyBody,
		enemyPosition,
		ADDR count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR enemyAttr,
		sizeof enemyBottom,
		enemyPosition,
		ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		ADDR count

    sub enemyPosition.Y,2

    ret
EnemyMove endp

;敵方射擊
EnemyAttack proc USES eax edx ecx ebx ,enemyX:word,enemyY:word

    mov ax,enemyX
    mov dx,enemyY					;傳入enemyPosition
	add ax,2						;座標移動到子彈該出現的位置
	add dx,3
    mov AttackPos.X,ax
    mov AttackPos.Y,dx				;位置存入AttackPos

	mov bx,allyPosition.Y
					;cx用於判斷子彈擊中飛機
keep:
	.IF AttackPos.Y!=40				;子彈最終位置
		INVOKE AttackMove			;呼叫子彈移動

	.ELSE
        mov cx,allyPosition.X			;allyPosition存入暫存器
        sub cx,AttackPos.X
        jmp LOO
		jmp endAttack
	.ENDIF
LOO:								;判斷子彈擊中飛機X軸
	.if cx == -1
		jmp enddd
	.elseif cx == -2
		jmp enddd
	.elseif cx == -3
		jmp enddd
	.elseif cx == -4
		jmp enddd
	.elseif cx == -5
		jmp enddd
	.elseif cx == -6
		jmp enddd
	.elseif cx == -7
		jmp enddd
	.elseif cx == -8
		jmp enddd
	.elseif cx == -9
		jmp enddd
	.elseif cx == -10
		jmp enddd
	.elseif cx == -11
		jmp enddd
	.elseif cx == 0
		jmp enddd
	.else
		jmp keep
	.endif
enddd:
	.if AttackPos.Y==bx			;進一步判斷子彈擊中飛機Y軸
		jmp endddd
	.else
		jmp keep
	.endif
endddd:
	.if allyCondition==1		;進一步判斷飛機是否處於無敵狀態
		invoke AllyRevive		;呼叫被擊中閃爍
		jmp endAttack
	.endif
endAttack:
    ret
EnemyAttack endp

;敵人子彈移動
AttackMove proc USES eax ebx ecx edx
	;繪製子彈
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR AttackAttr,
		1,
		AttackPos,
		addr cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR Attack,
		1,
		AttackPos,
		addr count
	invoke DetectShoot
	invoke DetectMove
	INVOKE Sleep,10
	;擦除子彈
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		ADDR AttackDisappearAttr,
		1,
		AttackPos,
		addr cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		ADDR Attack,
		1,
		AttackPos,
		addr count

    inc AttackPos.Y				;增加子彈Y軸 往下飛

    ret
AttackMove endp

end main

