//
//  GlassPane.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "PaintView.h"

@interface GlassPane : NSWindow {
	IBOutlet PaintView *screenView;
}

- (void) showHide:(id)sender;
- (void) openFinder:(id)sender;
- (void) actionQuit:(id)sender;
- (void) showGlassPane:(BOOL)flag;

@end
