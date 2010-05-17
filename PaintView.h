//
//  PaintView.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyPoint.h"

@interface PaintView : NSView {	
	NSWindow			*	mainWindow;
	NSMutableArray		*	myPaths;
	NSMutableArray		*	myPoints;
	NSMutableArray		*	firstControlPoints;
	NSMutableArray		*	secondControlPoints;
	NSBezierPath		*	path;

	BOOL					draw;
	BOOL					clickThrough;
	BOOL					isDrawing;
	BOOL					erase;
}

- (NSMutableArray *) getCurveControlPoints:(NSMutableArray *)pathToBeEdited;
- (NSMutableArray *) getFirstControlPoints:(NSMutableArray *)rhs;
- (void) erasePath:(NSPoint)point;
- (void) repositionPaths:(MyPoint *)delta;

- (void) insertObjectInMyPaths:(id)newPath;
- (void) removeObjectFromMyPaths:(id)existingPath;

@property(readwrite, assign) BOOL draw, clickThrough, isDrawing, erase;

@end
