# haskell-artifact-search
Search for artifacts in a 2-dimensional grid

## Problem

Several artifacts are buried undergroud, overlaid by a grid of square cells. The grid is visible but the artifacts are hidden. In a bid to reconstruct the artifacts, a person can choose whichever cells of the grid they like. If their choice includes ALL cells of an artifact, the artifact can be reconstructed, otherwise it cannot be. 

Given the grid cell locations of all the artifacts and the cell locations of all the searched locations, find the number of artifacts that can be reconstructed (i.e. all its cell locations have been found) and the number of artifacts for which some locations -- but not all -- have been found.

## Grid Cell Locations

The grid's rows are numbered 1 to N while the columns are numbered by capital English letters: A, B, C... The address of a cell is specified as the row number followed by the column number, as in 3C, 2B, etc.

Cell ranges are specified by their top left and bottom right cell addresses, spearated by a space. For example, "1B 2C" indicates the cells 1B, 1C, 2B, 2C as shown in the following figure.

An artifact can occupy at most 4 contiguous cells. For example, "1B 2C" can be an artifact's cells, as can "3D 4D" (2 cells; horizontal), "5B 7B" (3 cells; vertical) and "4E 4E" (just 1 cell). The artifact locations appear in a comma-separate order. For example, "3D 4D,1B 2C" are the cell ranges of two artifacts.

The list of searched cells is separated by a space, for example: "5B 4D 3D 5E 4E" and can appear in any order. Here's an example problem and its solution.

<Example TBD>
  
## Solution

The Haskell solution presented here is the "happy-path" solution. It assumes that all functions have the correct input; it assumes that the artifacts and searched strings have the correct syntax and the ranges are valid ones.

In the future I plan to implement a "sad-path" solution which will handle errors, hopefully transparently by using monads. The happy-path solution is a first attempt at getting the algorithm right.
