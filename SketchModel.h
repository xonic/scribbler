//
//  SketchModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 20.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PointModel.h"
#import "MainWindow.h"
#import "PathModel.h"

@class MainWindow;
@class PointModel;
@class SketchController;

@interface SketchModel : NSObject {
	NSMutableArray			*		smoothedPaths;
	NSMutableArray			*		currentPath;
	MainWindow				*		window;
	SketchController		*		controller;
}

@property (retain) NSMutableArray		*currentPath;
@property (retain) NSMutableArray		*smoothedPaths;

- (id) initWithController:(SketchController *)theController andWindow:(MainWindow *)theWindow;

// Basic adding and removing of paths and points
- (void) createNewPathAt:(NSPoint)inputPoint withColor:(NSColor *)theColor;
- (void) addPointToCurrentPath:(NSPoint)inputPoint;
- (void) saveCurrentPath;
- (void) removePathIntersectingWith:(NSPoint)inputPoint;

// Methods for adding and removing Paths to the array
// Needed for proper undo/redo implementation
- (void) insertPathModelIntoArray:(PathModel *)thePath;
- (void) removePathModelFromArray:(PathModel *)thePath;

// Smoothing path curves
- (void) smoothCurrentPath;
- (NSMutableArray *) getControlPoints:(NSMutableArray *)rhs;

// Repositioning
- (void) repositionPaths:(PointModel *)delta;

// Get stuff
- (NSArray *) getPointsOfPath:(NSMutableArray *)thePath;
- (NSColor *) getColorOfPath:(NSMutableArray *)thePath;

@end
