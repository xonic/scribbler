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
	NSBezierPath	*	path;
	NSBezierPath	*	currentPath;
	BOOL				draw;
	BOOL				clickThrough;
}

//- (NSRect)currentRect;

@property(readwrite, assign) BOOL draw;
@property(readwrite, assign) BOOL clickThrough;

@end
