INCLUDE Irvine32.inc

main	EQU start@0

.stack 4096

DetectShoot proto								;�����g�� �����ϥ� �I�sBulletShoot
BulletShoot proto,planeX:word,planeY:word		;�ͤ�g�� �I�sBulletMove
BulletMove proto								;�ͤ�l�u���� �I�sDetectMove
DetectMove proto								;�������� �����ϥ� �I�sMovRight,MovLeft
MovRight proto									;�k��
MovLeft proto									;����
AllyRevive proto								;�ͤ�_��
EnemyMove proto, enemyP:coord										;�Ĥ貾��
EnemyAttack proto,enemyX:word,enemyY:word 			;�Ĥ�g�� �I�sAttackMove
AttackMove proto 									;�Ĥ�l�u����
EnemyRevive proto									;�Ĥ�_��
WriteHP proto                                          ;��ܦ�q
WriteScore proto                                       ;��ܤ���
enemyDisappear proto, enemyP:coord
.data
startLogo0 byte "###############################################################################"
startLogo1 byte "|============-|        |====|  |====|  |====|        /====\       |===========|"
startLogo2 byte "|   _______   |        |    |  |    |  |    |       / ___  \      |           |"
startLogo3 byte "|   |      |  |        |     \ |    |  /    |      / /   \  \     |  ======|  |"
startLogo4 byte "|   |------|  |         \     \|    |/     /      /  ======  \    |  |_____|  |"
startLogo5 byte "|   __________|          \     =    =     /      /   ______   \   |  _____   _|"
startLogo6 byte "|   |           |-----|   \              /      /   /      \   \  |  |    \  \ "
startLogo7 byte "|___|           |_____|    \_____/\_____/      /___/        \___\ |__|     \__\"
startLogo8 byte "###############################################################################"
startLogo9 byte "                          --press 'g' to start--                               "
startColor word lengthof startLogo0 DUP (0Dh)
startPos COORD <20,10>
score word 1
allyPlaneUp BYTE (4)DUP(20h),2Fh,2Bh,5Ch,(4)DUP(20h)
allyPlaneMid1 BYTE (2)DUP(20h),2Fh,2Dh,7Ch,20h,7Ch,2Dh,5Ch,(2)DUP(20h)
allyPlaneMid2 BYTE 2Fh,(2)DUP(2Dh),7Ch,(3)DUP(20h),7Ch,(2)DUP(2Dh),5Ch
allyPlaneDown BYTE (2)DUP(20h),2Fh,2Dh,7Ch,3Dh,7Ch,2Dh,5Ch,(2)DUP(20h)
;�����˦�
allyAttr WORD 11 DUP(0Bh)						;�����C��
allyDisAttr WORD 11 DUP (00h)					;���������C��
allyPosition COORD <40,25>						;������l��m
allyCondition byte 1							;�������A 1������,0�������_����

allyHP dword 500		    					;������q
allyScore Dword 0								;�����o��

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
enemyPosition COORD <60,0>
enemy1Position COORD <60,0>
enemy2Position COORD <40,0>
enemy3Position COORD <30,0>
enemy4Position COORD <80,0>
enemy5Position COORD <70,0>
enemy6Position COORD <50,0>					;�ĤH������l��m
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

hp BYTE 'HP:'
hpPosition COORD <1,1>                          ;HP:��m
allyhpPosition COORD <4,1>                      ;��q�Ȧ�m
hpAttr word 3 DUP(0Ah)                         ;��q����C��

Scorew BYTE "SCORE:"
ScorePosition COORD <1,2>                          ;SCORE:��m
allyScorePosition COORD <7,2>                      ;���ƭȦ�m
ScoreAttr word 6 DUP(0Ah)                         ;��������C��

endLogo0 byte "###############################################################################"
endLogo1 byte "||==|        |=========|  |========|  |========|  |========|     |=========|  |"
endLogo2 byte "||  |        |  _____  |  |  ______|  |  ______|  |   __   |     |______   |  |"
endLogo3 byte "||  |        |  |   |  |  |  |_____   |  |_____   |  |  |  |         ___|  |  |"
endLogo4 byte "||  |        |  |   |  |  |_____   |  |   _____|  |  |__|  |        |   ___|  |"
endLogo5 byte "||  |______  |  |___|  |   _____|  |  |  |______  |  ____  |        |__|      |"
endLogo6 byte "||        |  |         |  |        |  |        |  |  |   \ \         __       |"
endLogo7 byte "||========|  |=========|  |========|  |========|  |==|    \=\       |__|      |"
endLogo8 byte "###############################################################################"
endLogo9 byte "                          --press 'anychar' to end--                           "
endColor word lengthof endLogo0 DUP (0Dh)
endPos COORD <20,10>


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
									;y�b�զ^��l��m

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
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyhpPosition
	mov eax, allyHP
	call WriteDec
	;ø�s��l����
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset ScoreAttr,
		lengthof SCOREW,
		ScorePosition,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset SCOREW,
		lengthof SCOREW,
		ScorePosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyScorePosition
	mov eax, allyScore
	call WriteDec

control:


        .if score>0
                .if enemy1Position.Y>30
                 mov ax, 100
                 call RandomRange
                 add ax,8
                 mov enemy1Position.X,ax
                 mov enemy1Position.Y,0
                 .endif
		INVOKE EnemyMove,enemy1Position
                inc enemy1Position.Y
        .endif
        .if score>4
                 .if enemy2Position.Y>30
                 mov ax, 100
                 call RandomRange
                 add ax,8
                 mov enemy2Position.X,ax
                 mov enemy2Position.Y,0
                 .endif
		INVOKE EnemyMove,enemy2Position
                inc enemy2Position.Y
        .endif
        .if score>9
                .if enemy3Position.Y>30
                 mov ax, 100
                 call RandomRange
                 add ax,8
                 mov enemy3Position.X,ax
                 mov enemy3Position.Y,0
                 .endif
		INVOKE EnemyMove,enemy3Position
                inc enemy3Position.Y
        .endif
        .if score>14
                .if enemy4Position.Y>30
                 mov ax, 100
                 call RandomRange
                 mov enemy4Position.X,ax
                 mov enemy4Position.Y,0
                 .endif
		INVOKE EnemyMove,enemy4Position
                inc enemy4Position.Y
        .endif
        .if score>19
                .if enemy5Position.Y>30
                 mov ax, 100
                 call RandomRange
                 add ax,8
                 mov enemy5Position.X,ax
                 mov enemy5Position.Y,0
                 .endif
		INVOKE EnemyMove,enemy5Position
                inc enemy5Position.Y
        .endif
        .if score>24
                .if enemy6Position.Y>30
                 mov ax, 100
                 call RandomRange
                 add ax,8
                 mov enemy6Position.X,ax
                 mov enemy6Position.Y,0
                 .endif
		INVOKE EnemyMove,enemy6Position
                inc enemy6Position.Y
        .endif

	;.IF enemyPosition.Y!=22
	;	INVOKE EnemyMove,enemyPosition										;�I�s�ĤH����
		;INVOKE EnemyAttack,enemyPosition.X,enemyPosition.Y		;�I�s�ĤH�g��
	;.ENDIF
	invoke DetectShoot											;�����g��
	invoke DetectMove											;��������
	jmp control													;�j�����ĤH�U��


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

	ret
WriteHP endp

WriteScore proc
		INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset ScoreAttr,
		lengthof SCOREW,
		ScorePosition,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset SCOREW,
		lengthof SCOREW,
		ScorePosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyScorePosition
	mov eax, allyScore
	call WriteDec

	ret
WriteScore endp


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
        ;cx�Ω�P�_�l�u�����Ĥ�

bulletup:
	.if bulletPos.Y!=0
		INVOKE BulletMove       ;�l�u�V�W����
		jmp checkX
	.else
		jmp endshoot
	.endif
checkX:
	mov cx, enemy1Position.X
	mov bx, enemy1Position.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
        sub cx, bulletPos.X         ;cx�Ω�P�_�l�u�����Ĥ�
	.if cx==0
		jmp check1Y
	.elseif cx==-1
		jmp check1Y
	.elseif cx==-2
		jmp check1Y
	.elseif cx==-3
		jmp check1Y
	.elseif cx==-4
		jmp check1Y
	.endif
        mov cx, enemy2Position.X
	mov bx, enemy2Position.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
        sub cx, bulletPos.X
	.if cx==0
		jmp check2Y
	.elseif cx==-1
		jmp check2Y
	.elseif cx==-2
		jmp check2Y
	.elseif cx==-3
		jmp check2Y
	.elseif cx==-4
		jmp check2Y
	.endif
        mov cx, enemy3Position.X
	mov bx, enemy3Position.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
        sub cx, bulletPos.X
	.if cx==0
		jmp check3Y
	.elseif cx==-1
		jmp check3Y
	.elseif cx==-2
		jmp check3Y
	.elseif cx==-3
		jmp check3Y
	.elseif cx==-4
		jmp check3Y
	.endif
        mov cx, enemy4Position.X
	mov bx, enemy4Position.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
        sub cx, bulletPos.X
	.if cx==0
		jmp check4Y
	.elseif cx==-1
		jmp check4Y
	.elseif cx==-2
		jmp check4Y
	.elseif cx==-3
		jmp check4Y
	.elseif cx==-4
		jmp check4Y
	.endif
        mov cx, enemy5Position.X
	mov bx, enemy5Position.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
        sub cx, bulletPos.X
	.if cx==0
		jmp check5Y
	.elseif cx==-1
		jmp check5Y
	.elseif cx==-2
		jmp check5Y
	.elseif cx==-3
		jmp check5Y
	.elseif cx==-4
		jmp check5Y
	.endif
        mov cx, enemy6Position.X
	mov bx, enemy6Position.Y     ;enemyPosition�s�J�Ȧs��
	inc bx
        sub cx, bulletPos.X
       	.if cx==0
		jmp check6Y
	.elseif cx==-1
		jmp check6Y
	.elseif cx==-2
		jmp check6Y
	.elseif cx==-3
		jmp check6Y
	.elseif cx==-4
		jmp check6Y
        .else
                jmp bulletup
	.endif
check1Y:
	.if bulletPos.Y==bx
		invoke enemyDisappear, enemy1Position
                mov enemy1Position.Y,31
		jmp endshoot
        .else
                jmp bulletup
	.endif
check2Y:
	.if bulletPos.Y==bx
		invoke enemyDisappear, enemy2Position
                mov enemy2Position.Y,31
		jmp endshoot
        .else
                jmp bulletup
	.endif
check3Y:
	.if bulletPos.Y==bx
		invoke enemyDisappear, enemy3Position
                mov enemy3Position.Y,31
		jmp endshoot
        .else
                jmp bulletup
	.endif
check4Y:
	.if bulletPos.Y==bx
		invoke enemyDisappear, enemy4Position
                mov enemy4Position.Y,31
		jmp endshoot
        .else
                jmp bulletup
	.endif
check5Y:
	.if bulletPos.Y==bx
		invoke enemyDisappear, enemy5Position
                mov enemy5Position.Y,31
		jmp endshoot
        .else
                jmp bulletup
	.endif
check6Y:
	.if bulletPos.Y==bx
		invoke enemyDisappear, enemy6Position
                mov enemy6Position.Y,31
		jmp endshoot
        .else
                jmp bulletup
	.endif

endshoot:
    ret
BulletShoot endp

enemyDisappear proc,
        enemyP:coord
    add allyScore,1000
    call WriteScore
	;�Y�Q�g���Aenemy����
	dec enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count

	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count

	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count

	INVOKE Sleep,500                  ;����
	ret
enemyDisappear endp
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
.if allyHP==0
theend:

	call Clrscr

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo0,
		lengthof endLogo0,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo1,
		lengthof endLogo1,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo2,
		lengthof endLogo2,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo3,
		lengthof endLogo3,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo4,
		lengthof endLogo4,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo5,
		lengthof endLogo5,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo6,
		lengthof endLogo6,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo7,
		lengthof endLogo7,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo8,
		lengthof endLogo8,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo9,
		lengthof endLogo9,
		endPos,
		offset bytesWritten

call WaitMsg
exit
.else
keepgo:
    mov allyCondition,1
.endif					;�S�Ψ�
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
EnemyMove proc USES eax ebx ecx edx,
     enemyP:coord
add score,1

INVOKE Sleep,20

dec enemyP.Y
INVOKE WriteConsoleOutputAttribute,
    outputHandle,
    ADDR enemyDisappearAttr,
    sizeof enemyTop,
    enemyP,
    ADDR cellsWritten

INVOKE WriteConsoleOutputCharacter,
    outputHandle,
    ADDR enemyTop,
    sizeof enemyTop,
    enemyP,
    ADDR count

	inc enemyP.Y

INVOKE WriteConsoleOutputAttribute,
    outputHandle,
    ADDR enemyDisappearAttr,
    sizeof enemyBody,
    enemyP,
    ADDR cellsWritten

INVOKE WriteConsoleOutputCharacter,
    outputHandle,
    ADDR enemyBody,
    sizeof enemyBody,
    enemyP,
    ADDR count

	inc enemyP.Y    ; next line

INVOKE WriteConsoleOutputAttribute,
    outputHandle,
    ADDR enemyDisappearAttr,
    sizeof enemyBottom,
    enemyP,
    ADDR cellsWritten

INVOKE WriteConsoleOutputCharacter,
    outputHandle,
    ADDR enemyBottom,
    sizeof enemyBottom,
    enemyP,
    ADDR count

    dec enemyP.Y

INVOKE WriteConsoleOutputAttribute,
    outputHandle,
    ADDR enemyAttr,
    sizeof enemyTop,
    enemyP,
    ADDR cellsWritten

INVOKE WriteConsoleOutputCharacter,
    outputHandle,
    ADDR enemyTop,
    sizeof enemyTop,
    enemyP,
    ADDR count

	inc enemyP.Y

INVOKE WriteConsoleOutputAttribute,
    outputHandle,
    ADDR enemyAttr,
    sizeof enemyBody,
    enemyP,
    ADDR cellsWritten

INVOKE WriteConsoleOutputCharacter,
    outputHandle,
    ADDR enemyBody,
    sizeof enemyBody,
    enemyP,
    ADDR count

	inc enemyP.Y    ; next line

INVOKE WriteConsoleOutputAttribute,
    outputHandle,
    ADDR enemyAttr,
    sizeof enemyBottom,
    enemyP,
    ADDR cellsWritten

INVOKE WriteConsoleOutputCharacter,
    outputHandle,
    ADDR enemyBottom,
    sizeof enemyBottom,
    enemyP,
    ADDR count


sub enemyP.Y, 2
INVOKE EnemyAttack,enemyP.X,enemyP.Y		;�I�s�ĤH�g��
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
	.if AttackPos.Y==22
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
		sub allyHP,100           ;�����A��֦�q
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
