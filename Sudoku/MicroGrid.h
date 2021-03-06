//
//  MicroGrid.h
//  Sudoku
//
//  Created by Wael Showair on 2016-02-11.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SudokuCell.h"
#import "RowColPair.h"


/* This class wraps a 3x3 small grid in Sudoku game. Typically, there are 9 micro grids in
 * Sudoku game. The features of this grid type is that:
 *
 * 1- it contains distinct numbers ranges from 1 to 9. 
 * 2- it should perform membership-testing fast since it is expected frequently to check whether a
 *    number exists in a micro grid.
 * 3- Ordered objects is a requiremnt to be able to have a macro row/columne of 9 elements from 3
 *    micro grids at a time.
 *
 * There NSOrderedSet/NSMutableOrderedSet classes in Objective-C that meet these requirements.
 */
@interface MicroGrid : NSObject

+(NSRange) fullRange;

/* Typically, this method will be called from the parser so there is no need to check on values
 * of the cells again since the parse has already did this check for us.
 */
-(instancetype) initWithSudokuCells:(NSArray<SudokuCell*>*)cells;

-(NSUInteger) numOfCells;
-(NSArray<SudokuCell*>*) getFlattenedCellsArray;

/* Retrieve row from micro grid */
-(NSArray<SudokuCell*>*) getRowAtIndex: (NSUInteger) index;

/* Retrieve column from micro grid */
-(NSArray<SudokuCell*>*) getColumnAtIndex: (NSUInteger) index;

/* Methods to retrieve specific cell from micro grid */
-(SudokuCell*) getSudokuCellAtRowColumn:(RowColPair) pair;

/* TODO: Methods to check whether a number can be placed at specific row/colum. */

#if UNIT_TESTING
- (NSUInteger) indexOfSudokuCell: (SudokuCell*) cell;
#endif
@end
