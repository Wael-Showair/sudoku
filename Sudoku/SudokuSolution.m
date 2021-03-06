//
//  ConstraintPropagation.m
//  Sudoku
//
//  Created by Wael Showair on 2016-02-13.
//  Copyright © 2016 Algonquin College. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SudokuSolution.h"

#define LENGTH_OF_SINGLE_POSSIBLE_VALUE         1

@interface SudokuSolution ()
@property(strong,nonatomic) NSMutableIndexSet* indexexSetOfSolvedCells;
@end

@implementation SudokuSolution

-(instancetype)init{
  self = [super init];

  return self;
}

-(void)solveSudokuGrid:(MacroGrid **)gridPtr{//solve

  MacroGrid* grid = *gridPtr;
  
  MacroGrid* possibleSolvedGrid = [self tryToSolveSudokuGrid:grid]; //parse
  
  MacroGrid* solvedGrid = [self searchPossibleSolutionsForSukoduGrid:possibleSolvedGrid]; //call search once
  
  if (nil == solvedGrid) {
    [self.delegate solver:self didFailToSolveSudokuGrid:*gridPtr];
  }

#if DEBUG_SOLVED_GRIDS
  [solvedGrid display];
#endif
  
  /* Set solved grid to the input pointer of the grid pointer. */
  *gridPtr = solvedGrid;
  
  /* Make sure that the delegate is not nil and it has implemented the optional method
   * didFinishSolvingSudokuGrid.
   */
  if ((nil != self.delegate) &&
      (YES == [self.delegate respondsToSelector:@selector(solver:didSolveSudokuGrid:withUpdatedIndexes:) ])) {
    [self.delegate solver:self didSolveSudokuGrid:*gridPtr withUpdatedIndexes:self.indexexSetOfSolvedCells];
  }

}

-(MacroGrid*)tryToSolveSudokuGrid:(MacroGrid *)grid{ //parse grid.

  self.indexexSetOfSolvedCells = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 81)];
  
  /* Create an internal macro grid to start solving the given sudoku grid.
   * Note that this grid initially has no cells' values and every cell has all full range from 1->9
   * in the cells' potential solution sets.
   */
  MacroGrid* solvedGrid = [[MacroGrid alloc] init];
  NSArray<SudokuCell*>* cellsOfSolvedGrid= [solvedGrid getFlattenedCells:MacroGridFlattingTypeCells];
  
  NSArray<SudokuCell*>* cellsOfSourceGrid= [grid getFlattenedCells:MacroGridFlattingTypeCells];
  
  __block BOOL canSolveGrid = YES;
  
  /* Iterate over the source grid cells. */
  [cellsOfSourceGrid enumerateObjectsUsingBlock:^(SudokuCell* sourceCell, NSUInteger index, BOOL* shouldStop){
    /* If value of the cell belongs to a valid potential range of values (1->9), Apply the constraint
     * propagation algorithm over the destination grid.
     */
    if (YES == NSLocationInRange(sourceCell.value, [SudokuCell fullRange])) {

      /* Remove the cell since it is has been already solved before applying the solution. */
      [self.indexexSetOfSolvedCells removeIndex:index];
      
      SudokuCell* destinationCell = [cellsOfSolvedGrid objectAtIndex:index];
      BOOL success = [self assignValue:sourceCell.value toSudokuCell:destinationCell inMacroGrid:solvedGrid];
      if (NO == success) {
        canSolveGrid = NO;
        *shouldStop = YES;
      }
    }
    
  }];
  
  return (YES == canSolveGrid)? solvedGrid: nil;
}

-(MacroGrid*) searchPossibleSolutionsForSukoduGrid: (MacroGrid*) possibleSolvedGrid{ //search
  __block MacroGrid* copyOfGrid;
  /* Have we found any contradition while trying to solve the grid? OR
   * Have we found out that a possible value can't be assigned to any cell in the grid?
   */
  if (nil == possibleSolvedGrid) {
    return nil;
  }
  
  /* 1. All cells in the possible solved grid, have only one and only one possible value. If yes,
   * then this is a valid solution for the grid. End the algorithm.
   */
  
  /*The following two vairables are just created in case the all the grid cells don't have one 
   * possible value for each.
   */
  NSMutableArray* potentialValuesCounts = [[NSMutableArray alloc] init];
  NSMutableArray* indexes = [[NSMutableArray alloc] init];
  
  NSArray<SudokuCell*>* cellsOfGrid = [possibleSolvedGrid getFlattenedCells:MacroGridFlattingTypeCells];
  

  /* Loop through all the cells of the grid, make sure that they all have one possible value.
   * If yes, then this grid is a valid solution.
   * if not, save how many possible values are there for the corresponding cell.
   */
  __block BOOL allCellsHaveOnePotentialValue = YES;
  [cellsOfGrid enumerateObjectsUsingBlock:^(SudokuCell* cell, NSUInteger cellIndex, BOOL* shouldStop){
    
    if (LENGTH_OF_SINGLE_POSSIBLE_VALUE != cell.potentialSolutionSet.count) {
      
      /* Indicate that the gird is no a possible solution. */
      allCellsHaveOnePotentialValue = NO;
      
      /* Save how many potential values are there for the cell. */
      [potentialValuesCounts addObject:@(cell.potentialSolutionSet.count)];
      
      /* Save index of the cell for to be able to loop throught those cells only. */
      [indexes addObject:@(cellIndex)];
    }
    
    /* Continute looping. */
    *shouldStop = NO;
    
  }];
  
  /* If each cell in the grid has only one potential value, then return it. */
  if (YES == allCellsHaveOnePotentialValue) {
    return possibleSolvedGrid;
  }
  
  /* 2. At this point, there are some cells having more than possible values. Get the cell which has
   * the minmum number of possibilites.
   */
  
  /* 2.1 Sort possible values counts in ascending order. Note that The new array contains references
   * to the receiving array’s elements, not copies of them.*/
  NSArray* sortedArray = [potentialValuesCounts sortedArrayUsingSelector:@selector(compare:)];
  /* 2.2 Minimum count must be in the first object of the sorted array. */
  NSNumber* minPotentialValuesCounts =[sortedArray firstObject];
  /* 2.3 Get index of the cell that we will try to set its value with one of its potential values.*/
  NSUInteger tempIndex = [potentialValuesCounts indexOfObject:minPotentialValuesCounts];
  NSUInteger requiredCellIndex = ((NSNumber*) [indexes objectAtIndex:tempIndex]).intValue;
  
  /* 2.4 Get the required cell on which we will be operating.*/
  SudokuCell* requiredCell = [cellsOfGrid objectAtIndex:requiredCellIndex];
  RowColPair pair =  convertIndexToPair(requiredCellIndex);
  __block SudokuCell* copyOfRequiredCell;
  __block MacroGrid* tempGrid;
  
  /* 2.5 Now pick any value from the possible values for the cell then assign to the cell. Finally
   * If you managed to assign the value, check if the whole grid has been solved or not (This is done
   * by recursively, searching possible solution method).
   */
  [requiredCell.potentialSolutionSet enumerateIndexesUsingBlock:^(NSUInteger possibleValue, BOOL* shouldStop){

    /* Create a new copy of the current grid. */
    copyOfGrid = [possibleSolvedGrid copyMacroGrid];

#if DEBUG_SOLVED_GRIDS
    NSLog(@"*************************** Before assignment value = %ld at cellIndex=%ld ****************************\n",possibleValue,requiredCellIndex);
    [copyOfGrid display];
#endif
    
    copyOfRequiredCell  = [copyOfGrid getSudokuCellAtRowColumn:pair];
    BOOL assignmentResult = [self assignValue:possibleValue toSudokuCell:copyOfRequiredCell inMacroGrid:copyOfGrid];
    tempGrid = [self searchPossibleSolutionsForSukoduGrid:copyOfGrid];

#if DEBUG_SOLVED_GRIDS
    NSLog(@"*************************** After assignment ****************************\n");
    [tempGrid display];
#endif
    
    if(YES == assignmentResult){
      if (nil != tempGrid){
        *shouldStop = YES;
      }
    }else{
      /* Continute looping. */
      *shouldStop = NO;
    }
    
  }];
  return tempGrid;
}

/* It turns out that the fundamental operation is not assigning a value, but rather eliminating one 
 * of the possible values for a cell.Then assign value(d) in a cell can be defined as
 * "eliminate all other possible values from the cell except the required number d".
 */
-(BOOL) assignValue: (NSUInteger) value toSudokuCell: (SudokuCell*) cell inMacroGrid: (MacroGrid*) grid{//assign

  __block BOOL result = YES;
  /* Since a value would be assigned to a cell, this means that the value does not belong to 
   * the impossible solution set.
   */
  NSMutableIndexSet* impossibleSolutionSet = [[NSMutableIndexSet alloc] initWithIndexSet:cell.potentialSolutionSet ];
  [impossibleSolutionSet removeIndex:value];
  
  /* Iterate over every value(d) in the impossbile solution set to eliminate that value(d) from the
   * potential solution set of the given cell.
   */
  [impossibleSolutionSet enumerateIndexesUsingBlock:^(NSUInteger impossibleValue, BOOL* shouldStop){
    result = [self eliminateValue:impossibleValue fromSudokuCell:cell inMacroGrid:grid];
    if (NO == result) {
      *shouldStop = YES;
    }
    *shouldStop = NO;
  }];
  
  return result;
}

-(BOOL) eliminateValue: (NSUInteger) value fromSudokuCell: (SudokuCell*) cell inMacroGrid: (MacroGrid*) grid{ //eliminate

  NSSet<SudokuCell*>* peers;
  NSArray<SudokuCell*>* superSet;
  NSUInteger lastPotentialValueOfCell;
  SudokuCell* targetCell;
  NSMutableIndexSet* setOfCellsIndexes;
  NSMutableIndexSet* setOfEliminationResults;
  
  if (NO == [cell.potentialSolutionSet containsIndex:value]) {
    return YES; /* value has been already eliminated. */
  }
  
  /* Eliminate the value from the potential solution set. */
  [cell.potentialSolutionSet removeIndex:value];
  
  switch (cell.potentialSolutionSet.count) {
    case 0:
      /* Contradication: You have just removed the last value from the potential solution set.*/
      return NO;

    case 1:
      /* If the cell contains only one value(v) in its potential solution set, then remove this
       * value(v) from the peers of the given cell.
       */
      lastPotentialValueOfCell = [cell.potentialSolutionSet firstIndex];
      cell.value = lastPotentialValueOfCell;
      peers = [grid peersOfSudokuCell:cell];

      setOfEliminationResults = [[NSMutableIndexSet alloc] init];
      for (SudokuCell* peerCell in peers) {
        BOOL result  = [self eliminateValue:lastPotentialValueOfCell fromSudokuCell:peerCell inMacroGrid:grid];
        [setOfEliminationResults addIndex:result];
      }

      /* if elimination of the value has been done correctly without any errors, then the length
       * of the set index must be 1. Otherwise, it will be 2 since the set will hold two different
       * value (0 for failure and 1 for success).
       */
      switch (setOfEliminationResults.count) {
        case 0:
          NSAssert(NO, @"Elimination counts can't be zero");
        case 1: // case elimination of a value, went success for all cells.
          /* Do nothing and continue executing the method. */
          break;
        default:
          return NO;
      }//switch
      
      break;
      
    default:
      /* Do nothting. */
      break;
  }
  
  /* After propagation of value elimination across multiple cells. There might be a possibility that
   * the eliminated value can be set to only one remaining cell. So if a super set (row/column/micro_grid)
   * is having only one possible cell for that value, then assign it to the cell.
   */
  superSet = [grid superSetOfSudokuCell:cell];

  /* Since Super Set consists of double array, loop through each sub array (sub set of the super set).*/
  for (NSArray<SudokuCell*>* subSet in superSet) {

    /* For every sub set, initialize new set index for the cells that still might have the eliminated
     * value (d) as a potential value. */
    setOfCellsIndexes = [[NSMutableIndexSet alloc] init];
    
    /* Loop throught the cells of the subset (which is technically an array). */
    [subSet enumerateObjectsUsingBlock:^(SudokuCell* cellInSubSet, NSUInteger cellIndex, BOOL* shouldStop){
      if ([cellInSubSet.potentialSolutionSet containsIndex:value]) {
        [setOfCellsIndexes addIndex:cellIndex];
      }
      *shouldStop = NO;
    }];
    
    
    switch (setOfCellsIndexes.count) {
      case 0:
        /* Contradiction: There is no cell that could have this value. */
        return NO;
        
      case 1:
        /* Once cell can only have the value(d), so assign the value(d) to the cell. */
        targetCell = [subSet objectAtIndex:[setOfCellsIndexes firstIndex]];
        return [self assignValue:value toSudokuCell:targetCell inMacroGrid:grid];
        
      default:
        /* Do nothing. */
        break;
    }//switch

  }//for loop
  
  
  return YES;
}

@end
