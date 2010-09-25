//
//  SketchModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 20.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "SketchModel.h"


@implementation SketchModel

@synthesize currentPath, smoothedPaths, undoManagers;

- (id) initWithController:(SketchController *)theController andWindow:(MainWindow *)theWindow
{	
	if(![super init])
		return nil;
	
	if(theController == nil || theWindow == nil){
		NSLog(@"SketchModel/initWithController:theController andWindow:theWindow - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	controller	  = [theController  retain];
	window		  = [theWindow	    retain];
	
	smoothedPaths = [[NSMutableArray alloc] init];
	currentPath   = [[NSMutableArray alloc] init];
	
	undoManagers   = [[NSMutableDictionary alloc] init];
	
	return self;
}

#pragma mark Create

- (void) createNewPathAt:(NSPoint)inputPoint withColor:(NSColor *)theColor
{
	currentPath  = [[NSMutableArray alloc] init];
	
	// Save the color as first element in our array
	[currentPath addObject:theColor];
	
	[currentPath addObject:[[PointModel alloc] initWithNSPoint:inputPoint]];
}

- (void) addPointToCurrentPath:(NSPoint)inputPoint
{
	[currentPath addObject:[[PointModel alloc] initWithNSPoint:inputPoint]];
}

- (void) saveCurrentPathWithOwner:(NSNumber *)tabletID
{
	[self smoothCurrentPath];

	NSBezierPath *newPath = [[[NSBezierPath alloc] init] autorelease];

	int pointCount = [currentPath count]-4;
	
	[newPath moveToPoint:[[currentPath objectAtIndex:1] myNSPoint]];
	
	for (int j=1; j < pointCount; j+=3)
	{
		[newPath curveToPoint: [[currentPath objectAtIndex:j+3] myNSPoint] 
				 controlPoint1:[[currentPath objectAtIndex:j+1] myNSPoint]
				 controlPoint2:[[currentPath objectAtIndex:j+2] myNSPoint]];
	}
	
	PathModel *newPathModel = [[PathModel alloc] initWithPath:newPath andColor:[currentPath objectAtIndex:0]];
	[newPathModel setCreationDate:[NSDate date]];
	[newPathModel setOwner:tabletID];
	
	NSLog(@"saved path at %@ - owner: %d", [newPathModel creationDate], [newPathModel owner]);
	
	// Check if an undoManager exists for this tablet
	if([undoManagers objectForKey:[tabletID stringValue]])
	{
		// Register the new path for undo operation
		[[undoManagers objectForKey:[tabletID stringValue]] registerDrawForPath:newPathModel];
		
	}
	else // create a new undoManager
	{
		UndoManager *newUndoManager = [[UndoManager alloc] initWithSketchModel:self andTabletID:tabletID];
		
		// Register the new path for undo operation
		[newUndoManager registerDrawForPath:newPathModel];
		
		// Save it into our dictionary
		[undoManagers setObject:newUndoManager forKey:[tabletID stringValue]];
		
		// bye
		[newUndoManager release];
	}
	
	[smoothedPaths addObject:newPathModel];
	
	[newPathModel release];
}

#pragma mark Remove

- (void) removePathIntersectingWith:(NSPoint)inputPoint forTablet:(NSNumber *)activeTabletID
{	
	for(id obj in smoothedPaths){
		if([[(PathModel *)obj path] containsPoint:inputPoint]){
			
			// Check if an undoManager exists
			if([undoManagers objectForKey:[activeTabletID stringValue]])
			{
				// Register the erasing operation for undo
				[[undoManagers objectForKey:[activeTabletID stringValue]] registerEraseForPath:(PathModel *)obj];
			}
			else // create a new undoManager
			{
				UndoManager *newUndoManager = [[UndoManager alloc] initWithSketchModel:self andTabletID:activeTabletID];
				
				// Register the erasing operation for undo
				[newUndoManager registerEraseForPath:(PathModel *)obj];
				
				// Save it to our dictionary
				[undoManagers setObject:newUndoManager forKey:[activeTabletID stringValue]];
				
				// bye
				[newUndoManager release];
			}
			
			[smoothedPaths removeObject:(PathModel *)obj];
		}
	}
}

- (void)removeAllPathsForTablet:(NSNumber *)activeTabletID
{
	
	NSMutableArray *backup = [smoothedPaths copy];
	
	// Check if an undoManager exists
	if([undoManagers objectForKey:[activeTabletID stringValue]])
	{
		// Register the erasing operation for undo
		[[undoManagers objectForKey:[activeTabletID stringValue]] registerEraseForAllPathModels:backup];
	}
	else // create a new undoManager
	{
		UndoManager *newUndoManager = [[UndoManager alloc] initWithSketchModel:self andTabletID:activeTabletID];
		
		// Register the erasing operation for undo
		[newUndoManager registerEraseForAllPathModels:backup];
		
		// Save it to our dictionary
		[undoManagers setObject:newUndoManager forKey:[activeTabletID stringValue]];
		
		// bye
		[newUndoManager release];
	}
	[backup release];
	[smoothedPaths removeAllObjects];
}

- (void)removeAllSmoothedPaths
{
	[smoothedPaths removeAllObjects];
}

#pragma mark Undo/Redo 

- (void)undoForTablet:(NSNumber *)tabletID
{
	if([undoManagers objectForKey:[tabletID stringValue]])
	{
		[[undoManagers objectForKey:[tabletID stringValue]] undo];
	}
	else 
	{
		NSLog(@"No undoManager found");
	}
}

- (void)redoForTablet:(NSNumber *)tabletID
{
	if([undoManagers objectForKey:[tabletID stringValue]])
	{
		[[undoManagers objectForKey:[tabletID stringValue]] redo];
	}
	else 
	{
		NSLog(@"No undoManager found");
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
	int n = [currentPath count] - 2;
	
	// Too few points
	if (n < 1) {
		NSLog(@"Method getCurveControlPoints: at least two points are needed! Aborting function.");
		return;
	}
	
	// Special case: Bezier curve should be a straight line
	if (n == 1) {
		// Calculate first control point
		NSPoint newPoint;
		newPoint.x = (2 * [[currentPath objectAtIndex:1] myNSPoint].x + [[currentPath objectAtIndex:2] myNSPoint].x) / 3;
		newPoint.y = (2 * [[currentPath objectAtIndex:1] myNSPoint].y + [[currentPath objectAtIndex:2] myNSPoint].y) / 3;
		
		// Create a new object to be added to path
		PointModel *newControlPoint = [[PointModel alloc] initWithNSPoint:newPoint];
		
		// Add the first control point to the array
		[currentPath insertObject:newControlPoint atIndex:2];
		
		// Calculate second control point
		NSPoint anotherNewPoint;
		anotherNewPoint.x = 2 * newPoint.x - [[currentPath objectAtIndex:1] myNSPoint].x;
		anotherNewPoint.y = 2 * newPoint.y - [[currentPath objectAtIndex:1] myNSPoint].y;
		
		// Create new object to be added to path
		PointModel *anotherNewControlPoint = [[PointModel alloc] initWithNSPoint:anotherNewPoint];
		
		// Add the second control point to array
		[currentPath insertObject:anotherNewControlPoint atIndex:3];
		
		return;
	}
	
	// Calculate first Bezier control points
	// Right hand side vector
	NSMutableArray *rhs = [[NSMutableArray alloc] init];
	
	// Set right hand side x values
	for (int i=1; i < n-1; ++i){
		
		// Calculate the new number 
		NSNumber *newRightHandX = [NSNumber numberWithDouble:4 * (double) [[currentPath objectAtIndex:i+1] myNSPoint].x + 
								   2 * (double) [[currentPath objectAtIndex:i+2] myNSPoint].x];
		// Add it to the array
		[rhs addObject:newRightHandX];
	}
	
	// Set the first element
	NSNumber *firstElementX = [NSNumber numberWithDouble:(double) [[currentPath objectAtIndex:1] myNSPoint].x +
							   2 * (double) [[currentPath objectAtIndex:2] myNSPoint].x];
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
		NSNumber *newRightHandY = [NSNumber numberWithDouble:4 * (double) [[currentPath objectAtIndex:i+1] myNSPoint].y + 
								   2 * (double) [[currentPath objectAtIndex:i+2] myNSPoint].y];
		// Add it to the array
		[rhs addObject:newRightHandY];
	}
	
	// Set the first element
	NSNumber *firstElementY = [NSNumber numberWithDouble:(double) [[currentPath objectAtIndex:1] myNSPoint].y +
							   2 * (double) [[currentPath objectAtIndex:2] myNSPoint].y];
	[rhs insertObject:firstElementY atIndex:0];
	
	// Set the last element
	NSNumber *lastElementY = [NSNumber numberWithDouble:(8 * (double) [[currentPath objectAtIndex:n-1] myNSPoint].y + 
														 (double) [[currentPath objectAtIndex:n] myNSPoint].y) / 2.0];
	[rhs addObject:lastElementY];
	
	// Get first control points y-values
	NSMutableArray *yPoints = [self getControlPoints:rhs];
	
	// Set the new array size for the path holding also all control points
	int newArraySize = 3 * ([currentPath count] - 1) - 2;
	
	// Auxiliary index variable
	int j = 0;
	
	// This loop goes i=0, i=3, i=6, etc. therefore we need an aux. index j=0, j=1 j=2, etc.
	for(int i=1; i<newArraySize; i+=3){
		
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
	// setup the transformation
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:[delta x] yBy:-[delta y]];
	
	// go through paths
	for(id pathModel in smoothedPaths)
	{
		[[(PathModel *)pathModel path] transformUsingAffineTransform:transform];
	}
}

- (NSArray *) getPointsOfPath:(NSMutableArray *)thePath
{
	NSRange theRange;
	theRange.location = 1;
	theRange.length   = [thePath count] - 1;
	
	return [thePath subarrayWithRange:theRange];
}

- (NSColor *) getColorOfPath:(NSMutableArray *)thePath
{
	return [thePath objectAtIndex:0];
}

- (void) dealloc 
{
	[currentPath release];
	[controller release];
	[undoManagers release];
	[window release];
	[super dealloc];
}

@end
