//
//  ScreenShotController.h
//  Scribbler
//
//  Created by Thomas Nägele on 28.08.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SketchView;

@interface ScreenShotController : NSObject {

	SketchView *activeView;
}

- (void)grabScreenShotFromView:(SketchView *)view;
- (void)myThreadMainMethod:(id)param;

@end
