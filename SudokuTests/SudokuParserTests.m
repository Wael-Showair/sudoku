//
//  SudokuParserTests.m
//  Sudoku
//
//  Created by Wael Showair on 2016-02-14.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SudokuParser.h"

@interface SudokuParserTests : XCTestCase
@property (strong, nonatomic) SudokuParser* parser;
@end

@implementation SudokuParserTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  self.parser = [[SudokuParser alloc] init];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  self.parser = nil;
}

- (void)testInitParser{
  
  NSRange expectedRange = NSMakeRange(0, 10);
  XCTAssertNotNil(self.parser);
  XCTAssertTrue(NSEqualRanges(expectedRange, self.parser.acceptableRange));
}

-(void) testParseGridFromPropertyListFileSuccessUsingMicroGrids{
  int expectedResults[] =
  {
    0, 0, 3, 9, 0, 0, 0, 0, 1, //micro_grid_0
    0, 2, 0, 3, 0, 5, 8, 0, 6, //micro_grid_1
    6, 0, 0, 0, 0, 1, 4, 0, 0, //micro_grid_2
    0, 0, 8, 7, 0, 0, 0, 0, 6, //micro_grid_3
    1, 0, 2, 0, 0, 0, 7, 0, 8, //micro_grid_4
    9, 0, 0, 0, 0, 8, 2, 0, 0, //micro_grid_5
    0, 0, 2, 8, 0, 0, 0, 0, 5, //micro_grid_6
    6, 0, 9, 2, 0, 3, 0, 1, 0, //micro_grid_7
    5, 0, 0, 0, 0, 9, 3, 0, 0, //micro_grid_8
  };
  
  MacroGrid* grid = [self.parser parseGridFromPropertyListFile:@"sudoku_grid"];
  NSArray<SudokuCell*>* cellsOfMicroGrids = [grid getFlattenedCells:MacroGridFlattingTypeMicroGrids];
  
  XCTAssertNotNil(grid);
  XCTAssertEqual(81, [grid numOfCells]);
  
  NSRange expectedFullRange = NSMakeRange(1, 9);
  NSIndexSet* expectedSetOfValuesForFullRange = [NSIndexSet indexSetWithIndexesInRange:expectedFullRange];
  
  for (int i=0; i<81; i++) {
    SudokuCell* cell = cellsOfMicroGrids[i];
    XCTAssertEqual(expectedResults[i], cell.value);
    
    /* In case the cell is empty, make sure it has all numbers in the potential solution set.*/
    if (0 == expectedResults[i]) {
      XCTAssertEqual(9, cell.potentialSolutionSet.count);
      XCTAssertTrue([expectedSetOfValuesForFullRange isEqualToIndexSet:cell.potentialSolutionSet]);
    }else{
      /* In case the cell is not empty, make sure it has only single possible value which
       * equals to the cell value.
       */
      NSIndexSet* expectedSetValue = [NSIndexSet indexSetWithIndex:cell.value];
      XCTAssertTrue([expectedSetValue isEqualToIndexSet:cell.potentialSolutionSet]);
    }
  }
}

-(void) testParseGridFromPropertyListFileSuccessUsingRowsCells{
  int expectedResults[] =
  {
    0, 0, 3, 9, 0, 0, 0, 0, 1, //micro_grid_1
    0, 2, 0, 3, 0, 5, 8, 0, 6, //micro_grid_2
    6, 0, 0, 0, 0, 1, 4, 0, 0, //micro_grid_3
    0, 0, 8, 7, 0, 0, 0, 0, 6, //micro_grid_4
    1, 0, 2, 0, 0, 0, 7, 0, 8, //micro_grid_5
    9, 0, 0, 0, 0, 8, 2, 0, 0, //micro_grid_6
    0, 0, 2, 8, 0, 0, 0, 0, 5, //micro_grid_7
    6, 0, 9, 2, 0, 3, 0, 1, 0, //micro_grid_8
    5, 0, 0, 0, 0, 9, 3, 0, 0, //micro_grid_9
  };
  
  MacroGrid* grid = [self.parser parseGridFromPropertyListFile:@"sudoku_grid_in_rows"];
  NSArray<SudokuCell*>* cellsOfMicroGrids = [grid getFlattenedCells:MacroGridFlattingTypeMicroGrids];
  
  XCTAssertNotNil(grid);
  XCTAssertEqual(81, [grid numOfCells]);
  
  NSRange expectedFullRange = NSMakeRange(1, 9);
  NSIndexSet* expectedSetOfValuesForFullRange = [NSIndexSet indexSetWithIndexesInRange:expectedFullRange];
  
  for (int i=0; i<81; i++) {
    SudokuCell* cell = cellsOfMicroGrids[i];
    XCTAssertEqual(expectedResults[i], cell.value);
    
    /* In case the cell is empty, make sure it has all numbers in the potential solution set.*/
    if (0 == expectedResults[i]) {
      XCTAssertEqual(9, cell.potentialSolutionSet.count);
      XCTAssertTrue([expectedSetOfValuesForFullRange isEqualToIndexSet:cell.potentialSolutionSet]);
    }else{
      /* In case the cell is not empty, make sure it has only single possible value which
       * equals to the cell value.
       */
      NSIndexSet* expectedSetValue = [NSIndexSet indexSetWithIndex:cell.value];
      XCTAssertTrue([expectedSetValue isEqualToIndexSet:cell.potentialSolutionSet]);
    }
  }
}

-(void) testParseGridWithInvalidValuesFromPropertyListFile{
  MacroGrid* grid = [self.parser parseGridFromPropertyListFile:@"sudoku_grid_invalid_values"];
  XCTAssertNil(grid);
}

-(void) testParseGridFromPropertyListFileNil{
  MacroGrid* grid = [self.parser parseGridFromPropertyListFile:nil];
  XCTAssertNil(grid);
}

-(void) testParseGridFromPropertyListFileNonExistant{
  MacroGrid* grid = [self.parser parseGridFromPropertyListFile:@"sudoku_grid_non_existant"];
  XCTAssertNil(grid);
}

@end
