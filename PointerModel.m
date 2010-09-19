//
//  PointerModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 19.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "PointerModel.h"


@implementation PointerModel

@synthesize uniqueID, color;

- (id)initWithUniqueID:(NSNumber *)theID andColor:(NSColor *)theColor
{
	if(![super init])
		return nil;
	
	uniqueID = [theID	 retain];
	color	 = [theColor retain];
	
	return self;
}

@end
