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
	myPaths				= [[NSMutableArray alloc] init];
	firstControlPoints  = [[NSMutableArray alloc] init];
	secondControlPoints = [[NSMutableArray alloc] init];
	path				= [[NSBezierPath alloc] init];
	
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
		for (int i=0; i < [myPaths count]; i++)
		{
			// Create a new path for performance reasons
			path = [[NSBezierPath alloc] init];
			
			// Move to first point without drawing
			[path moveToPoint:[[[myPaths objectAtIndex:i] objectAtIndex:0] myNSPoint]];
			
			// Go through points
			for (int j=0; j < [[myPaths objectAtIndex:i] count] - 4; j+=3)
			{
				[path curveToPoint:[[[myPaths objectAtIndex:i] objectAtIndex:j+3] myNSPoint] 
					 controlPoint1:[[[myPaths objectAtIndex:i] objectAtIndex:j+1] myNSPoint]
					 controlPoint2:[[[myPaths objectAtIndex:i] objectAtIndex:j+2] myNSPoint]];
			}
			// Draw the path
			[path stroke];
			
			// Bye path
			[path release];
		}
		
		// if user is currently drawing - draw drawingpath
		if (isDrawing) {
			// Create a new path for performance reasons
			path = [[NSBezierPath alloc] init];
			
			// Move to first point without drawing
			[path moveToPoint:[[myPoints objectAtIndex:0] myNSPoint]];
			
			// Go through points
			for (int i=1; i <[myPoints count]; i++)
				[path lineToPoint:[[myPoints objectAtIndex:i] myNSPoint]];
			
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
		// Create a new array for the points of our line
		myPoints = [[NSMutableArray alloc] init];
		
		if(erase){
			isDrawing = NO;
			// Erase Path
			[self erasePath:[self convertPoint:[event locationInWindow] fromView:nil]];
		} else {
			isDrawing = YES;
			// Get the point, convert it, make it a MyPoint object and add it to the current path
			[myPoints addObject:[[MyPoint alloc] initWithNSPoint:[self convertPoint:[event locationInWindow] fromView:nil]]];
		}
	
		[self setNeedsDisplay:YES];
		NSLog(@"mouseDown");
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	if ([event subtype] == NSTabletPointEventSubtype || [event subtype] == NSTabletProximityEventSubtype) {

		if(erase){
			// Erase Path
			[self erasePath:[self convertPoint:[event locationInWindow] fromView:nil]];
		} else {
			// Get the point, convert it, make it a MyPoint object and add it to the current path
			[myPoints addObject:[[MyPoint alloc] initWithNSPoint:[self convertPoint:[event locationInWindow] fromView:nil]]];
		}	
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if ([event subtype] == NSTabletPointEventSubtype || [event subtype] == NSTabletProximityEventSubtype) {

		if(erase){
			// The user stopped drawing
			isDrawing = NO;
			// Erase Path
			[self erasePath:[self convertPoint:[event locationInWindow] fromView:nil]];
		} else {
			// The user stopped drawing
			isDrawing = NO;
			// Get the point, convert it, make it a MyPoint object and add it to the current path
			[myPoints addObject:[[MyPoint alloc] initWithNSPoint:[self convertPoint:[event locationInWindow] fromView:nil]]];
			
			// Curve the path and add it to the others
			[self insertObjectInMyPaths:[self getCurveControlPoints:myPoints]];
			//[myPaths addObject: [self getCurveControlPoints: myPoints]];
		}
		
		[self setNeedsDisplay:YES];
		NSLog(@"mouseUp");
	}
}

// Method takes an array of line points p0, p1,...pn and calculates the 
// needed control points for a bezier interpolation. The new array has 
// the format: p0, c00, c01, p1, c10, c11, p2, c20, c21, p3, c30, c31,...
// until ...pn, cn0, cn1
- (NSMutableArray *) getCurveControlPoints:(NSMutableArray *)pathToBeEdited
{
	// Check if path exists
	if (!pathToBeEdited) {
		NSLog(@"Method getCurveControlPoints: parameter pathToBeEdited is nil! Aborting function.");
		return nil;
	}
	
	// Count the points of our path
	int n = [pathToBeEdited count] - 1;
	
	// Too few points
	if (n < 1) {
		NSLog(@"Method getCurveControlPoints: at least two points are needed! Aborting function.");
		return nil;
	}
	
	// Special case: Bezier curve should be a straight line
	if (n == 1) {
		// Calculate first control point
		NSPoint newPoint;
				newPoint.x = (2 * [[pathToBeEdited objectAtIndex:0] myNSPoint].x + [[pathToBeEdited objectAtIndex:1] myNSPoint].x) / 3;
				newPoint.y = (2 * [[pathToBeEdited objectAtIndex:0] myNSPoint].y + [[pathToBeEdited objectAtIndex:1] myNSPoint].y) / 3;
		
		// Create a new object to be added to path
		MyPoint *newControlPoint = [[MyPoint alloc] initWithNSPoint:newPoint];
		
		// Add the first control point to the array
		[pathToBeEdited insertObject:newControlPoint atIndex:1];
		
		// Calculate second control point
		NSPoint anotherNewPoint;
				anotherNewPoint.x = 2 * newPoint.x - [[pathToBeEdited objectAtIndex:0] myNSPoint].x;
				anotherNewPoint.y = 2 * newPoint.y - [[pathToBeEdited objectAtIndex:0] myNSPoint].y;
		
		// Create new object to be added to path
		MyPoint *anotherNewControlPoint = [[MyPoint alloc] initWithNSPoint:anotherNewPoint];
		
		// Add the second control point to array
		[pathToBeEdited insertObject:anotherNewControlPoint atIndex:2];
		
		// Gief back!
		return pathToBeEdited;
	}
	
	// Calculate first Bezier control points
	// Right hand side vector
	NSMutableArray *rhs = [[NSMutableArray alloc] init];
	
	// Set right hand side x values
	for (int i=1; i < n-1; ++i){
		
		// Calculate the new number 
		NSNumber *newRightHandX = [NSNumber numberWithDouble:4 * (double) [[pathToBeEdited objectAtIndex:i] myNSPoint].x + 
														 2 * (double) [[pathToBeEdited objectAtIndex:i+1] myNSPoint].x];
		// Add it to the array
		[rhs addObject:newRightHandX];
	}
	
	// Set the first element
	NSNumber *firstElementX = [NSNumber numberWithDouble:(double) [[pathToBeEdited objectAtIndex:0] myNSPoint].x +
												 2 * (double) [[pathToBeEdited objectAtIndex:1] myNSPoint].x];
	[rhs insertObject:firstElementX atIndex:0];
	
	// Set the last element
	NSNumber *lastElementX = [NSNumber numberWithDouble:(8 * (double) [[pathToBeEdited objectAtIndex:n-1] myNSPoint].x + 
														 (double) [[pathToBeEdited objectAtIndex:n] myNSPoint].x) / 2.0 ];
	[rhs addObject:lastElementX];
	
	// Get first control points x-values
	NSMutableArray *xPoints = [self getFirstControlPoints:rhs];
	
	// Free rhs array for new values
	[rhs removeAllObjects];
	
	// Set right hand side y values
	for (int i=1; i < n-1; ++i){
		
		// Calculate the new number 
		NSNumber *newRightHandY = [NSNumber numberWithDouble:4 * (double) [[pathToBeEdited objectAtIndex:i] myNSPoint].y + 
															 2 * (double) [[pathToBeEdited objectAtIndex:i+1] myNSPoint].y];
		// Add it to the array
		[rhs addObject:newRightHandY];
	}
	
	// Set the first element
	NSNumber *firstElementY = [NSNumber numberWithDouble:(double) [[pathToBeEdited objectAtIndex:0] myNSPoint].y +
													 2 * (double) [[pathToBeEdited objectAtIndex:1] myNSPoint].y];
	[rhs insertObject:firstElementY atIndex:0];
	
	// Set the last element
	NSNumber *lastElementY = [NSNumber numberWithDouble:(8 * (double) [[pathToBeEdited objectAtIndex:n-1] myNSPoint].y + 
															 (double) [[pathToBeEdited objectAtIndex:n] myNSPoint].y) / 2.0];
	[rhs addObject:lastElementY];
	
	// Get first control points y-values
	NSMutableArray *yPoints = [self getFirstControlPoints:rhs];
	
	// Set the new array size for the path holding also all control points
	int newArraySize = 3 * [pathToBeEdited count] - 2;
	
	// Auxiliary index variable
	int j = 0;
	
	// This loop goes i=0, i=3, i=6, etc. therefore we need an aux. index j=0, j=1 j=2, etc.
	for(int i=0; i<newArraySize; i+=3){
		
		// First control point
		MyPoint *firstControlPoint = [[MyPoint alloc] initWithDoubleX:[[xPoints objectAtIndex:j] doubleValue] Y:[[yPoints objectAtIndex:j] doubleValue]];
		
		// Insert after "real" point
		[pathToBeEdited insertObject:firstControlPoint atIndex:i+1];
		
		if(i < newArraySize-1){
			// Second control point
			double x = 2 * [[pathToBeEdited objectAtIndex:i+2] myNSPoint].x - [[xPoints objectAtIndex:j+1] doubleValue];
			double y = 2 * [[pathToBeEdited objectAtIndex:i+2] myNSPoint].y - [[yPoints objectAtIndex:j+1] doubleValue];
			
			MyPoint *secondControlPoint = [[MyPoint alloc] initWithDoubleX:x Y:y];
			
			// Insert after first control point
			[pathToBeEdited insertObject:secondControlPoint atIndex:i+2];
			
		} else {
			// Last control point
			double x = 2 * [[pathToBeEdited lastObject] myNSPoint].x + [[xPoints objectAtIndex:[xPoints count]-1] doubleValue];
			double y = 2 * [[pathToBeEdited lastObject] myNSPoint].y + [[yPoints objectAtIndex:[yPoints count]-1] doubleValue];
			
			MyPoint *lastControlPoint = [[MyPoint alloc] initWithDoubleX:x Y:y];
			
			[pathToBeEdited addObject:lastControlPoint];
		}
		// Increment auxiliary index
		if (j < [xPoints count] - 2)
			j++;
	}
	
	// Gief back!
	return pathToBeEdited;
}

- (NSMutableArray *) getFirstControlPoints:(NSMutableArray *)rhs
{
	int n = [rhs count];
	
	double x[n];
	double tmp[n];
	
	double b = 2.0;
	x[0] = [[rhs objectAtIndex:0] doubleValue] / b;
	
	for (int i=1; i<n; i++){
		tmp[i] = 1 / b;
		b = (i < n-1 ? 4.0 : 3.5) - tmp[i];
		x[i] = ([[rhs objectAtIndex:i] doubleValue] - x[i-1]) / b;
	}
	for (int i=1; i<n; i++){
		x[n-i-1] -= tmp[n-i] * x[n-i]; 
	}
	NSMutableArray *vector = [[NSMutableArray alloc] init];
	
	for(int i=0; i<n; i++){
		NSNumber *tmpNumber = [NSNumber numberWithDouble:x[i]];
		[vector addObject:tmpNumber];
		[tmpNumber release];
	}
	return vector;
}

- (void)erasePath:(NSPoint)point
{
	
	// Go through paths
	for (int i=0; i < [myPaths count]; i++)
	{
		// Go through points
		for (int j=0; j < [[myPaths objectAtIndex:i] count] - 3; j+=3)
		{
			//double distance = sqrt((pow((double)([[[myPaths objectAtIndex:i] objectAtIndex:j] myNSPoint].x - [[[myPaths objectAtIndex:i] objectAtIndex:j+3] myNSPoint].x), 2.0) + 
			//						pow((double)([[[myPaths objectAtIndex:i] objectAtIndex:j] myNSPoint].y - [[[myPaths objectAtIndex:i] objectAtIndex:j+3] myNSPoint].y), 2.0)));
			
			// Set the tolerance range
			NSNumber * tolerance = [NSNumber numberWithDouble:20.0]; // [NSNumber numberWithDouble:(distance / 10)];
			
			//NSLog(@"Distance = %f", distance);
			if([[[myPaths objectAtIndex:i] objectAtIndex:j] isInRange:tolerance ofNSPoint:point]){
				[self removeObjectFromMyPaths:[myPaths objectAtIndex:i]];
				//[myPaths removeObjectAtIndex:i];
				break;
			}
		}
	}
}

- (void) insertObjectInMyPaths:(id)newPath
{
	//NSLog(@"adding %@ to %@", newPath, myPaths);
	
	// Setup undo manager
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromMyPaths:newPath];
	
	if(![undo isUndoing])
		[undo setActionName:@"Draw Path"];

	// Finally add the new path
	[myPaths addObject:newPath];
	
}

- (void) removeObjectFromMyPaths:(id)existingPath
{
	//NSLog(@"removing %@ from %@", existingPath, myPaths);
	
	// Setup undo manager
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertObjectInMyPaths:existingPath];
	
	if(![undo isUndoing])
		[undo setActionName:@"Delete Path"];
	
	// Finally remove the path
	[myPaths removeObject:existingPath];
}

- (void)dealloc
{
	[mainWindow release];
	[firstControlPoints release];
	[secondControlPoints release];
	[myPaths release];
	[myPoints release];
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

@synthesize draw, clickThrough, isDrawing, erase;

@end
