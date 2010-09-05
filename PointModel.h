//
//  MyPoint.h
//  Scribbler
//
//  Created by Thomas Nägele on 09.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PointModel : NSObject {
	NSPoint myNSPoint;
}

- (id) initWithNSPoint:(NSPoint)initPoint;
- (id) initWithDoubleX:(double)x andDoubleY:(double)y;
- (NSPoint) myNSPoint;
- (double) x;
- (double) y;
- (void) setX:(double)x;
- (void) setY:(double)y;
- (void) addDelta:(NSPoint)delta;

- (BOOL) isInRange:(NSNumber *)range ofNSPoint:(NSPoint)point;

@end
