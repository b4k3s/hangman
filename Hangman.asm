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
; Version:      1.0
; Group:        Team C (MASM)
; Authors:      Christian Baker (Lead)
;               Anthony Cardona
;               Luke Shoff
;               Brendon Stutzman
;
; Class:        CIS 121 - Assembly Language & Computer Architecture
; Instructor:   Professor Manuel Hidalgo
; Date:         5 May 2021
;
; Description:
;   Allows the user to play an ASCII art version of the classic game,
;   Hangman. Shows a main menu where the user can choose to play the
;   game, quit the program, or see the credits for the game. The game
;   gives the user 7 wrong letter guesses to find the random word from
;   the hardcoded word bank. If the user guesses the word before reaching
;   7 wrong guesses, they win the game. If the user guesses 7 wrong
;   letters and has not found the word, they lose. All input is entered
;   from the keyboard; any invalid input is ignored.
;
;   * BA in comments stands for base address
;
;   Note: The length of our program is 416 lines of code in total
;   without whitespace and comments, but about 1/4 of that is taken up
;   by our string initializations due to the long, hardcoded list of
;   words required for the game.
;
;--------------------------------------------------------------------------
INCLUDE Irvine32.inc
; We made use of the following procedures from Kip Irvine's x86 library:
;   Crlf            - Prints a newline
;   Gotoxy          - Moves the cursor to position; DH,DL = row,col
;   Randomize       - Seeds the random number generator for RandomRange
;   RandomRange     - Generates a random # between 0 and value in EAX reg
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
winnerMsg       byte    "        You Win! :)",0dh,0ah,0
loserMsg        byte    "        Game Over :(",0dh,0ah,0
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
    call ClearScreen                ; Clear the screen
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
    mov  al,gameDone                ; AL <-- gameDone
    cmp  al,1                       ; If gameDone is false...
    jl   ContGame                   ; Then go to ContGame
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
; Author: Christian Baker & Anthony Cardona
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
        addr [edi],addr theWord
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
    mov  al,numOfWrong              ; AL  <-- numOfWrong
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
PrintWord PROC USES eax ecx edx esi edi
; Author: Christian Baker
;
; Uses a nested loop to iterate through each character in theWord and
; compares it to the correct characters guessed by the user. If it the
; letter in the word is found in the correct guesses list, it will print
; it out to the screen. If it is not found, it will instead print an
; underscore, meaning it still needs to be guessed. If all characters
; have been guessed, gameDone is set to true.
;--------------------------------------------------------------------------
    mov  al,1                       ; Assume gameDone is true (1)...
    mov  gameDone,al                ; until proven otherwise

    mov  esi,OFFSET theWord         ; ESI <-- BA of theWord
    mov  dh,[esi]                   ; DH  <-- first letter of theWord
    invoke Str_length,addr theWord  ; EAX <-- # of chars in theWord
    mov  ecx,eax                    ; ECX <-- EAX (outer counter)
OuterLoop:
    push ecx                        ; Push ECX to stack to save outer counter
    mov  edi,OFFSET rightGuesses    ; EDI <-- BA of rightGuesses array
    mov  dl,[esi]                   ; DL  <-- current letter of theWord

    mov  al,' '                     ; AL  <-- space char
    call WriteChar                  ; Print space (for between characters)

    mov  cl,numOfRight              ; CL  <-- # of right guesses (inner counter)
    cmp  cl,0                       ; If no correct guesses yet...
    jle  UnderScore                 ; Then jump to UnderScore

InnerLoop:
    mov  dh,[edi]                   ; DH  <-- current letter from rightGuesses
    cmp  dl,dh                      ; If theWord[outer] != rightGuesses[inner]...
    jne  NextCmp                    ; Then jump to NextCmp
    mov  al,dl                      ; AL <-- theWord[outer]
    call WriteChar                  ; Print the current letter of theWord
    jmp  NextLetter                 ; Jump to NextLetter
NextCmp:
    inc  edi                        ; Inc EDI to next elem in rightGuesses
    loop InnerLoop                  ; Dec ECX and Jump to InnerLoop

UnderScore:
    mov  al,'_'                     ; AL  <-- underscore char
    call WriteChar                  ; Print underscore (letter not guessed yet)
    mov  al,0                       ; Set gameDone to false (0)...
    mov  gameDone,al                ; b/c not all letters have been guessed

NextLetter:
    inc  esi                        ; Inc ESI to next letter of theWord
    pop  ecx                        ; Pop from stack to ECX to get outer counter
    loop OuterLoop                  ; Dec ECX and Jump to OuterLoop

    mov  ecx,3                      ; Newlines to print = 3
    call PrintNewlines              ; Print newlines
    ret
PrintWord ENDP

;--------------------------------------------------------------------------
PrintGuesses PROC USES eax ecx edx esi
; Author: Luke Shoff
;
; Prints a list of the characters the user has already guessed. Each
; character is separated by a comma and a space, unless it is the last
; character in the list.
;--------------------------------------------------------------------------
    mov edx,OFFSET triedLetters     ; EDX <-- triedLetters
    call WriteString                ; Prints already tried message
    mov  esi,OFFSET wrongGuesses    ; ESI <-- BA of wrongGuesse array
    mov  cl,numOfWrong              ; CL  <-- numOfWrong
    cmp  cl,0                       ; If there are no wrong guesses yet...
    jle  Finish                     ; Jump to Finish

PrintLetter:
    mov  al,[esi]                   ; AL  <-- current char of wrongGuesses
    call WriteChar                  ; Print current char of wrongGuesses

    cmp  cl,1                       ; If last iteration...
    je   Finish                     ; Jump to Finish (skip printing comma)
    mov  al,','                     ; AL  <-- comma char
    call WriteChar                  ; Print comma
    mov  al,' '                     ; AL  <-- space char
    call WriteChar                  ; Print space
    inc  esi                        ; Inc ESI to next guess in wrongGuesses
    loop PrintLetter                ; Dec ECX and jump to PrintLetter

Finish:
    mov  ecx,2                      ; Newlines to print = 2
    call PrintNewLines              ; Print newlines
    ret
PrintGuesses ENDP

;--------------------------------------------------------------------------
CheckChar PROC
; Author Christian Baker
;
; Checks whether input is lowercase alphabet character. If it is,
; character is converted to uppercase. Checks to make sure input is an
; uppercase alphabet character. Checks if the user has already guessed
; the character. Then, checks if the character is in the word. If it is,
; it is added to the list of right guesses, and if it is not, it is added
; to the list of wrong guesses. Finally, if the number of wrong guesses is
; now, more than 7, then sets gameDone to true. If input is not an
; alphabet character or it is a duplicate, it is ignored.
;
; Receives: EAX = user input
;--------------------------------------------------------------------------
    mov  bl,al                      ; BL  <-- user input (to free up EAX)
    cmp  bl,'z'                     ; If user input is greater than 'z'...
    jg   EndCheck                   ; Then invalid char, jump to EndCheck
    cmp  bl,'a'                     ; If user input is less than 'a'...
    jl   UpperCheck                 ; then jump to UpperCheck
    sub  bl,32                      ; Else, bl -= 32 to convert to upper

UpperCheck:
    cmp  bl,'Z'                     ; If user input is greater than 'Z'...
    jg   EndCheck                   ; Then invalid char, jump to EndCheck
    cmp  bl,'A'                     ; If user input is less than 'A'...
    jl   EndCheck                   ; Then invalid char, jump to EndCheck

    mov  esi,OFFSET rightGuesses    ; ESI <-- BA of rightGuesses
    mov  cl,numOfRight              ; CL  <-- numOfRightGuesses
    cmp  cl,0                       ; If there are no right guesses yet...
    jle  SetupNext                  ; Then Jump to SetupNext

DupRight:
    mov  dl,[esi]                   ; DL  <-- curr char of rightGuesses
    cmp  bl,dl                      ; If input is already in right array...
    je   EndCheck                   ; Then duplicate char, jump to EndCheck
    inc  esi                        ; Inc ESI to next char in rightGuesses
    loop DupRight                   ; Dec ECX and jump to DupRight

SetupNext:
    mov  esi,OFFSET rightGuesses    ; ESI <-- BA of rightGuesses
    mov  edi,OFFSET theWord         ; EDI <-- BA of theWord
    invoke Str_length,addr theWord  ; EAX <-- # of chars in theWord
    mov  ecx,eax                    ; ECX <-- EAX (for counter)
RightCheck:
    mov  dl,[edi]                   ; DL  <-- curr char of theWord
    cmp  bl,dl                      ; If the input char != theWord char...
    jne  NextChar                   ; Then jump to NextChar
    movzx edx,numOfRight            ; EDX <-- numOfRight (zero extended)
    add  esi,edx                    ; ESI += EDX, goto next open rightGuesses spot
    mov  [esi],bl                   ; Write input to rightGuesses array
    inc  dl                         ; Inc DL (increment num of right guesses)
    mov  numOfRight,dl              ; Write incremented value to numOfRight
    jmp  EndCheck                   ; Input valid and recorded, jump to EndCheck
NextChar:
    inc  edi                        ; Inc EDI to move to next char in theWord
    loop RightCheck                 ; Dec ECX and jump to RightCheck

    mov  esi,OFFSET wrongGuesses    ; ESI <-- BA of wrongGuesses
    mov  cl,numOfWrong              ; CL  <-- numOfWrong
    cmp  cl,0                       ; If there are no wrong guesses yet...
    jle  AddWrong                   ; Then jump to AddWrong

DupWrong:
    mov  dl,[esi]                   ; DL  <-- curr char of wrongGuesses
    cmp  bl,dl                      ; If input is already in wrong array...
    je   EndCheck                   ; Then duplicate char, jump to EndCheck
    inc  esi                        ; Inc ESI to next char in wrongGuesses
    loop DupWrong                   ; Dec ECX and jump to DupWrong

AddWrong:
    mov  esi,OFFSET wrongGuesses    ; ESI <-- BA of wrongGuesses
    movzx edx,numOfWrong            ; EDX <-- numOfWrong (zero extended)
    add  esi,edx                    ; ESI += EDX, goto next open wrongGuesses spot
    mov  [esi],bl                   ; Write input to wrongGuesses array
    inc  dl                         ; Inc DL (increment num of wrong guesses)
    mov  numOfWrong,dl              ; Write incremented value to numOfWrong

    cmp  dl,6                       ; If numOfWrong < 6 (Less than 7 guesses)...
    jle  EndCheck                   ; Then, jump to EndCheck
    mov  al,1                       ; Else, set gameDone to true (1)
    mov  gameDone,al                ; b/c user is out of guesses

EndCheck:
    ret
CheckChar ENDP

;--------------------------------------------------------------------------
PrintEnd PROC USES eax ecx edx
; Author: Brendon Stutzman
;
; Prints a winner or loser screen based on the outcome of the game, then
; reveals what the word to be guessed was with key press prompt.
;--------------------------------------------------------------------------
    call ClearScreen                ; Clear the screen
    mov  ecx,5                      ; Newlines to print = 5
    call PrintNewLines              ; Print newlines
    mov  al,numOfWrong              ; AL  <-- numOfWrong

UserLost:
    cmp  al,6                       ; If numOfWrong < 6...
    jle  UserWon                    ; Then jump to UserWon
    mov  edx,OFFSET loserMsg        ; EDX <-- BA of loserMsg
    call WriteString                ; Print the loser message
    jmp  RevealWord                 ; jump to RevealWord
UserWon:
    mov  edx,OFFSET winnerMsg       ; EDX <-- BA of winnerMsg
    call WriteString                ; Print the winner message

RevealWord:
    mov  ecx,2                      ; Newlines to print = 2
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET wordWas         ; EDX <-- BA of wordWas
    call WriteString                ; Print word was string
    mov  edx,OFFSET theWord         ; EDX <-- BA of theWord
    call WriteString                ; Print the word of the game
    mov  ecx,5                      ; Newlines to print = 5
    call PrintNewLines              ; Print newlines
    mov  edx,OFFSET pressKey        ; EDX <-- BA of pressKey
    call WriteString                ; Prints press key prompt
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
    mov  ecx,15                     ; # of lines to print (Game screen height)
    mov  dx,0                       ; Set cursor position to (0,0)
    call Gotoxy
    mov  edx,OFFSET clearStr        ; EDX <-- clearString
ClearLines:
    call WriteString                ; Print spaces over previous screen
    loop ClearLines                 ; Dec ECX and jump to ClearLines

    mov  dx,0                       ; Set cursor postion to (0,0)
    call Gotoxy                     ; to set up for next screen
    ret
ClearScreen ENDP

;--------------------------------------------------------------------------
PrintNewLines PROC
; Author: Christian Baker
;
; Prints the newlines as many times as the number that is in ECX register.
;
; Receives: ECX = # of newlines to print
;--------------------------------------------------------------------------
PrintLines:
    call Crlf                       ; Print newline
    loop PrintLines                 ; Dec ECX and jump to PrintLines
    ret
PrintNewLines ENDP

END main
