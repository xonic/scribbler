//
//  ScribblerAppDelegate.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GlassPane.h"

@interface ScribblerAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	NSMutableDictionary *glassPanes;
	
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSMutableDictionary *glassPanes;

- (NSMutableDictionary*) getCurrentKeyWindowInfos;
- (NSInteger)  getKeyWindowID:(NSMutableDictionary*) windowInfos;
- (NSString *) getKeyWindowsApplicationName:(NSMutableDictionary*) windowInfos;
- (NSRect *)   getKeyWindowBounds:(NSMutableDictionary*) windowInfos;

- (BOOL)checkIfPaneExists;

@end
