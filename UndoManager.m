//
//  UndoManager.m
//  Scribbler
//
//  Created by Thomas Nägele on 05.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "UndoManager.h"


@implementation UndoManager

- (id)initWithSketchModel:(SketchModel *)theSketchModel andTabletID:(NSNumber *)theTabletID
{
	if(![super init])
		return nil;
	
	sketchModel = [theSketchModel retain];
	tabletID	= [theTabletID	  retain];
	
	undoStack	= [[NSMutableArray alloc] init];
	redoStack	= [[NSMutableArray alloc] init];
	
	return self;
}

- (void)registerDrawForPath:(PathModel *)thePath
{
	HistoryObject * newHistoryObj = [[HistoryObject alloc] initWithOperation:OPERATION_ADD_PATH forPathModel:thePath];
	[undoStack addObject:newHistoryObj];
	[newHistoryObj release];
	
	[redoStack release];
	redoStack = [[NSMutableArray alloc] init];
}

- (void)registerEraseForPath:(PathModel *)thePath
{
	HistoryObject * newHistoryObj = [[HistoryObject alloc] initWithOperation:OPERATION_REMOVE_PATH forPathModel:thePath];
	[undoStack addObject:newHistoryObj];
	[newHistoryObj release];
	
	[redoStack release];
	redoStack = [[NSMutableArray alloc] init];
}

- (void)registerDrawForAllPathModels:(NSMutableArray *)allPathModels
{
	HistoryObject * newHistoryObj = [[HistoryObject alloc] initWithOperation:OPERATION_ADD_ALL_PATHS forAllPathModels:allPathModels];
	[undoStack addObject:newHistoryObj];
	[newHistoryObj release];
	
	[redoStack release];
	redoStack = [[NSMutableArray alloc] init];
}

- (void)registerEraseForAllPathModels:(NSMutableArray *)allPathModels
{
	HistoryObject * newHistoryObj = [[HistoryObject alloc] initWithOperation:OPERATION_REMOVE_ALL_PATHS forAllPathModels:allPathModels];
	[undoStack addObject:newHistoryObj];
	[newHistoryObj release];
	
	[redoStack release];
	redoStack = [[NSMutableArray alloc] init];
}

- (void)undo
{
	if([undoStack count] < 1)
		return;
	
	// Undo draw
	if ([[undoStack lastObject] operation] == OPERATION_ADD_PATH) 
	{	
		[[sketchModel smoothedPaths] removeObject:[[undoStack lastObject] thePath]];
		[redoStack addObject:[undoStack lastObject]];
		[undoStack removeLastObject];
		return;
	}
	
	// Undo erase
	if ([[undoStack lastObject] operation] == OPERATION_REMOVE_PATH)
	{
		[[sketchModel smoothedPaths] addObject:[[undoStack lastObject] thePath]];
		[redoStack addObject:[undoStack lastObject]];
		[undoStack removeLastObject];
		return;
	}
	
	// Undo add all paths
	if ([[undoStack lastObject] operation] == OPERATION_ADD_ALL_PATHS)
	{
		[[sketchModel smoothedPaths] removeAllObjects];
		[redoStack addObject:[undoStack lastObject]];
		[undoStack removeLastObject];
		return;
	}
	
	// Undo remove all paths
	if ([[undoStack lastObject] operation] == OPERATION_REMOVE_ALL_PATHS)
	{
		[[sketchModel smoothedPaths] setArray:[[undoStack lastObject] allPaths]];
		[redoStack addObject:[undoStack lastObject]];
		[undoStack removeLastObject];
		return;
	}
}

- (void)redo
{
	if ([redoStack count] < 1)
		return;
	
	// Redo draw
	if ([[redoStack lastObject] operation] == OPERATION_ADD_PATH)
	{
		[[sketchModel smoothedPaths] addObject:[[redoStack lastObject] thePath]];
		[undoStack addObject:[redoStack lastObject]];
		[redoStack removeLastObject];
		return;
	}
	
	// Redo erase
	if ([[redoStack lastObject] operation] == OPERATION_REMOVE_PATH)
	{
		[[sketchModel smoothedPaths] removeObject:[[redoStack lastObject] thePath]];
		[undoStack addObject:[redoStack lastObject]];
		[redoStack removeLastObject];
		return;
	}
	
	// Redo add all paths
	if ([[redoStack lastObject] operation] == OPERATION_ADD_ALL_PATHS)
	{
		[sketchModel setSmoothedPaths:[[redoStack lastObject] allPaths]];
		[undoStack addObject:[redoStack lastObject]];
		[redoStack removeLastObject];
		return;
	}
	
	// Redo remove all paths
	if ([[redoStack lastObject] operation] == OPERATION_REMOVE_ALL_PATHS)
	{
		[[sketchModel smoothedPaths] removeAllObjects];
		[undoStack addObject:[redoStack lastObject]];
		[redoStack removeLastObject];
		return;
	}
}

- (void)dealloc
{
	[sketchModel	  release];
	[tabletID		  release];
	
	[undoStack		  release];
	[redoStack		  release];
	
	[super			  dealloc];
}

@end
