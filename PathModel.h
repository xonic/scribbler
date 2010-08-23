//
//  PathModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PathModel : NSObject {
	NSBezierPath	*	path;
	NSColor			*	color;
	NSDate			*	creationDate;
	NSDate			*	undoDate;
	NSDate			*	redoDate;
	BOOL				isAffectedByScrollingAndResizing;
}

@property (retain) NSBezierPath *path;
@property (retain) NSColor		*color;
@property (retain) NSDate		*creationDate, *undoDate, *redoDate;
@property (assign) BOOL			 isAffectedByScrollingAndResizing;

- (id)initWithPath:(NSBezierPath *)thePath andColor:(NSColor *)theColor;

@end
