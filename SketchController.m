//
//  SketchController.m
//  Scribbler
//
//  Created by Thomas Nägele on 20.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "SketchController.h"


@implementation SketchController

@synthesize activeSketchView, selectedColor, mainWindow;

- (id) initWithMainWindow:(MainWindow *)theMainWindow
{
	if(![super init])
		return nil;
	
	if(theMainWindow == nil){
		NSLog(@"SketchController/initWithMainWindow:theMainWindow - ERROR: theMainWindow was nil");
		[self release];
		return nil;
	}
	
	mainWindow = [theMainWindow retain];
	
	// Set the default Color to red
	selectedColor = [NSColor redColor];
	
	// initialize array for list of windows
	windowModelList = [[NSMutableDictionary alloc] init];
	
	// initialize point variables for capture dragging
	startDragPoint = [[PointModel alloc] initWithDoubleX:-1 andDoubleY:-1];
	endDragPoint	= [[PointModel alloc] initWithDoubleX:-1 andDoubleY:-1];
	
	erase = NO;
	
	
	
	// Start watching global events to figure out when to show the pane	
	[NSEvent addGlobalMonitorForEventsMatchingMask:
	 (NSLeftMouseDraggedMask | NSKeyDownMask | NSTabletProximityMask | NSMouseEnteredMask | NSLeftMouseDownMask | NSOtherMouseDownMask)
										   handler:^(NSEvent *incomingEvent) {
											   
											   // The user pressed cmd+alt+ctrl+Z or the according tablet button
											   if ([incomingEvent modifierFlags] == 1835305){
												   NSLog(@"UNDO");
												   [[mainWindow undoManager] undo];
												   [activeSketchView setNeedsDisplay:YES];
												   return;
											   } 
											   // The user pressed shift+cmd+alt+ctrl+Z or the according tablet button
											   else if ([incomingEvent modifierFlags] ==  1966379) {
												   NSLog(@"REDO");
												   [[mainWindow undoManager] redo];
												   [activeSketchView setNeedsDisplay:YES];
												   return;
											   }				
											   // if change of keyWindow happens (this could only happen with a mouseDown event)
											   if ([incomingEvent type] == NSLeftMouseDown) {
												   if ([incomingEvent subtype] != NSTabletPointEventSubtype && [incomingEvent subtype] != NSTabletProximityEventSubtype) {
													   [self keyWindowHandler];
												   }
												   
												   // save windowposition in case of dragging
												   [startDragPoint initWithNSPoint:[self getKeyWindowBounds:[self getCurrentKeyWindowInfos]].origin];
											   }
											   
											   // if tabletpen is near the tablet
											   if ([incomingEvent type] == NSTabletProximity) {
												   
												   [mainWindow showGlassPane:[incomingEvent isEnteringProximity]];
												   
												   // Ignore the rest if pointing device exited proximity
												   if([incomingEvent isEnteringProximity]){
													   
													   // Check whether the user is drawing or erasing
													   if([incomingEvent pointingDeviceType] == NSEraserPointingDevice){
														   NSLog(@"Found Eraser");
														   erase = YES;
														   [activeSketchView setErase:YES];
													   } else {
														   NSLog(@"Found Pen");
														   erase = NO;
														   [activeSketchView setErase:NO];
													   }
												   }
											   }
											   
											   if ([incomingEvent type] == NSLeftMouseDragged) {
												   // save current windowposition
												   [endDragPoint initWithNSPoint:[self getKeyWindowBounds:[self getCurrentKeyWindowInfos]].origin];
												   
												   // calculate delta offset from startdragpoint (=window position @mouseDown) to enddragpoint (=current windowposition)
												   PointModel *delta = [[PointModel alloc] initWithDoubleX:[endDragPoint x]-[startDragPoint x] andDoubleY:[endDragPoint y]-[startDragPoint y]];
												   // call function to reposition all paths with delta
												   [[activeSketchView sketchModel] repositionPaths:delta];

												   // reset startpoint
												   [startDragPoint initWithNSPoint:[endDragPoint myNSPoint]];
												   // repaint sketchView
												   [activeSketchView setNeedsDisplay:YES];
											   }
											   
											   
										   }]; 
	
	// Start watching local events to figure out when to hide the pane	
	[NSEvent addLocalMonitorForEventsMatchingMask:
	 (NSMouseMovedMask | NSKeyDownMask | NSTabletProximityMask)// | NSTabletPointMask)
										  handler:^(NSEvent *incomingEvent) {
											  
											  NSEvent *result = incomingEvent;
											  
											  // The user pressed cmd+alt+ctrl+Z or the according tablet button
											  if ([incomingEvent modifierFlags] == 1835305){
												  NSLog(@"UNDO");
												  [[mainWindow undoManager] undo];
												  [activeSketchView setNeedsDisplay:YES];
											  } 
											  // The user pressed shift+cmd+alt+ctrl+Z or the according tablet button
											  else if ([incomingEvent modifierFlags] ==  1966379) {
												  NSLog(@"REDO");
												  [[mainWindow undoManager] redo];
												  [activeSketchView setNeedsDisplay:YES];
											  }
											  
											  // if tabletpen is near the tablet
											  if ([incomingEvent type] == NSTabletProximity){
												  
												  //[self keyWindowHandler];
												  
												  [mainWindow showGlassPane:[incomingEvent isEnteringProximity]];
												  
												  // Ignore the rest if pointing device exited proximity
												  if([incomingEvent isEnteringProximity]){
													  
													  // Check whether the user is drawing or erasing
													  if([incomingEvent pointingDeviceType] == NSEraserPointingDevice){
														  NSLog(@"Found Eraser");
														  erase = YES;
														  [activeSketchView setErase:YES];
													  } else {
														  NSLog(@"Found Pen");
														  erase = NO;
														  [activeSketchView setErase:NO];
													  }
												  }
											  }
											  
											  return result;
										  }]; 
	[self keyWindowHandler];
    return self;	
}

#pragma mark Events

- (void) handleMouseDownAt:(NSPoint)inputPoint from:(SketchView *)sender
{
	// Drawing or Erasing?
	if (!erase){
		// Create a new Path
		[[sender sketchModel] createNewPathAt:inputPoint withColor:(NSColor *)selectedColor];
	} else {
		// Remove intersecting Path
		[[sender sketchModel] removePathIntersectingWith:inputPoint];
	}
	[sender setNeedsDisplay:YES];
}

- (void) handleMouseDraggedAt:(NSPoint)inputPoint from:(SketchView *)sender
{
	// Drawing or Erasing?
	if (!erase){
		// Continue current Path
		[[sender sketchModel] addPointToCurrentPath:inputPoint];
	} else {
		// Remove intersecting Path
		[[sender sketchModel] removePathIntersectingWith:inputPoint];
	}
	[sender setNeedsDisplay:YES];
}

- (void) handleMouseUpAt:(NSPoint)inputPoint from:(SketchView *)sender
{
	// Drawing or Erasing?
	if (!erase){
		// Conclude Path and save it
		[[sender sketchModel] addPointToCurrentPath:inputPoint];
		[[sender sketchModel] saveCurrentPath];
	} else {
		// Remove intersecting Path
		[[sender sketchModel] removePathIntersectingWith:inputPoint];
	}
	[sender setNeedsDisplay:YES];
}

#pragma mark SketchView Visibility

- (void) setClickThrough:(BOOL)flag
{
	[activeSketchView setClickThrough:flag];
	[activeSketchView setNeedsDisplay:YES];
}

- (void) showHide
{
	if ([activeSketchView draw]) {
		[activeSketchView setDraw:NO];
		[activeSketchView setNeedsDisplay:YES];
	} else {
		[activeSketchView setDraw:YES];
		[activeSketchView setNeedsDisplay:YES];
	}

}

#pragma mark KeyWindow Functions

- (NSMutableDictionary*)getCurrentKeyWindowInfos
{
	//get info about the currently active application
	NSWorkspace* workspace            = [NSWorkspace sharedWorkspace];
	NSDictionary* currentAppInfo      = [workspace activeApplication];
	
	//get the PSN of the current app
	UInt32 lowLong                    = [[currentAppInfo objectForKey:@"NSApplicationProcessSerialNumberLow"] longValue];
	UInt32 highLong                   = [[currentAppInfo objectForKey:@"NSApplicationProcessSerialNumberHigh"] longValue];
	ProcessSerialNumber currentAppPSN = {highLong,lowLong};
	
	//grab window information from the window server
	CFArrayRef windowList             = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
	ProcessSerialNumber myPSN         = {kNoProcess, kNoProcess};
	
	//loop through the windows, the window list is ordered from front to back
	for (NSMutableDictionary* entry in (NSArray*) windowList)
	{
		int pid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
		GetProcessForPID(pid, &myPSN);
		
		//if the process of the current window in the list matches our process, get the front window number
		if(myPSN.lowLongOfPSN == currentAppPSN.lowLongOfPSN && myPSN.highLongOfPSN == currentAppPSN.highLongOfPSN)
		{
			[entry retain]; 
			CFRelease(windowList);
			//return because we found front window
			return entry;
		}
	}
	
	return 0;
}

- (NSNumber*) getKeyWindowID: (NSMutableDictionary*)windowInfos
{
	return [windowInfos objectForKey:(id)kCGWindowNumber];
}

- (NSString*) getKeyWindowsApplicationName: (NSMutableDictionary*)windowInfos
{
	return [windowInfos objectForKey:(id)kCGWindowOwnerName];
}
/*
- (NSRect *) getKeyWindowBounds: (NSMutableDictionary*) windowInfos
{
	return (NSRect *)&*([windowInfos objectForKey:(id)kCGWindowBounds]);
}*/
- (NSRect) getKeyWindowBounds: (NSMutableDictionary*) windowInfos
{
	CGRect rect;
	CFDictionaryRef blab = (CFDictionaryRef)[windowInfos objectForKey:(id)kCGWindowBounds];
	CGRectMakeWithDictionaryRepresentation(blab,&rect);
	return (NSRect)rect;
}

- (void) keyWindowHandler
{
	NSLog(@"--- keyWindowHandler ---");
	
	// get keyWindowID
	NSNumber* keyID = [self getKeyWindowID:[self getCurrentKeyWindowInfos]];
	
	if (keyID == nil) {
		return;
	}
	
	// lookup if there is an arrayEntry for this ID
	if ([windowModelList objectForKey:keyID] == nil) {
	
		// create the new classes for the window
		SketchModel *newModel  = [[SketchModel alloc] initWithController:self andWindow:mainWindow];
		WindowModel *newWindow = [[WindowModel alloc] initWithController:self];
		
		// the view is being created by the TabModel itself
		// so we just query the view from the model
		SketchView  *newView   = [[[newWindow activeTab] view] retain];
		
		// add to our list
		[windowModelList setObject:newWindow forKey:keyID];
		
		NSLog(@"added window %@ with id %@ to array",[windowModelList objectForKey:keyID],keyID);
		NSLog(@"we have now %d windows in our windowModelList", [windowModelList count]);
		
		// set as active
		activeSketchView = [newView retain];
		[mainWindow setContentView:activeSketchView];
		
		// free your mind... uhm... memory
		[newModel  release];
		[newView   release];
		[newWindow release];
	}
	else {
		// switch to other view
		activeSketchView = [[[windowModelList objectForKey:keyID] activeTab] view];
		[mainWindow setContentView:activeSketchView];
		NSLog(@"in Array: switched to window %@ with id %@", activeSketchView, keyID);
	}
	
	[keyID release];
}

@end
