//
//  TabletModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 26.07.10.
//  Copyright 2010 xonic. All rights reserved.
//
#import "TabletModel.h"



@implementation TabletModel

@synthesize tabletID, tabletColor;

- (id)initWithTabletID:(NSNumber *)theID andColor:(NSColor *)theColor
{
	if(![super init])
		return nil;
	
	tabletID    = [theID	retain];
	tabletColor = [theColor retain];
	
	penColors   = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)registerPen:(NSNumber *)uniqueID
{
	// check if the pen was already registered
	if([penColors objectForKey:[uniqueID stringValue]] != nil)
		return;
	
	float tmp = [penColors count];
	// every new pen will have 20% less brighntess than it's predecessor
	CGFloat brightnessReduction = tmp / 5.0;
	
	// set the color
	NSColor *newShade = [NSColor colorWithDeviceHue:[tabletColor hueComponent] 
										 saturation:[tabletColor saturationComponent] 
										 brightness:([tabletColor brightnessComponent] - brightnessReduction)
											  alpha:[tabletColor alphaComponent]];
	
	// save the color with the pen id
	[penColors setObject:newShade forKey:[uniqueID stringValue]];
	

}

- (BOOL)isPenRegistered:(NSNumber *)uniqueID
{
	// check if the pen was already registered
	if([penColors objectForKey:[uniqueID stringValue]] != nil)
		return YES;
	else 
		return NO;
}

- (NSColor *)getColorForPen:(NSNumber *)uniqueID
{
	// catch error
	if([penColors objectForKey:[uniqueID stringValue]] == nil){
		NSLog(@"TabletModel/getColorForPen - ERROR: There is no NSColor for the given uniqueID in the dictionary");
		return nil;
	}
	
	return [penColors objectForKey:[uniqueID stringValue]];
}

@end
