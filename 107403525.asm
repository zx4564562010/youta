INCLUDE Irvine32.inc
main	EQU start@0
.stack 4096
BulletHit proto,aPosX:byte,aPosY:byte,bPosX:byte,bPosY:byte ;;;;;;�ݭק�

DetectShoot proto								;�����g�� �����ϥ� �I�sBulletShoot
BulletShoot proto,planeX:word,planeY:word		;�ͤ�g�� �I�sBulletMove
BulletMove proto								;�ͤ�l�u���� �I�sDetectMove
DetectMove proto								;�������� �����ϥ� �I�sMovRight,MovLeft
MovRight proto									;�k��
MovLeft proto									;����
AllyRevive proto								;�ͤ�_��

EnemyMove proto  									;�Ĥ貾��
EnemyAttack proto,enemyX:word,enemyY:word 			;�Ĥ�g�� �I�sAttackMove
AttackMove proto 									;�Ĥ�l�u����
EnemyRevive proto									;�Ĥ�_��

.data

allyPlaneUp BYTE (4)DUP(20h),2Fh,2Bh,5Ch,(4)DUP(20h)
allyPlaneMid1 BYTE (2)DUP(20h),2Fh,2Dh,7Ch,20h,7Ch,2Dh,5Ch,(2)DUP(20h)
allyPlaneMid2 BYTE 2Fh,(2)DUP(2Dh),7Ch,(3)DUP(20h),7Ch,(2)DUP(2Dh),5Ch
allyPlaneDown BYTE (2)DUP(20h),2Fh,2Dh,7Ch,3Dh,7Ch,2Dh,5Ch,(2)DUP(20h)
;�����˦�
allyAttr WORD 11 DUP(0Bh)						;�����C��
allyDisAttr WORD 11 DUP (00h)					;���������C��
allyPosition COORD <40,25>						;������l��m
allyCondition byte 1							;�������A 1������,0�������_����

allyHealth byte ?								;�����ͩR
allyScore word ?								;�����o��

bullet byte '8'									;�l�u�˦�
bulletPos COORD <?,?>							;�l�u��m
bulletAttr word 0Bh								;�l�u�C��
bulletDisappearAttr word 00h					;�l�u�����C��


enemyTop BYTE ' ',3 DUP('_')
enemyBody BYTE 1 DUP('-\+/-')
enemyBottom BYTE 1 DUP('  *')
;�ĤH�����˦�
enemyAttr word 5 DUP(0Ch)						;�ĤH�����C��
enemyDisappearAttr word 5 DUP(00h)				;�ĤH���������C��
enemyPosition COORD <60,0>						;�ĤH������l��m
enemyCondition byte 1							;�ĤH�������A 1������,0���Q����

Attack byte '.'									;�ĤH�l�u�˦�
AttackPos COORD <?,?>							;�ĤH�l�u��m
AttackAttr word 0Ah								;�ĤH�l�u�C��
AttackDisappearAttr word 0						;�ĤH�l�u�����C��

outputHandle DWORD 0 						;CONSOLE ����ID
bytesWritten DWORD ?						;�^��
count DWORD 0								;�^��
cellsWritten DWORD ?						;;;;;;�ݭק�

input byte ?									;�ܼư����O�_��S
inputMov byte ?									;�ܼư����O�_��I P
inputQuit byte ?								;�ܼư����O�_��ESC

.code
main proc

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    call Clrscr

	;ø�s��l�ͭx
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

	sub allyPosition.Y,3										;y�b�զ^��l��m

	;ø�s��l�ĤH
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

	sub enemyPosition.Y, 2										;y�b�զ^��l��m

control:
	.if input==VK_ESCAPE										;esc�j���
		jmp theend
	.endif

	.IF enemyPosition.Y!=22
		INVOKE EnemyMove										;�I�s�ĤH����
		INVOKE EnemyAttack,enemyPosition.X,enemyPosition.Y		;�I�s�ĤH�g��
	.ENDIF
	invoke DetectShoot											;�����g��
	invoke DetectMove											;��������
	jmp control													;�j�����ĤH�U��

theend:
INVOKE AllyRevive												;�I�s�{�{����
	call WaitMsg
exit
main endp

;�ͤ谻���g��
DetectShoot proc
    INVOKE Sleep,15
    call ReadKey
    mov input,al
.IF input=='s'
    INVOKE BulletShoot,allyPosition.X,allyPosition.Y
.endif
	ret
DetectShoot endp

;�ͤ�l�u�g��
BulletShoot proc,
	planeX:word,
	planeY:word  						;�ǤJallyPosition

    mov ax,planeX
    mov dx,planeY
	add ax,5 							;�y�в��ʨ�l�u�ӥX�{����m
	sub dx,1   							;�P�W
    mov bulletPos.X,ax
    mov bulletPos.Y,dx

bulletup:
	.IF bulletPos.Y!=0
		INVOKE BulletMove  			 	;�l�u�V�W����
		jmp bulletup					;�j��������l�u���쩳
	.ELSE
		jmp endshoot
	.ENDIF
endshoot:
    ret
BulletShoot endp

;�ͤ�l�u����
BulletMove proc
	;�l�uø�s
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
	invoke DetectMove					;�l�u�b�����P�ɡA��������

	;�l�u����
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

    dec bulletPos.Y						;�l�u�y�ФW���@��
    ret
BulletMove endp

;�}��_���{�{�A�L�k�g������
AllyRevive proc uses ecx
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    call Clrscr

    mov allyCondition,0;				;�S�Ψ�
	mov ecx,3

blink:
	push ecx
    ;����ø�s
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

	sub allyPosition.Y,3					;y�b�զ^��l��m
	invoke Sleep,300						;����{�{

	;������������
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

	sub allyPosition.Y,3					;y�b�զ^��l��m

	invoke DetectShoot
	invoke DetectMove

    invoke Sleep,300
       pop ecx
       dec ecx
    .IF ecx!=0
        jmp blink							;�{�{�j��T��
    .ENDIF

    mov allyCondition,1						;�S�Ψ�
    ret
AllyRevive endp

;��������
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

;�V�k����
MovRight proc
	;������B
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

	;���sø�s
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

;�V������
MovLeft proc
	;������B
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

	;���sø�s
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

;�Ĥ貾��
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

;�Ĥ�g��
EnemyAttack proc USES eax edx ecx ebx ,enemyX:word,enemyY:word

    mov ax,enemyX
    mov dx,enemyY					;�ǤJenemyPosition
	add ax,2						;�y�в��ʨ�l�u�ӥX�{����m
	add dx,3
    mov AttackPos.X,ax
    mov AttackPos.Y,dx				;��m�s�JAttackPos

	mov bx,allyPosition.Y
					;cx�Ω�P�_�l�u��������
keep:
	.IF AttackPos.Y!=40				;�l�u�̲צ�m
		INVOKE AttackMove			;�I�s�l�u����

	.ELSE
        mov cx,allyPosition.X			;allyPosition�s�J�Ȧs��
        sub cx,AttackPos.X
        jmp LOO
		jmp endAttack
	.ENDIF
LOO:								;�P�_�l�u��������X�b
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
	.if AttackPos.Y==bx			;�i�@�B�P�_�l�u��������Y�b
		jmp endddd
	.else
		jmp keep
	.endif
endddd:
	.if allyCondition==1		;�i�@�B�P�_�����O�_�B��L�Ī��A
		invoke AllyRevive		;�I�s�Q�����{�{
		jmp endAttack
	.endif
endAttack:
    ret
EnemyAttack endp

;�ĤH�l�u����
AttackMove proc USES eax ebx ecx edx
	;ø�s�l�u
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
	;�����l�u
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

    inc AttackPos.Y				;�W�[�l�uY�b ���U��

    ret
AttackMove endp

end main

