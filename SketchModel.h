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

@class MainWindow;
@class PointModel;
@class SketchController;

@interface SketchModel : NSObject {
	NSMutableArray			*		curvedPaths;
	NSMutableArray			*		currentPath;
	MainWindow				*		window;
	SketchController		*		controller;
}

@property (retain) NSMutableArray *curvedPaths, *currentPath;

- (id) initWithController:(SketchController *)theController andWindow:(MainWindow *)theWindow;

// Basic adding and removing of paths and points
- (void) createNewPathAt:(NSPoint)inputPoint withColor:(NSColor *)theColor;
- (void) addPointToCurrentPath:(NSPoint)inputPoint;
- (void) saveCurrentPath;
- (void) removePath:(NSMutableArray *)path;
- (void) removePathIntersectingWith:(NSPoint)inputPoint;

// Methods for adding and removing Paths to the array
// Needed for proper undo/redo implementation
- (void) insertObjectInCurvedPaths:(NSMutableArray *)newObject;
- (void) removeObjectFromCurvedPaths:(NSMutableArray *)existingObject;

// Smoothing path curves
- (void) smoothCurrentPath;
- (NSMutableArray *) getControlPoints:(NSMutableArray *)rhs;

// Repositioning
- (void) repositionPaths:(PointModel *)delta;

// Get stuff
- (NSArray *) getPointsOfPath:(NSMutableArray *)thePath;
- (NSColor *) getColorOfPath:(NSMutableArray *)thePath;

@end
