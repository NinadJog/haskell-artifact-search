# haskell-artifact-search
Search for artifacts in a 2-dimensional grid

## Problem

Several artifacts are buried undergroud, overlaid by a grid of square cells. The grid is visible but the artifacts are hidden. In a bid to reconstruct the artifacts, a person can choose whichever cells of the grid they like in the hope that their choices cover one or more artifacts. If their choice includes all cells of an artifact, the artifact can be reconstructed, otherwise they are out of luck. 

Given the grid cell locations of all the artifacts and the cell locations of all the searched locations, find the number of artifacts that can be reconstructed (i.e. all its cell locations have been found) and the number of artifacts for which some locations -- but not all -- have been found.

## Grid Cell Locations

The grid's rows are numbered 1 to N while the columns are numbered by capital English letters: A, B, C... The address of a cell is specified as the row number followed by the column number, as in 3C, 2B, etc.

Cell ranges are specified by their top left and bottom right cell addresses, spearated by a space. For example, "1B 2C" indicates the cells 1B, 1C, 2B, 2C as shown in the following figure marked with 0, wherease the artifact "2D 4D" is marked in the figure with 1.

```
    A   B   C   D
  +---+---+---+---+
1 |   | 0 | 0 |   |
  +---+---+---+---+
2 |   | 0 | 0 | 1 |
  +---+---+---+---+
3 |   |   |   | 1 |
  +---+---+---+---+
4 |   |   |   | 1 |
  +---+---+---+---+

```
An artifact can occupy at most 4 contiguous cells. For example, "1B 2C" can be an artifact's cells, as can "4A 4B" (2 cells; horizontal), "5B 7B" (3 cells; vertical) and "4E 4E" (just 1 cell). But "1A 7A" cannot be an artifact because the range contains more than 4 cells.

The artifact locations appear in a comma-separated order. For example, "3D 4D,1B 2C" are the cell ranges of two artifacts.

The list of searched cells is separated by a space, for example: "5B 4D 3D 5E 4E". The cells can appear in any order. Here's an example problem and its solution.

Given artifacts = "1B 2C,2D 4D" and searched = "3D 1C 2D 4A 4D", where the searched cells are marked with an X in the following figure, we can see that all cells of the "2D 4D" artifact were searched whereas just one cell of the "1B 2C" artifact was searched. So the number of total searches is 1 and so is the number of partial searches. The answer is therefore the pair (1, 1), corresponding to (total, partial). Note that the searched cell 4A does not play any role in either of the counts because it does not contain a part of any artifact.

```
    A   B   C   D
  +---+---+---+---+
1 |   | 0 | X |   |
  +---+---+---+---+
2 |   | 0 | 0 | X |
  +---+---+---+---+
3 |   |   |   | X |
  +---+---+---+---+
4 | X |   |   | X |
  +---+---+---+---+
```
## Algorithm

How do we go about solving this problem? First off, given a list of artifacts such as "1B 2C,2D 4D", what information can we extract from it? 

We can tell that it contains 2 artifacts, the first of which contains 4 cells (1B, 1C, 2B, 2C) and the second contains 3 (2D, 3D, 4D).  

Should we store all of this information or is only some of it essential to computing the solution? In what type of data structure should we store it so its cell locations and artifact cell counts can be easily compared with the cells from the searched string to find the solution?

Since we need to determine whether the search hits all cells of an artifact or just a few, we should store the count of the number of cells in each artifact. Since there can be several artifacts, we should also assign an id to each artifact, say an integer starting from 0. From the given list of artifacts, we can construct two tables: One mapping the artifact ID to the number of cells it contains and the other mapping each artifact's cell address to its artifact id, as shown below.

```
  +----------+----------+       +------+-----------+  
  | Artifact |  Number  |       | Cell |  Artifact |
  |    ID    | of cells |       |      |     ID    |
  +----------+----------+       +------+-----------+
  |     0    |     4    |       |  1B  |     0     |
  +----------+----------+       +------+-----------+
  |     1    |     3    |       |  1C  |     0     |
  +----------+----------+       +------+-----------+
                                |  2B  |     0     |
                                +------+-----------+
                                |  2C  |     0     |
                                +------+-----------+
                                |  2D  |     1     |
                                +------+-----------+
                                |  3D  |     1     |
                                +------+-----------+
                                |  4D  |     1     |
                                +------+-----------+
```
We can afford to map each cell of an artifact to its artifact ID (such as "2D" -> 1) because each artifact contains a small number of cells -- at most 4. If it contained a large number -- say 10 or more -- this strategy would not be efficient. 

What information can we extract from a searched string such as "3D 1C 2D 4A 4D"? For each cell in the searched string, we can try to get the artifact ID from the cell-to-artifact-id table that we created (the second table in the above figure) from the artifacts string.

If there's an artifact under the searched cell, its artifact id will appear in the above table (for example, "3D"'s artifact ID is 1) but if it does not, the table lookup will fail (example: there's no artifact id for cell "4A"). If an artifact id is found, we should increment the searched count for that particular artifact, otherwise we do not have to do anything.

We can therefore create a table similar to the first table above, mapping artifact ids to the number of searched cells. In this example the table would be as follows.
```
  +----------+-----------+ 
  |          | Number of |
  | Artifact | searched  |
  |    ID    |   cells   |
  +----------+-----------+
  |     0    |     1     |
  +----------+-----------+
  |     1    |     3     |
  +----------+-----------+ 
```
In the final step we can compare the two tables to see whether the counts match. Artifact 0 has 4 cells but only 1 of its cells was searched, so the *partial* count is 1. Artifact 1 had 3 cells and all of them were searched, so the *total* count is also 1. The final result is therfore the pair (1, 1).
 
## Solution

The Haskell solution presented here is the "happy-path" solution. It assumes that all functions have the correct input and that the artifacts and searched strings have the correct syntax and the ranges are valid ones.

Here's the happy-path solution: [ArtifactGrid.hs](ArtifactGrid.hs)

In the future I plan to implement a "sad-path" solution in which the inputs to most functions will be checked for syntactic and semantic integrity and the result of the function will be Nothing if the check fails. In order to keep the error-checking and Maybe code under the covers without obscuring the program flow, we will use monads and do-notation.

The happy-path solution is a first attempt at getting the algorithm right. I'll keep the sad-path solution separate from the happy-path one so you can compare the two.

## Implementation

(Given a range such as "1B 2C", the *getArtCells* function calculates the addresses of the all the cells in the range and returns them in a list.)


