//
//  ScribblerAppDelegate.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ScribblerAppDelegate.h"
#import "MainWindow.h"

@implementation ScribblerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	initialSwitchToKeyWindow = YES;
}

-(void)awakeFromNib{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setTitle:@"☆"];
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"Scribbler"];
	
	// Initialize Growl delegate
	[GrowlApplicationBridge setGrowlDelegate:self]; 
	
	[GrowlApplicationBridge notifyWithTitle:@"Scribbler"
								description:@"Initialized Growl Notifications" 
						   notificationName:@"Pen Mode"
								   iconData:nil
								   priority:1
								   isSticky:NO
							   clickContext:nil]; 
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

	if(initialSwitchToKeyWindow) {
		[self setInitialSwitchToKeyWindow:NO];
		[NSApp hide:self];
		[NSApp sendAction:@selector(firstResponder:) to:nil from:self];
		[[(MainWindow*)window controller] keyWindowHandler];
	}
}

- (NSDictionary*) registrationDictionaryForGrowl 
{ 
    NSArray* defaults = 
    [NSArray arrayWithObjects:@"Mouse Mode", @"Pen Mode", nil]; 
	
    NSArray* all = 
    [NSArray arrayWithObjects:@"Mouse Mode", @"Pen Mode", nil]; 
	
    NSDictionary* growlRegDict = [NSDictionary dictionaryWithObjectsAndKeys: 
								  defaults, GROWL_NOTIFICATIONS_DEFAULT,all, 
								  GROWL_NOTIFICATIONS_ALL, nil]; 
	
    return growlRegDict; 
}


@synthesize initialSwitchToKeyWindow;

@end
