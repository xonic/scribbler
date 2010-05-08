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
	[screenView setClickThrough: !flag];
	[screenView setNeedsDisplay:YES];
	if(flag) {
		[self makeKeyAndOrderFront:nil];
		//NSLog(@"isKeyWindow=%d",[self isKeyWindow]);
	}
	
	//NSLog(@"keyWindowID=%d",[self getKeyWindowID:[self getCurrentKeyWindowInfos]]);
	
}


- (void)windowDidResignKey:(NSNotification *)notification
{
//	[self setLevel:NSFloatingWindowLevel];
	NSLog(@"didResignKey");

}

- (void)windowDidResignMain:(NSNotification *)notification
{
	NSLog(@"didResignMain");
}

- (void)becomeKeyWindow:(NSNotification *)notification
{
	NSLog(@"becomeKeyWindow");
}
- (void)becomeMainWindow:(NSNotification *)notification
{
	NSLog(@"becomeMainWindow");
}



@end
