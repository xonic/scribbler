//
//  MyPoint.h
//  Scribbler
//
//  Created by Thomas Nägele on 09.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyPoint : NSObject {
	NSPoint myNSPoint;
}

- (id) initWithNSPoint:(NSPoint)initPoint;
- (id) initWithDoubleX:(double)x Y:(double)y;
- (NSPoint) myNSPoint;
- (float) x;
- (float) y;
- (void) setX:(float)x;
- (void) setY:(float)y;
- (void) addDelta:(NSPoint)delta;

- (BOOL) isInRange:(NSNumber *)range ofNSPoint:(NSPoint)point;

@end
