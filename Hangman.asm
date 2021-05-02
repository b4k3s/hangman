TITLE Hangman         (Hangman.asm)
;                                                    ______
;   _   _                                            |/   |
;  | | | | __ _ _ __   __ _ _ __ ___   __ _ _ __     |    ()
;  | |_| |/ _` | '_ \ / _` | '_ ` _ \ / _` | '_ \    |   /||\
;  |  _  | (_| | | | | (_| | | | | | | (_| | | | |   |    /\
;  |_| |_|\__,_|_| |_|\__, |_| |_| |_|\__,_|_| |_|   |\
;                     |___/                         ``````````
;                              Final Project
;
; Version: 1.0
; Authors: Team C (MASM)
;   Christian Baker, Anthony Cardona, Luke Shoff, Brendon Stutzman
;
; Class: CIS 121 - Assembly Language & Computer Architecture
; Instructor: Professor Manuel Hidalgo
; Date: 5 May 2021
;
; Description:
;   Allows the user to play an ASCII art version of the classic game,
;   Hangman. Shows a main menu where the user can choose to play the
;   game, quit the program, or see the credits for the game. The game
;   gives the user 7 wrong letter guesses to find the random word from
;   the hardcoded word bank. If the user guesses the word before reaching
;   7 guesses, they win the game. If the user guesses 7 letters and has
;   not found the word, they lose. All input is entered from the keyboard;
;   any invalid input is ignored.
;
;   * BA in code means base address
;
;--------------------------------------------------------------------------
INCLUDE Irvine32.inc
; We made use of the following procedures from Kip Irvine's x86 library:
;   Crlf            - Prints a newline
;   Gotoxy          - Moves the cursor to position; DH,DL = row,col
;   Randomize       - Seeds the random number generator for RandomRange
;   RandomRange     - Generates a rendom # between 0 and value in EAX reg
;   ReadChar        - Gets char from keyboard and stores in EAX reg
;   Str_copy        - Copies one string variable to another string variable
;   Str_length      - Loads the length of a given string into the EAX reg
;   WriteChar       - Prints char in the EAX register
;   WriteString     - Prints string starting with base address in EDX reg
;--------------------------------------------------------------------------

.data
theWord         byte    15  DUP(0)  ; The word to be guessed
numOfWrong      byte    0           ; # of wrong guesses
numOfRight      byte    0           ; # of right guesses
wrongGuesses    byte    7   DUP(0)  ; Array of user's wrong guesses
rightGuesses    byte    26  DUP(0)  ; Array of user's right guesses
gameDone        byte    0           ; Bool to tell program if game is done

; Words to Guess (List curated by Brendon Stutzman)
numOfWords      byte    60
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
word16          byte    "VORTEX",0
word17          byte    "WRISTWATCH",0
word18          byte    "SWIVEL",0
word19          byte    "KNAPSACK",0
word20          byte    "QUARTZ",0
word21          byte    "PAJAMAS",0
word22          byte    "JACKPOT",0
word23          byte    "BOOKWORM",0
word24          byte    "ZODIAC",0
word25          byte    "AVENUE",0
word26          byte    "TRANSCRIPT",0
word27          byte    "DAIQUIRI",0
word28          byte    "BEEKEEPER",0
word29          byte    "AWKWARD",0
word30          byte    "FISHHOOK",0
word31          byte    "BAGPIPES",0
word32          byte    "JELLY",0
word33          byte    "JAWBREAKER",0
word34          byte    "JUICY",0
word35          byte    "JACKPOT",0
word36          byte    "PEEKABOO",0
word37          byte    "UNKNOWN",0
word38          byte    "KLUTZ",0
word39          byte    "OXYGEN",0
word40          byte    "PIXEL",0
word41          byte    "VAPORIZE",0
word42          byte    "COBWEB",0
word43          byte    "YUMMY",0
word44          byte    "ZOMBIE",0
word45          byte    "ZIGZAG",0
word46          byte    "ZIPPER",0
word47          byte    "SPHINX",0
word48          byte    "QUIZ",0
word49          byte    "PUPPY",0
word50          byte    "MICROWAVE",0
word51          byte    "FLUFFY",0
word52          byte    "CROQUET",0
word53          byte    "AVENUE",0
word54          byte    "PNEUMONIA",0
word55          byte    "GNARLY",0
word56          byte    "KEYHOLE",0
word57          byte    "LUXURY",0
word58          byte    "MEGAHERTZ",0
word59          byte    "YOUTH",0

; Array of the strings above
wordBank        dword   word00,word01,word02,word03,word04,word05
                dword   word06,word07,word08,word09,word10,word11
                dword   word12,word13,word14,word15,word16,word17
                dword   word18,word19,word20,word21,word22,word23
                dword   word24,word25,word26,word27,word28,word29
                dword   word30,word31,word32,word33,word34,word35
                dword   word36,word37,word38,word39,word40,word41
                dword   word42,word43,word44,word45,word46,word47
                dword   word48,word49,word50,word51,word52,word53
                dword   word54,word55,word56,word57,word58,word59

; String of spaces used to clear screen
clearStr        byte    "                                  ",0dh,0ah,0

; Prompts and Messages
makeSelect      byte    " Make a Selection: ",0
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
gallowsTop      byte    0dh,0ah,"  ______",0dh,0ah
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

; End of Game Strings
winner          byte    "        You Win! :)",0dh,0ah,0
loser           byte    "        Game Over :(",0dh,0ah,0
wordWas         byte    "       The word was",0dh,0ah,"         ",0

.code
main PROC
MainMenu:
    call PrintMenu                  ; Print the menu screen
    call ReadChar                   ; Get input char from user
    cmp  al,'q'                     ; If user input is 'q'...
    je   QuitGame                   ; Then quit game
    cmp  al,'s'                     ; If user input is 's'...
    je   PlayGame                   ; Then start game
    cmp  al,'c'                     ; If user input is 'c'...
    je   CreditScreen               ; Then show credits
    jmp  MainMenu                   ; Else jump back to MainMenu

PlayGame:
    call ClearScreen
    mov  eax,0                      ; Initialize input for game
    mov  gameDone,al                ; Set gameDone to false (0)
    mov  numOfRight,al              ; Set # of right guesses to 0
    mov  numOfWrong,al              ; Set # of wrong guesses to 0
    call GetWord                    ; Get random word from word bank
ContGame:
    call PrintHangman               ; Print ASCII art hangman
    call PrintWord                  ; Print letters or underscores
    call PrintGuesses               ; Print wrong letters tried
    mov  edx,OFFSET chooseLetter    ; EDX <-- BA of chooseLetter
    call WriteString                ; Print user prompt for letter
    mov  al,gameDone                ; AL <-- gameDone
    cmp  al,0                       ; If gameDone is true...
    jg   EndGame                    ; Then go to EndGame
    call ReadChar                   ; Get guessed letter from user
    call CheckChar                  ; Store char if eligible
    mov  al,gameDone                ; AL <--gameDone
    cmp  al,1                       ; If gameDone is false...
    jl   ContGame                    ; Then go to ContGame
EndGame:
    call PrintEnd                   ; Print Win/Lose Screen
    call ReadChar                   ; Wait for input (Pause)
    jmp  MainMenu                   ; Jump back to MainMenu

CreditScreen:
    call PrintCredits               ; Print credits
    call ReadChar                   ; Wait for input (Pause)
    jmp  MainMenu                   ; Jump back to MainMenu

QuitGame:
    call ClearScreen                ; Clear the screen
    exit
main ENDP

;--------------------------------------------------------------------------
PrintMenu PROC USES ecx edx
; Author: Luke Shoff
;
; Prints the menu screen with prompt.
;--------------------------------------------------------------------------
    call ClearScreen                ; Clear the screen
    mov  ecx,5                      ; Newlines to print = 5
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET titleScr        ; EDX <-- BA of titleScr
    call WriteString                ; Print Hangman title and options
    mov  ecx,3                      ; Newlines to print = 3
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET makeSelect      ; EDX <-- BA of makeSelect
    call WriteString                ; Print prompt for user selection
    ret
PrintMenu ENDP

;--------------------------------------------------------------------------
PrintCredits PROC USES ecx edx
; Author: Brendon Stutzman
;
; Prints the team credits screen with prompt.
;--------------------------------------------------------------------------
    call ClearScreen                ; Clears the screen
    mov  ecx,5                      ; Newlines to print = 5
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET madeBy          ; EDX <-- BA of madeBy
    call WriteString                ; Print our names
    mov  ecx,3                      ; Newlines to print = 3
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET pressKey        ; EDX <-- pressKey
    call WriteString                ; Print prompt for key press
    ret
PrintCredits ENDP

;--------------------------------------------------------------------------
GetWord PROC USES eax ebx esi edi
; Author: Christian Baker
;
; Gets a random number between 0 and numOfWords - 1. Selects the
; corresponding word element from the wordBank string array. Then, copies
; that random word to theWord to be used for that round of the game.
;--------------------------------------------------------------------------
    mov  al,numOfWords              ; AL <-- numOfWords
    call Randomize                  ; Get randomizer seed
    call RandomRange                ; Get random # btwn 0 and EAX - 1
    mov  ebx,4                      ; Elements are dwords, so 4 bytes
    mul  ebx                        ; EAX *= EBX, Gets correct offset
    mov  esi,OFFSET wordBank        ; ESI <-- BA of wordBank
    add  esi,eax                    ; ESI += EAX, Go to BA for chosen word
    mov  edi,[esi]                  ; EDI <-- Dereferenced BA
    invoke Str_copy,                ; Copy chosen word to theWord
        addr [edi], addr theWord
    ret
GetWord ENDP

;--------------------------------------------------------------------------
PrintHangman PROC USES edx eax
; Author: Anthony Cardona
;
; Prints the ASCII art Hangman character. Checks to see which parts to
; print based on how many wrong letter guesses that the user has made.
;--------------------------------------------------------------------------
    mov  dx,0                       ; Set cursor position to (0,0)
    call Gotoxy                     ; (Faster than clearing screen)
    mov  al,numOfWrong              ; AL <-- numOfWrong
    mov  edx,OFFSET gallowsTop      ; EDX <-- BA of gallowsTop
    call WriteString                ; Print top part of gallows

TheHead:
    cmp  al,1                       ; If wrong guesses < 1...
    jl   TheNoose                   ; Then jump to TheNoose
    mov  edx,OFFSET manHead         ; EDX <-- BA of manHead
    jmp  Write1                     ; Jump to Write1
TheNoose:
    mov  edx,OFFSET gallowsNoose    ; EDX <-- BA of gallowsNoose
Write1:
    call WriteString                ; Print line 1 option from EDX

TwoArms:
    cmp  al,4                       ; If wrong guesses < 4...
    jl   OneArm                     ; Then jump to OneArm
    mov  edx,OFFSET manArms         ; EDX <-- BA manArms
    jmp  Write2                     ; Jump to Write2
OneArm:
    cmp  al,3                       ; If wrong guesses < 3...
    jl   TheTorso                   ; Then jump to TheTorso
    mov  edx,OFFSET manArm          ; EDX <-- BA of manArm
    jmp  Write2                     ; Jump to Write2
TheTorso:
    cmp  al,2                       ; If wrong guesses < 2...
    jl   NoTorso                    ; Then jump to NoTorso
    mov  edx,OFFSET manTorso        ; EDX <-- BA of manTorso
    jmp  Write2                     ; Jump to Write2
NoTorso:
    mov  edx,OFFSET gallowsMid      ; EDX <-- gallowsMid
Write2:
    call WriteString                ; Print line 2 option from EDX

TwoLegs:
    cmp  al,6                       ; If wrong guesses < 6...
    jl   OneLeg                     ; Then jump to OneLeg
    mov  edx,OFFSET manLegs         ; EDX <-- BA of manLegs
    jmp  Write3                     ; Jump to Write3
OneLeg:
    cmp  al,5                       ; If wrong guesses < 5...
    jl   NoLegs                     ; Then jump to NoLegs
    mov  edx,OFFSET manLeg          ; EDX <-- BA of manLeg
    jmp  Write3                     ; Jump to Write3
NoLegs:
    mov  edx,OFFSET gallowsMid      ; EDX <-- BA of gallowsMid
Write3:
    call WriteString                ; Print line 3 option from EDX

    mov  edx,OFFSET gallowsBase     ; EDX <-- BA of gallowsBase
    call WriteString                ; Print bottom part of gallows
    ret
PrintHangman ENDP

;--------------------------------------------------------------------------
PrintWord PROC USES eax ecx edx 
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
OuterLoop:
    push ecx
    mov  edi,OFFSET rightGuesses
    mov  dl,[esi]
    mov  bl,numOfRight

    mov  al,' '
    call WriteChar

    mov  cl,numOfRight
    cmp  cl,0
    jle  UnderScore

InnerLoop:
    mov  dh,[edi]
    cmp  dl,dh
    jne  NextCmp
    mov  al,dl
    call WriteChar
    jmp  NextLetter
NextCmp:
    inc  edi
    loop InnerLoop

UnderScore:
    mov  al,'_'
    call WriteChar
    mov  al,0
    mov  gameDone,al

NextLetter:
    inc  esi
    pop  ecx
    loop OuterLoop

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
    mov esi, OFFSET wrongGuesses
    mov cl, numOfWrong              ; moves wrongGuesses into cl reg
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

    mov  esi,OFFSET rightGuesses
    mov  cl,numOfRight
    cmp  cl,0
    jle  S2

L1:
    mov  dl,[esi]
    cmp  bl,dl
    je   exitcheck
    inc  esi
    loop L1

S2:
    mov  esi,OFFSET rightGuesses
    mov  edi,OFFSET theWord
    invoke Str_length, addr theWord
    mov  ecx,eax

L2:
    mov  dl,[edi]
    cmp  bl,dl
    jne  nextchar
    mov  edx,0
    mov  dl,numOfRight
    add  esi,edx
    mov  [esi],bl
    inc  dl
    mov  numOfRight,dl
    jmp  exitcheck
nextchar:
    inc  edi
    loop L2

S3:
    mov  esi,OFFSET wrongGuesses
    mov  cl,numOfWrong
    cmp  cl,0
    jle  itswrong

L3:
    mov  dl,[esi]
    cmp  bl,dl
    je   exitcheck
    inc  esi
    loop L3

itswrong:
    mov  esi,OFFSET wrongGuesses
    mov  edx,0
    mov  dl,numOfWrong
    add  esi,edx
    mov  [esi],bl
    inc  dl
    mov  numOfWrong,dl

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
    mov  AL, numOfWrong
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
