INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.386
.model flat,stdcall
.stack 4096

.data
board BYTE " 1      |2      |3      ",10,13,
           "        |       |       ",10,13,
           "        |       |       ",10,13,
           " -------+-------+-------",10,13, 
           " 4      |5      |6      ",10,13,
           "        |       |       ",10,13,
           "        |       |       ",10,13,
           " -------+-------+-------",10,13,
           " 7      |8      |9      ",10,13, 
           "        |       |       ",10,13,
           "        |       |       ",10,13,0
           
currentPlayer  BYTE 'X'
choice         DWORD ?
winner         DWORD 0
XWinsCount    DWORD 0
OWinsCount    DWORD 0
tieCount      DWORD 0
playAgainIn    BYTE 2 DUP (?)
introMessage         BYTE "TicTacToe Game",0
playAgainMessage     BYTE "Play again (y/n)? ",0
outroMessage         BYTE "Thanks for playing!",0
whoseTurnMessage          BYTE "'s turn. Choose a square: ",0
invalidChoiceMessage BYTE "Invalid choice. Choose a square: ",0
tieMessage          BYTE "Tie!",0
winMessage          BYTE " wins!",0
winCountMessage      BYTE " Wins: ",0
tieMessageCount     Byte "Ties: ",0

.code
printIntro     PROTO
clearBoard     PROTO
printBoard     PROTO
chooseSquare   PROTO
checkWinner    PROTO
processWinner  PROTO
processTie     PROTO
switchPlayer   PROTO
printOutro     PROTO

main PROC
     ; print intro
     call printIntro

Play:  
     ; clear board
     push OFFSET board
     call clearBoard
     
     ; print starting board
     push OFFSET board
     call printBoard

     ; prompt for choices until game is won
Loop1:   
     ; prompt player to choose square
     mov al,currentPlayer          ; move currentPlayer (X or O) into al
     push eax                      ; push currentPlayer (in al) to stack
     push OFFSET board             ; push address of board to stack
     call chooseSquare
     
     ; print board after move
     push OFFSET board
     call printBoard

     ; check if game over    
     push OFFSET winner            ; push address of winner to stack
     mov al,currentPlayer          ; move currentPlayer (X or O) into al
     push eax                      ; push currentPlayer (in al) to stack
     push OFFSET board             ; push address of board to stack
     call checkWinner
     mov eax,winner
     cmp eax,1                     ; if winner/eax is 1, game is over
     je Win
     cmp eax,2
     je Tie

     ; switch to other player
     push OFFSET currentPlayer
     call switchPlayer
     jmp Loop1

Win:
     push OFFSET tieCount
     push OFFSET OWinsCount
     push OFFSET XWinsCount
     mov al,currentPlayer          ; move currentPlayer (X or O) into al
     push eax                      ; push currentPlayer (in al) to stack
     call processWinner
     jmp PlayAgain

Tie:
     push OFFSET tieCount
     push OFFSET OWinsCount
     push OFFSET XWinsCount
     call processWinner
     jmp PlayAgain
     
PlayAgain:
     ; prompt for another game
     mov edx,OFFSET playAgainMessage
     call WriteString
     mov edx,OFFSET playAgainIn
     mov ecx,2
     call ReadString
     mov al,playAgainIn
     cmp al,'y'
     je Play
     cmp al,'n'
     je Finish
     
Finish: 
     ; print outro
     call printOutro
     
     ; pause before closing window
     call WaitMsg
	
     call ExitProcess
main ENDP

; Prints intro message.
;    Pre: nothing
;    Post:  nothing
printIntro PROC
     mov edx,OFFSET introMessage
     call WriteString
     call Crlf
     call Crlf
     ret
printIntro ENDP

; Clears board.
;    Pre: [ebp + 8] = address of board
;    Post:  nothing
clearBoard PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; clear board squares
     mov esi,[ebp + 8]        ; move address of board into esi
     mov bl,' '
     mov [esi + 30],bl
     mov [esi + 38],bl
     mov [esi + 46],bl
     mov [esi + 134],bl
     mov [esi + 142],bl
     mov [esi + 150],bl
     mov [esi + 238],bl
     mov [esi + 246],bl
     mov [esi + 254],bl

     ; clean up stack frame
     popad
     pop  ebp
     ret  4
clearBoard ENDP

; Prints board.
;    Pre: [ebp + 8] = address of board
;    Post:  nothing
printBoard PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; print board
     call Crlf
     call Crlf
     call Crlf
     mov edx,[ebp + 8]
     call WriteString
     call Crlf

     ; clean up stack frame
     popad
     pop  ebp
     ret  4
printBoard ENDP

; Prompts player to choose a cell in the board to place an X or O. Validates input and
; will only accept a number 1-9. Cells to place at are as follows:
; 1 = 30, 2 = 38, 3 = 46, 4 = 134, 5 = 142, 6 = 150, 7 = 238, 8 = 246, 9 = 254
;    Pre: [ebp +  8] = address of board
;              [ebp + 12] = currentPlayer
;    Post:  nothing
chooseSquare PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; loop until choice entered
     mov  eax,[ebp + 12]
     call WriteChar
     mov edx,OFFSET whoseTurnMessage
     call WriteString

ValidateSquare:
     call ReadDec
     mov  choice,eax
     cmp  choice,9
     ja   Invalid             ; value for terms too high, jump to Invalid
     cmp  choice,1
     jb   Invalid             ; value for terms too low, jump to Invalid
     cmp choice,1                         
     je Place1                
     cmp choice,2                         
     je Place2                
     cmp choice,3                         
     je Place3               
     cmp choice,4                         
     je Place4               
     cmp choice,5                         
     je Place5               
     cmp choice,6                         
     je Place6                
     cmp choice,7                         
     je Place7                
     cmp choice,8                         
     je Place8                
     cmp choice,9                         
     je Place9                
     jmp  Finish

Place1:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,30               ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place2:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,38               ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place3:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,46               ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place4:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,134              ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place5:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,142              ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place6:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,150              ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place7:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,238              ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place8:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,246              ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Place9:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,254              ; increment esi to correct cell
     mov bl,' '
     cmp [esi],bl             ; check if cell is empty
     jne Invalid              ; jump if cell is not empty
     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov [esi],bl             
     jmp Finish

Invalid:
     mov  edx,OFFSET invalidChoiceMessage
     call WriteString
     jmp  ValidateSquare

Finish:
     ; clean up stack frame
     popad
     pop  ebp
     ret 8
chooseSquare ENDP

; Checks to see if either player has won by looking for runs of 3 X's or O's. Done by looking at a
; particular cell in the board array. For example, a run in the first row would mean
; that cell 30, 38, and 46 would all be either X or O.
;    Pre: [ebp +  8] = address of board  
;              [ebp + 12] = currentPlayer
;              [ebp + 16] = winner
;    Post:  0 in winner if no winner found, 1 if winner found, 2 if tie
checkWinner PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     mov bl,[ebp + 12]        ; move currentPlayer into bl
     mov edi,[ebp + 16]       ; store address of winner in edi

CheckRow1:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,30               ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckRow2            ; no winner here, so check next row, column, or diagonal
     add esi,8                ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckRow2            ; no winner here, so check next row, column, or diagonal
     add esi,8                ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckRow2            ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckRow2:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,134              ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckRow3            ; no winner here, so check next row, column, or diagonal
     add esi,8                ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckRow3            ; no winner here, so check next row, column, or diagonal
     add esi,8                ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckRow3            ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckRow3:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,238              ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn1         ; no winner here, so check next row, column, or diagonal
     add esi,8                ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn1         ; no winner here, so check next row, column, or diagonal
     add esi,8                ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn1         ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckColumn1:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,30               ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn2         ; no winner here, so check next row, column, or diagonal
     add esi,104              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn2         ; no winner here, so check next row, column, or diagonal
     add esi,104              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn2         ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckColumn2:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,38               ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn3         ; no winner here, so check next row, column, or diagonal
     add esi,104              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn3         ; no winner here, so check next row, column, or diagonal
     add esi,104              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckColumn3         ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckColumn3:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,46               ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckDiagonal1       ; no winner here, so check next row, column, or diagonal
     add esi,104              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckDiagonal1       ; no winner here, so check next row, column, or diagonal
     add esi,104              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckDiagonal1       ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckDiagonal1:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,30               ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckDiagonal2       ; no winner here, so check next row, column, or diagonal
     add esi,112              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckDiagonal2       ; no winner here, so check next row, column, or diagonal
     add esi,112              ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckDiagonal2       ; no winner here, so check next row, column, or diagonal
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckDiagonal2:
     mov esi,[ebp + 8]        ; move address of board into esi
     add esi,46               ; increment esi to correct cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckTie            ; no winner here, so no winner at all
     add esi,96               ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckTie            ; no winner here, so no winner at all
     add esi,96               ; increment esi to next cell
     cmp [esi],bl             ; check if cell is the same as currentPlayer
     jne CheckTie            ; no winner here, so no winner at all
     jmp WinnerFound          ; if we've made it this far then we have a winner

CheckTie:
     mov esi,[ebp + 8]        ; move address of board into esi
     mov bl,' '
     cmp [esi + 30],bl        ; check if cell is empty
     je NoWinnerFound         ; cell is empty, so can't be tie
     cmp [esi + 38],bl
     je NoWinnerFound
     cmp [esi + 46],bl
     je NoWinnerFound
     cmp [esi + 134],bl
     je NoWinnerFound
     cmp [esi + 142],bl
     je NoWinnerFound
     cmp [esi + 150],bl
     je NoWinnerFound
     cmp [esi + 238],bl
     je NoWinnerFound
     cmp [esi + 246],bl
     je NoWinnerFound
     cmp [esi + 254],bl
     je NoWinnerFound
     jmp TieFound

NoWinnerFound:
     mov edx,0
     mov [edi],edx
     jmp Finish

WinnerFound:
     mov edx,1
     mov [edi],edx
     jmp Finish

TieFound:
     mov edx,2
     mov [edi],edx
     jmp Finish

Finish:
     ; clean up stack frame
     popad
     pop  ebp
     ret 12
checkWinner ENDP

; Prints winner and increments that player's score.
;    Pre: [ebp +  8] = currentPlayer
;              [ebp + 12] = address of XWinsCount
;              [ebp + 16] = address of OWinsCount
;              [ebp + 20] = address of tieCount
;    Post:  nothing
processWinner PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; process arguments
     mov eax,[ebp + 8]
     mov esi,[ebp + 12]            ; move address of XWinsCount into esi
     mov edi,[ebp + 16]            ; move address of OWinsCount into edi

     ; print winner
     call WriteChar
     mov edx,OFFSET winMessage
     call WriteString
     call Crlf
     call Crlf
     call Crlf
     call Crlf

     ; increment wins
     cmp al,'X'
     je IncrementXwins
     cmp al,'O'
     je IncrementOwins

IncrementXwins:
     mov ebx,[esi]
     inc ebx
     mov [esi],ebx
     jmp PrintScores

IncrementOwins:
     mov ebx,[edi]
     inc ebx
     mov [edi],ebx
     jmp PrintScores

     ; print scores
PrintScores:
     mov esi,[ebp + 12]             ; move address of XWinsCount into esi
     mov al,'X'
     call WriteChar
     mov edx,OFFSET winCountMessage
     call WriteString
     mov eax,[esi]
     call WriteDec
     call Crlf

     mov esi,[ebp + 16]            ; move address of OWinsCount into esi
     mov al,'O'
     call WriteChar
     mov edx,OFFSET winCountMessage
     call WriteString
     mov eax,[esi]
     call WriteDec
     call Crlf

     mov esi,[ebp + 20]            ; move address of tieCount into esi
     mov edx,OFFSET tieMessageCount
     call WriteString
     mov eax,[esi]
     call WriteDec
     call Crlf
     call Crlf
     call Crlf
     call Crlf

     ; clean up stack frame
     popad
     pop  ebp
     ret 16
processWinner ENDP

; Prints tie and increments tieCount.
;    Pre: [ebp +  8] = address of XWinsCount
;              [ebp + 12] = address of OWinsCount
;              [ebp + 16] = address of tieCount
;    Post:  nothing
processTie PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; print tie!
     mov edx,OFFSET tieMessage
     call WriteString
     call Crlf

     ; increment tie
IncrementTies:
     mov esi,[ebp + 16]            ; move address of tieCount into esi
     mov ebx,[esi]
     inc ebx
     mov [esi],ebx
     jmp PrintScores

     ; print scores
PrintScores:
     mov esi,[ebp + 8]             ; move address of XWinsCount into esi
     mov al,'X'
     call WriteChar
     mov edx,OFFSET winCountMessage
     call WriteString
     mov eax,[esi]
     call WriteDec
     call Crlf

     mov esi,[ebp + 12]            ; move address of OWinsCount into esi
     mov al,'O'
     call WriteChar
     mov edx,OFFSET winCountMessage
     call WriteString
     mov eax,[esi]
     call WriteDec
     call Crlf

     mov esi,[ebp + 16]            ; move address of tieCount into esi
     mov edx,OFFSET tieMessageCount
     call WriteString
     mov eax,[esi]
     call WriteDec
     call Crlf

     ; clean up stack frame
     popad
     pop  ebp
     ret 12
processTie ENDP

; Switches an X to an O or an O to an X.
;    Pre: [ebp + 8] = address of currentPlayer  
;    Post:  nothing
switchPlayer PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; get currentPlayer char
     mov esi,[ebp + 8]        ; move address of currentPlayer into esi
     mov ebx,[esi]            ; move character pointed to by eax to ebx

     ; prepare registers for comparison
     mov ecx,'X'
     mov edx,'O'

     ; compare 
     cmp bl,cl                ; currentPlayer is X so switch to O
     je XtoO
     cmp bl,dl                ; currentPlayer is O so switch to X
     je OtoX

     ; swap currentPlayer
XtoO:
     mov bl,dl
     jmp Finish
OtoX:
     mov bl,cl
     jmp Finish
     
Finish:
     ; move back into currentPlayer via address in esi
     mov [esi],bl

     ; clean up stack frame
     popad
     pop  ebp
     ret 4
switchPlayer ENDP

; Prints outro.
;    Pre: nothing
;    Post:  nothing
printOutro PROC
    ; prepare stack frame
     push ebp
     mov  ebp,esp
     pushad

     ; procedure code here
     mov edx,OFFSET outroMessage
     call WriteString
     call Crlf

     ; clean up stack frame
     popad
     pop  ebp
     ret
printOutro ENDP

END main