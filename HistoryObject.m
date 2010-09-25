//
//  HistoryObject.m
//  Scribbler
//
//  Created by Thomas Nägele on 21.09.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "HistoryObject.h"


@implementation HistoryObject

@synthesize operation, thePath, allPaths;

- (id)initWithOperation:(int)theOperation forPathModel:(PathModel *)thePathModel
{
	if(![super init])
		return nil;
	
	operation = theOperation;
	thePath   = [thePathModel retain];
	allPaths  = nil;
	timeStamp = [NSDate date];
	
	return self;
}

- (id)initWithOperation:(int)theOperation forAllPathModels:(NSMutableArray *)thePathModels
{
	if(![super init])
		return nil;
	
	operation = theOperation;
	thePath	  = nil;
	allPaths  = [thePathModels retain];
	timeStamp = [NSDate date];
	
	return self;
}

@end
