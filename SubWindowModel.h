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

@interface SubWindowModel : NSObject {
	
	WindowModel			* parent;
	SketchView			* view;
	NSMutableDictionary		* scrollInfos;	
}

@property (retain) SketchView *view;
@property (retain) NSMutableDictionary *scrollInfos;

- (id) initWithParent:(WindowModel *)theParent;
- (id) initWithView:(SketchView *)theView andParent:(WindowModel *)theParent;

@end
