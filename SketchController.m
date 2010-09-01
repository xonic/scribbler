//
//  SketchController.m
//  Scribbler
//
//  Created by Thomas Nägele on 20.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "SketchController.h"

id refToSelf; // declaration of a reference to self - to access class functions in outter c methods

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
	
	// setup our color palette
	colorPalette = [[ColorController alloc] init];
	
	// setup our known tablets list
	tablets = [[NSMutableDictionary alloc] init];
	
	// Set the default Color to red
	selectedColor = [NSColor colorWithDeviceHue:0 saturation:1 brightness:1 alpha:1];
	
	// initialize array for list of windows
	windowModelList = [[NSMutableDictionary alloc] init];
	
	// initialize point variables for capture dragging
	startDragPoint = [[PointModel alloc] initWithDoubleX:-1 andDoubleY:-1];
	endDragPoint   = [[PointModel alloc] initWithDoubleX:-1 andDoubleY:-1];
	
	erase = NO;
	
	mouseMode = NO;
	penIsNearTablet = NO;
	
	// Start watching global events to figure out when to show the pane	
	[NSEvent addGlobalMonitorForEventsMatchingMask:
	 (NSLeftMouseDraggedMask | NSKeyDownMask | NSKeyUpMask | NSTabletProximityMask | NSMouseEnteredMask | NSLeftMouseDownMask | NSRightMouseDown | NSOtherMouseDownMask)
										   handler:^(NSEvent *incomingEvent) {
											   
											   // Check whether the pen is near the tablet
											   if ([incomingEvent type] == NSTabletProximity) {
												   penIsNearTablet = [incomingEvent isEnteringProximity];
											   }
											   
											   // If the user clicks the right mouse button, save a screen shot
											   if([incomingEvent type] == NSRightMouseDown){
												   if ([mainWindow isVisible]) {
													   ScreenShotController *screenGrabber = [[ScreenShotController alloc] init];
													   [screenGrabber grabScreenShot];
													   [screenGrabber release];
													   return;
												   } else {
													   [mainWindow showGlassPane:YES];
													   ScreenShotController *screenGrabber = [[ScreenShotController alloc] init];
													   [screenGrabber grabScreenShot];
													   [screenGrabber release];
													   [mainWindow showGlassPane:NO];
													   return;
												   }

											   }
											   
											   // key Events
											   if([incomingEvent type] == NSKeyDown || [incomingEvent type] == NSKeyUp){
												   // The user pressed cmd+shift+f7 or the according tablet button
												   if(((([incomingEvent modifierFlags] & NSCommandKeyMask) && 
														([incomingEvent modifierFlags] & NSShiftKeyMask)) && 
														([incomingEvent keyCode] == 10)) &&
														([incomingEvent type] == NSKeyDown)){
													   
													   if ([mainWindow isVisible]) {
														   [mainWindow showGlassPane:NO];
													   }
													   mouseMode = YES;
												   } 
												   
													// The user released cmd+shift+f7 or the according tablet button
												   if(((([incomingEvent modifierFlags] & NSCommandKeyMask) && 
														([incomingEvent modifierFlags] & NSShiftKeyMask)) && 
														([incomingEvent keyCode] == 10)) &&
														([incomingEvent type] == NSKeyUp)){
													   
													   if (penIsNearTablet) {
														   [mainWindow showGlassPane:YES];
													   }
													   mouseMode = NO;   
												   }
												   
												   // The user pressed cmd+alt+ctrl+Z or the according tablet button
												   if ([incomingEvent modifierFlags] == 1835305 && [incomingEvent keyCode] == 16){
													   NSLog(@"UNDO");
													   [[mainWindow undoManager] undo];
													   [activeSketchView setNeedsDisplay:YES];
													   return;
												   } 
												   // The user pressed shift+cmd+alt+ctrl+Z or the according tablet button
												   else if ([incomingEvent modifierFlags] ==  1966379 && [incomingEvent keyCode] == 16) {
													   NSLog(@"REDO");
													   [[mainWindow undoManager] redo];
													   [activeSketchView setNeedsDisplay:YES];
													   return;
												   }
											   }
												   /*
											   NSLog(@"----------------------- GLOBAL");
											   NSLog(@"the event type is %d", [incomingEvent type]);
											   if([incomingEvent type] == NSKeyDown || [incomingEvent type] == NSKeyUp)
												   NSLog(@"modifierFlags: %d, keycode: %d", [incomingEvent modifierFlags], [incomingEvent keyCode]);
											   if(mouseMode)
												   NSLog(@"mouseMode = YES");
											   else  
												   NSLog(@"mouseMode = NO");
											   NSLog(@"------------------------------");
											   NSLog(@"");
*/
											  				
											   // if change of keyWindow happens (this could only happen with a mouseDown event)
											   if ([incomingEvent type] == NSLeftMouseDown) {
												   //if ([incomingEvent subtype] != NSTabletPointEventSubtype && [incomingEvent subtype] != NSTabletProximityEventSubtype) {
													   [self keyWindowHandler];
												   //}
												   
												   // save windowposition in case of dragging
												   [startDragPoint initWithNSPoint:[self getKeyWindowBounds:[self getCurrentKeyWindowInfos]].origin];
												   
												   // TODO Accessibility testen
												   NSLog(@"mouseDown");
												   
												   AXUIElementRef _systemWideElement;
												   AXUIElementRef _focusedApp;
												   CFTypeRef _focusedWindow;
												   CFTypeRef _position;
												   CFTypeRef _size;												   
												   
												   _systemWideElement = AXUIElementCreateSystemWide();

												   //Get the app that has the focus
												   AXUIElementCopyAttributeValue(_systemWideElement,
																				 (CFStringRef)kAXFocusedApplicationAttribute,
																				 (CFTypeRef*)&_focusedApp);
												   
												   //Get the window that has the focus
												   if(AXUIElementCopyAttributeValue((AXUIElementRef)_focusedApp,
																					(CFStringRef)NSAccessibilityFocusedWindowAttribute,
																					(CFTypeRef*)&_focusedWindow) == kAXErrorSuccess) {
													   
													   if(CFGetTypeID(_focusedWindow) == AXUIElementGetTypeID()) {
														   //Get the Window's Current Position
														   if(AXUIElementCopyAttributeValue((AXUIElementRef)_focusedWindow,
																							(CFStringRef)NSAccessibilityPositionAttribute,
																							(CFTypeRef*)&_position) != kAXErrorSuccess) {
															   NSLog(@"Can't Retrieve Window Position");
														   }
														   //Get the Window's Current Size
														   if(AXUIElementCopyAttributeValue((AXUIElementRef)_focusedWindow,
																							(CFStringRef)NSAccessibilitySizeAttribute,
																							(CFTypeRef*)&_size) != kAXErrorSuccess) {
															   NSLog(@"Can't Retrieve Window Size");
														   }
													   }
												   }else {
													   NSLog(@"Problem with App");
												   }
												   
												   //NSLog(@"position=%@ size=%@",_position, _size);
												   
											   }
											   
											   // if tabletpen is near the tablet
											   if ([incomingEvent type] == NSTabletProximity && !mouseMode) {

												   [mainWindow showGlassPane:[incomingEvent isEnteringProximity]];
												   
												   // Ignore the rest if pointing device exited proximity
												   if([incomingEvent isEnteringProximity]){
													   
													   NSLog(@"the tablet id is: %d", [incomingEvent systemTabletID]);
													   //NSLog(@"the pointer unique id is: %d", [incomingEvent uniqueID]);
													   
													   // check for tablet and pen id
													   NSNumber *theTabletID = [NSNumber numberWithInt:[incomingEvent systemTabletID]];
													   NSNumber *thePenID	 = [NSNumber numberWithInt:[incomingEvent uniqueID]];
													   
													   // this is a new tablet, create an object for it
													   if([tablets objectForKey:[theTabletID stringValue]] == nil)
													   {
														   TabletModel *newTablet = [[TabletModel alloc] initWithTabletID:theTabletID andColor:[colorPalette getColorFromPalette]];
														   [tablets setObject:newTablet forKey:[theTabletID stringValue]];
														   
														   [newTablet release];
													   }
													   
													   // the pen is new to the tablet, register it
													   if (![[tablets objectForKey:[theTabletID stringValue]] isPenRegistered:thePenID]) 
														   [[tablets objectForKey:[theTabletID stringValue]] registerPen:thePenID];
													   
													   // finally get the color for the pen
													   selectedColor = [[tablets objectForKey:[theTabletID stringValue]] getColorForPen:thePenID];
													   
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
												   
												   NSMutableDictionary *keyWindowInfos = [self getCurrentKeyWindowInfos];
												   [activeSketchView setKeyWindow:[self getKeyWindowBounds:keyWindowInfos]];
												   [activeSketchView invertKeyWindowBoundsYAxis];
												   
												   // repaint sketchView
												   [activeSketchView setNeedsDisplay:YES];
											   }
											   
											   
										   }]; 
	
	// Start watching local events to figure out when to hide the pane	
	[NSEvent addLocalMonitorForEventsMatchingMask:
	 (NSRightMouseDownMask | NSMouseMovedMask | NSKeyDownMask | NSKeyUpMask | NSTabletProximityMask)// | NSTabletPointMask)
										  handler:^(NSEvent *incomingEvent) {
											  
											  NSEvent *result = incomingEvent;
											  
											  // Check whether the pen is near the tablet
											  if ([incomingEvent type] == NSTabletProximity) {
												  penIsNearTablet = [incomingEvent isEnteringProximity];
											  }											  
											  												
											  // If the user clicks the right mouse button, save a screen shot
											  if([incomingEvent type] == NSRightMouseDown){
												  if ([mainWindow isVisible]) {
													  ScreenShotController *screenGrabber = [[ScreenShotController alloc] init];
													  [screenGrabber grabScreenShot];
													  [screenGrabber release];
													  return result;
												  } else {
													  [mainWindow showGlassPane:YES];
													  ScreenShotController *screenGrabber = [[ScreenShotController alloc] init];
													  [screenGrabber grabScreenShot];
													  [screenGrabber release];
													  [mainWindow showGlassPane:NO];
													  return result;
												  }
												  
											  }
											  
											  // key Events
											  if([incomingEvent type] == NSKeyDown || [incomingEvent type] == NSKeyUp){
												  // The user pressed cmd+shift+f7 or the according tablet button
												  if(((([incomingEvent modifierFlags] & NSCommandKeyMask) && 
													   ([incomingEvent modifierFlags] & NSShiftKeyMask)) && 
													   ([incomingEvent keyCode] == 10)) &&
													   ([incomingEvent type] == NSKeyDown)){
													  
													  if ([mainWindow isVisible]) {
														  [mainWindow showGlassPane:NO];
													  }
													  mouseMode = YES;
												  } 
												  
												  // The user released cmd+shift+f7 or the according tablet button
												  if(((([incomingEvent modifierFlags] & NSCommandKeyMask) && 
													   ([incomingEvent modifierFlags] & NSShiftKeyMask)) && 
													   ([incomingEvent keyCode] == 10)) &&
													   ([incomingEvent type] == NSKeyUp)){
													  
													  if (penIsNearTablet) {
														  [mainWindow showGlassPane:YES];
													  }
													  mouseMode = NO;   
												  }
												  
												  // The user pressed cmd+alt+ctrl+Z or the according tablet button
												  if ([incomingEvent modifierFlags] == 1835305 && [incomingEvent keyCode] == 16){
													  NSLog(@"UNDO");
													  [[mainWindow undoManager] undo];
													  [activeSketchView setNeedsDisplay:YES];
												  } 
												  // The user pressed shift+cmd+alt+ctrl+Z or the according tablet button
												  else if ([incomingEvent modifierFlags] ==  1966379 && [incomingEvent keyCode] == 16) {
													  NSLog(@"REDO");
													  [[mainWindow undoManager] redo];
													  [activeSketchView setNeedsDisplay:YES];
												  }
											  }
											  /*
											  NSLog(@"------------------------ LOCAL");
											  NSLog(@"the event type is %d", [incomingEvent type]);
											  if([incomingEvent type] == NSKeyDown || [incomingEvent type] == NSKeyUp)
												  NSLog(@"modifierFlags: %d, keycode: %d", [incomingEvent modifierFlags], [incomingEvent keyCode]);
											  if(mouseMode)
												  NSLog(@"mouseMode = YES");
											  else  
												  NSLog(@"mouseMode = NO");
											  NSLog(@"------------------------------");
											  NSLog(@"");
											  */
											  
											  
											  // if tabletpen is near the tablet
											  if ([incomingEvent type] == NSTabletProximity && !mouseMode){
												  
												  //[self keyWindowHandler];

												  [mainWindow showGlassPane:[incomingEvent isEnteringProximity]];
												  
												  // Ignore the rest if pointing device exited proximity
												  if([incomingEvent isEnteringProximity]){
													  
													  NSLog(@"the tablet id is: %d", [incomingEvent systemTabletID]);
													  //NSLog(@"the pointer unique id is: %d", [incomingEvent uniqueID]);
													  
													  // check for tablet and pen id
													  NSNumber *theTabletID = [NSNumber numberWithInt:[incomingEvent systemTabletID]];
													  NSNumber *thePenID	 = [NSNumber numberWithInt:[incomingEvent uniqueID]];
													  
													  // this is a new tablet, create an object for it
													  if([tablets objectForKey:[theTabletID stringValue]] == nil)
													  {
														  TabletModel *newTablet = [[TabletModel alloc] initWithTabletID:theTabletID andColor:[colorPalette getColorFromPalette]];
														  [tablets setObject:newTablet forKey:[theTabletID stringValue]];
													  }
													  
													  // the pen is new to the tablet, register it
													  if (![[tablets objectForKey:[theTabletID stringValue]] isPenRegistered:thePenID]) 
														  [[tablets objectForKey:[theTabletID stringValue]] registerPen:thePenID];
													  
													  // finally get the color for the pen
													  selectedColor = [[tablets objectForKey:[theTabletID stringValue]] getColorForPen:thePenID];
													  
													  // Check whether the user is drawing or erasing
													  if([incomingEvent pointingDeviceType] == NSEraserPointingDevice){
														  //NSLog(@"Found Eraser");
														  erase = YES;
														  [activeSketchView setErase:YES];
													  } else {
														  //NSLog(@"Found Pen");
														  erase = NO;
														  [activeSketchView setErase:NO];
													  }
												  }
											  }
	
											  return result;
										  }]; 
	
	
	// start the notificationCenter to catch windowActivation Events
	[[[NSWorkspace sharedWorkspace]
	 notificationCenter] addObserver:self	 
							selector:@selector(anAppWasActivated:)
								name:nil 
							  object:nil];
	
	// save reference from self
	refToSelf = self;
	
	return self;	
}

#pragma mark Events

- (void) handleMouseDownAt:(NSPoint)inputPoint from:(SketchView *)sender
{
	// Drawing or Erasing?
	if (!erase){
		// Create a new Path
		[[sender sketchModel] createNewPathAt:inputPoint withColor:selectedColor];
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
	return [NSNumber numberWithInt:[[windowInfos objectForKey:(id)kCGWindowNumber] intValue]];
}

- (int) getProcessID: (NSMutableDictionary*)windowInfos
{
	return [[windowInfos objectForKey:(id)kCGWindowOwnerPID] intValue];
}

- (NSString*) getKeyWindowsApplicationName: (NSMutableDictionary*)windowInfos
{
	return [windowInfos objectForKey:(id)kCGWindowOwnerName];
}

- (NSRect) getKeyWindowBounds: (NSMutableDictionary*) windowInfos
{
	CGRect rect;
	CFDictionaryRef ref = (CFDictionaryRef)[windowInfos objectForKey:(id)kCGWindowBounds];
	CGRectMakeWithDictionaryRepresentation(ref, &rect);
	
	return (NSRect)rect;
}

- (void) keyWindowHandler
{
	//NSLog(@"--- keyWindowHandler ---");
	
	// get current key window infos
	NSMutableDictionary* currentInfos = [self getCurrentKeyWindowInfos];
	// get keyWindowID
	NSNumber* keyID = [self getKeyWindowID:currentInfos];
	// get processID
	int pid = [self getProcessID:currentInfos];
	
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
		
		//NSLog(@"added window %@ with id %@ to array",[windowModelList objectForKey:keyID],keyID);
		//NSLog(@"we have now %d windows in our windowModelList", [windowModelList count]);
		
		// set as active
		activeSketchView = [newView retain];
		[mainWindow setContentView:activeSketchView];
		
		// register keyWindow for accessibility notifications (to get notifications even if the user switch to another window via exposé)
		[self registerForAccessibilityEvents:pid];
		
		// free your mind... uhm... memory
		[newModel  release];
		[newView   release];
		[newWindow release];
	}
	else {
		// switch to other view

		if (activeSketchView != [[[windowModelList objectForKey:keyID] activeTab] view]) {
			activeSketchView = [[[windowModelList objectForKey:keyID] activeTab] view];
			[mainWindow setContentView:activeSketchView];
			//NSLog(@"in Array: switched to window %@ with id %@", activeSketchView, keyID);
			//[keyID release];
		}
		
	}
}

- (void)anAppWasActivated:(NSNotification *)notification
{
	// if an other application was activated (eg. via exposé or appSwitcher)
	if ([[notification name] isEqualToString:@"NSWorkspaceDidActivateApplicationNotification"]) {
		// call keyWindowHandler, but only if it wasn't scribbler itself which was activated
		if( ![[self getKeyWindowsApplicationName: [self getCurrentKeyWindowInfos]] isEqualToString:[[NSRunningApplication currentApplication] localizedName]] )
			[self keyWindowHandler];
	}
}

- (void) registerForAccessibilityEvents:(int) pid {
	// pid can be NULL(0) if the application is only in dock (minimized or inactive)
	// and application was reached via the appSwitcher
	if (pid!=0) {
		AXUIElementRef sys = AXUIElementCreateApplication(pid);
		AXError err;
		AXObserverRef observer;
		err = AXObserverCreate (pid, callback, &observer);
		err = AXObserverAddNotification(observer, sys, kAXFocusedWindowChangedNotification, NULL);
		CFRunLoopAddSource ([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
	}
	
	// TODO: if an app was reached via the appSwitcher but is only in dock - a view is created for the dock
	//		 how should scribbler handle the situation in order to ensure user satisfaction?
	// NOTE: offer feedback to user with a short visual notification to which window the user will be drawing. eg. showing
	//		 windowBounds for a second with fadeout when proximity event occurs (only first time after keyWindow has changed)
}

@end


static void callback (AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon)
{
	[refToSelf anAppWasActivated:[NSNotification notificationWithName:@"NSWorkspaceDidActivateApplicationNotification" 
														  object:refToSelf 
														userInfo:nil]];
}
