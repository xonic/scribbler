//
//  PaintView.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PaintView.h"


@implementation PaintView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
	
	// alloc Arrays
	myPaths = [[NSMutableArray alloc] init];
	path = [[NSBezierPath alloc] init];
	
	draw = YES;
	clickThrough = YES;
			
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
		
		// Draw our paths
		[[NSColor redColor] set];
		
		// Go through paths
		for (int i=0; i < [myPaths count]; i++)
		{
			// Create a new path for performance reasons
			path = [[NSBezierPath alloc] init];
			
			// Move to first point without drawing
			[path moveToPoint:[[[myPaths objectAtIndex:i] objectAtIndex:0] myNSPoint]];
			
			// Go through points
			for (int j=0; j < [[myPaths objectAtIndex:i] count] - 1; j++)
			{
				[path lineToPoint:[[[myPaths objectAtIndex:i] objectAtIndex:j+1] myNSPoint]];
			}
			// Draw the path
			[path stroke];
			
			// Bye path
			[path release];
		}
	}
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)event
{
	// Create a new array for the points of our line
	myPoints = [[NSMutableArray alloc] init];
	
	// Add the new array to our list of paths
	[myPaths addObject:myPoints];
	
	// Get the mouse point and convert location
	NSPoint p = [event locationInWindow];
	downPoint = [self convertPoint:p fromView:nil];
	
	// Create a new MyPoint object
	currentPoint = [[MyPoint alloc] initWithNSPoint:downPoint];
		
	// Add the converted point to the list of points for active path
	[myPoints addObject:currentPoint];
	
	[self setNeedsDisplay:YES];
	NSLog(@"mouseDown");
}

- (void)mouseDragged:(NSEvent *)event
{
	// Get the next mouse point and convert location 
	NSPoint p = [event locationInWindow];
	downPoint = [self convertPoint:p fromView:nil];
	
	// Create a new MyPoint object
	currentPoint = [[MyPoint alloc] initWithNSPoint:downPoint];
	
	// Add the converted point to the list of points for active path
	[myPoints addObject:currentPoint];
	
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	// Get the last mouse point and convert location
	NSPoint p = [event locationInWindow];
	downPoint = [self convertPoint:p fromView:nil];
	
	// Create a new MyPoint object
	currentPoint = [[MyPoint alloc] initWithNSPoint:downPoint];
	
	// Add the converted point to the list of points for active path
	[myPoints addObject:currentPoint];

	[self setNeedsDisplay:YES];
}

- (void)dealloc
{
	[myPaths release];
	[myPoints release];
	[currentPoint release];
	[path release];
	[super dealloc];
}

- (BOOL) acceptsFirstResponder
{
	return YES;
} 

- (BOOL) canBecomeKeyWindow
{
	return YES;
}

@synthesize draw;
@synthesize clickThrough;

@end
