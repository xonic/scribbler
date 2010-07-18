//
//  TabModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchView.h"
#import "WindowModel.h"


@class SketchView;
@class WindowModel;

@interface TabModel : NSObject {
	
	WindowModel		*		parent;
	SketchView		*		view;
	// TODO: add accessibility attributes
	
}

@property (retain) SketchView *view;

- (id)initWithParent:(WindowModel *)theParent;
- (id)initWithView:(SketchView *)theView andParent:(WindowModel *)theParent;

@end
