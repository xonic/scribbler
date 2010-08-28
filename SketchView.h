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
#import "TabModel.h"


@class MainWindow;
@class SketchModel;
@class SketchController;
@class TabModel;

@interface SketchView : NSView {	
	//MainWindow			*	mainWindow;
	SketchModel			*	sketchModel;
	TabModel			*	tabModel;
	SketchController	*   controller;

	BOOL					draw;
	BOOL					clickThrough;
	BOOL					isDrawing;
	BOOL					erase;
	
	NSRect					keyWindow;
}

@property (retain) SketchModel *sketchModel;
@property BOOL draw, clickThrough, isDrawing, erase;
@property (readwrite) NSRect keyWindow;

- (id)initWithController:(SketchController *)theController andSketchModel:(SketchModel *)theSketchModel andTabModel:(TabModel *)theTabModel;
- (id)initWithController:(SketchController *)theController andTabModel:(TabModel *)theTabModel;
- (void)invertKeyWindowBoundsYAxis;

@end
