//
//  UndoManager.m
//  Scribbler
//
//  Created by Thomas Nägele on 05.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "UndoManager.h"


@implementation UndoManager

// Initialization
- (id)initWithSketchModel:(SketchModel *)theSketchModel andTabletID:(NSNumber *)theTabletID
{
	if(![super init])
		return nil;
	
	sketchModel = [theSketchModel retain];
	tabletID	= [theTabletID	  retain];
	
	undoDrawingStack = [[NSMutableArray alloc] init];
	redoDrawingStack = [[NSMutableArray alloc] init];
	
	undoErasingStack = [[NSMutableArray alloc] init];
	redoErasingStack = [[NSMutableArray alloc] init];
	
	lastAction = 0;
	
	return self;	
}

// Manage Drawing stacks
- (void)registerDrawingForUndo:(PathModel *)path
{
	// Save path to undo
	[undoDrawingStack addObject:path];
	
	// Flush all other stacks
	[undoErasingStack removeAllObjects];
	[redoDrawingStack removeAllObjects];
	[redoErasingStack removeAllObjects];
	
	// Set Drawing as the last action 
	lastAction = 0;
}

- (void)resetDrawingStacks
{
	[undoDrawingStack removeAllObjects];
	[redoDrawingStack removeAllObjects];
}

// Manage Erasing stacks
- (void)registerErasingForUndo:(PathModel *)path
{
	// Save erase operation to undo
	[undoErasingStack addObject:path];
	
	// Flush all other stacks
	[undoDrawingStack removeAllObjects];
	[redoErasingStack removeAllObjects];
	[redoDrawingStack removeAllObjects];
	
	// Set Erasing as the last action
	lastAction = 1;
}

- (void)resetErasingStacks
{
	[undoErasingStack removeAllObjects];
	[redoErasingStack removeAllObjects];
}

// Undo/Redo
- (void)undo
{
	// Check what the last Action was
	if(lastAction == 0)
	{
		// Check whether there are undoable paths
		if ([undoDrawingStack count] == 0) 
		{
			NSLog(@"There are no paths to undo for this UndoManager");
			return;
		}
		else
		{
			// Pop the last undoable path from our Undo stack and push it onto the Redo stack
			[redoDrawingStack addObject:[undoDrawingStack lastObject]];
			
			// Delete it from the SketchModel
			[[sketchModel smoothedPaths] removeObject:[undoDrawingStack lastObject]];
			
			// And also from our Undo stack
			[undoDrawingStack removeLastObject];
			
			return;
		}
	} else if (lastAction == 1) { // Erase was the last action
		
		// Check whether there are erased paths that can be undone
		if ([undoErasingStack count] == 0) {
			NSLog(@"There are no erased paths to undo for this UndoManager");
			return;
		}
		else 
		{
			// Pop the last erased path from our Undo stack and push it onto the redo stack
			[redoErasingStack addObject:[undoErasingStack lastObject]];
			
			// Re-add it to our SketchModel
			[[sketchModel smoothedPaths] addObject:[undoErasingStack lastObject]];
			
			// Remove it from the undo stack
			[undoErasingStack removeLastObject];
			
			return;
		}
	}
}

- (void)redo
{
	// Check what the last action was
	if(lastAction == 0)
	{
		// Check whether there are redoable paths
		if([redoDrawingStack count] == 0)
		{
			NSLog(@"There are no paths to redo for this UndoManager");
			return;
		}
		else 
		{
			// Pop the last redoable path from our Redo stack and push it onto the Undo stack
			[undoDrawingStack addObject:[redoDrawingStack lastObject]];
			
			// Re-add the path to our SketchModel
			[[sketchModel smoothedPaths] addObject:[redoDrawingStack lastObject]];
			
			// Remove it from the Redo stack
			[redoDrawingStack removeLastObject];
			
			return;
		}
	} else if (lastAction == 1) { // Erase was the last action
		
		// Check whether there are erase operations to redo
		if([redoErasingStack count] == 0)
		{
			NSLog(@"There are no erasing operations to redo for this UndoManager");
			return;
		}
		else 
		{
			// Pop the last redoable erasing operation from our Redo stack and push it onto the Undo stack
			[undoErasingStack addObject:[redoErasingStack lastObject]];
			
			// Remove it from our SketchModel
			[[sketchModel smoothedPaths] removeObject:[redoErasingStack lastObject]];
			
			// Remove it from the Redo stack
			[redoErasingStack removeLastObject];
			
			return;
		}
	}
}

- (void)dealloc
{
	[sketchModel	  release];
	[tabletID		  release];
	
	[undoDrawingStack release];
	[redoDrawingStack release];
	
	[undoErasingStack release];
	[redoErasingStack release];
	
	[super			  dealloc];
}

@end
