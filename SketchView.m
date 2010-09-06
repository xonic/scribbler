//
//  SketchView.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SketchView.h"


@implementation SketchView

@synthesize sketchModel, draw, clickThrough, isDrawing, erase, keyWindow, drawWindowBounds, flushScreen;

- (id)initWithController:(SketchController *)theController 
		  andSketchModel:(SketchModel *)theSketchModel 
			 andTabModel:(SubWindowModel *)theTabModel
{
    if (![super initWithFrame:[[NSScreen mainScreen] frame]])
        return nil;
	
	if(theController == nil || theSketchModel == nil || theTabModel == nil){
		NSLog(@"SketchView/initWithController:theController andSketchModel:theSketchModel andTabModel:theTabModel - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	// Setup the SketchModel
	sketchModel  = [theSketchModel retain];
	
	// Setup the TabModel
	tabModel     = [theTabModel	   retain];
	
	// Setup the Controller
	controller   = [theController  retain];
	
	keyWindow = [controller getKeyWindowBounds:[controller getCurrentKeyWindowInfos]];
	
	NSRect mainScreenFrame = [[NSScreen mainScreen] frame];
	keyWindow.origin.y = mainScreenFrame.size.height - (keyWindow.origin.y + keyWindow.size.height);
	
	draw			 = YES;
	clickThrough	 = YES;
	isDrawing		 =  NO;
	erase			 =  NO;
	drawWindowBounds =  NO;	
	flushScreen		 =  NO;
		
    return self;
}

- (id)initWithController:(SketchController *)theController andTabModel:(SubWindowModel *)theTabModel
{
	if (![super initWithFrame:[[NSScreen mainScreen] frame]])
        return nil;
	
	if(theController == nil || theTabModel == nil){
		NSLog(@"SketchView/initWithController:theController andTabModel:theTabModel - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	// Setup the SketchModel
	sketchModel  = [[SketchModel alloc] initWithController:theController andWindow:[theController mainWindow]];
	
	// Setup the TabModel
	tabModel     = [theTabModel	   retain];
	
	// Setup the Controller
	controller   = [theController  retain];
	
	keyWindow = [controller getKeyWindowBounds:[controller getCurrentKeyWindowInfos]];
	
	NSRect mainScreenFrame = [[NSScreen mainScreen] frame];
	keyWindow.origin.y = mainScreenFrame.size.height - (keyWindow.origin.y + keyWindow.size.height);
	
	NSLog(@"origin.x = %f origin.y = %f width = %f height = %f sketchview init", keyWindow.origin.x, keyWindow.origin.y, keyWindow.size.width, keyWindow.size.height);
	draw			 = YES;
	clickThrough	 = YES;
	isDrawing		 =  NO;
	erase			 =  NO;
	drawWindowBounds =  NO;
	flushScreen		 =  NO;
	
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
   	
	if(draw) {
		
		if (flushScreen) {
			NSRect bounds = [self bounds];
			[[NSColor clearColor] set];
			[NSBezierPath fillRect:bounds];
			return;
		}
		if(!clickThrough) {
			NSRect bounds = [self bounds];
			[[[NSColor grayColor] colorWithAlphaComponent:0.05] set];
			[NSBezierPath fillRect:bounds];
		}
		else {
			NSRect bounds = [self bounds];
			[[NSColor clearColor] set];
			[NSBezierPath fillRect:bounds];
		}
		
		if(drawWindowBounds){
			[NSBezierPath setDefaultLineWidth:5];
			[NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
			[[NSColor colorWithCalibratedRed:0.17 green:0.44 blue:0.96 alpha:1.0] set];
			[NSBezierPath strokeRect:keyWindow];		
			//[NSBezierPath setDefaultLineWidth:1];
		} 
		[NSBezierPath setDefaultLineWidth:2.5];
		NSArray *smoothedPaths = [sketchModel smoothedPaths];
		
		for (id pathModel in smoothedPaths){
			[[pathModel	color] set];
			[[(PathModel *)pathModel path] stroke];
		}
		
		
		// if user is currently drawing - draw drawingpath
		if (isDrawing && !erase) {
			
			// Get the Color
			NSColor *theColor = [sketchModel getColorOfPath:[sketchModel currentPath]];
			
			// Get the points
			NSArray *thePoints = [sketchModel getPointsOfPath:[sketchModel currentPath]];
			
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
		}
	}
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)event
{
	// TODO: check for special cases i.e. click on a scrollbar etc.
	if ([event subtype] == NSTabletPointEventSubtype || [event subtype] == NSTabletProximityEventSubtype) {
		isDrawing = YES;
		[controller handleMouseDownAt:[self convertPoint:[event locationInWindow] fromView:nil] from:self];
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	// TODO: check for special cases i.e. drag on a scrollbar etc.
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

- (void)updateKeyWindowBounds
{
	keyWindow = [controller getKeyWindowBounds:[controller getCurrentKeyWindowInfos]];
	
	NSRect mainScreenFrame = [[NSScreen mainScreen] frame];
	keyWindow.origin.y = mainScreenFrame.size.height - (keyWindow.origin.y + keyWindow.size.height);
	return;
}

- (void)dealloc
{
	[sketchModel release];
	[tabModel    release];
	[controller  release];
	[super       dealloc];
}

@end
