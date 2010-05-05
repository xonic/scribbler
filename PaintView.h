//
//  PaintView.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PaintView : NSView {
	NSWindow *mainWindow;
	NSPoint downPoint;
	NSPoint currentPoint;
	NSMutableArray *ovals;
	NSBezierPath *path, *currentPath;
	BOOL draw;
	BOOL clickThrough;
}

- (NSRect)currentRect;

@property(readwrite, assign) BOOL draw;
@property(readwrite, assign) BOOL clickThrough;

@end
