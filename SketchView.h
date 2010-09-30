//
//  SketchView.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SketchModel.h"
#import "PathModel.h"
#import "SubWindowModel.h"


@class MainWindow;
@class SketchModel;
@class SketchController;
@class SubWindowModel;

@interface SketchView : NSView {	
	//MainWindow		*	mainWindow;
	SketchModel			*	sketchModel;
	SubWindowModel		*	tabModel;
	SketchController	*   controller;
	NSCursor			*	customCursor;
	NSCursor			*	theNormalCursor;
	
	BOOL					draw;
	BOOL					clickThrough;
	BOOL					isDrawing;
	BOOL					erase;
	BOOL					drawWindowBounds;
	BOOL					drawMouseModeBounds;
	
	double					screenShotFlashAlpha;
	
	NSRect					keyWindow;
}

@property (retain) SketchModel *sketchModel;
@property BOOL draw, clickThrough, isDrawing, erase, drawWindowBounds, drawMouseModeBounds;
@property (readwrite) NSRect keyWindow;
@property (retain) NSCursor *customCursor;


- (id)initWithController:(SketchController *)theController andSketchModel:(SketchModel *)theSketchModel andTabModel:(SubWindowModel *)theTabModel;
- (id)initWithController:(SketchController *)theController andTabModel:(SubWindowModel *)theTabModel;

- (void)updateKeyWindowBounds;
- (void)setScreenShotFlashAlpha:(double)value;

- (void)foldViewIn;
- (void)foldViewOut;

@end
