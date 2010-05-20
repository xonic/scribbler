//
//  PaintView.h
//  Scribbler
//
//  Created by Clemens Sagmeister on 21.04.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchModel.h"

@class MainWindow;
@class SketchModel;
@class SketchController;

@interface SketchView : NSView {	
	MainWindow			*	mainWindow;
	SketchModel			*	model;
	SketchController	*   controller;

	BOOL					draw;
	BOOL					clickThrough;
	BOOL					isDrawing;
	BOOL					erase;
}

@property (retain) SketchModel *model;
@property BOOL draw, clickThrough, isDrawing, erase;

- (id) initWithController:(SketchController *)theController andModel:(SketchModel *)theModel;

@end
