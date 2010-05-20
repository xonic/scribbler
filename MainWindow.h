//
//  GlassPane.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "SketchView.h"
#import "PointModel.h"
#import "SketchController.h"

@class SketchView;
@class PointModel;
@class SketchController;

@interface MainWindow : NSWindow {
	IBOutlet SketchView			*	screenView;
	SketchController			*	controller;
}

- (void) showHide:(id)sender;
- (void) openFinder:(id)sender;
- (void) actionQuit:(id)sender;
- (void) showGlassPane:(BOOL)flag;

@property(readwrite, assign) PointModel *startDragPoint, *endDragPoint;
@property (retain) SketchController *controller;

@end