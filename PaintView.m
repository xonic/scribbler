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
	ovals = [[NSMutableArray alloc] init];
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
		
		// draw ovals from array
		[[NSColor redColor] set];
		int count = [ovals count];
		for(int i=0;i<count;i++) {
			[path appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:[[ovals objectAtIndex:i] rectValue]]];
		}
		[path stroke];
	
		// draw current dragged path
		currentPath = [[NSBezierPath alloc] init];
		[currentPath appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:[self currentRect]]];
		[currentPath stroke];
		[currentPath dealloc];
	}
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)event
{
	NSPoint p = [event locationInWindow];
	downPoint = [self convertPoint:p fromView:nil];
	currentPoint = downPoint;
	[self setNeedsDisplay:YES];
	NSLog(@"mouseDown");
}

- (void)mouseDragged:(NSEvent *)event
{
	NSPoint p = [event locationInWindow];
	currentPoint = [self convertPoint:p fromView:nil];
	[self autoscroll:event];
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	NSPoint p = [event locationInWindow];
	currentPoint = [self convertPoint:p fromView:nil];
	[ovals addObject:[NSValue valueWithRect:[self currentRect]]];
	[self setNeedsDisplay:YES];
}

- (NSRect)currentRect
{
	float minX = MIN(downPoint.x, currentPoint.x);
	float maxX = MAX(downPoint.x, currentPoint.x);
	float minY = MIN(downPoint.y, currentPoint.y);
	float maxY = MAX(downPoint.y, currentPoint.y);
	
	return NSMakeRect(minX, minY, maxX-minX, maxY-minY);
}

- (void)dealloc
{
	[ovals release];
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
