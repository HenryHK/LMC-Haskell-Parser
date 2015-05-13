## Simple Little Man Computer Parser in Haskell

Supporting commands:

<ul>
<li>INP: ask user to type in a number then store it in the accumulator</li>
<li>STA: get the value in the accumulator then store it in the mailbox of the given label</li>
<li>LDA: get the value in the mailbox of the given label then store it in the accumulator</li>
<li>ADD: get the value in the mailbox of the given label, add it with the accumulator and store</li>
<li>SUB: subtract the value in mailbox of the given label from the value in the accumulator</li>
<li>OUT: print out the value in the accumulator</li>
<li>BRA: jump to the instruction with the given label</li>
<li>BRZ: check the value in the accumulator. if it is zero jump to the instruction with the given label</li>
<li>BRP: check the value in the accumulator. if it is positive, jump to the instruction with the given label</li>
<li>HLT: terminate the program</li>
<li>DAT: declare a variable with an initial value. The initial value is zero by default</li>
</ul>

NOTICE: 1. ALL DAT s are at the front of a program; 2. Each line contains an instruction; 3. Each start with a lable or a space

test case:

--a program for parse testing<br/>
programTest :: String<br/>
programTest = "Start LDA ZERO//first line\n STA RESULT\n STA COUNT\n INP\n BRZ END\n STA VALUE //store input a value\nLOOP LDA RESULT"

--for parse testing<br/>
str :: String<br/>
str = "Start LDA ZERO//first line\nEND STA RESULT"

--take a user input and count down to zero<br/>
countDown :: String<br/>
countDown = "ONE DAT 1\n INP //test fuck\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT"

test :: String<br/>
test = "THREE DAT 3 //sjhdas kj\n LDA THREE\n BRP QUIT\n OUT//sd sa\nQUIT HLT"

count :: String<br/>
count = "ONE DAT 1//first line\nTHREE DAT 3 //second line\n LDA THREE\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT//sd as"

--used for test STA command</br>
sta :: String<br/>
sta = "ONE DAT 1\n LDA ONE\n ADD ONE\n STA ONE\n SUB ONE\n OUT\n LDA ONE\n OUT\n HLT"

Reference: [Little Man Computer](http://en.wikipedia.org/wiki/Little_man_computer)