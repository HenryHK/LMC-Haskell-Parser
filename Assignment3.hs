module Assignment3 where

import Parsing
import Control.Monad.State

-- Exercise 1
option :: a -> Parser a -> Parser a
option x p = p +++ return x

optionMaybe :: Parser a -> Parser (Maybe a)
optionMaybe p = option Nothing (do
									x <- p
									return (Just x))

-- Exercise 2
sepBy1 :: Parser a -> Parser b -> Parser [a]
sepBy1 p sep = do{ x <-p
				; xs <- many(sep >> p)	
				; return (x:xs)}

sepBy :: Parser a -> Parser b -> Parser [a]
sepBy p sep = sepBy1 p sep +++ return []

-- You should not modify this definition. But you can add a deriving clause if you want.
type Label = String
type Program = [(Maybe Label, Instruction)]

data Instruction
    = ADD Label
    | SUB Label
    | STA Label
    | LDA Label
    | BRA Label
    | BRZ Label
    | BRP Label
    | DAT Int
    | INP
    | OUT
    | HLT
    deriving (Read, Show)
-- Exercise 3
instruction :: Parser Instruction
instruction = P (\inp -> case parse (sepBy (many alphanum ) (char ' '+++char '/')) inp of 
						[([ins], out)] -> case takeWhile (/='/') ins of 
												"DAT" -> [(DAT 0, out)]
												ins' -> [((read ins') :: Instruction, out)]
						[([ins, lbl], out)]	-> 	case ins of
												"DAT" -> case lbl of 
															"" -> [(DAT 0, out)]
															('/':_) -> [(DAT 0, out)]
															otherwise -> [((read ("DAT " ++ takeWhile (/='/') lbl))::Instruction, out)]
												ins' -> case lbl of 
															"" -> [((read ins') :: Instruction, out)]
															('/':_) -> [((read ins') :: Instruction, out)]
															otherwise -> [((read (ins' ++ " \"" ++ takeWhile (/='/') lbl ++"\"")) :: Instruction, out)]
						[( ins:(lbl:_ ) , out)]	-> 	case ins of
												"DAT" -> case lbl of
															"" -> [(DAT 0, out)] 
															('/':_) -> [(DAT 0, out)]
															otherwise -> [((read ("DAT " ++ takeWhile (/='/') lbl))::Instruction, out)]
												ins' -> case lbl of
															"" -> [((read ins') :: Instruction, out)] 
															('/':_) -> [((read ins') :: Instruction, out)]
															otherwise -> [((read (ins' ++ " \"" ++ takeWhile (/='/') lbl ++"\"")) :: Instruction, out)]
						otherwise -> []			
						)
line :: Parser (Maybe Label, Instruction)
line = P (\ln -> case parse (optionMaybe (many alphanum)) ln of
					[(Just "", ins)] -> case parse (token instruction) ins of 
											[(ins', content)] -> [((Nothing, ins'), content)]
											otherwise -> []
					[(Just lbl, ins)] -> case parse (token instruction) ins of 
											[(ins', content)] -> [((Just lbl, ins'), content)]
											otherwise -> []
	)
{-
-- Exercise 4
line :: Parser (Maybe Label, Instruction)
line = P (\ln -> case parse (sepBy (many alphanum) (char ' ')) ln of
			[(lbl:(ins:(content:_)), out)] -> case lbl of
												"" -> case ins of 
														"DAT" -> case content of 
																	"" -> [( (Nothing, DAT 0), "" )]
																	otherwise -> [( (Nothing, (read (ins++" "++content))::Instruction), "" )]
														ins' -> case content of 
																	"" -> [( (Nothing, read ins' :: Instruction), "" )]
																	otherwise -> [( (Nothing, (read (ins'++" \""++content++"\""))::Instruction), "" )]
												otherwise -> case ins of 
																"DAT" -> case content of
																			"" -> [( (Just lbl, DAT 0), "" )]
																			otherwise -> [( (Just lbl, (read (ins++" "++content))::Instruction), "" )]
																ins' -> case content of 
																			"" -> [( (Just lbl, read ins'::Instruction), "" )]
																			otherwise -> [( (Just lbl, (read (ins'++" \""++content++"\""))::Instruction), "" )]
			[(lbl:(ins:_), out)] -> case lbl of
										"" -> case ins of 
												"DAT" -> [( (Nothing, DAT 0), "" )]
												ins' -> [( (Nothing, read ins' :: Instruction), "" )]
										otherwise -> case ins of 
												"DAT" -> [( (Just lbl, DAT 0), "" )]
												ins' -> [( (Just lbl, read ins'::Instruction), "" )]
			otherwise -> []
			)

-}
parseLMC :: String -> Program
parseLMC s = case parse (sepBy line (char '\n')) s of
               [(p, "")] -> p
               _ -> error "Parse error"

-- Exercise 5
showProgram :: Program -> String
showProgram [] = []
showProgram ((maybeLabel,ins):xs) = case maybeLabel of 
										Just label -> label ++ " " ++ [x | x <- (show ins), x/='\"'] ++ "\n" ++ showProgram xs 
										Nothing -> " " ++ [x | x <- (show ins), x/='\"'] ++ "\n" ++ showProgram xs 

type Addr = Int
type Accumulator = Maybe Int
type PC = Int
type Mailbox = (String, Int)

data Env
    = Env
    { mailboxes :: [(String, Int)]
    , accumulator :: Accumulator
    , pc :: Addr -- program counter
    , instructions :: [Instruction]
    , labelAddr :: [(String, Int)]
    }

-- Exercise 6
initMailboxes :: Program -> [Mailbox]
initMailboxes [] = []
initMailboxes ((lbl, DAT i):xs) = case lbl of 
									Just lbl' -> (lbl', i) :  initMailboxes xs
									Nothing -> initMailboxes xs
initMailboxes (x:xs) = initMailboxes xs

initLabelAddr :: [Maybe Label] -> [(Label, Addr)]
initLabelAddr labels = let label' = map (\x -> case x of 
													Just v -> v
													Nothing -> "") labels in [x | x <- zip label' [0..length label'-1]]

mkInitEnv :: Program -> Env
mkInitEnv prog = Env {  mailboxes = initMailboxes prog,
						accumulator = Nothing,
						pc = 0,
						instructions =  foldr (\x acc -> (snd x):acc) [] prog,
						labelAddr = initLabelAddr [fst x | x <- prog]
						}

type IOEnv = StateT Env IO

-- Exercise 7

decode :: Instruction  -> IOEnv ()
decode INP =
    do val <- liftIO (readLn :: IO Int)
       setAccumulator val
       i <- nextInstruction
       decode i
decode OUT =
    do acc <- getAccumulator
       liftIO $ print acc
       i <- nextInstruction
       decode i
decode (ADD i) = 
	do acc <- getAccumulator
	   val <- getValue i
	   setAccumulator (acc + val)
	   i <- nextInstruction
	   decode i
decode (SUB i) = 
	do acc <- getAccumulator
	   val <- getValue i
	   setAccumulator (acc - val)
	   i <- nextInstruction
	   decode i
--STA to be tested, seemingly works fine, see sta for test purpose
decode (STA op) = 
	do val <- getAccumulator
	   env <- get
	   case lookup op (mailboxes env) of 
	   		Just v -> put $ env {mailboxes = ((op,val): (filter (\x -> fst x/=op) (mailboxes env)))}
	   		Nothing -> put $ env {mailboxes = ((op,val):(mailboxes env))}
	   i <- nextInstruction
	   decode i
decode (LDA op) =
	do env <- get
	   case lookup op (mailboxes env) of
			Just v -> setAccumulator v
	   i <- nextInstruction
	   decode i
decode (BRA branch) = 
	do env <- get
	   case lookup branch (labelAddr env) of
	   		Just addr ->   put $ env { pc = addr }
	   i <- nextInstruction
	   decode i
decode (BRZ branch) =
    do acc <- getAccumulator
       case acc of 
         0 -> decode (BRA branch)
         _ -> do i <- nextInstruction
                 decode i
decode (BRP branch) =
	do env <- get
	   acc <- getAccumulator
	   if acc>0 then
	   		do decode (BRA branch)
	   else
	   		do i <- nextInstruction
	   		   decode i
decode (DAT label) = 
	do i <- nextInstruction
	   decode i
decode HLT = liftIO $ print "Program Terminated"

getValue :: Label ->IOEnv Int
getValue str =
    do env <- get
       let mailbox = mailboxes env
       case lookup str mailbox of
         Just val -> return val
         Nothing -> error "No value of this label is available in mailboxes"


setAccumulator :: Int -> IOEnv ()
setAccumulator acc =
    do env <- get
       put $ env { accumulator = Just acc }

getAccumulator :: IOEnv Int
getAccumulator =
    do env <- get
       case accumulator env of
         Just i -> return i
         Nothing -> error "Nothing in the accumulator"

nextInstruction :: IOEnv Instruction
nextInstruction =
    do env <- get
       let i = pc env
       when (i == length (instructions env)) $ error "No more instructions"
       put $ env { pc = i + 1 }
       return $ instructions env !! i

evalProgram :: Program -> IO ()
evalProgram [] = return ()
evalProgram p@((_,i):_) = liftM fst $ runStateT (decode i) (mkInitEnv p)


--a program
programTest :: String
programTest = "Start LDA ZERO//first line\n STA RESULT\n STA COUNT\n INP\n BRZ END\n STA VALUE //store input a value\nLOOP LDA RESULT"


str :: String
str = "Start LDA ZERO//first line\nEND STA RESULT"

--take a user input and count down to zero
countDown :: String
countDown = "ONE DAT 1\n INP //test fuck\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT"

test :: String
test = "THREE DAT 3 //sjhdas kj\n LDA THREE\n BRP QUIT\n OUT//sd sa\nQUIT HLT"

count :: String 
count = "ONE DAT 1//first line\nTHREE DAT 3 //second line\n LDA THREE\nLOOP SUB ONE\n OUT\n BRZ QUIT\n BRA LOOP\nQUIT HLT//sd as"

sta :: String
sta = "ONE DAT 1\n LDA ONE\n ADD ONE\n STA ONE\n SUB ONE\n OUT\n LDA ONE\n OUT\n HLT"