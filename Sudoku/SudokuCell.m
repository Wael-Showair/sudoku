//
//  SudokuCell.m
//  Sudoku
//
//  Created by Wael Showair on 2016-02-11.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

#import "SudokuCell.h"

#define DOES_POSSIBLE_SOLUTION_SET_HAVE_SINGLE_VALUE  (1==self.potentialSolutionSet.count)

@implementation SudokuCell

#pragma initalization

-(instancetype) init{

  self = [super init];

  /* Initialize the value of the cell to invalid value*/
  return [self initWithValue:INVALID_VALUE];
  
}

-(instancetype) initWithValue: (NSUInteger)value{
  self = [super init];
  
  /* If the given value is out of range, set value to invalid value */
  if (!NSLocationInRange(value, [SudokuCell fullRange])) {
    /* During normal running, set the out of range value to invalid value. */
    value = INVALID_VALUE;
    
    /* Set the potential solution set of the cell to all possible values. */
    self.potentialSolutionSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:[SudokuCell fullRange]];
    
  }else{
    /* Set the potential solution set of the cell to include only the given value. */
    self.potentialSolutionSet = [[NSMutableIndexSet alloc] initWithIndex:value];
  }
  
  self.value = value;
  return self;
}

-(id)copyWithZone:(NSZone *)zone{
  SudokuCell* cell = [[[self class] alloc] initWithValue:_value];
  cell.potentialSolutionSet = [[NSMutableIndexSet alloc] initWithIndexSet:_potentialSolutionSet];
  return cell;
}

-(void) setValue:(NSUInteger)value{
  
  if (INVALID_VALUE == value) {
    
    /* Set the potential solution set of the cell */
    self.potentialSolutionSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:[SudokuCell fullRange]];

  } else{
    
    /* make sure that solution set contains only one value which will be set to the cell. */
    NSAssert(DOES_POSSIBLE_SOLUTION_SET_HAVE_SINGLE_VALUE,
              @"Cell Value Set Error: Trying to set cell value where its Potential Solution Set contains more than one possible value");

    /* make sure that the desired value belongs to the possible solution set of the cell. */
    NSAssert([self.potentialSolutionSet containsIndex:value], @"Cell Value Set Error: Potential Solution Set does not contain the value that will be set to the cell");
  }
  
  _value = value;
}

+(NSRange)fullRange{
  /* Create a range of numbers from 1 to 9 */
  return NSMakeRange(1, 9);
}
#pragma Comparison

/* source: http://nshipster.com/equality/ */

-(BOOL)isEqualToSudokuCell: (SudokuCell*) cell{
  
  if (!cell) {
    return NO;
  }

  /* This is the key factor of deciding whether two cells are logically equal or not.
   * TODO: Perhaps, need to check potential solution set as well. */
  if (self.value != cell.value) {
    return NO;
  }
  
  return YES;
  
}

-(BOOL) isEqual:(id) cell{
  if (self != cell) {
    return NO;
  }
  
  if (![cell isKindOfClass:[SudokuCell class]]) {
   return NO;
  }
  
  return [self isEqualToSudokuCell:cell];
}

#if 0

/* My implementation of the hash method prevents the data structure that constructs the grid cells
 * from retrieving the index of a given cell.
 */
-(NSUInteger)hash{
  
  /* hash implementations might be improved by bit-shifting or rotating composite values that may overlap.*/
  return self.value ^ [self.potentialSolutionSet hash];
}
#endif

#pragma actions

-(void)eliminateNumberFromSolutionSet:(NSUInteger)number{
  
  if(!NSLocationInRange(number, [SudokuCell fullRange]) ||
     ![self.potentialSolutionSet containsIndex:number]){
    return;
  }

  /* Remove the given number from the current potentional solution set. */
  [self.potentialSolutionSet removeIndex:number];
}

@end
