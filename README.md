Little Man Computer Parser in Haskell

Supporting commands:
INP: ask user to type in a number then store it in the accumulator
STA: get the value in the accumulator then store it in the mailbox of the given label
LDA: get the value in the mailbox of the given label then store it in the accumulator
ADD: get the value in the mailbox of the given label, add it with the accumulator and store
SUB: subtract the value in mailbox of the given label from the value in the accumulator
OUT: print out the value in the accumulator
BRA: jump to the instruction with the given label
BRZ: check the value in the accumulator. if it is zero jump to the instruction with the given label
BRP: check the value in the accumulator. if it is positive, jump to the instruction with the given label
HLT: terminate the program
DAT: declare a variable with an initial value. The initial value is zero by default

test case:

--a program for parse testing
programTest :: String
programTest = "Start LDA ZERO//first line\n STA RESULT\n STA COUNT\n INP\n BRZ END\n STA VALUE //store input a value\nLOOP LDA RESULT"

--for parse testing
str :: String 
str = "Start LDA ZERO//first line\nEND STA RESULT"

--take a user input and count down to zero
countDown :: String
countDown = "ONE DAT 1\n INP //test fuck\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT"

test :: String
test = "THREE DAT 3 //sjhdas kj\n LDA THREE\n BRP QUIT\n OUT//sd sa\nQUIT HLT"

count :: String 
count = "ONE DAT 1//first line\nTHREE DAT 3 //second line\n LDA THREE\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT//sd as"

--used for test STA command
sta :: String
sta = "ONE DAT 1\n LDA ONE\n ADD ONE\n STA ONE\n SUB ONE\n OUT\n LDA ONE\n OUT\n HLT"