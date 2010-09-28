//
//  ScribblerAppDelegate.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ScribblerAppDelegate.h"
#import "MainWindow.h"
#import <Carbon/Carbon.h>

@implementation ScribblerAppDelegate

@synthesize window, initialSwitchToKeyWindow;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	initialSwitchToKeyWindow = YES;
	RunApplicationEventLoop();
}

-(void)awakeFromNib{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setTitle:@"☆"];
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"Scribbler"];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

	if(initialSwitchToKeyWindow) {
		[self setInitialSwitchToKeyWindow:NO];
		[NSApp hide:self];
		[NSApp sendAction:@selector(firstResponder:) to:nil from:self];
		[[(MainWindow*)window controller] keyWindowHandler];
	}
}

@end
