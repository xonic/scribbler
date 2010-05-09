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
- (NSPoint) myNSPoint;
- (float) x;
- (float) y;

@end
