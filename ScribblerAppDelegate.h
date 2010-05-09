//
//  ScribblerAppDelegate.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScribblerAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSWindow *window;

@end
