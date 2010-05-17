//
//  GlassPane.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GlassPane.h"

@implementation GlassPane

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:[[NSScreen mainScreen] frame] styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
	
    if (!self)
    {
		return nil;
    }
	
	[self setLevel:CGShieldingWindowLevel()];//NSFloatingWindowLevel];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	// uncomment next line to overrule OS menubars
	//[self setLevel:NSMainMenuWindowLevel + 1];
	
	// initialize Array for future keyWindowViews
	keyWindowViews = [[NSMutableDictionary alloc] init];
		
	// Start watching global events to figure out when to show the pane	
	[NSEvent addGlobalMonitorForEventsMatchingMask:
			(NSMouseMovedMask | NSKeyDownMask | NSTabletProximityMask | NSMouseEnteredMask | NSLeftMouseDownMask)
			handler:^(NSEvent *incomingEvent) {

				// The user pressed cmd+alt+ctrl+Z or the according tablet button
				if ([incomingEvent modifierFlags] == 1835305){
					NSLog(@"UNDO");
					[[screenView undoManager] undo];
					[screenView setNeedsDisplay:YES];
					return;
				} 
				// The user pressed shift+cmd+alt+ctrl+Z or the according tablet button
				else if ([incomingEvent modifierFlags] ==  1966379) {
					NSLog(@"REDO");
					[[screenView undoManager] redo];
					[screenView setNeedsDisplay:YES];
					return;
				}
				
				// if change of keyWindow happens (this could only happen with a mouseDown event)
				if ([incomingEvent type] == NSLeftMouseDown) {
					if ([incomingEvent subtype] != NSTabletPointEventSubtype && [incomingEvent subtype] != NSTabletProximityEventSubtype) {
						[self keyWindowHandler];
					}
				}
				
				// if tabletpen is near the tablet
				if ([incomingEvent type] == NSTabletProximity) {
					[self showGlassPane:[incomingEvent isEnteringProximity]];
					
					// Ignore the rest if pointing device exited proximity
					if([incomingEvent isEnteringProximity]){
					
						// Check whether the user is drawing or erasing
						if([incomingEvent pointingDeviceType] == NSEraserPointingDevice){
							NSLog(@"Found Eraser");
							[self getKeyWindowViewAndSetEraserTo:YES];
						} else {
							NSLog(@"Found Pen");
							[self getKeyWindowViewAndSetEraserTo:NO];
						}
					}
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
					[[screenView undoManager] undo];
					[screenView setNeedsDisplay:YES];
				} 
				// The user pressed shift+cmd+alt+ctrl+Z or the according tablet button
				else if ([incomingEvent modifierFlags] ==  1966379) {
					NSLog(@"REDO");
					[[screenView undoManager] redo];
					[screenView setNeedsDisplay:YES];
				}
				
				// if tabletpen is near the tablet
				if ([incomingEvent type] == NSTabletProximity){
					
					[self showGlassPane:[incomingEvent isEnteringProximity]];
					
					// Ignore the rest if pointing device exited proximity
					if([incomingEvent isEnteringProximity]){
					
						// Check whether the user is drawing or erasing
						if([incomingEvent pointingDeviceType] == NSEraserPointingDevice){
							NSLog(@"Found Eraser");
							[self getKeyWindowViewAndSetEraserTo:YES];
						} else {
							NSLog(@"Found Pen");
							[self getKeyWindowViewAndSetEraserTo:NO];
						}
					}
				}
				
				return result;
	}]; 
				
    return self;
}

- (void) showHide:(id)sender {
			
	if([screenView draw]) {
		// hide painting ability
		[screenView setDraw: NO];
		[screenView setNeedsDisplay:YES];
		
	}
	else {
		// show painting ability
		[screenView setDraw: YES];
		[screenView setNeedsDisplay:YES];
		//[self orderFrontRegardless];
	}
}

- (void) openFinder:(id)sender {
	[[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (void) showGlassPane:(BOOL)flag {
	NSLog(@"showGlassPane: %@",screenView);
	[screenView setClickThrough: !flag];
	[screenView setNeedsDisplay:YES];
	if(flag) {
		[self makeKeyAndOrderFront:nil];
		//NSLog(@"isKeyWindow=%d",[self isKeyWindow]);
	}
	
	NSLog(@"keyWindowID=%@",[self getKeyWindowID:[self getCurrentKeyWindowInfos]]);
	
}

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

- (NSRect *) getKeyWindowBounds: (NSMutableDictionary*) windowInfos
{
	return (NSRect *)&*([windowInfos objectForKey:(id)kCGWindowBounds]);
}

- (void) getKeyWindowViewAndSetEraserTo:(BOOL)value {
	// get keyWindowID
	NSNumber* keyID = [self getKeyWindowID:[self getCurrentKeyWindowInfos]];
	// Make sure the PaintView exists
	if(!screenView)
		return;
	if(value)
		NSLog(@"--- Setting Mode to 'Erase' on KeyWindow: %@ with ID: %@ ---", screenView, keyID);
	else 
		NSLog(@"--- Setting Mode to 'Draw' on KeyWindow: %@ with ID: %@ ---", screenView, keyID);
	[screenView setErase:value];
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
	if ([keyWindowViews objectForKey:keyID]==nil) {
		// add view for current keyWindow
		PaintView *newView = [[PaintView alloc] initWithFrame:[[NSScreen mainScreen] frame]];
		[keyWindowViews setObject:newView forKey:keyID];
		NSLog(@"added window %@ with id %@ to array",[keyWindowViews objectForKey:keyID],keyID);
		screenView = newView;
		[self setContentView:screenView];
	}
	else {
		// switch to other view
		screenView = [keyWindowViews objectForKey:keyID];
		[self setContentView:screenView];
		NSLog(@"in Array: switched to window %@ with id %@", screenView, keyID);
	}
}

- (void)dealloc
{
	[screenView release];
	[keyWindowViews release];
	[super dealloc];
}

@end
