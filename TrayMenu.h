//
//  TrayMenu.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TrayMenu : NSObject {
	@private NSStatusItem *statusItem;
}
- (void) activateStatusMenu;

@end
