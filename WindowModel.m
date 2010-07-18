//
//  WindowModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "WindowModel.h"


@implementation WindowModel

@synthesize tabs, activeTab, controller;

- (id)initWithController:(SketchController *)theController
{
	if(![super init])
		return nil;
	
	if(theController == nil){
		NSLog(@"WindowModel/initWithController:theController - ERROR: theController was nil.");
		[self release];
		return nil;
	}
	
	// setup the controller
	controller = [theController retain];
	
	// setup the subviews (tabs)
	tabs = [[NSMutableArray alloc] init];
	
	// create and add the first subview (tab)
	TabModel *newTab = [[TabModel alloc] initWithParent:self];
	[tabs addObject:newTab];
	
	// set the subview as the active view
	activeTab = [newTab retain];
	
	// bye
	[newTab release];
	
	return self;
}
/*
- (id)initWithView:(SketchView *)theView
{
	if(![super init])
		return nil;
	
	if(theView == nil){
		NSLog(@"WindowModel/initWithView:theView - ERROR: the view was nil.");
		[self release];
		return nil;
	}
	
	// setup the subviews (tabs)
	tabs = [[NSMutableArray alloc] init];
	
	// create and add the first subview (tab)
	TabModel *newTab = [[TabModel alloc] initWithView:theView andParent:self];
	[tabs addObject:newTab];
	
	// set the subview as the active view
	activeTab = [newTab retain];
	
	// bye
	[newTab release];
	
	return self;
}
*/
@end
