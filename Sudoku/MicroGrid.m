//
//  MicroGrid.m
//  Sudoku
//
//  Created by Wael Showair on 2016-02-11.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

#import "MicroGrid.h"


#define NUM_OF_CELLS_PER_MICRO_GRID   9
#define NUM_OF_CELLS_PER_ROW          3
#define NUM_OF_CELLS_PER_COL          3
#define ONE_CELL                      1

@interface MicroGrid ()

/* Note that cells property is private so that the interface of the class with outside world stays
 * the same and independent on the actual implementation of the data structure type of the cells
 * property.
 */
@property NSMutableOrderedSet* cells;
@end

@implementation MicroGrid

#pragma initialization

-(instancetype) init{

  self = [super init];
  
  NSMutableArray* arrayOfSudokuCells = [[NSMutableArray alloc] init];
  for (int i=0; i< NUM_OF_CELLS_PER_MICRO_GRID; i++) {
    SudokuCell* cell = [[SudokuCell alloc] init];
    [arrayOfSudokuCells addObject:cell];
  }
  /* Although number of Sudoku cells is fixed in any micro grid but according to Apple documentation
   * It is not recommended to edit the mutable contents of immutable set.
   */
  self.cells = [NSMutableOrderedSet orderedSetWithArray:arrayOfSudokuCells];
  return self;
}

-(NSUInteger) numOfCells{
  return self.cells.count;
}

#pragma Row/Column Operations

-(NSArray<SudokuCell*>*)getRowAtIndex:(NSUInteger)index{
  
  if (NUM_OF_CELLS_PER_ROW > index) {

    /* Create a range of consecutive indexes since cells of any micro grid are actually
     * represented by flattend data structure. 
     * Requesting row at index n, means that cells[n], cells[n+1] & cells[n+2]
     * should be returned from the method.
     */
    
    /* Create set of indexes of the cells that construct the row by creating a NSRange. */
    NSRange range = NSMakeRange(index, NUM_OF_CELLS_PER_ROW);
    NSIndexSet* setOfIndexes = [NSIndexSet indexSetWithIndexesInRange:range];

    /* Return the cells of the given indexes. */
    return [self.cells objectsAtIndexes:setOfIndexes];
  }else{
    return nil;
  }
  
}

-(NSArray<SudokuCell*>*)getColumnAtIndex:(NSUInteger)index{
  
  if (NUM_OF_CELLS_PER_COL > index) {

    /* Since the cells of any micro grid are represented by flattened data structure,
     * Requesting column at index n, means that cells[n], cells[n+3] & cells[n+6]
     */
    
    /* Create set of indexes of the cells that construct the column by create mutable index set.
     * Can't use NSRange since the objects are not consecutive.
     */
    
    /* Add index of first cell in the column. */
    NSMutableIndexSet* setOfIndexes = [NSMutableIndexSet indexSetWithIndex:index];

    /* Add index of the second cell in the column. */
    index+=NUM_OF_CELLS_PER_ROW;
    [setOfIndexes addIndex:index];

    /* Add index of the second cell in the column. */
    index+=NUM_OF_CELLS_PER_ROW;
    [setOfIndexes addIndex:index];
    
    /* Return the cells of the given indexes. */
    return [self.cells objectsAtIndexes:setOfIndexes];
  }else{
    return nil;
  }

}

-(SudokuCell*)getSudokuCellAtRowColumn:(RowColPair)pair{
  
  if (NUM_OF_CELLS_PER_MICRO_GRID > pair.row  &&
      NUM_OF_CELLS_PER_MICRO_GRID > pair.column) {

    /* Since the cells of any micro grid are represented by flattened data structure,
     * Requesting cell at row n & column m, means that the cell is actually is at index = n*3+m
     */
    NSUInteger index = pair.row * NUM_OF_CELLS_PER_ROW + pair.column;
    
    /* return the cell of the given row/column pair. */
    return [self.cells objectAtIndex:index];
  }else{
    return nil;
  }
}

@end
