//
//  MainWindow.m
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if (![super initWithContentRect:[[NSScreen mainScreen] frame] styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag])
		return nil;
	
	[self setLevel:CGShieldingWindowLevel()];//NSFloatingWindowLevel];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	// uncomment next line to overrule OS menubars
	//[self setLevel:NSMainMenuWindowLevel + 1];
	
	controller = [[SketchController alloc] initWithMainWindow:self];
	
    return self;
}

- (void) showHide:(id)sender {
	
	[controller showHide];
}

- (void) openFinder:(id)sender {
	[[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (void) showGlassPane:(BOOL)flag {
	[controller setClickThrough: !flag];
	if(flag) {
		[self makeKeyAndOrderFront:nil];
	}
}

- (void)dealloc
{
	[controller release];
	[super dealloc];
}

@synthesize startDragPoint, endDragPoint;

@end
