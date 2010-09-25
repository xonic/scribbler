//
//  HistoryObject.h
//  Scribbler
//
//  Created by Thomas Nägele on 21.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "PathModel.h"


@interface HistoryObject : NSObject {
	
	int					operation;
	PathModel		*	thePath;
	NSMutableArray	*	allPaths;
	NSDate			*	timeStamp;
}

@property int operation;
@property (retain) PathModel * thePath;
@property (retain) NSMutableArray * allPaths;

- (id)initWithOperation:(int)theOperation forPathModel:(PathModel *)thePathModel;
- (id)initWithOperation:(int)theOperation forAllPathModels:(NSMutableArray *)thePathModels;

@end
