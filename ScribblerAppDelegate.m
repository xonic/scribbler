//
//  ScribblerAppDelegate.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ScribblerAppDelegate.h"

@implementation ScribblerAppDelegate

@synthesize window, glassPanes;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	glassPanes = [[NSMutableDictionary alloc] initWithCapacity:25];
	
	// Start watching global events to figure out when to show the pane	
	[NSEvent addGlobalMonitorForEventsMatchingMask:
	 (NSMouseMovedMask | NSKeyDownMask | NSTabletProximityMask | NSMouseEntered)
										   handler:^(NSEvent *incomingEvent) {
											   
											   if ([incomingEvent type] == NSTabletProximity) 
											   {
												   if([self checkIfPaneExists])
												   {
													   NSString *string = [NSString stringWithFormat:@"%d", [self getKeyWindowID:[self getCurrentKeyWindowInfos]]];
													   
													   [[glassPanes objectForKey:string] showGlassPane:[incomingEvent isEnteringProximity]];
												   } else {
													   GlassPane *newPane = [[GlassPane alloc] initWithContentRect:[[NSScreen mainScreen] frame] styleMask:NSBorderlessWindowMask backing:2 defer:NO];
													   NSString *string = [NSString stringWithFormat:@"%d", [self getKeyWindowID:[self getCurrentKeyWindowInfos]]];
													   [glassPanes setObject:newPane forKey:string];
													   [newPane release];
													   NSLog(@"newPane: %@", [glassPanes objectForKey:string]);
												   }

											   }
										   }]; 
	
	// Start watching local events to figure out when to hide the pane	
	[NSEvent addLocalMonitorForEventsMatchingMask:
	 (NSMouseMovedMask | NSKeyDownMask | NSTabletProximityMask)// | NSTabletPointMask)
										  handler:^(NSEvent *incomingEvent) {
											  
											  NSEvent *result = incomingEvent;
											  
											  //if ([incomingEvent type] == NSTabletProximity)
												  //[self showGlassPane:[incomingEvent isEnteringProximity]];
											  
											  //NSLog(@"Event id = %@", result);
											  return result;
										  }]; 
}

-(void)awakeFromNib{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setTitle:@"☆"];
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"Scribbler"];
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

- (NSInteger) getKeyWindowID: (NSMutableDictionary*)windowInfos
{
	return [[windowInfos objectForKey:(id)kCGWindowNumber] integerValue];
}

- (NSString*) getKeyWindowsApplicationName: (NSMutableDictionary*)windowInfos
{
	return [windowInfos objectForKey:(id)kCGWindowOwnerName];
}

- (NSRect *) getKeyWindowBounds: (NSMutableDictionary*) windowInfos
{
	return (NSRect *)&*([windowInfos objectForKey:(id)kCGWindowBounds]);
}

- (BOOL)checkIfPaneExists
{
	NSString *string = [NSString stringWithFormat:@"%d", [self getKeyWindowID:[self getCurrentKeyWindowInfos]]];
	if (![glassPanes objectForKey:string]) {
		NSLog(@"we need a new pane");
		return NO;
	} else {
		NSLog(@"pane exists");
		return YES;
	}

	
}

@end
