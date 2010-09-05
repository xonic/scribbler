//
//  UndoManager.h
//  Scribbler
//
//  Created by Thomas Nägele on 05.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchModel.h"

@class SketchModel;

@interface UndoManager : NSObject {
	
	// The parent
	SketchModel		*	sketchModel;
	
	// Each SketchModel has a Dictionary holding an UndoManager for each Tablet: 
	// <string:tabletID> <--> <object:UndoManager>
	NSNumber		*	tabletID;
	
	// Undo and redo the drawing operation
	NSMutableArray	*	undoDrawingStack;
	NSMutableArray	*	redoDrawingStack;
	
	// Undo and redo the erasing operation
	NSMutableArray	*	undoErasingStack;
	NSMutableArray	*	redoErasingStack;
	
	// Remember the last action that came from the tablet
	// 0 = Drawing
	// 1 = Erasing
	int					lastAction; 
}

// Initialization
- (id)initWithSketchModel:(SketchModel *)theSketchModel andTabletID:(NSNumber *)theTabletID;

// Manage Drawing stacks
- (void)registerDrawingForUndo:(PathModel *)path; // Holds paths that can be undone
- (void)resetDrawingStacks;

// Manage Erasing stacks
- (void)registerErasingForUndo:(PathModel *)path; // Holds erased paths, the erasing can be undone
- (void)resetErasingStacks;

// Undo/Redo
- (void)undo;
- (void)redo;

@end
