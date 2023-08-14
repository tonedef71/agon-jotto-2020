10000 REM :::::::::::::::::::::::::::::::::::::::::::::
10010 REM :: JOTTO 2020 FOR AgonLight (BBC BASIC v3) ::
10020 REM :::::::::::::::::::::::::::::::::::::::::::::
10030 REM :: 20230813: V1.0 - Initial Release        ::
10040 REM :::::::::::::::::::::::::::::::::::::::::::::
10050 REM :: JOTTO 2020 was originally developed as  ::
10060 REM :: an entry for MuleSoft Hackathon 2020.   ::
10070 REM :: Its public release back in autumn 2020  ::
10080 REM :: predates the public release of Wordle   ::
10090 REM :: by well over a year.                    ::
10100 REM :::::::::::::::::::::::::::::::::::::::::::::
10110 REM :: It is best experienced in a 40+ column, ::
10120 REM :: 16+ color display mode                  ::
10130 REM :::::::::::::::::::::::::::::::::::::::::::::
10140 REM!Embed @dir$+"data/dat02.bin", @dir$+"data/dat03.bin", @dir$+"data/dat04.bin"
10150 REM!Embed @dir$+"data/dat05.bin", @dir$+"data/dat06.bin", @dir$+"data/dat07.bin"
10160 REM!Embed @dir$+"data/dat08.bin", @dir$+"data/dat09.bin", @dir$+"data/dat10.bin"
10170 REM!Embed @dir$+"data/dat11.bin", @dir$+"data/dat12.bin", @dir$+"data/dict02.bin"
10180 REM!Embed @dir$+"data/dict03.bin", @dir$+"data/dict04.bin", @dir$+"data/dict05.bin"
10190 REM!Embed @dir$+"data/dict06.bin", @dir$+"data/dict07.bin", @dir$+"data/dict08.bin"
10200 REM!Embed @dir$+"data/dict09.bin", @dir$+"data/dict10.bin", @dir$+"data/dict11.bin"
10210 REM!Embed @dir$+"data/dict12.bin"
10220 CLEAR
10230 REPEAT CLS:SY$=FN_TO_UPPER(FN_PROMPT(0,0,"TARGET (A)gon or (B)BC B-SDL:","A")):UNTIL SY$ = "A" OR SY$ = "B"
10240 IF SY$ = "B" THEN LEFT = 136:RIGHT = 137:DOWN = 138:UP = 139:DL% = 10:MO% = 9:ELSE LEFT = 8:RIGHT = 21:DOWN = 10:UP = 11:DL% = 14:MO% = 2
10250 IF SY$ = "A" THEN REPEAT CLS:MO$=FN_PROMPT(0,0,"MODE (1,2,3,...):",STR$(MO%)):UNTIL VAL(MO$) > 0:MO% = VAL(MO$)
10260 MODE MO%
10270 PROC_SETUP
10280 ON ERROR PROC_HANDLE_ERROR:REM Handle ESC key
10290 PROC_WELCOME
10300 REPEAT
10310   PROC_DEFAULT_COLORS
10320   PROC_NEW_GAME
10330   PROC_MAIN_LOOP:REM Invoke main loop
10340   PROC_GAME_OVER
10350   Resp$ = FN_PLAY_AGAIN
10360   IF Resp$ = "Y" THEN CLS:VDU 31,0,0:ELSE PROC_GOODBYE(GameName$)
10370 UNTIL Resp$ <> "Y"
10380 END
10390 :
10400 REM ::::::::::::::::::::
10410 REM ::   Setup Game   ::
10420 REM ::::::::::::::::::::
10430 DEF PROC_SETUP
10440 LOCAL i%
10450 MAXINT% = &3B9AC9FF:GameName$ = "JOTTO-2020":MinimumAllowedGuesses% = 5
10460 BLACK = 0:RED = 1:GREEN = 2:YELLOW = 3:BLUE = 4:MAGENTA = 5:CYAN = 6:WHITE = 7:C_ORANGE = 8 + (SY$ = "A" AND FN_COLORCOUNT = &40) *-50
10470 P_TOP = 0:P_LEFT = 1:P_RIGHT = 2:P_BOTTOM = 3:BLANK = 32
10480 FR_1 = 150:FR_2 = 151:FR_3 = 152:FR_4 = 153:FR_5 = 154:FR_6 = 155:FR_7 = 156:FR_8 = 156:FR_9 = 156
10490 B_VERT = 140:B_HORZ = 141:B_UR = 142:B_UL = 143:B_DL = 144:B_DR = 145:T_UP = 146:T_DOWN = 147
10500 IF SY$ = "A" THEN CW% = FN_getByteVDP(&13):CH% = FN_getByteVDP(&14):ELSE CW% = 40:CH% = 24
10510 C_AICP$ = " .*?":C_BLANK% = 1:C_ABSENT% = 2:C_CORRECT% = 3:C_PRESENT% = 4
10520 COL_AICP$ = CHR$(WHITE)+CHR$(RED)+CHR$(GREEN)+CHR$(YELLOW)
10530 A_FRAMES$ = CHR$(FR_1)+CHR$(FR_2)+CHR$(FR_3)+CHR$(FR_4)+CHR$(FR_5)+CHR$(FR_6)+CHR$(FR_7)+CHR$(FR_8)+CHR$(FR_9)+CHR$(FR_1)
10540 TK = TIME:PROC_SLEEP(100):TK = TIME - TK:REM CALIBRATE TIME TICKS
10550 SP% = INT(30 * TK / 100):REM Speed Throttler (smaller value speeds up the game)
10560 BX$ = CHR$(B_UR) + CHR$(B_HORZ) + CHR$(B_UL) + CHR$(B_VERT) + CHR$(B_DL) + CHR$(B_HORZ) + CHR$(B_DR) + CHR$(B_VERT)
10570 DIM PerfectLetterCounts%(25),PresentLetterCounts%(25),BestScores%(10),LastPlayedWords%(10)
10580 FOR i% = 0 TO 10:BestScores%(i%) = MinimumAllowedGuesses%:NEXT i%:REM Default best scores
10590 FOR i% = 0 TO 10:LastPlayedWords%(i%) = 0:NEXT i%:REM Initialize last played words to zero
10600 PROC_REDEFINE_COLORS
10610 PROC_REDEFINE_CHARS
10620 ENDPROC
10630 :
10640 REM ::::::::::::::::::::::
10650 REM ::     New Game     ::
10660 REM ::::::::::::::::::::::
10670 DEF PROC_NEW_GAME
10680 LOCAL lastPlayedWordIndex%, n%
10690 REPEAT CLS:PRINT TAB(0,0)CHR$(17)CHR$(WHITE)"Puzzle Size (2 - 12): "CHR$(17)CHR$(YELLOW)"5"CHR$(8);:n%=FN_PROMPT_FOR_NUMBER(5, 2):SIZE% = n%:UNTIL SIZE% >= 2 AND SIZE% <= 12
10700 StrictlyWordGuesses% = FN_STRICTLY_WORD_GUESSES
10710 PROC_BESTSCORES_READ:MaximumTurns% = FN_COMPUTE_MAXIMUM_TURNS(SIZE%)
10720 TARGET$ = FN_SELECT_A_MYSTERY_WORD(SIZE%)
10730 SOLVED$ = STRING$(SIZE%, MID$(C_AICP$, C_CORRECT%, 1))
10740 LetterStates$ = STRING$(26, CHR$(C_BLANK%))
10750 Lost% = FALSE:GuessCount% = 0
10760 CurrentLine% = 4
10770 CLS
10780 ENDPROC
10790 :
10800 REM ::::::::::::::::::::::
10810 REM ::     Main Loop    ::
10820 REM ::::::::::::::::::::::
10830 DEF PROC_MAIN_LOOP
10840 LOCAL a%, count%, guess$, mask$
10850 count% = 0:a% = LEN(FN_PAD_NUMBER(MaximumTurns%, 2)):PROC_DISPLAY_BEST_SCORE(SIZE%)
10860 REPEAT
10870   PROC_DISPLAY_LETTER_STATES(0, 0)
10880   PRINT CHR$(17)CHR$(CYAN)TAB(0, CurrentLine%)FN_PAD_NUMBER((count% + 1), a%)" of "FN_PAD_NUMBER(MaximumTurns%, a%)"> "CHR$(17)CHR$(WHITE);
10890   guess$ = FN_PROMPT_FOR_GUESS(SIZE%)
10900   mask$ = FN_COMPARE(guess$, TARGET$):PRINT" ";
10910   PROC_REVEAL(guess$, mask$, FALSE):PROC_DEFAULT_COLORS
10920   count% = count% + 1:CurrentLine% = CurrentLine% + 1
10930 UNTIL mask$ = SOLVED$ OR count% = MaximumTurns%
10940 Lost% = mask$ <> SOLVED$
10950 PRINT CHR$(17)CHR$(CYAN);:PROC_SUSPENSE(a% + 8 + SIZE%, ASC("-")):PRINT">"CHR$(17)CHR$(WHITE);
10960 IF Lost% THEN PROC_WAH_WAH:PROC_REVEAL(FN_ROTATE(TARGET$, 12), SOLVED$, TRUE)
10970 IF NOT Lost% THEN PRINT FN_RVS(C_ORANGE, BLACK, guess$):PROC_CHARGE:PROC_UPDATE_BEST_SCORE(SIZE%,FN_MIN(count%, MaximumTurns%)):PROC_DISPLAY_BEST_SCORE(SIZE%)
10980 PROC_DISPLAY_LETTER_STATES(0, 0):PROC_BESTSCORES_WRITE:GuessCount% = count%
10990 ENDPROC
11000 :
11010 REM ::::::::::::::::::::::::::::::::::::::
11020 REM :: Prompt For Strictly Word Guesses ::
11030 REM ::::::::::::::::::::::::::::::::::::::
11040 DEF FN_STRICTLY_WORD_GUESSES
11050 LOCAL r$, x%, y%
11060 x% = 0:y% = VPOS + 1
11070 REPEAT r$ = FN_PROMPT(x%, y%, CHR$(17)+CHR$(WHITE)+"Strictly word guesses? (Y/N)"+CHR$(17)+CHR$(YELLOW), "Y") UNTIL INSTR("YN", r$) <> 0
11080 := ("Y" = r$)
11090 :
11100 REM ::::::::::::::::::::::::
11110 REM :: Prompt For A Guess ::
11120 REM ::::::::::::::::::::::::
11130 DEF FN_PROMPT_FOR_GUESS(length%)
11140 LOCAL c$, c%, e$, l%, r$, validWord%, x%, y%
11150 validWord% = FALSE:x% = POS:y% = VPOS
11160 PROC_EMPTY_KEYBOARD_BUFFER:e$ = STRING$(length%, " ")
11170 REPEAT
11180   r$ = "":l% = 0:PROC_SHOW_CURSOR
11190   REPEAT
11200     c$ = FN_TO_UPPER(INKEY$(10))
11210     IF ((c$ = CHR$(127) OR c$ = CHR$(8)) AND LEN(r$) > 0) THEN r$ = LEFT$(r$, LEN(r$) - 1)
11220     IF (c$ >= "A" AND c$ <= "Z") AND FN_IS_VIABLE_LETTER_GUESS(c$) AND LEN(r$) < length% THEN r$ = r$ + c$
11230     IF LEN(r$) <> l% THEN l% = LEN(r$):c% = (l% = length%) * -C_ORANGE + (l% < length%) * -WHITE:VDU 17,c%:PRINT TAB(x%, y%)e$TAB(x%, y%)r$;
11240   UNTIL c$ = CHR$(13) AND LEN(r$) = length%
11250   PROC_HIDE_CURSOR
11260   IF StrictlyWordGuesses% THEN validWord% = FN_CHECK_WORD_VALIDITY(r$):ELSE validWord% = TRUE
11270   IF NOT validWord% THEN PRINT TAB(x%, y%)e$TAB(x%, y%);
11280 UNTIL validWord%
11290 :=r$
11300 :
11310 REM :::::::::::::::::::::::::::
11320 REM :: Compute Maximum Turns ::
11330 REM :::::::::::::::::::::::::::
11340 DEF FN_COMPUTE_MAXIMUM_TURNS(numLetters%)
11350 := MinimumAllowedGuesses% + (numLetters% < 7) * -1
11360 :
11370 REM :::::::::::::::::::::::::::::::::::::
11380 REM :: Compare Guess With Mystery Word ::
11390 REM :::::::::::::::::::::::::::::::::::::
11400 DEF FN_COMPARE(guess$, target$)
11410 LOCAL ch$, gc$, i%, l%, n%, r$
11420 l% = LEN(target$):guess$ = FN_ROTATE(guess$, -12):r$ = ""
11430 FOR i% = 1 TO l%
11440   gc$ = MID$(guess$, i%, 1):tc$ = FN_TO_UPPER(MID$(target$, i%, 1))
11450   IF gc$ = tc$ THEN ch$ = MID$(C_AICP$, C_CORRECT%, 1):guess$ = FN_XSTRING$(guess$, i%, ch$):target$ = FN_XSTRING$(target$, i%, ch$)
11460 NEXT i%
11470 FOR i% = 1 TO l%
11480   gc$ = MID$(guess$, i%, 1):n% = INSTR(target$, gc$):tc$ = FN_TO_UPPER(MID$(target$, i%, 1)):ch$ = MID$(C_AICP$, C_ABSENT%, 1)
11490   IF gc$ = tc$ THEN ch$ = tc$
11500   IF n% > 0 AND gc$ <> tc$ THEN ch$ = MID$(C_AICP$, C_PRESENT%, 1):guess$ = FN_XSTRING$(guess$, i%, ch$):target$ = FN_XSTRING$(target$, n%, ch$)
11510   r$ = r$ + ch$:REM PRINT guess$, target$, gc$, n%
11520 NEXT i%
11530 := r$
11540 :
11550 REM ::::::::::::::::::::::::::
11560 REM :: Encrypt/Decrypt Text ::
11570 REM ::::::::::::::::::::::::::
11580 DEF FN_CRYPT(text$)
11590 LOCAL i%,l%,r$
11600 r$ = "":l% = LEN(text$)
11610 FOR i% = 1 TO l%
11620   r$ = r$ + CHR$(ASC(MID$(text$,i%,1)) EOR l%
11630 NEXT i%
11640 := r$
11650 :
11660 REM ::::::::::::::::::::::::::::
11670 REM :: Rotate Letters In Text ::
11680 REM ::::::::::::::::::::::::::::
11690 DEF FN_ROTATE(text$, n%)
11700 LOCAL i%, l%, r$
11710 r$ = "":l% = LEN(text$)
11720 FOR i% = 1 TO l%
11730   r$ = r$ + CHR$((ASC(FN_TO_UPPER(MID$(text$,i%,1))) - ASC("A") + 26 - n%) MOD 26 + ASC("A"))
11740 NEXT i%
11750 := r$
11760 :
11770 REM :::::::::::::::::::::::::::::::::::::::::
11780 REM :: Animate Frames Of Revolving Letters ::
11790 REM :::::::::::::::::::::::::::::::::::::::::
11800 DEF PROC_ANIMATE_FRAMES(x%, y%, col%, ch$)
11810 LOCAL c%, i%, l%
11820 l% = LEN(A_FRAMES$) - 1
11830 FOR i% = 1 TO l%
11840   PRINTTAB(x%, y%);
11850   c% = (i% < l%) * -WHITE + (i% = l%) * -col%
11860   PRINT CHR$(17)CHR$(c%)MID$(A_FRAMES$, i%, 1)
11870   PROC_SOUND(95 - i%, 1):PROC_SLEEP(12)
11880 NEXT i%
11890 ENDPROC
11900 :
11910 REM ::::::::::::::::::::::::::::
11920 REM :: Reveal Status Of Guess ::
11930 REM ::::::::::::::::::::::::::::
11940 DEF PROC_REVEAL(guess$, mask$, final%)
11950 LOCAL ch$, col%, i%, l%, state%, tone%, x%, y%
11960 l% = LEN(mask$):x% = POS:y% = VPOS
11970 IF NOT final% THEN FOR i% = 1 TO l%:PRINT TAB(x% + i% - 1, y%)FN_RVS(WHITE, BLACK, MID$(guess$, i%, 1));:NEXT i%
11980 FOR i% = 1 TO l%
11990   ch$ = MID$(mask$, i%, 1)
12000   state% = INSTR(C_AICP$, ch$)
12010   col% = final% * -C_ORANGE + (NOT final%) * -ASC(MID$(COL_AICP$, state%, 1))
12020   tone% = final% * -120 + (NOT final%) * 12 * (state% - 2) + 8
12030   ch$ = MID$(guess$, i%, 1)
12040   PROC_ANIMATE_FRAMES(x%, y%, col%, ch$):PROC_SOUND(tone%, 10):PRINT TAB(x%, y%)FN_RVS(col%, BLACK, ch$);
12050   x% = x% + 1
12060   PROC_UPDATE_LETTER_STATE(ch$, state%)
12070 NEXT i%:PRINT
12080 ENDPROC
12090 :
12100 REM ::::::::::::::::::::::::::::
12110 REM :: Animation For Suspense ::
12120 REM ::::::::::::::::::::::::::::
12130 DEF PROC_SUSPENSE(count%, ch%):LOCAL i%:FOR i% = 1 TO count%:VDU ch%:PROC_SOUND(112, 1):PROC_SLEEP(12):NEXT i%:ENDPROC
12140 :
12150 REM ::::::::::::::::::::::::::::::
12160 REM :: Is Guess A Viable Letter ::
12170 REM ::::::::::::::::::::::::::::::
12180 DEF FN_IS_VIABLE_LETTER_GUESS(ch$)
12190 LOCAL r%, state%
12200 r% = TRUE
12210 state% = FN_RETRIEVE_LETTER_STATE(ch$)
12220 IF (state% = C_ABSENT%) THEN r% = FALSE
12230 := r%
12240 :
12250 REM ::::::::::::::::::::::::::::::::::::::::::::::
12260 REM :: Update Match Status For A Guessed Letter ::
12270 REM ::::::::::::::::::::::::::::::::::::::::::::::
12280 DEF PROC_UPDATE_LETTER_STATE(letter$, state%)
12290 LOCAL currentState%, finalState%
12300 currentState% = FN_RETRIEVE_LETTER_STATE(letter$):finalState% = currentState%
12310 IF state% = C_ABSENT% AND currentState% = C_BLANK% THEN finalState% = state%
12320 IF state% = C_PRESENT% AND currentState% <> C_CORRECT% THEN finalState% = state%
12330 IF state% = C_CORRECT% THEN finalState% = state%
12340 LetterStates$ = FN_XSTRING$(LetterStates$, ASC(letter$) - 64, CHR$(finalState%))
12350 ENDPROC
12360 :
12370 REM :::::::::::::::::::::::::::
12380 REM :: Retrieve Match Status ::
12390 REM :::::::::::::::::::::::::::
12400 DEF FN_RETRIEVE_LETTER_STATE(letter$)
12410 := ASC(MID$(LetterStates$, ASC(letter$) - 64, 1))
12420 :
12430 REM ::::::::::::::::::::::::::::::::::::::::::
12440 REM :: Display Match Status For All Letters ::
12450 REM ::::::::::::::::::::::::::::::::::::::::::
12460 DEF PROC_DISPLAY_LETTER_STATES(x%, y%)
12470 LOCAL col%, i%
12480 FOR i% = 1 TO LEN(LetterStates$)
12490   col% = ASC(MID$(COL_AICP$, ASC(MID$(LetterStates$, i%, 1)), 1))
12500   PRINT TAB(x% + i% - 1, y%)FN_RVS(col%, BLACK, CHR$(i% + 64))
12510 NEXT i%
12520 PROC_DEFAULT_COLORS
12530 ENDPROC
12540 :
12550 REM ::::::::::::::::::::::::::::::::::::
12560 REM :: Select A Mystery Word To Guess ::
12570 REM ::::::::::::::::::::::::::::::::::::
12580 DEF FN_SELECT_A_MYSTERY_WORD(length%)
12590 LOCAL i%, index%, wordCount%
12600 wordCount% = FN_WORD_COUNT(length%):i% = length% - 2
12610 PROC_READ_LAST_PLAYED_WORDS
12620 index% = (LastPlayedWords%(i%) + 1) MOD wordCount%
12630 IF (NOT index%) THEN index% = FN_RND_INT(1, wordCount%)
12640 LastPlayedWords%(i%) = index%
12650 PROC_WRITE_LAST_PLAYED_WORDS
12660 := FN_FILE_READ_CHARS("DATA/DAT" + FN_PAD_NUMBER(length%, 2) + ".BIN", length%, index%)
12670 :
12680 REM :::::::::::::::::::::::::
12690 REM ::   File Read Chars   ::
12700 REM :::::::::::::::::::::::::
12710 DEF FN_FILE_READ_CHARS(file$, length%, offset%)
12720 LOCAL f0%, error%, i%, r$
12730 error% = FALSE:r$ = ""
12740 f0% = OPENIN(file$)
12750 IF f0% <> 0 THEN PTR#f0% = length% * (offset% - 1):FOR i% = 1 TO length%:r$ = r$ + CHR$(BGET#f0%):NEXT i%:ELSE error% = TRUE
12760 CLOSE#f0%
12770 := r$
12780 :
12790 REM ::::::::::::::::::
12800 REM ::  File Write  ::
12810 REM ::::::::::::::::::
12820 DEF PROC_FILE_WRITE(file$, str$)
12830 LOCAL f0%
12840 f0% = OPENOUT(file$)
12850 PRINT#f0%, str$
12860 CLOSE#f0%
12870 ENDPROC
12880 :
12890 REM ::::::::::::::::
12900 REM :: Word Count ::
12910 REM ::::::::::::::::
12920 DEF FN_WORD_COUNT(size%)
12930 LOCAL f0%, r%
12940 r% = -1
12950 f0% = OPENIN("DATA/DAT"+FN_PAD_NUMBER(size%, 2)+".BIN")
12960 IF f0% <> 0 THEN r% = EXT#f0% DIV size%
12970 CLOSE#f0%
12980 := r%
12990 :
13000 REM :::::::::::::::::::::::::::::::::::::::::::
13010 REM :: Validate Word Against Dictionary File ::
13020 REM :::::::::::::::::::::::::::::::::::::::::::
13030 DEF FN_CHECK_WORD_VALIDITY(word$)
13040 LOCAL isValid%, msg$, r%, size%, wordCount%
13050 isValid% = FALSE:size% = LEN(word$):wordCount% = 0:msg$ = "":r% = TRUE
13060 f0% = FN_DICT_FILE_EXISTS(size%)
13070 IF f0% THEN wordCount% = FN_DICT_WORD_COUNT(f0%, size%)
13080 IF wordCount% THEN isValid% = (0 <= FN_BINARY_SEARCH(f0%, word$, 0, wordCount%))
13090 CLOSE#f0%
13100 IF wordCount% AND NOT isValid% THEN r% = FALSE:msg$ = CHR$(17) + CHR$(YELLOW) + word$ + CHR$(17) + CHR$(RED) + " NOT IN WORD LIST!!!" + CHR$(17) + CHR$(WHITE)
13110 IF msg$ <> "" THEN PRINT TAB(0, 2)msg$:PROC_SOUND(56,15):PROC_SLEEP(200):PRINT TAB(0, 2)STRING$(CW%," "):REM FN_CENTER(msg$)
13120 := r%
13130 :
13140 REM ::::::::::::::::::::::::::::::::::::::::::::::::::::
13150 REM :: Determine If A Dictionary File Exists On Drive ::
13160 REM ::::::::::::::::::::::::::::::::::::::::::::::::::::
13170 DEF FN_DICT_FILE_EXISTS(size%)
13180 := OPENIN("DATA/DICT"+FN_PAD_NUMBER(size%, 2)+".BIN")
13190 :
13200 REM ::::::::::::::::::::::::::::::::::::::::::::::
13210 REM :: Derive Count Of Words In Dictionary File ::
13220 REM ::::::::::::::::::::::::::::::::::::::::::::::
13230 DEF FN_DICT_WORD_COUNT(f0%, size%)
13240 LOCAL r%
13250 r% = 0:IF f0% THEN r% = EXT#f0% DIV size%
13260 := r%
13270 :
13280 REM ::::::::::::::::::::::::::::::::::::::
13290 REM :: Read A Word From Dictionary File ::
13300 REM ::::::::::::::::::::::::::::::::::::::
13310 DEF FN_DICT_READ_WORD(f0%, size%, index%)
13320 LOCAL i%, r$
13330 r$ = ""
13340 IF f0% THEN PTR#f0% = size% * (index% - 1):FOR i% = 1 TO size%:r$ = r$ + CHR$(BGET#f0%):NEXT i%
13350 := r$
13360 :
13370 REM :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
13380 REM :: Use Binary Search To Search For Word In Dictionary File ::
13390 REM :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
13400 DEF FN_BINARY_SEARCH(f0%, word$, lo%, hi%)
13410 LOCAL r%
13420 r% = -1
13430 REPEAT
13440   mid% = (lo% + hi%) DIV 2
13450   fword$ = FN_DICT_READ_WORD(f0%, size%, mid%)
13460   IF fword$ > word$ THEN hi% = mid% - 1
13470   IF fword$ < word$ THEN lo% = mid% + 1
13480   IF fword$ = word$ THEN r% = mid%
13490 UNTIL lo% > hi% OR r% >= 0
13500 := r%
13510 :
13520 REM ::::::::::::::::::::::::::::
13530 REM :: Read Last Played Words ::
13540 REM ::::::::::::::::::::::::::::
13550 DEF PROC_READ_LAST_PLAYED_WORDS
13560 LOCAL fin%, error%, i%
13570 fin% = OPENIN("DATA/DAT01.BIN"):error% = NOT fin%
13580 IF NOT error% THEN FOR i% = 0 TO 10:INPUT#fin%, LastPlayedWords%(i%):NEXT i%
13590 CLOSE#fin%
13600 ENDPROC
13610 :
13620 REM ::::::::;::::::::::::::::::::
13630 REM :: Write Last Played Words ::
13640 REM :::::::::;:::::::::::::::::::
13650 DEF PROC_WRITE_LAST_PLAYED_WORDS
13660 LOCAL fout%, i%
13670 fout% = OPENOUT("DATA/DAT01.BIN")
13680 FOR i% = 0 TO 10:PRINT#fout%, LastPlayedWords%(i%):NEXT i%
13690 CLOSE#fout%
13700 ENDPROC
13710 :
13720 REM ::::::::::::::::::::::::
13730 REM :: Display Best Score ::
13740 REM ::::::::::::::::::::::::
13750 DEF PROC_DISPLAY_BEST_SCORE(size%)
13760 LOCAL hs$
13770 hs$ = CHR$(17)+CHR$(YELLOW)+"BEST "+CHR$(17)+CHR$(WHITE)+STR$(BestScores%(size% - 2))+"/"+STR$(MaximumTurns%)
13780 PRINT TAB(CW% - LEN(hs$) + 4, 0)hs$
13790 ENDPROC
13800 :
13810 REM :::::::::::::::::::::::
13820 REM :: Update Best Score ::
13830 REM :::::::::::::::::::::::
13840 DEF PROC_UPDATE_BEST_SCORE(size%, numGuesses%)
13850 IF (BestScores%(size% - 2) > numGuesses%) THEN BestScores%(size% - 2) = numGuesses%:REM Check if best score has been surpassed and update if needed
13860 ENDPROC
13870 :
13880 REM ::::::::::::::::::::::::
13890 REM ::  Best Scores Read  ::
13900 REM ::::::::::::::::::::::::
13910 DEF PROC_BESTSCORES_READ
13920 LOCAL fin%, error%, i%
13930 fin% = OPENIN(GameName$ + ".HI"):error% = NOT fin%
13940 IF NOT error% THEN FOR i% = 0 TO 10:INPUT#fin%, BestScores%(i%):NEXT i%
13950 CLOSE#fin%
13960 ENDPROC
13970 :
13980 REM :::::::::::::::::::::::::
13990 REM ::  Best Scores Write  ::
14000 REM :::::::::::::::::::::::::
14010 DEF PROC_BESTSCORES_WRITE
14020 LOCAL fout%, i%
14030 fout% = OPENOUT(GameName$ + ".HI")
14040 FOR i% = 0 TO 10:PRINT#fout%, BestScores%(i%):NEXT i%
14050 CLOSE#fout%
14060 ENDPROC
14070 :
14080 REM ::::::::::::::::::::::::
14090 REM :: Derive Superlative ::
14100 REM ::::::::::::::::::::::::
14110 DEF FN_DERIVE_SUPERLATIVE(numGuesses%)
14120 LOCAL r$
14130 r$ = "Inconceivable?"
14140 IF numGuesses% > 1 THEN r$ = "Extraordinary"
14150 IF numGuesses% > 2 THEN r$ = "Exceptional"
14160 IF numGuesses% > 3 THEN r$ = "Splendid"
14170 IF numGuesses% > 4 THEN r$ = "Remarkable"
14180 IF numGuesses% > 5 THEN r$ = "Commendable"
14190 := r$
14200 :
14210 REM :::::::::::::::::::
14220 REM ::    Welcome    ::
14230 REM :::::::::::::::::::
14240 DEF PROC_WELCOME
14250 LOCAL boxh%, boxw%, c%, cc%, ch$, co%, ex%, perimeter%, t%, t$, ux%, uy%
14260 boxh% = 20:boxw% = 38:cc% = 0:ex% = FALSE:perimeter% = 2 * (boxw% + boxh% - 2):t% = 2:ux% = (CW% - boxw%) DIV 2:uy% = 0:co% = 0
14270 PROC_DEFAULT_COLORS:CLS:PROC_HIDE_CURSOR
14280 PRINT TAB(0, uy% + 2);
14290 PROC_CENTER("Welcome to ..."):PRINT:PRINT
14300 PROC_CENTER(FN_RVS(GREEN,YELLOW,STRING$(10, CHR$(BLANK)))):PRINT
14310 PROC_CENTER(FN_RVS(GREEN,YELLOW,CHR$(BLANK)+CHR$(BLANK)+CHR$(T_DOWN)+CHR$(BLANK)+CHR$(BLANK)+CHR$(T_DOWN)+CHR$(BLANK)+CHR$(B_UR)+CHR$(B_UL)+CHR$(BLANK))):PRINT
14320 PROC_CENTER(FN_RVS(GREEN,YELLOW,CHR$(BLANK)+CHR$(BLANK)+CHR$(B_VERT)+CHR$(B_UR)+CHR$(B_UL)+CHR$(B_VERT)+CHR$(T_DOWN)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(BLANK))):PRINT
14330 PROC_CENTER(FN_RVS(GREEN,YELLOW,CHR$(BLANK)+CHR$(BLANK)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(BLANK))):PRINT
14340 PROC_CENTER(FN_RVS(GREEN,YELLOW,CHR$(BLANK)+CHR$(B_DR)+CHR$(B_DL)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_DR)+CHR$(B_DL)+CHR$(BLANK))):PRINT
14350 PROC_CENTER(FN_RVS(GREEN,YELLOW,STRING$(3, CHR$(BLANK))+CHR$(B_DR)+CHR$(B_DL)+CHR$(BLANK)+CHR$(B_VERT)+STRING$(3, CHR$(BLANK)))):PRINT
14360 PROC_CENTER(FN_RVS(GREEN,YELLOW,STRING$(10, CHR$(BLANK)))):PRINT:PROC_DEFAULT_COLORS
14370 PROC_CENTER(CHR$(17)+CHR$(YELLOW)+CHR$(B_UR)+CHR$(B_UL)+CHR$(B_UR)+CHR$(B_UL)+CHR$(B_UR)+CHR$(B_UL)+CHR$(B_UR)+CHR$(B_UL)+CHR$(BLANK)+CHR$(BLANK)):PRINT
14380 PROC_CENTER(CHR$(B_UR)+CHR$(B_DL)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_UR)+CHR$(B_DL)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(BLANK)+CHR$(BLANK)):PRINT
14390 PROC_CENTER(CHR$(B_VERT)+CHR$(BLANK)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(BLANK)+CHR$(B_VERT)+CHR$(B_VERT)+CHR$(BLANK)+CHR$(BLANK)):PRINT
14400 PROC_CENTER(CHR$(B_DR)+CHR$(B_HORZ)+CHR$(B_DR)+CHR$(B_DL)+CHR$(B_DR)+CHR$(B_HORZ)+CHR$(B_DR)+CHR$(B_DL)+CHR$(BLANK)+CHR$(BLANK)):PRINT
14410 COLOUR CYAN:PRINT:PROC_CENTER("Hit a key to continue")
14420 PROC_CLOCKWISE_BOX(ux% + 1, uy% + 1, boxw% - 2, boxh% - 2, CYAN)
14430 REPEAT
14440   ch% = FN_RND_INT(ASC("A"),ASC("Z"))
14450   PROC_CLOCKWISE_PLOT(cc%, BLACK, BLANK, ux%, uy%, boxw%, boxh%)
14460   cc% = (cc% + 1) MOD perimeter%:IF cc% = 1 THEN co% = (co% + 1) MOD 7 + 1
14470   PROC_CLOCKWISE_PLOT(cc%, co%, ch%, ux%, uy%, boxw%, boxh%)
14480   IF SY$ = "A" THEN c% = INKEY(DL%):PROC_EMPTY_KEYBOARD_BUFFER:ELSE c% = INKEY(TK/DL%)
14490   IF c% > 0 THEN ex% = TRUE
14500 UNTIL ex%
14510 boxh% = 17:boxw% = 38:cc% = 0:ex% = FALSE:perimeter% = 2 * (boxw% + boxh% - 2):t% = 2:ux% = (CW% - boxw%) DIV 2:uy% = 0:co% = 0
14520 PROC_DEFAULT_COLORS:CLS
14530 PRINT TAB(0, uy% + 2);
14540 PROC_CENTER(CHR$(17)+CHR$(YELLOW)+"Jotto 2020"+CHR$(17)+CHR$(WHITE)+" is a modern variant of"):PRINT
14550 PROC_CENTER(CHR$(17)+CHR$(GREEN)+"JOTTO"+CHR$(17)+CHR$(WHITE)+", the classic pen and paper "):PRINT
14560 PROC_CENTER("word guessing game. The object of"):PRINT
14570 PROC_CENTER("the game is to guess the mystery "):PRINT
14580 PROC_CENTER("English word with a letter length"):PRINT
14590 PROC_CENTER("between 2 and 12 (your choosing)."):PRINT
14600 PROC_CENTER("After each guess you will get to "):PRINT
14610 PROC_CENTER("see a report of the letters (or  "):PRINT
14620 PROC_CENTER("JOTs) in the guess that match or "):PRINT
14630 PROC_CENTER("occur in the mystery word...     "):PRINT:PRINT
14640 COLOUR CYAN:PROC_CENTER("Hit a key to continue")
14650 PROC_CLOCKWISE_BOX(ux% + 1, uy% + 1, boxw% - 2, boxh% - 2, CYAN)
14660 REPEAT
14670   ch% = FN_RND_INT(ASC("A"),ASC("Z"))
14680   PROC_CLOCKWISE_PLOT(cc%, BLACK, BLANK, ux%, uy%, boxw%, boxh%)
14690   cc% = (cc% + 1) MOD perimeter%:IF cc% = 1 THEN co% = (co% + 1) MOD 7 + 1
14700   PROC_CLOCKWISE_PLOT(cc%, co%, ch%, ux%, uy%, boxw%, boxh%)
14710   IF SY$ = "A" THEN c% = INKEY(DL%):PROC_EMPTY_KEYBOARD_BUFFER:ELSE c% = INKEY(TK/DL%)
14720   IF c% > 0 THEN ex% = TRUE
14730 UNTIL ex%
14740 PROC_DEFAULT_COLORS:CLS:boxh% = 21:cc% = 0:ex% = FALSE:perimeter% = 2 * (boxw% + boxh% - 2)
14750 PRINT TAB(0, uy% + 2);
14760 PROC_CENTER(FN_RVS(RED,BLACK,"A")+CHR$(17)+CHR$(WHITE)+": Absent from mystery word      "):PRINT:PRINT
14770 PROC_CENTER(FN_RVS(YELLOW,BLACK,"A")+CHR$(17)+CHR$(WHITE)+": Present BUT improperly located"):PRINT:PRINT
14780 PROC_CENTER(FN_RVS(GREEN,BLACK,"A")+CHR$(17)+CHR$(WHITE)+": Present AND perfectly located "):PRINT:PRINT
14790 PROC_CENTER("Through a process of elimination,"):PRINT
14800 PROC_CENTER("you should be able to deduce the "):PRINT
14810 PROC_CENTER("correct letters using logic.     "):PRINT
14820 PROC_CENTER("The number of allowed guesses for"):PRINT
14830 PROC_CENTER("solving the mystery word is based"):PRINT
14840 PROC_CENTER("on the length of the mystery     "):PRINT
14850 PROC_CENTER("word, but the minimum is five.   "):PRINT:PRINT
14860 COLOUR WHITE:PROC_CENTER("Good luck and have fun!"):PRINT:PRINT
14870 COLOUR GREEN:PROC_CENTER("Hit a key to begin playing")
14880 PROC_CLOCKWISE_BOX(ux% + 1, uy% + 1, boxw% - 2, boxh% - 2, CYAN)
14890 REPEAT
14900   ch% = FN_RND_INT(ASC("A"),ASC("Z"))
14910   PROC_CLOCKWISE_PLOT(cc%, BLACK, BLANK, ux%, uy%, boxw%, boxh%)
14920   cc% = (cc% + 1) MOD perimeter%:IF cc% = 1 THEN co% = (co% + 1) MOD 7 + 1
14930   PROC_CLOCKWISE_PLOT(cc%, co%, ch%, ux%, uy%, boxw%, boxh%)
14940   IF SY$ = "A" THEN c% = INKEY(DL%):PROC_EMPTY_KEYBOARD_BUFFER:ELSE c% = INKEY(TK/DL%)
14950   IF c% > 0 THEN ex% = TRUE
14960 UNTIL ex%
14970 PROC_DEFAULT_COLORS
14980 ENDPROC
14990 :
15000 REM :::::::::::::::::
15010 REM ::  Game Over  ::
15020 REM :::::::::::::::::
15030 DEF PROC_GAME_OVER
15040 LOCAL co%, msg$
15050 IF Lost% THEN co% = RED:msg$ = "So sorry! You lost.":ELSE co% = GREEN:msg$ = FN_DERIVE_SUPERLATIVE(GuessCount%)+"!!"
15060 VDU 17,co%:VDU 31, 0, GuessCount% + 6:PROC_CENTER(msg$)
15070 PROC_SLEEP(200)
15080 ENDPROC
15090 :
15100 REM :::::::::::::::::::::::
15110 REM :: Play Another Game ::
15120 REM :::::::::::::::::::::::
15130 DEF FN_PLAY_AGAIN
15140 LOCAL r$
15150 VDU 17,YELLOW
15160 REPEAT r$ = FN_CENTERED_PROMPT(0, GuessCount% + 8, "Play Again? (Y/N)", "") UNTIL INSTR("YN", r$) <> 0
15170 = r$
15180 :
15190 REM :::::::::::::::::
15200 REM :: Say Goodbye ::
15210 REM :::::::::::::::::
15220 DEF PROC_GOODBYE(game$)
15230 PROC_HIDE_CURSOR
15240 CLS:PROC_FULL_CENTER_TEXT("So long and thank you for playing...")
15250 FOR i% = 0 TO FN_CENTER(game$) - 1:PRINTTAB(0, CH% DIV 2 + 2)STRING$(i%, " ")CHR$(17)CHR$(i% MOD 7 + 1)game$:PROC_SLEEP(20):NEXT i%
15260 PROC_DEFAULT_COLORS
15270 PROC_SHOW_CURSOR
15280 ENDPROC
15290 :
15300 REM :::::::::::::::::::::
15310 REM ::   Center text   ::
15320 REM :::::::::::::::::::::
15330 DEF FN_CENTER(text$)
15340 LOCAL x%
15350 x% = CW% - LEN(text$)
15360 := x% DIV 2 + x% MOD 2
15370 :
15380 REM :::::::::::::::::::::::::::::::::::
15390 REM :: Display Text In Reverse Video ::
15400 REM :::::::::::::::::::::::::::::::::::
15410 DEF FN_RVS(fg%, bg%, text$):= CHR$(17)+CHR$(128+fg%)+CHR$(17)+CHR$(bg%)+text$+CHR$(17)+CHR$(fg%)+CHR$(17)+CHR$(128+bg%)
15420 :
15430 REM ::::::::::::::::::::::
15440 REM :: Maximum of x & y ::
15450 REM ::::::::::::::::::::::
15460 DEF FN_MAX(x, y):= y + (x > y) * (y - x)
15470 :
15480 REM ::::::::::::::::::::::
15490 REM :: Minimum of x & y ::
15500 REM ::::::::::::::::::::::
15510 DEF FN_MIN(x, y):= y + (x < y) * (y - x)
15520 :
15530 REM ::::::::::::::::::::::
15540 REM :: The Ceiling Of n ::
15550 REM ::::::::::::::::::::::
15560 DEF FN_CEILING(n):= INT(n) + (n - INT(n) > 0) * -1
15570 :
15580 REM ::::::::::::::::::::::
15590 REM ::  The Floor Of n  ::
15600 REM ::::::::::::::::::::::
15610 DEF FN_FLOOR(n):= INT(n) + (n - INT(n) < 0)
15620 :
15630 REM ::::::::::::::::::::::::
15640 REM :: The Factorial Of n ::
15650 REM ::::::::::::::::::::::::
15660 DEF FN_FACTORIAL(n%):REM Where n$ is between 0 and 12
15670 LOCAL r%
15680 r% = 1:IF n% = 0 THEN n% = 1:ELSE IF n% < 0 THEN ERROR 30, "-ve factorial"
15690 REPEAT r% = r% * n%:n% = n% - 1:UNTIL n% < 1
15700 := r%
15710 :
15720 REM ::::::::::::::::::::::::::::
15730 REM :: Fibonacci number for n ::
15740 REM ::::::::::::::::::::::::::::
15750 DEF FN_FIBONACCI(n%)
15760 LOCAL a%, b%, i%, r%
15770 a% = 0:b% = 1:r% = 0:IF n% < 0 THEN ERROR 30, "-ve fibonacci"
15780 IF (n% > 0) THEN FOR i% = 2 TO n%:r% = a% + b%:a% = b%:b% = r%:NEXT i%
15790 := r%
15800 :
15810 REM :::::::::::::::::::::::::::
15820 REM ::   Bounded time ticks  ::
15830 REM :::::::::::::::::::::::::::
15840 DEF FN_INT_TIME:= TIME MOD MAXINT%
15850 :
15860 REM :::::::::::::::::::::::
15870 REM :: Has time reached  ::
15880 REM :: target seconds?   ::
15890 REM :::::::::::::::::::::::
15900 DEF FN_IS_TIME(sec%, prevSec%, targetSec%):= (sec% MOD targetSec% = 0 AND sec% <> prevSec%)
15910 :
15920 REM ::::::::::::::::::::::
15930 REM :: Retrieve a byte  ::
15940 REM :: register value   ::
15950 REM :: from VDP         ::
15960 REM ::::::::::::::::::::::
15970 DEF FN_getByteVDP(var%):A% = &A0:L% = var%:= USR(&FFF4)
15980 :
15990 REM ::::::::::::::::::::::
16000 REM :: Retrieve a word  ::
16010 REM :: register value   ::
16020 REM :: from VDP         ::
16030 REM ::::::::::::::::::::::
16040 DEF FN_getWordVDP(var%):= FN_getByteVDP(var%) + 256 * FN_getByteVDP(var% + 1)
16050 :
16060 REM ::::::::::::::::::::::
16070 REM :: Retrieve the     ::
16080 REM :: number of colors ::
16090 REM :: reported by VDP  ::
16100 REM ::::::::::::::::::::::
16110 DEF FN_COLORCOUNT:= FN_getByteVDP(&15)
16120 :
16130 REM ::::::::::::::::::::::
16140 REM :: Retrieve the     ::
16150 REM :: ASCII key code   ::
16160 REM :: reported by VDP  ::
16170 REM ::::::::::::::::::::::
16180 DEF FN_ASCII_KEYCODE:= FN_getByteVDP(&05)
16190 :
16200 REM ::::::::::::::::::::::
16210 REM :: Retrieve the     ::
16220 REM :: Virtual key code ::
16230 REM :: reported by VDP  ::
16240 REM ::::::::::::::::::::::
16250 DEF FN_VIRTUAL_KEYCODE:= FN_getByteVDP(&17)
16260 :
16270 REM :::::::::::::::::::::::::::::
16280 REM :: Retrieve the number of  ::
16290 REM :: keys as reported by VDP ::
16300 REM :::::::::::::::::::::::::::::
16310 DEF FN_ASCII_KEYCOUNT:= FN_getByteVDP(&19)
16320 :
16330 REM :::::::::::::::::::::::::::::::::
16340 REM :: Retrieve a keypress within  ::
16350 REM :: the given timeout value     ::
16360 REM :::::::::::::::::::::::::::::::::
16370 DEF FN_GET_KEY(timeout%)
16380 LOCAL i%, keycount%, r%, sync%
16390 r% = -1
16400 keycount% = FN_ASCII_KEYCOUNT
16410 i% = 0
16420 REPEAT
16430   IF keycount% <> FN_ASCII_KEYCOUNT THEN r% = FN_ASCII_KEYCODE:IF r% = 0 THEN r% = FN_VIRTUAL_KEYCODE ELSE *FX 19
16440   i% = i% + 1
16450 UNTIL i% = timeout% OR r% > 0
16460 := r%
16470 :
16480 REM :::::::::::::::::::::::::::
16490 REM :: Empty Keyboard Buffer ::
16500 REM :::::::::::::::::::::::::::
16510 DEF PROC_EMPTY_KEYBOARD_BUFFER
16520 REPEAT UNTIL INKEY(0) = -1
16530 ENDPROC
16540 :
16550 REM ::::::::::::::::::::::::::::
16560 REM :: Disable display of the ::
16570 REM :: cursor on the screen   ::
16580 REM ::::::::::::::::::::::::::::
16590 DEF PROC_HIDE_CURSOR:VDU 23,1,0;0;0;0;:ENDPROC
16600 :
16610 REM ::::::::::::::::::::::::::::
16620 REM :: Enable display of the  ::
16630 REM :: cursor on the screen   ::
16640 REM ::::::::::::::::::::::::::::
16650 DEF PROC_SHOW_CURSOR:VDU 23,1,1;0;0;0;:ENDPROC
16660 :
16670 REM :::::::::::::::::::::::::::::::::
16680 REM :: Center text both vertically ::
16690 REM :: and horizontally            ::
16700 REM :::::::::::::::::::::::::::::::::
16710 DEF PROC_FULL_CENTER_TEXT(text$):PRINT TAB(FN_CENTER(text$), CH% DIV 2)text$;:ENDPROC
16720 :
16730 REM :::::::::::::::::::::::::::::::::::::::
16740 REM :: Pause execution of the program    ::
16750 REM :: for a number of ticks (1/100) sec ::
16760 REM :::::::::::::::::::::::::::::::::::::::
16770 DEF PROC_SLEEP(hundredth_seconds%):LOCAL t:hundredth_seconds% = hundredth_seconds% + (hundredth_seconds% < 0) * -hundredth_seconds%:t = TIME:REPEAT UNTIL ((TIME - t) > hundredth_seconds%):ENDPROC
16780 :
16790 REM ::::::::::::::::::::::::::::::::
16800 REM :: Return TRUE when random    ::
16810 REM :: value is below given value ::
16820 REM ::::::::::::::::::::::::::::::::
16830 DEF FN_RND_PCT(n%):=RND(1) <= (n% / 100):REM Returns TRUE or FALSE
16840 :
16850 REM :::::::::::::::::::::::::::::::::
16860 REM :: Random Integer Within Range ::
16870 REM :::::::::::::::::::::::::::::::::
16880 DEF FN_RND_INT(lo%, hi%):= (RND(1) * (hi% - lo% + 1)) + lo%
16890 :
16900 REM ::::::::::::::::::::::::::::::::
16910 REM :: Generate A Random Sequence ::
16920 REM ::::::::::::::::::::::::::::::::
16930 DEF FN_RND_SEQ(n%)
16940 LOCAL i%, r$
16950 R$ = ""
16960 FOR i% = 1 TO n%
16970   r$ = r$ + MID$(P$, FN_RND_INT(1, 7), 1)
16980 NEXT i%
16990 := r$
17000 :
17010 REM ::::::::::::::::::::::::::::::::
17020 REM :: Prepend Zeroes To A Number ::
17030 REM ::::::::::::::::::::::::::::::::
17040 DEF FN_PAD_NUMBER(val%, len%)
17050 LOCAL s$
17060 s$ = STR$(val%)
17070 := STRING$(len% - LEN(s$), "0") + s$
17080 :
17090 REM ::::::::::::::::::::::::::::::::
17100 REM :: Replace A Char In A String ::
17110 REM ::::::::::::::::::::::::::::::::
17120 DEF FN_XSTRING$(text$, pos%, char$)
17130 := LEFT$(text$, pos% - 1) + char$ + RIGHT$(text$, LEN(text$) - pos%)
17140 :
17150 REM ::::::::::::::::::::::
17160 REM ::   To Uppercase   ::
17170 REM ::::::::::::::::::::::
17180 DEF FN_TO_UPPER(ch$):LOCAL ch%:ch% = ASC(ch$):ch$ = CHR$(ch% + 32 * (ch% >= 97 AND ch% <= 122)):=ch$
17190 :
17200 REM ::::::::::::::::::::::
17210 REM ::   To Lowercase   ::
17220 REM ::::::::::::::::::::::
17230 DEF FN_TO_LOWER(ch$):LOCAL ch%:ch% = ASC(ch$):ch$ = CHR$(ch% - 32 * (ch% >= 65 AND ch% <= 90)):=ch$
17240 :
17250 REM :::::::::::::::::::::::::
17260 REM :: Prompt For Response ::
17270 REM :::::::::::::::::::::::::
17280 DEF FN_PROMPT(x%, y%, text$, default$)
17290 LOCAL r$
17300 PROC_EMPTY_KEYBOARD_BUFFER
17310 PRINT TAB(x%, y%)text$;" ";default$:PRINT TAB(x% + LEN(text$) + 1, y%);
17320 r$ = GET$:r$ = FN_TO_UPPER(r$):IF r$ = CHR$(13) THEN r$ = default$
17330 := r$
17340 :
17350 REM ::::::::::::::::::::::::::::::::::
17360 REM :: Centered Prompt For Response ::
17370 REM ::::::::::::::::::::::::::::::::::
17380 DEF FN_CENTERED_PROMPT(x%, y%, text$, default$)
17390 := FN_PROMPT(x% DIV 2 + FN_CENTER(text$), y%, text$, default$)
17400 :
17410 REM :::::::::::::::::::::::::::::
17420 REM ::  Display Centered Text  ::
17430 REM :::::::::::::::::::::::::::::
17440 DEF PROC_CENTER(text$)
17450 LOCAL i%, n%, l%
17460 l% = 0
17470 FOR i% = 1 TO LEN(text$)
17480   IF ASC(MID$(text$, i%, 1)) >= BLANK THEN l% = l% + 1
17490 NEXT i%
17500 n% = FN_CENTER(STRING$(l%, CHR$(BLANK)))
17510 i% = VPOS:VDU 31, n%, i%
17520 FOR i% = 1 TO LEN(text$)
17530   VDU ASC(MID$(text$, i%, 1))
17540 NEXT i%
17550 ENDPROC
17560 :
17570 REM :::::::::::::::::::::::::
17580 REM :: Prompt For A Number ::
17590 REM :::::::::::::::::::::::::
17600 DEF FN_PROMPT_FOR_NUMBER(defaultValue%, maxDigitCount%)
17610 LOCAL c$, r$
17620 r$ = "":PROC_EMPTY_KEYBOARD_BUFFER
17630 REPEAT
17640   c$ = INKEY$(10)
17650   IF ((c$ = CHR$(127) OR c$ = CHR$(8)) AND LEN(r$) > 0) THEN r$ = LEFT$(r$, LEN(r$) - 1):PRINT CHR$(127);
17660   IF (c$ >= "0" AND c$ <= "9") AND (LEN(r$) < maxDigitCount%) THEN r$ = r$ + c$:PRINT c$;
17670 UNTIL c$ = CHR$(13)
17680 IF LEN(r$) < 1 THEN r$ = STR$(defaultValue%)
17690 :=VAL(r$)
17700 :
17710 REM ::::::::::::::::::::::::::::
17720 REM :: Restore Default Colors ::
17730 REM ::::::::::::::::::::::::::::
17740 DEF PROC_DEFAULT_COLORS
17750 COLOUR 128+BLACK:COLOUR WHITE
17760 ENDPROC
17770 :
17780 REM :::::::::::::::::::::::::::::::::::::::::::
17790 REM ::  Calculate type index of a clockwise  ::
17800 REM ::  position on a box's perimeter        ::
17810 REM :::::::::::::::::::::::::::::::::::::::::::
17820 DEF FN_CLOCKWISE_BOX_SIDE_INDEX(pos%, width%, height%)
17830 REM 0 = UPPER_LEFT_CORNER, 1 = UPPER_MIDDLE, 2 = UPPER_RIGHT_CORNER, 3 = MIDDLE_RIGHT, 4 = LOWER_RIGHT_CORNER, 5 = LOWER_MIDDLE, 6 = LOWER_LEFT_CORNER, 7 = MIDDLE_LEFT
17840 LOCAL r%
17850 r% = (pos% > 0 AND pos% < width% - 1) * -1 + (pos% = width% - 1) * -2 + (pos% >= width% AND pos% < width% + height% - 2) * -3 + (pos% = width% + height% - 2) * -4
17860 r% = r% + (pos% > width% + height% - 2 AND pos% < 2 * width% + height% - 3) * -5 + (pos% = 2 * width% + height% - 3) * -6 + (pos% > 2 * width% + height% - 3) * -7
17870 :=r%
17880 :
17890 REM ::::::::::::::::::::::::::
17900 REM ::  Draw Box Clockwise  ::
17910 REM ::::::::::::::::::::::::::
17920 DEF PROC_CLOCKWISE_BOX(ux%, uy%, width%, height%, color%)
17930 LOCAL aq%, bq%, ch%, i%, p%, x%, y%
17940 aq% = width% + height% - 2:bq% = aq% + width%:p% = bq% + height% - 2
17950 FOR i% = 0 TO p% - 1
17960   x% = (i% < width%) * -i% + (i% > (width%-1) AND i% < aq%) * -(width%-1) + (i% >= aq% AND i% < bq%) * (i% - (bq% - 1)) + (i% >= bq%) * 0
17970   y% = (i% < width%) * 0 + (i% > (width%-1) AND i% < aq%) * -(i% - (width%-1)) + (i% >= aq% AND i% < bq%) * -(height%-1) + (i% >= bq%) * -((height%-2) - (i% - bq%))
17980   ch% = ASC(MID$(BX$, FN_CLOCKWISE_BOX_SIDE_INDEX(i%, width%, height%) + 1, 1))
17990   PROC_PLOT(ux% + x%, uy% + y%, ch%, color%)
18000 NEXT i%
18010 ENDPROC
18020 :
18030 REM ::::::::::::::::::::::::::::::::
18040 REM ::       Clockwise Plot       ::
18050 REM ::::::::::::::::::::::::::::::::
18060 DEF PROC_CLOCKWISE_PLOT(pos%, color%, char%, ux%, uy%, width%, height%)
18070 LOCAL cx%, cy%, a%, b%, c%
18080 a% = width% + height% - 2:b% = a% + width%:c% = b% + height% - 2
18090 cx% = (pos% < width%) * -pos% + (pos% > (width% - 1) AND pos% < a%) * -(width% - 1)
18100 cx% = cx% + (pos% >= a% AND pos% < b%) * (pos% - (b% - 1)) + (pos% >= b%) * 0
18110 cy% = (pos% < width%) * 0 + (pos% > (width% - 1) AND pos% < a%) * -(pos% - (width% - 1))
18120 cy% = cy% + (pos% >= a% AND pos% < b%) * -(height% - 1) + (pos% >= b%) * -((height% - 2) - (pos% - b%))
18130 VDU 31,ux% + cx%,uy% + cy%,17,color%,char%:REM Plot a character on the path
18140 ENDPROC
18150 :
18160 REM :::::::::::::::::::::::
18170 REM :: Play Simple Sound ::
18180 REM :::::::::::::::::::::::
18190 DEF PROC_SOUND(index%, duration%)
18200 LOCAL constant%
18210 SOUND 1, -12, index%, duration%
18220 ENDPROC
18230 :
18240 REM :::::::::::::::::::::::::
18250 REM :: Play Musical Phrase ::
18260 REM :::::::::::::::::::::::::
18270 DEF PROC_PLAY(notes$)
18280 LOCAL d%, j%, l%, p%
18290 l% = LEN(notes$) DIV 3
18300 FOR j% = 1 TO l% STEP 2
18310   p% = VAL(MID$(notes$, 3 * (j% - 1) + 1, 3)):d% = VAL(MID$(notes$, 3 * (j% - 1) + 4, 3))
18320   IF p% >= 0 THEN SOUND 1, -10, p%, d%:ELSE SOUND 1, 0, 0, d%
18330   SOUND 1, 0, p%, 1:REM Stacatto the currently playing sound
18340 NEXT j%
18350 ENDPROC
18360 :
18370 REM :::::::::::::::::::
18380 REM ::  CHARGE!!!!!  ::
18390 REM :::::::::::::::::::
18400 DEF PROC_CHARGE
18410 PROC_PLAY("129001149001165001177004165002177008"):REM PITCH,DURATION
18420 ENDPROC
18430 :
18440 REM ::::::::::::::
18450 REM ::  Tada!!  ::
18460 REM ::::::::::::::
18470 DEF PROC_TADA
18480 PROC_PLAY("197002225008"):REM PITCH,DURATION
18490 ENDPROC
18500 :
18510 REM :::::::::::::::
18520 REM ::  WAH-WAH  ::
18530 REM :::::::::::::::
18540 DEF PROC_WAH_WAH
18550 PROC_PLAY("081002081002081002069020073002073002073002061024"):REM PITCH,DURATION
18560 ENDPROC
18570 :
18580 REM :::::::::::::::::::::::::::
18590 REM :: Plot a single colored ::
18600 REM :: character to screen   ::
18610 REM :::::::::::::::::::::::::::
18620 DEF PROC_PLOT(x%, y%, ch%, co%)
18630 VDU 31, x%, y%
18640 VDU 17, co%, ch%
18650 ENDPROC
18660 :
18670 REM ::::::::::::::::::::::::::
18680 REM :: Define Custom Colors ::
18690 REM ::::::::::::::::::::::::::
18700 DEF PROC_REDEFINE_COLORS
18710 IF SY$="A" AND FN_COLORCOUNT < &40 THEN VDU 19,C_ORANGE,&FF,&FF,&80,&00:ELSE COLOUR C_ORANGE,&FF,&80,&00
18720 ENDPROC
18730 :
18740 REM ::::::::::::::::::::::::::::::
18750 REM :: Define Custom Characters ::
18760 REM ::::::::::::::::::::::::::::::
18770 DEF PROC_REDEFINE_CHARS
18780 VDU 23,B_VERT,24,24,24,24,24,24,24,24:REM VERTICAL
18790 VDU 23,B_HORZ,0,0,0,255,255,0,0,0:REM HORIZONTAL
18800 VDU 23,B_UR,0,0,0,7,15,28,24,24:REM UPRIGHT C
18810 VDU 23,B_UL,0,0,0,224,240,56,24,24:REM UPLEFT C
18820 VDU 23,B_DL,24,24,56,240,224,0,0,0:REM DOWNLEFT C
18830 VDU 23,B_DR,24,24,28,15,7,0,0,0:REM DOWN RIGHT C
18840 VDU 23,T_UP,24,24,24,255,255,0,0,0:REM UP T
18850 VDU 23,T_DOWN,0,0,0,255,255,24,24,24:REM DOWN T
18860 VDU 23,FR_1,255,255,255,255,255,255,255,255
18870 VDU 23,FR_2,127,255,255,255,255,255,255,254
18880 VDU 23,FR_3,62,126,126,126,126,126,126,124
18890 VDU 23,FR_4,28,60,60,60,60,60,60,56
18900 VDU 23,FR_5,28,28,28,28,28,28,28,28
18910 VDU 23,FR_6,56,60,60,60,60,60,60,28
18920 VDU 23,FR_7,124,126,126,126,126,126,126,62
18930 VDU 23,FR_8,124,126,126,126,126,126,126,62
18940 VDU 23,FR_9,254,255,255,255,255,255,255,127
18950 ENDPROC
18960 :
18970 REM ::::::::::::::::::::::::::::::
18980 REM ::  Error Handling Routine  ::
18990 REM ::::::::::::::::::::::::::::::
19000 DEF PROC_HANDLE_ERROR
19010 IF ERR <> 17 THEN PROC_DEFAULT_COLORS:PROC_SHOW_CURSOR:PRINT:REPORT:PRINT" @line #";ERL:STOP
19020 ENDPROC
