//
//  SketchView.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchModel.h"
#import "PathModel.h"
#import "SubWindowModel.h"


@class MainWindow;
@class SketchModel;
@class SketchController;
@class SubWindowModel;

@interface SketchView : NSView {	
	//MainWindow			*	mainWindow;
	SketchModel			*	sketchModel;
	SubWindowModel			*	tabModel;
	SketchController	*   controller;

	BOOL					draw;
	BOOL					clickThrough;
	BOOL					isDrawing;
	BOOL					erase;
	BOOL					drawWindowBounds;
	
	NSRect					keyWindow;
}

@property (retain) SketchModel *sketchModel;
@property BOOL draw, clickThrough, isDrawing, erase, drawWindowBounds;
@property (readwrite) NSRect keyWindow;


- (id)initWithController:(SketchController *)theController andSketchModel:(SketchModel *)theSketchModel andTabModel:(SubWindowModel *)theTabModel;
- (id)initWithController:(SketchController *)theController andTabModel:(SubWindowModel *)theTabModel;


@end
