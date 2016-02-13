//
//  MacroGrid.m
//  Sudoku
//
//  Created by Wael Showair on 2016-02-12.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

#import "MacroGrid.h"
#import "MicroGrid.h"

#define NUM_OF_MICRO_GRIDS          9
#define NUM_OF_CELLS_PER_ROW        9
#define NUM_OF_CELLS_PER_COL        9
#define NUM_OF_CELLS_IN_MACRO_GRID  81

#define ConvertIndexInto

@interface MacroGrid ()

/* Note that cells property is private so that the interface of the class with outside world stays
 * the same and independent on the actual implementation of the data structure type of the cells
 * property.
 */
@property NSMutableOrderedSet* cells;
@end

@implementation MacroGrid

-(instancetype)init{
  
  self = [super init];
  
  self.cells = [[NSMutableOrderedSet alloc] init];
  
  /* Create 9 micro grids per the macro grid. */
  for (int i=0; i< NUM_OF_MICRO_GRIDS ; i++) {
    
    MicroGrid* microGrid = [[MicroGrid alloc] init];
    
    /* Get flattened cells of the micro grid. */
    NSMutableOrderedSet* cellsOfMicroGrid = [microGrid getFlattenedCells];
    
    /* add the micro grid cells into cells of the macro grid. */
    [self.cells unionOrderedSet:cellsOfMicroGrid];
  }
  
  return self;
}

-(NSArray<SudokuCell *> *)getRowForCellAtIndex:(NSUInteger)index{
  if (NUM_OF_CELLS_IN_MACRO_GRID > index) {
    
    /* Row index is calculated through dividing given index by number of cells per row. */
    NSUInteger rowIndex = index/NUM_OF_CELLS_PER_ROW;

    /* return the row at the relative index. */
    return [self getRowAtIndex:rowIndex];
  }else{
    return nil;
  }
}

-(NSArray<SudokuCell *> *)getColumnForCellAtIndex:(NSUInteger)index{
  if (NUM_OF_CELLS_IN_MACRO_GRID > index) {

    /* Colum number is calculated by getting the remainder of dividing given index by
     * number of cells per colum.
     */
    NSUInteger columnIndex = (index % NUM_OF_CELLS_PER_COL);
    
    /* return the column at the relative index. */
    return [self getColumnAtIndex:columnIndex];
  }else{
    return nil;
  }
}

-(NSArray<SudokuCell *> *)getRowAtIndex:(NSUInteger)index{
  
  if (NUM_OF_CELLS_PER_ROW > index) {
    
    /* Create a range of consecutive indexes since cells of any macro grid are actually
     * represented by flattend data structure.
     * Requesting row at index n, means that cells[n+i]: i=0->8
     * should be returned from the method.
     */
    
    /* Create set of indexes of the cells that construct the row by creating a NSRange. */
    NSRange range = NSMakeRange(index * NUM_OF_CELLS_PER_ROW,  NUM_OF_CELLS_PER_ROW);
    NSIndexSet* setOfIndexes = [NSIndexSet indexSetWithIndexesInRange:range];
    
    /* Return the cells of the given indexes. */
    return [self.cells objectsAtIndexes:setOfIndexes];
    
  }else{
    return nil;
  }
}

-(NSArray<SudokuCell *> *)getColumnAtIndex:(NSUInteger)index{
  
  if (NUM_OF_CELLS_PER_COL > index) {
    
    /* Since the cells of any macro grid are represented by flattened data structure,
     * Requesting column at index n, means that cells[n+9*i]: i=0->8
     */
    
    /* Create set of indexes of the cells that construct the column by create mutable index set.
     * Can't use NSRange since the objects are not consecutive.
     */
    
    /* Add index of first cell in the column. */
    NSMutableIndexSet* setOfIndexes = [NSMutableIndexSet indexSetWithIndex:index];
    
    for (int i=0; i<NUM_OF_CELLS_PER_COL-1; i++) {
      /* Add index of the next cell in the column. */
      index+=NUM_OF_CELLS_PER_ROW;
      [setOfIndexes addIndex:index];
    }
    
    /* Return the cells of the given indexes. */
    return [self.cells objectsAtIndexes:setOfIndexes];
    
  }else{
    return nil;
  }
}

-(SudokuCell *)getSudokuCellAtRowColumn:(RowColPair)pair{
  
  if (NUM_OF_CELLS_PER_ROW > pair.row  && NUM_OF_CELLS_PER_COL > pair.column) {
    
    /* Since the cells of any micro grid are represented by flattened data structure,
     * Requesting cell at row n & column m, means that the cell is actually is at index = n*3+m
     */
    NSUInteger index = convertPairToIndex(pair);
    
    /* return the cell of the given row/column pair. */    
    return [self.cells objectAtIndex:index];
    
  }else{
    
    return nil;
  }
}

-(NSUInteger)indexOfSudokuCell:(SudokuCell *)cell{
  return [self.cells indexOfObject:cell];
}

-(NSArray<SudokuCell *> *)superSetOfSudokuCell:(SudokuCell *)cell{
  
#warning To be tested
  
  /* Get index of the sudoku cell in the macro grid. */
  NSUInteger index = [self indexOfSudokuCell:cell];

  /* Convert the index into row/column pair structure.*/
  RowColPair pair = convertIndexToPair(index);

  NSArray* cellsOfRow       = [self getRowAtIndex:pair.row];
  NSArray* cellsOfColumn    = [self getColumnAtIndex:pair.column];
  NSArray* cellsOfMicroGrid = [self getMicroGridForSudokuCellAtIndex: pair.row];
  
  /* Construct a set of all obtained cells. */
  NSIndexSet* setOfIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, NUM_OF_CELLS_PER_ROW)];

  /* TODO: What about returning NSSet for each of the previous getters methods. */
  NSOrderedSet* superSet = [NSOrderedSet orderedSetWithObjects:
                              [cellsOfRow objectsAtIndexes:setOfIndexes],
                              [cellsOfColumn objectsAtIndexes:setOfIndexes],
                              [cellsOfMicroGrid objectsAtIndexes:setOfIndexes],
                              nil];
  return superSet.array;
  
}

-(NSArray<SudokuCell *> *)peersOfSudokuCell:(SudokuCell *)cell{
#warning To be impmeneted and tested
  return nil;
}

-(NSArray<SudokuCell*>*) getMicroGridForSudokuCellAtIndex: (NSUInteger) index{
  
  if ((NUM_OF_CELLS_IN_MACRO_GRID > index) && (0 == index%NUM_OF_CELLS_PER_ROW)) {
    
    /* Create set of indexes of the cells that construct the row by creating a NSRange. */
    NSRange range = NSMakeRange(index * NUM_OF_CELLS_PER_ROW,  NUM_OF_CELLS_PER_ROW);
    NSIndexSet* setOfIndexes = [NSIndexSet indexSetWithIndexesInRange:range];
    
    /* Return the cells of the given indexes. */
    return [self.cells objectsAtIndexes:setOfIndexes];
  }else{
    return nil;
  }
}

-(NSUInteger)numOfCells{
  return self.cells.count;
}
@end
