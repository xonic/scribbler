//
//  SketchModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 20.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "SketchModel.h"


@implementation SketchModel

@synthesize curvedPaths, currentPath;

- (id) initWithController:(SketchController *)theController andWindow:(MainWindow *)theWindow
{	
	if(![super init])
		return nil;
	
	[theController retain];
	controller = theController;
	[theWindow retain];
	window = theWindow;
	
	curvedPaths = [[NSMutableArray alloc] init];
	currentPath = [[NSMutableArray alloc] init];
	
	return self;
}

#pragma mark Create

- (void) createNewPathAt:(NSPoint)inputPoint
{
	currentPath = [[NSMutableArray alloc] init];
	[currentPath addObject:[[PointModel alloc] initWithNSPoint:inputPoint]];
}

- (void) addPointToCurrentPath:(NSPoint)inputPoint
{
	[currentPath addObject:[[PointModel alloc] initWithNSPoint:inputPoint]];
}

- (void) saveCurrentPath
{
	[currentPath retain];
	
	// Get a new hot'n fresh smooooooooth path
	NSMutableArray *newPath = [[NSMutableArray alloc] init];
	newPath = currentPath;
	
	// Setup the undo operation
	[[[window undoManager] prepareWithInvocationTarget:self] removePath:newPath];
	
	if(![[window undoManager] isUndoing])
		[[window undoManager] setActionName:@"Draw Path"];
	
	// Finally add the new path
	[curvedPaths addObject:newPath];
	[currentPath release];
}

#pragma mark Remove

- (void) removePath:(NSMutableArray *)path
{
	// Does the path really exist in our array?
	if(![curvedPaths containsObject:path]){
		NSLog(@"Trying to remove a path which is not in the array");
		return;
	}
	
	// Setup the redo operation
	[[[window undoManager] prepareWithInvocationTarget:self] saveCurrentPath];
	
	if(![[window undoManager] isUndoing])
		[[window undoManager] setActionName:@"Delete Path"];
	
	// Finally remove the path
	[curvedPaths removeObject:path];
}

- (void) removePathIntersectingWith:(NSPoint)inputPoint
{
	// Are there any paths?
	if([curvedPaths count] == 0)
		return;
	
	// Go through paths
	for (int i=0; i < [curvedPaths count]; i++)
	{
		// Go through points
		for (int j=0; j < [[curvedPaths objectAtIndex:i] count] - 3; j+=3)
		{
			// Set the tolerance range
			NSNumber * tolerance = [NSNumber numberWithDouble:20.0];
			
			if([[[curvedPaths objectAtIndex:i] objectAtIndex:j] isInRange:tolerance ofNSPoint:inputPoint]){
				[self removePath:[curvedPaths objectAtIndex:i]];
				break;
			}
		}
	}
}

#pragma mark Smooth

// Method takes an array of line points p0, p1,...pn and calculates the 
// needed control points for a bezier interpolation. The new array has 
// the format: p0, c00, c01, p1, c10, c11, p2, c20, c21, p3, c30, c31,...
// until ...pn, cn0, cn1
- (void) smoothCurrentPath
{
	// Check if path exists
	if (!currentPath) {
		NSLog(@"Method getCurveControlPoints: parameter edgyPath is nil! Aborting function.");
		return;
	}
	
	// Count the points of our path
	int n = [currentPath count] - 1;
	
	// Too few points
	if (n < 1) {
		NSLog(@"Method getCurveControlPoints: at least two points are needed! Aborting function.");
		return;
	}
	
	// Special case: Bezier curve should be a straight line
	if (n == 1) {
		// Calculate first control point
		NSPoint newPoint;
		newPoint.x = (2 * [[currentPath objectAtIndex:0] myNSPoint].x + [[currentPath objectAtIndex:1] myNSPoint].x) / 3;
		newPoint.y = (2 * [[currentPath objectAtIndex:0] myNSPoint].y + [[currentPath objectAtIndex:1] myNSPoint].y) / 3;
		
		// Create a new object to be added to path
		PointModel *newControlPoint = [[PointModel alloc] initWithNSPoint:newPoint];
		
		// Add the first control point to the array
		[currentPath insertObject:newControlPoint atIndex:1];
		
		// Calculate second control point
		NSPoint anotherNewPoint;
		anotherNewPoint.x = 2 * newPoint.x - [[currentPath objectAtIndex:0] myNSPoint].x;
		anotherNewPoint.y = 2 * newPoint.y - [[currentPath objectAtIndex:0] myNSPoint].y;
		
		// Create new object to be added to path
		PointModel *anotherNewControlPoint = [[PointModel alloc] initWithNSPoint:anotherNewPoint];
		
		// Add the second control point to array
		[currentPath insertObject:anotherNewControlPoint atIndex:2];
		
		return;
	}
	
	// Calculate first Bezier control points
	// Right hand side vector
	NSMutableArray *rhs = [[NSMutableArray alloc] init];
	
	// Set right hand side x values
	for (int i=1; i < n-1; ++i){
		
		// Calculate the new number 
		NSNumber *newRightHandX = [NSNumber numberWithDouble:4 * (double) [[currentPath objectAtIndex:i] myNSPoint].x + 
								   2 * (double) [[currentPath objectAtIndex:i+1] myNSPoint].x];
		// Add it to the array
		[rhs addObject:newRightHandX];
	}
	
	// Set the first element
	NSNumber *firstElementX = [NSNumber numberWithDouble:(double) [[currentPath objectAtIndex:0] myNSPoint].x +
							   2 * (double) [[currentPath objectAtIndex:1] myNSPoint].x];
	[rhs insertObject:firstElementX atIndex:0];
	
	// Set the last element
	NSNumber *lastElementX = [NSNumber numberWithDouble:(8 * (double) [[currentPath objectAtIndex:n-1] myNSPoint].x + 
														 (double) [[currentPath objectAtIndex:n] myNSPoint].x) / 2.0 ];
	[rhs addObject:lastElementX];
	
	// Get first control points x-values
	NSMutableArray *xPoints = [self getControlPoints:rhs];
	
	// Free rhs array for new values
	[rhs removeAllObjects];
	
	// Set right hand side y values
	for (int i=1; i < n-1; ++i){
		
		// Calculate the new number 
		NSNumber *newRightHandY = [NSNumber numberWithDouble:4 * (double) [[currentPath objectAtIndex:i] myNSPoint].y + 
								   2 * (double) [[currentPath objectAtIndex:i+1] myNSPoint].y];
		// Add it to the array
		[rhs addObject:newRightHandY];
	}
	
	// Set the first element
	NSNumber *firstElementY = [NSNumber numberWithDouble:(double) [[currentPath objectAtIndex:0] myNSPoint].y +
							   2 * (double) [[currentPath objectAtIndex:1] myNSPoint].y];
	[rhs insertObject:firstElementY atIndex:0];
	
	// Set the last element
	NSNumber *lastElementY = [NSNumber numberWithDouble:(8 * (double) [[currentPath objectAtIndex:n-1] myNSPoint].y + 
														 (double) [[currentPath objectAtIndex:n] myNSPoint].y) / 2.0];
	[rhs addObject:lastElementY];
	
	// Get first control points y-values
	NSMutableArray *yPoints = [self getControlPoints:rhs];
	
	// Set the new array size for the path holding also all control points
	int newArraySize = 3 * [currentPath count] - 2;
	
	// Auxiliary index variable
	int j = 0;
	
	// This loop goes i=0, i=3, i=6, etc. therefore we need an aux. index j=0, j=1 j=2, etc.
	for(int i=0; i<newArraySize; i+=3){
		
		// First control point
		PointModel *firstControlPoint = [[PointModel alloc] initWithDoubleX:[[xPoints objectAtIndex:j] doubleValue] andDoubleY:[[yPoints objectAtIndex:j] doubleValue]];
		
		// Insert after "real" point
		[currentPath insertObject:firstControlPoint atIndex:i+1];
		
		if(i < newArraySize-1){
			// Second control point
			double x = 2 * [[currentPath objectAtIndex:i+2] myNSPoint].x - [[xPoints objectAtIndex:j+1] doubleValue];
			double y = 2 * [[currentPath objectAtIndex:i+2] myNSPoint].y - [[yPoints objectAtIndex:j+1] doubleValue];
			
			PointModel *secondControlPoint = [[PointModel alloc] initWithDoubleX:x andDoubleY:y];
			
			// Insert after first control point
			[currentPath insertObject:secondControlPoint atIndex:i+2];
			
		} else {
			// Last control point
			double x = 2 * [[currentPath lastObject] myNSPoint].x + [[xPoints objectAtIndex:[xPoints count]-1] doubleValue];
			double y = 2 * [[currentPath lastObject] myNSPoint].y + [[yPoints objectAtIndex:[yPoints count]-1] doubleValue];
			
			PointModel *lastControlPoint = [[PointModel alloc] initWithDoubleX:x andDoubleY:y];
			
			[currentPath addObject:lastControlPoint];
		}
		// Increment auxiliary index
		if (j < [xPoints count] - 2)
			j++;
	}
}

- (NSMutableArray *) getControlPoints:(NSMutableArray *)rhs
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

#pragma mark Reposition

- (void) repositionPaths:(PointModel *)delta
{
	// duplicate paths
	NSMutableArray *repositionPaths = [[NSMutableArray alloc] initWithArray:curvedPaths];
	
	// Go through paths
	for (int i=0; i < [repositionPaths count]; i++)
		// Go through points
		for (int j=0; j < [[repositionPaths objectAtIndex:i] count]; j++)
			// add delta to each point
			[[[repositionPaths objectAtIndex:i] objectAtIndex:j] addDelta:[delta myNSPoint]];
	
	// retain changed paths
	[repositionPaths retain];	
	
	// override original paths with changed ones
	curvedPaths = repositionPaths;
}

- (void) dealloc 
{
	[curvedPaths release];
	[currentPath release];
	[controller release];
	[window release];
	[super dealloc];
}

@end
