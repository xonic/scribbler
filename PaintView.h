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
	NSWindow		*	mainWindow;
	NSPoint				downPoint;		
	MyPoint			*	currentPoint;
	NSMutableArray	*	myPaths;
	NSMutableArray	*	myPoints;
	NSMutableArray	*	firstControlPoints;
	NSMutableArray	*	secondControlPoints;
	NSBezierPath	*	path;
	NSBezierPath	*	currentPath;
	NSMutableArray	*	curvedPath;
	BOOL				draw;
	BOOL				clickThrough;
	BOOL				isDrawing;
}

- (NSMutableArray *) getCurveControlPoints:(NSMutableArray *)pathToBeEdited;
- (NSMutableArray *) getFirstControlPoints:(NSMutableArray *)rhs;

@property(readwrite, assign) BOOL draw;
@property(readwrite, assign) BOOL clickThrough;
@property(readwrite, assign) BOOL isDrawing;

@end
