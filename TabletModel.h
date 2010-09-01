//
//  TabletModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 26.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TabletModel : NSObject {
	
	NSNumber				*		tabletID;
	NSColor					*		tabletColor;	
	NSMutableDictionary		*		penColors;
}

@property (retain, readonly) NSNumber *tabletID;
@property (retain, readonly) NSColor  *tabletColor;

- (id)initWithTabletID:(NSNumber *)theID andColor:(NSColor *)theColor;

- (void)registerPen:(NSNumber *)uniqueID;
- (BOOL)isPenRegistered:(NSNumber *)uniqueID;

- (NSColor *)getColorForPen:(NSNumber *)uniqueID;

@end
