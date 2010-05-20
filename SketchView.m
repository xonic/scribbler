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
		[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
		[theShadow set];
		
		// Draw our paths
		[[NSColor redColor] set];
		
		// Go through paths
		for (int i=0; i < [[model curvedPaths] count]; i++)
		{
			// Create a new path for performance reasons
			NSBezierPath *path = [[NSBezierPath alloc] init];
			
			// Move to first point without drawing
			[path moveToPoint:[[[[model curvedPaths] objectAtIndex:i] objectAtIndex:0] myNSPoint]];
			
			// Go through points
			for (int j=0; j < [[[model curvedPaths] objectAtIndex:i] count] - 4; j+=3)
			{
				[path curveToPoint:[[[[model curvedPaths] objectAtIndex:i] objectAtIndex:j+3] myNSPoint] 
					 controlPoint1:[[[[model curvedPaths] objectAtIndex:i] objectAtIndex:j+1] myNSPoint]
					 controlPoint2:[[[[model curvedPaths] objectAtIndex:i] objectAtIndex:j+2] myNSPoint]];
			}
			
			// Draw the path
			[path stroke];
			
			// Bye path
			[path release];
		}
		
		// if user is currently drawing - draw drawingpath
		if (isDrawing && !erase) {
			// Create a new path for performance reasons
			NSBezierPath *path = [[NSBezierPath alloc] init];
			
			// Move to first point without drawing
			[path moveToPoint:[[[model currentPath] objectAtIndex:0] myNSPoint]];
			
			// Go through points
			for (int i=1; i <[[model currentPath] count]; i++)
				[path lineToPoint:[[[model currentPath] objectAtIndex:i] myNSPoint]];
						
			// Draw the path
			[path stroke];
			
			// Bye path
			[path release];
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
