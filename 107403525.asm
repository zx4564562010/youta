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
WriteHP proto                                       ;��ܦ�q
;�|�y�}
.data
startLogo0 byte "###############################################################################"
startLogo1 byte "�z�w�w�w�w�w�w�w�w�w�w�w�w�w�{        |====|  |====|  |====|        /====\       |===========|"
startLogo2 byte "�y   _______  �y       |    |  |    |  |    |       / ___  \      |           |"
startLogo3 byte "�y   |      | �y       |     \ |    |  /    |      / /   \  \     |  ======|  |"
startLogo4 byte "�y   �|�w�w�w�w�w�w�} �y        \     \|    |/     /      /  ======  \    |  |_____|  |"
startLogo5 byte "�y   �z�w�w�w�w�w�w�w�w�w�}         \     =    =     /      /   ______   \   |  _____   _|"
startLogo6 byte "�y   |          �z�w�w�w�w�w�{   \              /      /   /      \   \  |  |    \  \ "
startLogo7 byte "�y___|          �|�w�w�w�w�w�}    \_____/\_____/      /___/        \___\ |__|     \__\"
startLogo8 byte "###############################################################################"
startLogo9 byte "                          --press 'g' to start--                               "
startColor word lengthof startLogo0 DUP (0Dh)
startPos COORD <20,10>

allyPlaneUp BYTE (4)DUP(20h),2Fh,2Bh,5Ch,(4)DUP(20h)
allyPlaneMid1 BYTE (2)DUP(20h),2Fh,2Dh,7Ch,20h,7Ch,2Dh,5Ch,(2)DUP(20h)
allyPlaneMid2 BYTE 2Fh,(2)DUP(2Dh),7Ch,(3)DUP(20h),7Ch,(2)DUP(2Dh),5Ch
allyPlaneDown BYTE (2)DUP(20h),2Fh,2Dh,7Ch,3Dh,7Ch,2Dh,5Ch,(2)DUP(20h)
;�����˦�
allyAttr WORD 11 DUP(0Bh)						;�����C��
allyDisAttr WORD 11 DUP (00h)					;���������C��
allyPosition COORD <40,25>						;������l��m
allyCondition byte 1							;�������A 1������,0�������_����

allyHP dword 1000		    					;������q
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

hp BYTE 1 DUP('HP: 1000')
hpPosition COORD <1,1>                          ;HP: ��m
allyhpPosition COORD <5,1>                      ;��q�Ȧ�m
hpAttr word 10 DUP(0Ah)                         ;��q����C��
hpDisAttr WORD 1 DUP (00h)				    	;��q�����C��
.code
main proc

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
     INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo0,
		lengthof startLogo0,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo1,
		lengthof startLogo1,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo2,
		lengthof startLogo2,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo3,
		lengthof startLogo3,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo4,
		lengthof startLogo4,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo5,
		lengthof startLogo5,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo6,
		lengthof startLogo6,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo7,
		lengthof startLogo7,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo8,
		lengthof startLogo8,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo9,
		lengthof startLogo9,
		startPos,
		offset bytesWritten
    inc startPos.Y
    q:
    call ReadChar
    .if al=='g'
    call Clrscr
    .else
        jmp q
    .endif


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
		offset enemyAttr,
		sizeof enemyTop,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyPosition,
		offset count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBody,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyPosition,
		offset count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBottom,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		offset count

	sub enemyPosition.Y, 2										;y�b�զ^��l��m

	;ø�s��l��q
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset hpAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count

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

;��ܦ�q
WriteHP proc
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset hpAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyhpPosition
	mov eax, allyHP
	call WriteDec

	add hpPosition.X, 7
	INVOKE WriteConsoleOutputAttribute,     ;��1000���̫�@��0����
		outputHandle,
		offset hpDisAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count
	sub hpPosition.X, 7

	ret
WriteHP endp

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
BulletShoot proc USES eax edx ecx ebx,
	planeX:word,
	planeY:word                ;�n��planeX,planeY

    mov ax,planeX
    mov dx,planeY
	add ax,5                   ;�y�о��^�l�u�ӥX�{����m
	sub dx,4                   ;�P�W
    mov bulletPos.X,ax
    mov bulletPos.Y,dx

	;�T�{�Ĥ観�S���Q�ڤ�l�u�g��
	mov cx, enemyPosition.X
	mov bx, enemyPosition.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
    sub cx, bulletPos.X         ;cx�Ω�P�_�l�u�����Ĥ�

bulletup:
	.if bulletPos.Y!=0
		INVOKE BulletMove       ;�l�u�V�W����
		jmp checkX
	.else
		jmp endshoot
	.endif
checkX:
	.if cx==0
		jmp checkY
	.elseif cx==-1
		jmp checkY
	.elseif cx==-2
		jmp checkY
	.elseif cx==-3
		jmp checkY
	.elseif cx==-4
		jmp checkY
	.else
		jmp bulletup
	.endif
checkY:
	.if bulletPos.Y==bx
		jmp enemyDisappear
	.else
		jmp bulletup
	.endif
enemyDisappear:

	;�Y�Q�g���Aenemy����
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyPosition,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyPosition,
		offset count

	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyPosition,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyPosition,
		offset count

	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyPosition,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		offset count

	INVOKE Sleep,500                  ;����
	mov enemyPosition.Y, -1           ;enemy���^���T��m

endshoot:
    ret
BulletShoot endp

;�ͤ�l�u����
BulletMove proc USES eax ebx ecx edx
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
    ;call Clrscr

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
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyPosition,
		offset count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyPosition,
		offset count
	inc enemyPosition.Y    ; next line
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		offset count

	invoke DetectShoot
	invoke DetectMove
	dec enemyPosition.Y

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyTop,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyPosition,
		offset count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBody,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyPosition,
		offset count
	inc enemyPosition.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBottom,
		enemyPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyPosition,
		offset count

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

keep:
	.if AttackPos.Y==20
		mov bx,allyPosition.Y
		mov cx,allyPosition.X			;allyPosition�s�J�Ȧs��
		sub cx,AttackPos.X				;cx�Ω�P�_�l�u��������
	.endif
	.IF AttackPos.Y!=40				;�l�u�̲צ�m
		INVOKE AttackMove			;�I�s�l�u����
		jmp LOO
	.ELSE
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
		sub allyHP,50           ;�����A��֦�q
		INVOKE WriteHP          ;��ܦ�q
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

