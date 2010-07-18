//
//  WindowModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TabModel.h"
#import "SketchView.h"
#import "SketchController.h"

@class SketchController;
@class TabModel;
@class SketchView;

@interface WindowModel : NSObject {
	
	NSMutableArray						*tabs;
	TabModel							*activeTab;
	SketchController					*controller;
}

@property (retain) NSMutableArray		*tabs;
@property (retain) TabModel				*activeTab;
@property (retain) SketchController		*controller;

- (id)initWithController:(SketchController *)theController;
//- (id)initWithView:(SketchView *)theView;

@end
