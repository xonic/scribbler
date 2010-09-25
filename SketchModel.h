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
#import "UndoManager.h"

@class MainWindow;
@class PointModel;
@class SketchController;
@class UndoManager;

@interface SketchModel : NSObject {
	NSMutableArray			*		smoothedPaths;
	NSMutableArray			*		currentPath;
	MainWindow				*		window;
	SketchController		*		controller;
	NSMutableDictionary		*		undoManagers;
}

@property (retain) NSMutableArray		*currentPath;
@property (retain) NSMutableArray		*smoothedPaths;
@property (retain) NSMutableDictionary  *undoManagers;

- (id) initWithController:(SketchController *)theController andWindow:(MainWindow *)theWindow;

// Basic adding and removing of paths and points
- (void) createNewPathAt:(NSPoint)inputPoint withColor:(NSColor *)theColor;
- (void) addPointToCurrentPath:(NSPoint)inputPoint;
- (void) saveCurrentPathWithOwner:(NSNumber *)tabletID;
- (void) removePathIntersectingWith:(NSPoint)inputPoint forTablet:(NSNumber *)activeTabletID;
- (void)removeAllPathsForTablet:(NSNumber *)activeTabletID;
- (void)removeAllSmoothedPaths;

// undo/redo
- (void) undoForTablet:(NSNumber *)tabletID;
- (void) redoForTablet:(NSNumber *)tabletID;

// Smoothing path curves
- (void) smoothCurrentPath;
- (NSMutableArray *) getControlPoints:(NSMutableArray *)rhs;

// Repositioning
- (void) repositionPaths:(PointModel *)delta;

// Get stuff
- (NSArray *) getPointsOfPath:(NSMutableArray *)thePath;
- (NSColor *) getColorOfPath:(NSMutableArray *)thePath;

@end
