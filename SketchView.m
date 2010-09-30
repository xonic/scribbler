//
//  SketchView.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SketchView.h"


@implementation SketchView

@synthesize sketchModel, draw, clickThrough, isDrawing, erase, keyWindow, drawWindowBounds, customCursor, drawMouseModeBounds;

- (id)initWithController:(SketchController *)theController 
		  andSketchModel:(SketchModel *)theSketchModel 
			 andTabModel:(SubWindowModel *)theTabModel
{
    if (![super initWithFrame:[[NSScreen mainScreen] frame]])
        return nil;
	
	if(theController == nil || theSketchModel == nil){
		NSLog(@"SketchView/initWithController:theController andSketchModel:theSketchModel andTabModel:theTabModel - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	// Setup the SketchModel
	sketchModel  = [theSketchModel retain];
	
	// Setup the TabModel
	if(theTabModel != nil)
		tabModel = [theTabModel	   retain];
	
	// Setup the Controller
	controller   = [theController  retain];
	
	// Get the key window bounds for our fabulous glow
	[self updateKeyWindowBounds];
	
	customCursor = [NSCursor crosshairCursor];
	theNormalCursor = [NSCursor arrowCursor];
	
	draw				= YES;
	clickThrough		= YES;
	isDrawing			=  NO;
	erase				=  NO;
	drawWindowBounds	=  NO;
	drawMouseModeBounds	=  NO;	
	
	if (theTabModel == nil) {
		// enable layer control
		[self setWantsLayer:YES];
		[[self layer] setAnchorPoint:CGPointMake(0.0, 0.0)];
		// get original view bounds and enlarge the height to paint the shadow
		NSRect oBounds = [self frame];
		[self setFrame:NSMakeRect(oBounds.origin.x, oBounds.origin.y, oBounds.size.width, oBounds.size.height+30)];
	}
	
    return self;
}

- (id)initWithController:(SketchController *)theController andTabModel:(SubWindowModel *)theTabModel
{
	if (![super initWithFrame:[[NSScreen mainScreen] frame]])
        return nil;
	
	if(theController == nil){
		NSLog(@"SketchView/initWithController:theController andTabModel:theTabModel - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	// Setup the SketchModel
	sketchModel  = [[SketchModel alloc] initWithController:theController andWindow:[theController mainWindow]];
	
	// Setup the TabModel
	if(theTabModel != nil)
		tabModel = [theTabModel	   retain];
	
	// Setup the Controller
	controller   = [theController  retain];
	
	// Get the key window bounds for our fabulous glow
	[self updateKeyWindowBounds];
	
	customCursor = [NSCursor crosshairCursor];
	theNormalCursor = [NSCursor arrowCursor];
	
	NSLog(@"origin.x = %f origin.y = %f width = %f height = %f sketchview init", keyWindow.origin.x, keyWindow.origin.y, keyWindow.size.width, keyWindow.size.height);
	draw				= YES;
	clickThrough		= YES;
	isDrawing			=  NO;
	erase				=  NO;
	drawWindowBounds	=  NO;
	drawMouseModeBounds	=  NO;
	
	if (theTabModel == nil) {
		// enable layer control
		//[self setWantsLayer:YES];
		[[self layer] setAnchorPoint:CGPointMake(0.0, 0.0)];
		// get original view bounds and enlarge the height to paint the shadow
		NSRect oBounds = [self frame];
		[self setFrame:NSMakeRect(oBounds.origin.x, oBounds.origin.y, oBounds.size.width, oBounds.size.height+30)];
	}
	
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	
	if([controller penIsNearTablet] && ![controller mouseMode])
		[customCursor set];
	else 
		[theNormalCursor set];
	
	if(draw) {
		
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
		
		// if tabModel = nil we've got the whiteBoard view:
		// so paint the view white
		if (tabModel==nil) {
			
			NSRect bounds = [self bounds];
			[[NSColor whiteColor] set];
			
			// create the shadow
			NSShadow *dropShadow = [[NSShadow alloc] init];
			[dropShadow setShadowColor:[NSColor blackColor]];
			[dropShadow setShadowBlurRadius:150];
			[dropShadow setShadowOffset:NSMakeSize(0,0)];
			
			// save graphics state
			[NSGraphicsContext saveGraphicsState];
			
			// set the stroke to 10px
			[NSBezierPath setDefaultLineWidth:10.0];
			// create the shadowPath			
			NSBezierPath *path = [[NSBezierPath alloc] init];
			[path moveToPoint:NSMakePoint(0, bounds.origin.y+30)];
			[path lineToPoint:NSMakePoint(bounds.size.width, bounds.origin.y+30)];
			// set the shadow
			[dropShadow set];
			// Draw the shadowPath
			[path stroke];
			
			// restore state
			[NSGraphicsContext restoreGraphicsState];
			
			// draw whiteboard
			[NSBezierPath fillRect:NSMakeRect(bounds.origin.x, bounds.origin.y+22, bounds.size.width, bounds.size.height)];
			
			// Bye stuff
			[path release];
			[dropShadow release];			
		}
		
		if(drawWindowBounds && ![controller isWhiteBoardVisible]){
			[NSBezierPath setDefaultLineWidth:5];
			[NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
			[[NSColor colorWithCalibratedRed:0.17 green:0.44 blue:0.96 alpha:1.0] set];
			[NSBezierPath strokeRect:keyWindow];		
			//[NSBezierPath setDefaultLineWidth:1];
		} 
		
		/*if(drawMouseModeBounds) {
		 [NSBezierPath setDefaultLineWidth:25];
		 [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
		 [[NSColor colorWithCalibratedRed:0.17 green:0.44 blue:0.96 alpha:0.3] set];
		 NSRect bounds = [[NSScreen mainScreen] frame];
		 bounds.size.height-=22;
		 NSLog(@"mouseModeBounds= %f,%f",bounds.size.width, bounds.size.height);
		 [NSBezierPath strokeRect:bounds];
		 }*/
		
		if(screenShotFlashAlpha>0.0) {
			NSRect bounds = [self bounds];
			[[[NSColor whiteColor] colorWithAlphaComponent:screenShotFlashAlpha] set];
			[NSBezierPath fillRect:bounds];			
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
	if([[controller activeWindow] loadAccessibilityData])
	{
		keyWindow = [[controller activeWindow] getWindowBounds];
		NSLog(@"keyWindow = accessibility");
	}
	else 
	{
		keyWindow = [controller getKeyWindowBounds:[controller getCurrentKeyWindowInfos]];
		NSLog(@"the man your man could smell like");
	}
	NSRect mainScreenFrame = [[NSScreen mainScreen] frame];
	keyWindow.origin.y = mainScreenFrame.size.height - (keyWindow.origin.y + keyWindow.size.height);
}

- (void)setScreenShotFlashAlpha:(double)value {
	screenShotFlashAlpha = value;
}

- (void)foldViewIn {
	NSRect viewRect = [self frame];
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
	anim.delegate = controller; //to get the animationDidStop:finished: message
	anim.fromValue = [NSValue valueWithPoint:NSMakePoint(viewRect.origin.x, viewRect.size.height)];
	anim.toValue = [NSValue valueWithPoint:NSMakePoint(viewRect.origin.x, viewRect.origin.y-22)];
	anim.fillMode = kCAFillModeForwards;
	[anim setValue:@"foldViewIn" forKey:@"animationType"];
	[anim setDuration:0.25];
	[[self layer] addAnimation:anim forKey:@"positionAnimation"];
	[self setFrame:NSMakeRect(viewRect.origin.x, viewRect.origin.y-22, viewRect.size.width, viewRect.size.height)];	
}

- (void)foldViewOut {
	NSRect viewRect = [self frame];
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
	anim.delegate = controller; //to get the animationDidStop:finished: message
	anim.fromValue = [NSValue valueWithPoint:NSMakePoint(viewRect.origin.x, viewRect.origin.y-22)];
	anim.toValue = [NSValue valueWithPoint:NSMakePoint(viewRect.origin.x, viewRect.size.height)];
	anim.fillMode = kCAFillModeForwards;
	anim.removedOnCompletion = NO;
	[anim setValue:@"foldViewOut" forKey:@"animationType"];
	[anim setDuration:0.25];	
	[[self layer] addAnimation:anim forKey:@"positionAnimation"];
	
	/*
	 CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
	 anim.delegate = controller; //to get the animationDidStop:finished: message
	 anim.fromValue= [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0, 1, 0, 0)];
	 float f = M_PI/2;
	 anim.toValue=[NSValue valueWithCATransform3D:CATransform3DMakeRotation(f, 1, 0, 0)];
	 anim.fillMode = kCAFillModeForwards;
	 anim.removedOnCompletion = NO;
	 [anim setValue:@"foldViewOut" forKey:@"animationType"];
	 [anim setDuration:0.25];	
	 [[self layer] addAnimation:anim forKey:@"zPositionAnimation"];*/
}

- (void)dealloc
{
	[sketchModel release];
	if(tabModel != nil)
		[tabModel release];
	[controller  release];
	[super       dealloc];
}

@end
