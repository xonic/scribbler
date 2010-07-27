//
//  ColorController.h
//  Scribbler
//
//  Created by Thomas Nägele on 26.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ColorController : NSObject {
	
	NSMutableArray		* colorPalette;
	int					  returnColorIndex;
}

@property (retain, readonly) NSMutableArray *colorPalette;

- (NSColor *)getColorFromPalette;

@end
