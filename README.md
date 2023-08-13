# agon-jotto-2020

Jotto 2020: a modern variant of the classic game of [*Jotto*](https://en.wikipedia.org/wiki/Jotto) for AgonLight and BBC BASIC SDL written in [BBC BASIC v3](https://en.wikipedia.org/wiki/BBC_BASIC)

* Jotto 2020 cleverly combines the game play of [Jotto](https://en.wikipedia.org/wiki/Jotto) with [Mastermind](https://en.wikipedia.org/wiki/Mastermind_(board_game)) and adds the option to guess mystery words of lengths from 2 to 12 letters.
* Jotto 2020 debuted online in November 2020 as [my contest submission](https://dev.to/tonedef71/everyday-is-an-api-day-with-jotto-5eh8) for the [MuleSoft Hackathon 2020](https://blogs.mulesoft.com/dev-guides/announcing-the-mulesoft-hackathon-2020-winners/)
* Jotto 2020 may be played on an [AgonLight retro-computer](https://www.olimex.com/Products/Retro-Computers/AgonLight2/open-source-hardware), the [AgonLight Emulator](https://github.com/astralaster/agon-light-emulator/releases), or the [BBC BASIC SDL](http://www.bbcbasic.co.uk/bbcsdl/).

## Display
Jotto 2020 supports multiple display modes on the AgonLight, but looks best on a mode that supports a palette of 64 colors and minimum screen dimensions of 40 columns by 22 rows.

On BBC BASIC SDL, one display mode (MODE 9) is supported.

## How To Play
The object of the game is to guess that mystery word. Each guess you make will be answered by a report of the letters (or "jots") in the guess word that match or occur in the mystery word.

Jotto 2020 will provide instant feedback of how many of the letters are in the correct position in the mystery word.

Through a process of elimination, you should be able to deduce the correct letters using logic.

The number of allowed guesses to solve the mystery word varies based on the length of the secret word. The minimum is five guesses.

Jotto 2020 beings by prompting for the number of letters for the mystery word. You can select a mystery word as short as two letters, or as long as twelve letters.

The game will next prompt whether or not guesses should strictly be limited to actual words: "Y" to enforce guesses to be actual words, "N" to allow any input of letters.  The traditional game of pen and paper Jotto required that guesses be legitimate five-letter words.

To begin playing, simply enter your guess word; it must be the same number of letters as the mystery word.  You may press the backspace on your computer keyboard to erase one or more letters of your guess.  When the requisite number of letters have been entered, the color of the letters will change to orange, and you may then press the "Enter" key on your computer's keyboard to submit your guess for feedback. 

Jotto 2020 uses color-coded feedback resembling a traffic light metaphor to report which letters of your guess occur in the mystery word and whether or not any of those letters are in the correct position.
* Yellow letters will be displayed for those letters that are in the mystery word but are in the wrong position.
* Green letters will only be displayed for those letters that are both in the mystery word and in the correct position.
* Red letters will be displayed for letters that do not exist in the mystery word or for any extra copies of letters that have already been displayed as yellow or green letters.

For example:
If the mystery 5-letter word is "RADAR"...

  ... and you guessed "ARROW", 
  then Jotto 2020 will report a result displayed as
  three yellow letters and two red letters.

  ... and you guessed "RAZOR", 
  then Jotto 2020 will report a result displayed as 
  three green letters and two red letters.

  ... and you guessed "ERROR", 
  then Jotto 2020 will report a result displayed as 
  one green letter, one yellow letter, and three red letters; one 'R' is correctly placed (green), one 'R' is improperly placed (yellow), and the extra 'R' (red), just like the 'E' and the 'O', is 
  not in the mystery word.
  
Continue submitting guesses until you correctly solve the mystery word or you run out of allowed guess attempts.

## Demo Playthrough
https://github.com/tonedef71/agon-jotto-2020/assets/3978924/d52c57b5-d3ea-4299-a57d-22dd7d7e499f

