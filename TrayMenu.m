//
//  TrayMenu.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "TrayMenu.h"


@implementation TrayMenu

- (void) showHide:(id)sender {
	NSLog(@"superclass=%@",[self className]);
	
}

- (void) openFinder:(id)sender {
	[[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (NSMenu *) createMenu {
	NSZone *menuZone = [NSMenu menuZone];
	NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
	NSMenuItem *menuItem;
	
	// Add To Items
	menuItem = [menu addItemWithTitle:@"Show/Hide"
							   action:@selector(showHide:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	
	menuItem = [menu addItemWithTitle:@"Open Finder"
							   action:@selector(openFinder:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	
	// Add Separator
	[menu addItem:[NSMenuItem separatorItem]];
	
	// Add Quit Action
	menuItem = [menu addItemWithTitle:@"Quit"
							   action:@selector(actionQuit:)
						keyEquivalent:@""];
	[menuItem setToolTip:@"Click to Quit Scribbler"];
	[menuItem setTarget:self];
	
	return menu;
}

- (void) activateStatusMenu {
	NSMenu *menu = [self createMenu];
	
	statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSSquareStatusItemLength] retain];
	[statusItem setMenu:menu];
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"Scribbler"];
	//[statusItem setImage:[NSImage imageNamed:@"trayIcon"]];
	[statusItem setTitle: NSLocalizedString(@"☆",@"")];
	
	[menu release];
}

@end
