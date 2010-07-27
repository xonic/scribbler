//
//  ColorController.m
//  Scribbler
//
//  Created by Thomas Nägele on 26.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "ColorController.h"


@implementation ColorController

@synthesize colorPalette;

- (id)init
{
	if(![super init])
		return nil;
	
	colorPalette	 = [[NSMutableArray alloc] init];
	returnColorIndex = 0;
	
	CGFloat steps = 1.0;
	
	for(int i=0; i<12; i++){
		
		NSColor * aColor = [NSColor colorWithDeviceHue:steps saturation:(CGFloat)1.0 brightness:(CGFloat)1.0 alpha:(CGFloat)1.0];
		[colorPalette addObject:aColor];
		//NSLog(@"ColorController: hue: %f, sat: %f, brightness: %f, alpha: %f", [aColor hueComponent], [aColor saturationComponent], [aColor brightnessComponent], [aColor alphaComponent]);
		NSLog(@"ColorController: created color with id: %d", aColor);
		steps -= 0.06;
	}

	return self;
}

- (NSColor *)getColorFromPalette
{
	returnColorIndex += 1;
	returnColorIndex = returnColorIndex % 12;
	
	return [colorPalette objectAtIndex:returnColorIndex];
}

@end
