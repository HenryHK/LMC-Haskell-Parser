Little Man Computer Parser in Haskell

Supporting commands:

<ul>
<li>INP: ask user to type in a number then store it in the accumulator</li><br/>
<li>STA: get the value in the accumulator then store it in the mailbox of the given label</li><br/>
<li>LDA: get the value in the mailbox of the given label then store it in the accumulator</li><br/>
<li>ADD: get the value in the mailbox of the given label, add it with the accumulator and store</li><br/>
<li>SUB: subtract the value in mailbox of the given label from the value in the accumulator</li><br/>
<li>OUT: print out the value in the accumulator</li><br/>
<li>BRA: jump to the instruction with the given label</li><br/>
<li>BRZ: check the value in the accumulator. if it is zero jump to the instruction with the given label</li><br/>
<li>BRP: check the value in the accumulator. if it is positive, jump to the instruction with the given label</li><br/>
<li>HLT: terminate the program</li><br/>
<li>DAT: declare a variable with an initial value. The initial value is zero by default</li><br/>
</ul>

test case:

--a program for parse testing</br><br/>
programTest :: String</br><br/>
programTest = "Start LDA ZERO//first line\n STA RESULT\n STA COUNT\n INP\n BRZ END\n STA VALUE //store input a value\nLOOP LDA RESULT"

--for parse testing</br><br/>
str :: String</br><br/>
str = "Start LDA ZERO//first line\nEND STA RESULT"

--take a user input and count down to zero</br><br/>
countDown :: String</br><br/>
countDown = "ONE DAT 1\n INP //test fuck\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT"

test :: String</bra><br/>
test = "THREE DAT 3 //sjhdas kj\n LDA THREE\n BRP QUIT\n OUT//sd sa\nQUIT HLT"

count :: String</br><br/>
count = "ONE DAT 1//first line\nTHREE DAT 3 //second line\n LDA THREE\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT//sd as"

--used for test STA command</br>
sta :: String
sta = "ONE DAT 1\n LDA ONE\n ADD ONE\n STA ONE\n SUB ONE\n OUT\n LDA ONE\n OUT\n HLT"