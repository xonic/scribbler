//
//  MyPoint.m
//  Scribbler
//
//  Created by Thomas Nägele on 09.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "MyPoint.h"


@implementation MyPoint

- (id) initWithNSPoint:(NSPoint)initPoint
{
	if(![super init])
		return nil;
	
	myNSPoint.x = initPoint.x;
	myNSPoint.y = initPoint.y;
	
	return self;
}

- (id) initWithDoubleX:(double) x Y:(double) y
{
	if(![super init])
		return nil;
	
	myNSPoint.x = (float) x;
	myNSPoint.y = (float) y;
	
	return self;
}

- (NSPoint) myNSPoint
{
	return myNSPoint;
}

- (float) x
{
	return myNSPoint.x;
}

- (float) y
{
	return myNSPoint.y;
}

- (void) setX:(float) x
{
	myNSPoint.x = x;
}

- (void) setY:(float) y
{
	myNSPoint.y = y;
}

// function to add a delta offset to the point
- (void) addDelta:(NSPoint)delta
{
	myNSPoint.x+=delta.x;
	myNSPoint.y+=delta.y;
}

- (BOOL) isInRange:(NSNumber *)range ofNSPoint:(NSPoint)point
{
	if (myNSPoint.x > (point.x - [range doubleValue]) && myNSPoint.x < (point.x + [range doubleValue])) {
		if (myNSPoint.y > (point.y - [range doubleValue]) && myNSPoint.y < (point.y + [range doubleValue])) {
			return YES;
		}
	}
	return NO;
}

@end
