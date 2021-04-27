TITLE Hangman         (Hangman.asm)

; Desc TODO

;--------------------------------------------------------------------------
INCLUDE Irvine32.inc
; We made use of the following procedures from Kip Irvine's library:
;
;   WriteString     - Prints string starting with base address in EDX register
;   WriteChar       - Prints char in the EAX register
;   ReadChar        - Gets char from keyboard and stores in EAX register
;   Crlf            - Prints a newline
;   Str_length      - 
;   Str_copy        - 
;   Randomize       - 
;   RandomRange     - 
;--------------------------------------------------------------------------

.data
theWord         byte    15  DUP(0)
wrongGuesses    byte    0
rightGuesses    byte    0
gameDone        byte    0

; Arrays to hold guesses
wrongArray      byte    7   DUP(0)
rightArray      byte    26  DUP(0)

; Words to Guess
numOfWords      byte    16
word00          byte    "DINOSAUR",0
word01          byte    "BANJO",0
word02          byte    "BIKINI",0
word03          byte    "BLIZZARD",0
word04          byte    "DIZZY",0
word05          byte    "FLAPJACK",0
word06          byte    "GALAXY",0
word07          byte    "ICEBOX",0
word08          byte    "JUMBO",0
word09          byte    "GOSSIP",0
word10          byte    "JUKEBOX",0
word11          byte    "KAYAK",0
word12          byte    "LUCKY",0
word13          byte    "RHYTHM",0
word14          byte    "SUBWAY",0
word15          byte    "WITCHCRAFT",0

; String of spaces for clearing screen
clearStr        byte    "                                  ",0dh,0ah,0

; Prompts and Messages
select          byte    " Make a Selection: ",0
pressKey        byte    " Press Any Key: ",0
triedLetters    byte    " Already Tried: ",0
chooseLetter    byte    " Choose a Letter: ",0

; Main Menu Strings
titleScr        byte    "          Hangman",0dh,0ah,0dh,0ah,0dh,0ah
                byte    "          [s]tart",0dh,0ah
                byte    "          [q]uit",0dh,0ah
                byte    "          [c]redits",0dh,0ah,0

; Credits String
madeBy          byte    "          Made by:",0dh,0ah,0dh,0ah
                byte    "      Christian Baker",0dh,0ah
                byte    "      Anthony Cardona",0dh,0ah
                byte    "         Luke Shoff",0dh,0ah
                byte    "      Brendon Stutzman",0dh,0ah,0

; Gallows Strings
gallowsTop      byte    "  ______",0dh,0ah
                byte    "  |/   |",0dh,0ah
                byte    "  |    |",0dh,0ah,0
gallowsNoose    byte    "  |    O",0dh,0ah,0
gallowsMid      byte    "  |",0dh,0ah,0
gallowsBase     byte    "  |\",0dh,0ah
                byte    " `````````",0dh,0ah,0

; Man Strings
manHead         byte    "  |    ()",0dh,0ah,0
manTorso        byte    "  |    ||",0dh,0ah,0
manArm          byte    "  |   /||",0dh,0ah,0
manArms         byte    "  |   /||\",0dh,0ah,0
manLeg          byte    "  |    /",0dh,0ah,0
manLegs         byte    "  |    /\",0dh,0ah,0

; End Strings
winner          byte    "        You Win! :)",0dh,0ah,0
loser           byte    "        Game Over :(",0dh,0ah,0
wordWas         byte    "       The word was",0dh,0ah
                byte    "         ",0

.code
main PROC
MainMenu:
    call PrintMenu                  ; print the menu screen
    call ReadChar                   ; get input char from user
    cmp  al,'q'                     ; if user input is 'q'...
    je   QuitGame                   ; then quit game
    cmp  al,'s'                     ; if user input is 's'...
    je   PlayGame                   ; then start game
    cmp  al,'c'                     ; if user input is 'c'...
    je   CreditScreen               ; then show credits
    jmp  MainMenu                   ; else loop back to menu

PlayGame:
    call ClearScreen
    mov  eax,0                      ; Initialize input for game
    mov  gameDone,al                ; done    = 0 (false)
    mov  rightGuesses,al            ; correct = 0
    mov  wrongGuesses,al            ; wrong   = 0
    call GetWord                    ; Get random word from list
ContGame:
    call PrintHangman               ; Print ASCII hangman
    call PrintWord                  ; Print letters of the word
    call PrintGuesses               ; Print wrong letters tried
    mov  edx,OFFSET chooseLetter    ; edx <- chooseLetter prompt string
    call WriteString                ; Print string (Irvine)
    mov  al,gameDone
    cmp  al,0
    jg   EndGame
    call ReadChar                   ; Get guessed letter from user
    call CheckChar                  ; Store char if eligible
    mov  al,gameDone
    cmp  al,1
    jl  ContGame                    ; then continue game
EndGame:
    call PrintEnd
    call ReadChar
    jmp  MainMenu                   ; else quit to main menu

CreditScreen:
    call PrintCredits               ; Print credits
    call ReadChar                   ; Wait for input
    jmp  MainMenu                   ; Go back to main menu

QuitGame:
    call ClearScreen                ; Clear the screen
    exit
main ENDP



;--------------------------------------------------------------------------
PrintMenu PROC
; Author: Team C
;
; Prints the menu screen with prompt.
;
; Registers used: AX, EDX
; Returns: Nothing
;--------------------------------------------------------------------------
    call ClearScreen                ; Clear the screen
    mov  ecx,5                      ; Newlines to print = 5
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET titleScr        ; Print hangman title and options
    call WriteString
    mov  ecx,3                      ; Newlines to print = 3
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET select          ; Print make selection prompt string
    call WriteString
    ret
PrintMenu ENDP

;--------------------------------------------------------------------------
PrintCredits PROC
; Author: Team C
;
; Prints the team credits screen with prompt.
;
; Registers used: AX, EDX
; Returns: Nothing
;--------------------------------------------------------------------------
    call ClearScreen                ; Clears the screen
    mov  ecx,5                      ; Prints 5 newlines
    call PrintNewLines
    mov  edx,OFFSET madeBy          ; Prints our names
    call WriteString
    mov  ecx,3                      ; Prints 3 newlines
    call PrintNewLines                   
    mov  edx,OFFSET pressKey        ; Prints "Press Any Key"
    call WriteString
    ret
PrintCredits ENDP

;--------------------------------------------------------------------------
GetWord PROC
; Author: Anthony Cardona
;
; Desc TODO
;
; Registers used: AX
; Returns: 
;--------------------------------------------------------------------------
    mov  al,numOfWords
    call Randomize
    call RandomRange

W00:
    cmp  al, 0
    jne  W01
    invoke Str_copy, addr word00, addr theWord
    jmp  goback
W01:
    cmp  al, 1 
    jne  W02
    invoke Str_copy, addr word01, addr theWord
    jmp  goback
W02:
    cmp  al, 2 
    jne  W03
    invoke Str_copy, addr word02, addr theWord
    jmp  goback
W03:
    cmp  al, 3 
    jne  W04
    invoke Str_copy, addr word03, addr theWord
    jmp  goback
W04:
    cmp  al, 4 
    jne  W05
    invoke Str_copy, addr word04, addr theWord
    jmp  goback
W05:
    cmp  al, 5 
    jne  W06
    invoke Str_copy, addr word05, addr theWord
    jmp  goback
W06:
    cmp  al, 6 
    jne  W07
    invoke Str_copy, addr word06, addr theWord
    jmp  goback
W07:
    cmp  al, 7 
    jne  W08
    invoke Str_copy, addr word07, addr theWord
    jmp  goback
W08:
    cmp  al, 8 
    jne  W09
    invoke Str_copy, addr word08, addr theWord
    jmp  goback
W09:
    cmp  al, 9 
    jne  W10
    invoke Str_copy, addr word09, addr theWord
    jmp  goback
W10:
    cmp  al, 10 
    jne  W11
    invoke Str_copy, addr word10, addr theWord
    jmp  goback
W11:
    cmp  al, 11 
    jne  W12
    invoke Str_copy, addr word11, addr theWord
    jmp  goback
W12:
    cmp  al, 12 
    jne  W13
    invoke Str_copy, addr word12, addr theWord
    jmp  goback
W13:
    cmp  al, 13 
    jne  W14
    invoke Str_copy, addr word13, addr theWord
    jmp  goback
W14:
    cmp  al, 14 
    jne  W15
    invoke Str_copy, addr word14, addr theWord
    jmp  goback
W15:
    invoke Str_copy, addr word15, addr theWord
goback:
    ret
GetWord ENDP

;--------------------------------------------------------------------------
PrintHangman PROC USES edx eax
; Author: Team C
;
; Prints the ASCII hangman character. Checks to see which parts to print
; based on how many wrong letter guesses that the user has made.
;--------------------------------------------------------------------------
    mov  dx,0                       ; Set cursor position to (0,0)
    call Gotoxy                     ; (Faster than clearing screen)
    mov  al,wrongGuesses            ; al <-- # of wrong guesses
    call Crlf                       ; Print newline
    mov  edx,OFFSET gallowsTop      ; Print top part of gallows
    call WriteString

    cmp  al,1                       ; If wrong guesses < 1...
    jl   TheNoose                   ; Then jump to TheNoose
    mov  edx,OFFSET manHead         ; EDX <-- manHead
    jmp  Write1                     ; Jump to Write1
TheNoose:
    mov  edx,OFFSET gallowsNoose    ; Else, edx <-- noose
Write1:
    call WriteString                ; Print line 1 option from EDX

    cmp  al,4                       ; If wrong guesses < 4...
    jl   OneArm                     ; Then jump to OneArm
    mov  edx,OFFSET manArms         ; EDX <-- manArms
    jmp  Write2                     ; Jump to Write2
OneArm:
    cmp  al,3                       ; If wrong guesses < 3...
    jl   TheTorso                   ; Then jump to TheTorso
    mov  edx,OFFSET manArm          ; EDX <-- manArm
    jmp  Write2                     ; Jump to Write2
TheTorso:
    cmp  al,2                       ; If wrong guesses < 2...
    jl   NoTorso                    ; Then jump to NoTorso
    mov  edx,OFFSET manTorso        ; EDX <-- manTorso
    jmp  Write2                     ; Jump to Write2
NoTorso:
    mov  edx,OFFSET gallowsMid      ; Else, EDX <-- gallowsMid
Write2:
    call WriteString                ; Print line 2 option from EDX

    cmp  al,6                       ; If wrong guesses < 6...
    jl   OneLeg                     ; Then jump to OneLeg
    mov  edx,OFFSET manLegs         ; EDX <-- manLegs
    jmp  Write3                     ; Jump to Write3
OneLeg:
    cmp  al,5                       ; If wrong guesses < 5...
    jl   NoLegs                     ; Then jump to NoLegs
    mov  edx,OFFSET manLeg          ; EDX <-- manLeg
    jmp  Write3                     ; Jump to Write3
NoLegs:
    mov  edx,OFFSET gallowsMid      ; Else, EDX <-- gallowsMid
Write3:
    call WriteString                ; Print line 3 option from EDX

    mov  edx,OFFSET gallowsBase     ; Print bottom part of gallows
    call WriteString
    ret
PrintHangman ENDP

;--------------------------------------------------------------------------
PrintWord PROC
; Author: Christian Baker
;
; Fixed.
;--------------------------------------------------------------------------
    mov  al,1                       ;
    mov  gameDone,al                ;

    mov  esi,OFFSET theWord         ;
    mov  dh,[esi]                   ;
    invoke Str_length, addr theWord ; eax <- length
    mov  ecx,eax                    ;
OL:
    push ecx
    mov  edi,OFFSET rightArray
    mov  dl,[esi]
    mov  bl,rightGuesses

    mov  al,' '
    call WriteChar

    mov  cl,rightGuesses
    cmp  cl,0
    jle  UnderScore

IL:
    mov  dh,[edi]
    cmp  dl,dh
    jne  NextCmp
    mov  al,dl
    call WriteChar
    jmp  NextLetter
NextCmp:
    inc  edi
    loop IL

UnderScore:
    mov  al,'_'
    call WriteChar
    mov  al,0
    mov  gameDone,al

NextLetter:
    inc  esi
    pop  ecx
    loop OL

    mov  ecx,3
    call PrintNewlines
    ret
PrintWord ENDP

;--------------------------------------------------------------------------
PrintGuesses PROC USES eax ecx edx esi
; Author: Luke Shoff
;
;
;--------------------------------------------------------------------------
    mov edx,OFFSET triedLetters
    call WriteString
    mov esi, OFFSET wrongArray
    mov cl, wrongGuesses            ; moves wrongGuesses into cl reg
    cmp cl,0
    jle ExitLoop

L1:
    mov al,[esi]                    ; put char of wrongArray in al
    call WriteChar

    cmp cl,1                        ; If last iteration...
    je ExitLoop                     ; Jump to skip printing comma
    mov  al,','
    call WriteChar
    mov  al,' '
    call WriteChar
    inc  esi                        ; shifts to next char
    loop L1                         ; go to start of loop

ExitLoop:
    mov  ecx,2
    call PrintNewLines
    ret
PrintGuesses ENDP

;--------------------------------------------------------------------------
CheckChar PROC
; Author Christian Baker
;
; First, checks whether the character in the AL register is a lowercase
; alphabet letter. If it is, converts to uppercase. Then, checks whether
; character is an alphabet character.
;--------------------------------------------------------------------------
    mov  bl,al
    cmp  bl,'z'
    jg   exitcheck
    cmp  bl,'a'
    jl   uppercase
    sub  bl,32

uppercase:
    cmp  bl,'Z'
    jg   exitcheck
    cmp  bl,'A'
    jl   exitcheck

    mov  esi,OFFSET rightArray
    mov  cl,rightGuesses
    cmp  cl,0
    jle  S2

L1:
    mov  dl,[esi]
    cmp  bl,dl
    je   exitcheck
    inc  esi
    loop L1

S2:
    mov  esi,OFFSET rightArray
    mov  edi,OFFSET theWord
    invoke Str_length, addr theWord
    mov  ecx,eax

L2:
    mov  dl,[edi]
    cmp  bl,dl
    jne  nextchar
    mov  edx,0
    mov  dl,rightGuesses
    add  esi,edx
    mov  [esi],bl
    inc  dl
    mov  rightGuesses,dl
    jmp  exitcheck
nextchar:
    inc  edi
    loop L2

S3:
    mov  esi,OFFSET wrongArray
    mov  cl,wrongGuesses
    cmp  cl,0
    jle  itswrong

L3:
    mov  dl,[esi]
    cmp  bl,dl
    je   exitcheck
    inc  esi
    loop L3

itswrong:
    mov  esi,OFFSET wrongArray
    mov  edx,0
    mov  dl,wrongGuesses
    add  esi,edx
    mov  [esi],bl
    inc  dl
    mov  wrongGuesses,dl

    cmp  dl,6
    jle  exitcheck
    mov  al,1
    mov  gameDone,al

exitcheck:
    ret
CheckChar ENDP

;--------------------------------------------------------------------------
PrintEnd PROC
; Author: Brendon Stutzman
;
; Prints a winner or loser screen based on the outcome of the game, then
; reveals what the word to be guessed was.
;--------------------------------------------------------------------------
    call ClearScreen                ; Clear the screen
    mov  ecx, 5                     ; Print 5 newlines
    call PrintNewLines
    mov  AL, wrongGuesses
    cmp  AL, 6                      ; If wrong < 6...
    jle  youwin                     ; Then jump to youwin
    mov  EDX, OFFSET loser          ; Print loser message
    call WriteString
    jmp  revealword                 ; jump to revealword

youwin:
    mov  EDX, OFFSET winner         ; Print winner message
    call WriteString

revealword:
    mov  ecx, 2                     ; Print 2 newlines
    call PrintNewLines
    mov  EDX, OFFSET wordWas        ; Print "The word was"
    call WriteString
    mov  EDX, OFFSET theWord        ; Print the word to guess
    call WriteString
    mov  ecx, 5                     ; Print 5 newlines
    call PrintNewLines
    mov  EDX, OFFSET pressKey       ; Print "Press any key"
    call WriteString
    ret
PrintEnd ENDP

;-- EXTRA UTILITY PROCEDURES ----------------------------------------------

;--------------------------------------------------------------------------
ClearScreen PROC USES ecx edx
; Author: Christian Baker
;
; Clears only the lines that are used in the program. This was needed
; because the Clrscr procedure in the Irvine Library that clears the
; entire window was lagging badly.
;--------------------------------------------------------------------------
    mov  ecx,15                     ; i = 15
    mov  dx,0                       ; Move cursor to (0,0)
    call Gotoxy
    mov  edx,OFFSET clearStr        ; edx <-- clearString
L1:
    call WriteString                ; Print clearString from edx
    loop L1                         ; Loop back to ClearIt

    mov  dx,0                       ; Move cursor to (0,0)
    call Gotoxy
    ret
ClearScreen ENDP

;--------------------------------------------------------------------------
PrintNewLines PROC
; Author: Christian Baker
;
; Prints the newlines as many times as the number that is in ECX register.
;--------------------------------------------------------------------------
L1:
    call Crlf                       ; Print newline
    loop L1                         ; loop back
    ret
PrintNewLines ENDP

END main
