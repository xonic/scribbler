//
//  SketchController.h
//  Scribbler
//
//  Created by Thomas Nägele on 20.05.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PointModel.h"
#import "SketchModel.h"
#import "MainWindow.h"
#import "SketchView.h"
#import "WindowModel.h"

@class SketchModel;
@class MainWindow;
@class SketchView;
@class PointModel;

@interface SketchController : NSObject {
//	NSMutableDictionary			*	keyWindowViews;
	NSMutableDictionary			*	windowModelList;
	SketchView					*	activeSketchView;
	MainWindow					*	mainWindow;
	PointModel					*   startDragPoint;
	PointModel					*	endDragPoint;
	NSColor						*	selectedColor;
	
	BOOL							erase;
	BOOL							mouseMode;
	BOOL							mainWindowWasVisible;
	BOOL							penIsNearTablet;
}
@property (retain) NSColor *selectedColor;
@property (retain) SketchView *activeSketchView;
@property (retain) MainWindow *mainWindow;

- (id) initWithMainWindow:(MainWindow *)theMainWindow;

- (void) handleMouseDownAt:(NSPoint)inputPoint from:(SketchView *)sender;
- (void) handleMouseDraggedAt:(NSPoint)inputPoint from:(SketchView *)sender;
- (void) handleMouseUpAt:(NSPoint)inputPoint from:(SketchView *)sender;

- (void) setClickThrough:(BOOL)flag;
- (void) showHide;

- (NSMutableDictionary*)getCurrentKeyWindowInfos;
- (NSNumber*) getKeyWindowID: (NSMutableDictionary*)windowInfos;
- (int) getProcessID: (NSMutableDictionary*)windowInfos;
- (NSString*) getKeyWindowsApplicationName: (NSMutableDictionary*)windowInfos;
- (NSRect) getKeyWindowBounds: (NSMutableDictionary*) windowInfos;
- (void) keyWindowHandler;
- (void) registerForAccessibilityEvents:(int)pid;

static void callback (AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon);

@end

