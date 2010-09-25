//
//  UndoManager.h
//  Scribbler
//
//  Created by Thomas Nägele on 05.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchModel.h"
#import "HistoryObject.h"
#import "Constants.h"

@class SketchModel;

@interface UndoManager : NSObject {
	
	// The parent
	SketchModel		*	sketchModel;
	
	// Each SketchModel has a Dictionary holding an UndoManager for each Tablet: 
	// <string:tabletID> <--> <object:UndoManager>
	NSNumber		*	tabletID;
	
	NSMutableArray	*	undoStack;
	NSMutableArray	*	redoStack;
}

// Initialization
- (id)initWithSketchModel:(SketchModel *)theSketchModel andTabletID:(NSNumber *)theTabletID;

- (void)registerDrawForPath:(PathModel *)thePath;
- (void)registerEraseForPath:(PathModel *)thePath;
- (void)registerDrawForAllPathModels:(NSMutableArray *)allPathModels;
- (void)registerEraseForAllPathModels:(NSMutableArray *)allPathModels;

- (void)undo;
- (void)redo;

@end
