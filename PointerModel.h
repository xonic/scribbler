//
//  PointerModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 19.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PointerModel : NSObject {
	
	NSNumber		*	uniqueID;
	NSColor			*	color;
}

@property (retain) NSNumber *uniqueID;
@property (retain) NSColor	*color;

- (id)initWithUniqueID:(NSNumber *)theID andColor:(NSColor *)theColor;

@end
