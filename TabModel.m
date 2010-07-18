//
//  TabModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "TabModel.h"


@implementation TabModel

@synthesize view;

- (id)initWithParent:(WindowModel *)theParent
{
	if(![super init])
		return nil;
	
	if(theParent == nil){
		NSLog(@"TabModel/initWithParent:theParent - ERROR: theParent was nil.");
		[self release];
		return nil;
	}
	
	parent = [theParent retain];
	
	//  create a new SketchView 
	// (the corresponding SketchModel 
	//  will be created by the init method itself)
	view   = [[SketchView alloc] initWithController:[parent controller] andTabModel:self];
	
	return self;
}

- (id)initWithView:(SketchView *)theView andParent:(WindowModel *)theParent
{
	if(![super init])
		return nil;
	
	if(theView == nil || theParent == nil){
		NSLog(@"TabModel/initWithView:theView andParent:theParent - ERROR: one of the parameters was nil.");
		[self release];
		return nil;
	}
	
	view   = [theView   retain];
	parent = [theParent retain];
	
	return self;
}

@end
