//
//  PathModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "PathModel.h"


@implementation PathModel

@synthesize path, color;

- (id)initWithPath:(NSBezierPath *)thePath andColor:(NSColor *)theColor
{
	if (![super init])
		return nil;
	
	[thePath  retain];
	[theColor retain];
	
	path   =  thePath;
	color  =  theColor;
	
	return self;
}


@end
