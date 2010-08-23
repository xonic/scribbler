//
//  PathModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "PathModel.h"


@implementation PathModel

@synthesize path, color, isAffectedByScrollingAndResizing, creationDate, undoDate, redoDate;

- (id)initWithPath:(NSBezierPath *)thePath andColor:(NSColor *)theColor
{
	if (![super init])
		return nil;
	
	if(thePath == nil || theColor == nil){
		NSLog(@"PathModel/initWithPath:thePath andColor:andColor - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	path   =  [thePath  retain];
	color  =  [theColor retain];
	
	creationDate = nil;
	undoDate	 = nil;
	redoDate	 = nil;
	
	isAffectedByScrollingAndResizing = NO;
	
	return self;
}

@end
