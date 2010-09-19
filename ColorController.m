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
	pointerColors	 = [[NSMutableDictionary alloc] init];
	returnColorIndex = 0;
	
	currentXMLTag	 = [[NSString alloc] init];
	currentPointerID = [[NSNumber alloc] init];
	currentRedComponent = [[NSNumber alloc] init];
	currentGreenComponent = [[NSNumber alloc] init];
	currentBlueComponent = [[NSNumber alloc] init];
	
	CGFloat steps = 1.0;
	
	for(int i=0; i<12; i++){
		
		NSColor * aColor = [NSColor colorWithDeviceHue:steps saturation:(CGFloat)1.0 brightness:(CGFloat)1.0 alpha:(CGFloat)1.0];
		[colorPalette addObject:aColor];
		//NSLog(@"ColorController: hue: %f, sat: %f, brightness: %f, alpha: %f", [aColor hueComponent], [aColor saturationComponent], [aColor brightnessComponent], [aColor alphaComponent]);
		//NSLog(@"ColorController: created color with id: %d", aColor);
		steps -= 0.06;
	}
	
	[self loadColors];

	return self;
}

- (NSColor *)getColorFromPalette
{
	returnColorIndex += 3;
	returnColorIndex = returnColorIndex % 12;
	
	return [colorPalette objectAtIndex:returnColorIndex];
}

- (NSColor *)getColorForPointerID:(NSNumber *)uniqueID
{
	return [[pointerColors objectForKey:[uniqueID stringValue]] color];
}

- (void)loadColors
{

	NSString *file = [[NSBundle mainBundle] pathForResource:@"pointerColors" ofType:@"xml"];
	NSURL *furl = [NSURL fileURLWithPath:file];
	if (!furl) {
		NSLog(@"Can't create an URL from file %@.", file);
		return;
	}
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:furl];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	//the parser found an XML tag and is giving you some information about it
	//what are you going to do?
	
	// save the name of the active element
	[currentXMLTag release];
	currentXMLTag = [[NSString alloc] initWithString:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//the parser found some characters inbetween an opening and closing tag
	//what are you going to do?
	
	if ([currentXMLTag isEqualToString:@"uniqueID"]) {
		
		[currentPointerID release];
		currentPointerID = [[NSNumber alloc] initWithLongLong:[string longLongValue]];
	}
	
	if ([currentXMLTag isEqualToString:@"red"]) {
		
		[currentRedComponent release];
		currentRedComponent = [[NSNumber alloc] initWithFloat:[string floatValue] / 255.0];
	}
	
	if ([currentXMLTag isEqualToString:@"green"]) {
		
		[currentGreenComponent release];
		currentGreenComponent = [[NSNumber alloc] initWithFloat:[string floatValue] / 255.0];
	}
	
	if ([currentXMLTag isEqualToString:@"blue"]) {
		
		[currentBlueComponent release];
		currentBlueComponent = [[NSNumber alloc] initWithFloat:[string floatValue] / 255.0];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"pointer"]) {
		
		PointerModel *newPointer = [[PointerModel alloc] initWithUniqueID:currentPointerID 
																 andColor:[NSColor colorWithCalibratedRed:[currentRedComponent floatValue] 
																									green:[currentGreenComponent floatValue]
																									 blue:[currentBlueComponent floatValue]
																									alpha:1.0]];
		[pointerColors setObject:newPointer forKey:[currentPointerID stringValue]];
		
		[newPointer release];
	}
}

@end
