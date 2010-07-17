//
//  PaintView.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SketchView.h"


@implementation SketchView

@synthesize model, draw, clickThrough, isDrawing, erase;

- (id)initWithController:(SketchController *)theController andModel:(SketchModel *)theModel
{
    if (![super initWithFrame:[[NSScreen mainScreen] frame]])
        return nil;
	
	// Setup the Model
	[theModel retain];
	model = theModel;
	
	// Setup the Controller
	[theController retain];
	controller = theController;
	
	draw				= YES;
	clickThrough		= YES;
	isDrawing			= NO;
	erase				= NO;
		
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
   	
	if(draw) {
		if(!clickThrough) {
			NSRect bounds = [self bounds];
			[[NSColor colorWithCalibratedWhite:1.0 alpha:0.05] set];
			[NSBezierPath fillRect:bounds];
		}
		else {
			NSRect bounds = [self bounds];
			[[NSColor clearColor] set];
			[NSBezierPath fillRect:bounds];
		}
		
		[NSGraphicsContext saveGraphicsState];
		
		// Create the shadow below and to the right of the shape.
		NSShadow* theShadow = [[NSShadow alloc] init];
		[theShadow setShadowOffset:NSMakeSize(1.8, -1.8)];
		[theShadow setShadowBlurRadius:2.0];
		
		// Use a partially transparent color for shapes that overlap.
		[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.1]];
		[theShadow set];
		/*
		NSDictionary *colorsAndPaths = [[NSDictionary alloc] init];
					  colorsAndPaths = [model smoothedPaths];
		
		NSArray	*paths = [[NSArray alloc] init];
				 paths = [[model smoothedPaths] allKeys];
		*/
		
		NSArray *smoothedPaths = [model smoothedPaths];
		
		for (id pathModel in smoothedPaths){
			[[pathModel	color] set];
			[[pathModel path]  stroke];
		}
		
		
		// if user is currently drawing - draw drawingpath
		if (isDrawing && !erase) {
			
			// Get the Color
			NSColor *theColor = [model getColorOfPath:[model currentPath]];
			
			// Get the points
			NSArray *thePoints = [model getPointsOfPath:[model currentPath]];
			
			// Create a new path for performance reasons
			NSBezierPath *path = [[NSBezierPath alloc] init];
			
			// Set the color
			[theColor set];
			
			// Move to first point without drawing
			[path moveToPoint:[[thePoints objectAtIndex:0] myNSPoint]];
			
			int pointCount = [thePoints count];
			
			// Go through points
			for (int i=0; i < pointCount; i++)
				[path lineToPoint:[[thePoints objectAtIndex:i] myNSPoint]];
						
			// Draw the path
			[path stroke];
			
			// Bye stuff
			[path release];
			[theColor release];
		}
		
		[NSGraphicsContext restoreGraphicsState];
		[theShadow release];
	}
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)event
{
	if ([event subtype] == NSTabletPointEventSubtype || [event subtype] == NSTabletProximityEventSubtype) {
		isDrawing = YES;
		[controller handleMouseDownAt:[self convertPoint:[event locationInWindow] fromView:nil] from:self];
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	if ([event subtype] == NSTabletPointEventSubtype || [event subtype] == NSTabletProximityEventSubtype) {
		[controller handleMouseDraggedAt:[self convertPoint:[event locationInWindow] fromView:nil] from:self];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if ([event subtype] == NSTabletPointEventSubtype || [event subtype] == NSTabletProximityEventSubtype) {
		isDrawing = NO;
		[controller handleMouseUpAt:[self convertPoint:[event locationInWindow] fromView:nil] from:self];
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
} 

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)dealloc
{
	[mainWindow release];
	[model release];
	[controller release];
	[super dealloc];
}

@end
