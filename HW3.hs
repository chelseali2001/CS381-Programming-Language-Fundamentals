-- Group members:
--  * Chelsea Li, 933294417
--  * Eduardo Gonzalez, 933823679
--  * Daniel Aguilar, 932795465
--
-- Grading note: 15pts total
--  * 2pts Expr data type
--  * 2pts expression examples
--  * 2pts prettyExpr
--  * 3pts Cmd data type
--  * 2pts macro bodies
--  * 3pts prettyCmd
--  * 1pt  boxes program
--
module HW3 where

import Data.List (intercalate)

--
-- * Part 1: Expressions
--

-- ** Syntax

-- | Variable names.
type Var = String

-- | Expressions.
data Expr
  = Add Expr Expr
  | Mul Expr Expr
  | Lit Int
  | Var Var
  deriving (Eq,Show)


-- ** Examples

-- | 2 + 3 * x
expr1 :: Expr
expr1 = Add (Lit 2) ( Mul (Lit 3) (Var "x") ) 

-- | 2 + 3 * x + 4
expr2 :: Expr
expr2 = Add (expr1) (Lit 4)

-- | (x + 2) * 3 * y
expr3 :: Expr
expr3 = Mul (Add (Var "x") (Lit 2)) (Mul (Lit 3) (Var "y"))

-- | (x + 2) * (y + 3)
expr4 :: Expr
expr4 = Mul (Add (Var "x") (Lit 2)) (Add (Var "y") (Lit 3))


-- ** Pretty printer

-- | Pretty print an expression.
--
--   >>> prettyExpr expr1
--   "2 + 3 * x"
--
--   >>> prettyExpr expr2
--   "2 + 3 * x + 4"
--
--   >>> prettyExpr expr3
--   "(x + 2) * 3 * y"
--
--   >>> prettyExpr expr4
--   "(x + 2) * (y + 3)"
--
prettyExpr :: Expr -> String
prettyExpr (Lit a) = show a
prettyExpr (Var a) = a
prettyExpr (Add a b) = prettyExpr a ++ " + " ++ prettyExpr b
prettyExpr (Mul (Add e1 e2) (Add e3 e4)) =  "(" ++ prettyExpr e1 ++ " + " ++ prettyExpr e2 ++ ")" ++ " * " ++ "(" ++ prettyExpr e3 ++ " + " ++ prettyExpr e4 ++ ")"
prettyExpr (Mul (Add e1 e2) e3) = "(" ++ prettyExpr e1 ++ " + " ++ prettyExpr e2 ++ ")" ++ " * " ++ prettyExpr e3
prettyExpr (Mul e1 (Add e2 e3)) =  prettyExpr e1 ++ " * " ++ "(" ++ prettyExpr e3 ++ " + " ++ prettyExpr e3 ++ ")"
prettyExpr (Mul e1 e2) = prettyExpr e1 ++ " * " ++ prettyExpr e2


--
-- * Part 2: Commands
--

-- ** Syntax

-- | Macro names.
type Macro = String

-- | The arguments to be evaluated and passed to a macro.
type Args = [Expr]

-- | A sequence of commands.
type Block = [Cmd]

-- | The mode of the pen.
data Mode = Down | Up
  deriving (Eq,Show)

-- | Commands.
data Cmd
   = Pen Mode
   | Move Expr Expr
   | Call Macro Args
   | For Var Expr Expr Block
  deriving (Eq,Show)


-- ** Examples

-- | The body of the box macro.
--
--   >>> putStrLn (prettyBlock boxBody)
--   {
--     pen up;
--     move(x, y);
--     pen down;
--     move(x + w, y);
--     move(x + w, y + h);
--     move(x, y + h);
--     move(x, y)
--   }
--
boxBody :: Block
boxBody = [Pen Up, Move (Var "x") (Var "y"), Pen Down, Move (Add (Var "x") (Var "w")) (Var "y"),
           Move (Add (Var "x") (Var "w")) (Add (Var "y") (Var "h")), Move (Var "x") (Add (Var "y") (Var "h")),
           Move (Var "x") (Var "y")]


-- | The body of the main macro.
--
--   >>> putStrLn (prettyBlock mainBody)
--   {
--     for i = 1 to 15 {
--       box(i, i, i, i)
--     }
--   }
mainBody :: Block
mainBody = [For ("i") (Lit 1) (Lit 15) [Call ("box") [(Var "i"), (Var "i"), (Var "i"), (Var "i") ] ] ]


-- ** Pretty printer

-- Some functions that might be useful for you:
--
--   concat :: [[a]] -> [a]
--     Concatenates a list of lists into a single list. Useful for
--     concatenating a list of strings into a single string.
--     Imported from the Prelude.
--
--   intercalate :: [a] -> [[a]] -> [a]
--     Insert a list between every list in a list of lists, then concatenate
--     the results. Useful for inserting  separators between every string in
--     a list of strings, then concatenating the whole thing into one string.
--     Imported from Data.List.


-- | Pretty print the pen mode.
--
--   >>> prettyMode Down
--   "down"
--
--   >>> prettyMode Up
--   "up"
--
prettyMode :: Mode -> String
prettyMode Down = "down"
prettyMode Up   = "up"


-- | Pretty print a command.
--
--   >>> prettyCmd (Pen Down)
--   "pen down"
--
--   >>> prettyCmd (Move (Lit 2) (Add (Var "x") (Lit 3)))
--   "move(2, x + 3)"
--
--   >>> prettyCmd (Call "foo" [Lit 2, (Mul (Var "x") (Lit 3))])
--   "foo(2, x * 3)"
--
--   >>> prettyCmd (For "i" (Lit 1) (Lit 10) [])
--   "for i = 1 to 10 {}"
--
prettyCmd :: Cmd -> String
prettyCmd (Pen x) = "pen " ++ prettyMode x
prettyCmd (Move x y) = "move" ++ "(" ++ prettyExpr x ++ ", " ++ prettyExpr y ++ ")"
prettyCmd (For a b c d) = "for " ++ a ++ " = " ++ prettyExpr b ++ " to " ++ prettyExpr c ++ " " ++ prettyBlock d
prettyCmd (Call m ex) = m ++ "(" ++ prettyArgs ex ++ ")"
  where
    prettyArgs = intercalate ", " . map prettyExpr

-- | Pretty print a block of commands.
--
--   >>> prettyBlock []
--   "{}"
--
--   >>> putStrLn (prettyBlock [Pen Up, Move (Lit 2) (Lit 3), Pen Down])
--   {
--     pen up;
--     move(2, 3);
--     pen down
--   }
--
prettyBlock :: Block -> String
prettyBlock [] = "{}"  -- special case for empty blocks
prettyBlock cs = "{\n  " ++ indent (prettyCmds cs) ++ "\n}"
  where
    indent = concatMap (\c -> if c == '\n' then "\n  " else [c])
    prettyCmds = intercalate ";\n" . map prettyCmd


--
-- * Part 3: Programs
--

-- | The parameters of a macro are a list of variables that will be bound to
--   the arguments passed to the macro when it is called.
type Pars = [Var]

-- | A macro definition.
data Def = Define Macro Pars Block
  deriving (Eq,Show)

-- | A program is a list of macro definitions plus the block of the main macro.
data Prog = Program [Def] Block
  deriving (Eq,Show)


-- | The entire example program.
--
--   >>> putStrLn (pretty boxes)
--   box(x, y, w, h) {
--     pen up;
--     move(x, y);
--     pen down;
--     move(x + w, y);
--     move(x + w, y + h);
--     move(x, y + h);
--     move(x, y)
--   }
--   main() {
--     for i = 1 to 15 {
--       box(i, i, i, i)
--     }
--   }
--
boxes :: Prog
boxes = Program [Define "box" ["x", "y", "w", "h"] [Pen Up, Move (Var "x") (Var "y"), Pen Down, Move (Add (Var "x") (Var "w")) (Var "y"), Move (Add (Var "x") (Var "w")) (Add (Var "y") (Var "h")), Move (Var "x") (Add (Var "y") (Var "h")), Move (Var "x") (Var "y")]] [For "i" (Lit 1) (Lit 15) [Call "box" [(Var "i"), (Var "i"), (Var "i"), (Var "i")]]]


-- | Pretty print a macro definition.
prettyDef :: Def -> String
prettyDef (Define m ps b) =
    concat [m, "(", intercalate ", " ps, ") ", prettyBlock b]

-- | Pretty print a program.
pretty :: Prog -> String
pretty (Program ds b) =
    concat [intercalate "\n" (map prettyDef ds), "\nmain() ", prettyBlock b]