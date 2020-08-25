{-
Created:  August 22, 2020
Updated:  August 25, 2020
Author:   Ninad Jog
-}

module ArtifactGrid where
  
import Data.List.Split
import Data.List

import Data.Map (Map)
import qualified Data.Map as Map

-------------------------
{-
This is the main function, the answer to the question.
Given the artifacts and searched locations, this function returns
counts of the number of artifacts searched fully and partially
-}
solution :: String -> String -> (Int, Int)
solution artifacts searched = (total, partial)
  where
    (artIdMap, artCountMap) = processArtifacts artifacts
    srchCounts      = processSearched searched artIdMap
    (total, partial)  = findCounts artCountMap srchCounts
    
{-         
Test cases:
    solution "1B 2C,2D 4D" "2B 2D 3D 4D 4A"  Answer: (1,1)
    solution "1A 1B,2C 2C" "1B"              Answer: (0,1)
    solution "1A 1B,2C 2C" "1D"              Answer: (0,0)
    solution "1A 1B,2C 2C,3D 3E" "1B 2C 1A"  Answer: (2,0)

-}   

-------------------------
type Coord = (Int, Char)

{-
Given a string such as "23M", it returns the tuple (23, M)
The last elment in the string is a single char while the initial
part forms an integer
-}
getCellCoords :: String -> Coord
getCellCoords cell = (read (init cell), last cell)

-------------------------
{-
Given the top left and bottom right cells of an artifact, this
function returns a list containing all cells from the artifact.

Example: Given "1B 2C", it returns [(1, "B"), (2, "C")]

TBD later: Change return type to Maybe [Coord] to handle failures.
-}
getCornerCoords :: String -> [Coord]
getCornerCoords xs = coords
  where
    corners = (splitOn " " xs)
    coords  = map getCellCoords corners

-------------------------
{-
Given the top left and bottom right cells of an artifact, this
function returns a list containing all cells from the artifact.

Example: Given "1B 2C", it returns ["1B", "1C", "2B", "2C"]

TBD later: Change return type to Maybe String to handle failures.
-}

getArtCells :: String -> [String]
getArtCells corners = 
  let
    top:btm:[] = getCornerCoords corners
  in
    getCells top btm

-------------------------
{-
Given the coordinates of the top left and bottom right cells,
this function returns the addresses of all cells in the range.
Example:

Input:  [(1, 'B'), (2, 'C')]
Output: ["1B", "1C", "2B", "2C"]
-}
getCells :: Coord -> Coord -> [String]
getCells (r1, c1) (r2, c2) = [(show r) ++ [c] | r <- [r1..r2], c <- [c1..c2]]
  
-------------------------
{-
Given a list of top left & bottom right locations of
several artifacts, return the locations of all cells from
all the artifacts. Example:

Input:  "1B 2C,2D 4D"
Output: [["1B", "1C", "2B", "2C"], ["2D", "3D", "4D"]]
-}
getAllArtCells :: String -> [[String]]
getAllArtCells arts = [getArtCells c | c <- xs]
  where
    xs = splitOn "," arts

-------------------------
{-
Expands the cells of artifacts AND pairs them up with the
artifact ID. Example:

Input:  [["1B", "1C", "2B", "2C"], ["2D", "3D", "4D"]]
Output: [("1B",0),("1C",0),("2B",0),("2C",0),("2D",1),("3D",1),("4D",1)]

-}
getArtCellMap :: [[String]] -> Map String Int
getArtCellMap arts =
  let
    ys = zip arts [0..]         -- [(["1B", "1C", "2B", "2C"], 0), (["2D", "3D", "4D"], 1)]
    zs = concat [distribIdx cs idx | (cs, idx) <- ys]
    -- [("1B",0),("1C",0),("2B",0),("2C",0),("2D",1),("3D",1),("4D",1)]
  in
    Map.fromList zs
    
-------------------------

distribIdx :: [String] -> Int -> [(String, Int)]
distribIdx xs idx = [(x, idx) | x <- xs]

-------------------------
{- 
Given a comma-separated list of artifacts by their top-left
and bottom-right cells, this function returns two maps: one
from every cell of an artifact to its artifact id and the
other from the artifact id to the count of the cells in it

Example input: "1B 2C,2D 4D"
-}
processArtifacts :: String -> (Map String Int, Map Int Int)
processArtifacts arts =
  let
    xs = getAllArtCells arts  -- [["1B", "1C", "2B", "2C"], ["2D", "3D", "4D"]]
    idMap     = getArtCellMap xs
    countMap  = getCountMap xs
  in
    (idMap, countMap)


-------------------------
{-
Given a list of artifacts, each containing several cells,
this function counts the number of cells in each artifact
and returns a map from the artifact id (starting from 0 for
the first artifact) to the count. Example:

Input:  [["1B", "1C", "2B", "2C"], ["2D", "3D", "4D"]]
Output: fromList [(0,4),(1,3)]
-}
getCountMap :: [[String]] -> Map Int Int
getCountMap arts = Map.fromList $ zip [0..] (map length arts)


-- =======================
{-
Given a string containing all the cells that are searched
(in any order) and a map of the artifact cells to their ids,
this function returns a list of tuples with the artifact
id as the first and the number of cells searched as the second.

Inputs:  "2B 2D 3D 4D 4A"
fromList [("1B",0),("1C",0),("2B",0),("2C",0),("2D",1),("3D",1),("4D",1)]

Output: [(0,1),(1,3)]
-}
processSearched :: String -> Map String Int -> [(Int, Int)]
processSearched searched idMap =
  let
    xs = splitOn " " searched
    ys = [Map.lookup x idMap | x <- xs] -- [Just 0,Just 1,Just 1,Just 1,Nothing]
    zs = [y | Just y <- ys] -- [0, 1, 1, 1]
    ws = group $ sort zs    -- [[0],[1,1,1]]
  in
    zip (map head ws) (map length ws) -- [(0,1),(1,3)]
 
-------------------------

findCounts :: Map Int Int -> [(Int, Int)] -> (Int, Int)
findCounts artMap ss = (total, partial)
  where
    xs = [ isTotal artMap artId srchCount | (artId, srchCount) <- ss]    
    total   = sum [ 1 | x <- xs, x == True  ]
    partial = sum [ 1 | x <- xs, x == False ]
  
-------------------------
isTotal :: Map Int Int -> Int -> Int -> Bool
isTotal artMap artId count =
  case Map.lookup artId artMap of
    Nothing -> False
    Just a  -> count == a
