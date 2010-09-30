//
//  WindowModel.h
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubWindowModel.h"
#import "SketchView.h"
#import "SketchController.h"
#import "PathModel.h"

@class SketchController;
@class SubWindowModel;
@class SketchView;

typedef enum _SRWindowChange {
	SRWindowChangeWasNotSignificant	= 0,
	SRWindowWasScrolled				= 1,
	SRWindowWasResized				= 2,
	SRWindowAddedSubWindow			= 3,
	SRWindowChangedSubWindow		= 4
} SRWindowChange;

typedef enum _SRUIElementType {
	SRUIElementHasNoRelevance		= 0,
	SRUIElementIsPartOfAScrollbar	= 1,
	SRUIElementIsScrollArea			= 2,
	SRUIElementIsTextArea			= 3,
	SRUIElementIsWebArea			= 4,
	SRUIElementIsWindow				= 5,
	SRUIElementIsMenuBar			= 6
} SRUIElementType;

@interface WindowModel : NSObject {
	
	NSMutableArray						*subWindows;
	SubWindowModel						*activeSubWindow;
	SketchController					*controller;
	
	AXUIElementRef	_systemWideElement;
	AXUIElementRef	_focusedApp;
	CFTypeRef		_focusedWindow;
	
	SRWindowChange	lastWindowChange;
	NSPoint			lastMovingDiff;
	
	BOOL			windowWasRepositioned;
}

@property (retain) NSMutableArray		*subWindows;
@property (retain) SubWindowModel		*activeSubWindow;
@property (retain) SketchController		*controller;
@property (readwrite) BOOL				windowWasRepositioned;

- (id) initWithController:(SketchController *)theController;
//- (id) initWithView:(SketchView *)theView;
- (void) initScrollPositionsOfWindow;

- (BOOL) loadAccessibilityData;
- (CGPoint) carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint;
- (NSArray *) attributeNamesOfUIElement:(AXUIElementRef)element;
- (id) valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;
- (NSString *) getUIDofScrollArea:(AXUIElementRef)scrollArea;
- (id) getScrollAreaRefWithUID:(NSString *)uid;
- (BOOL) isUIDOfScrollArea:(AXUIElementRef)scrollArea equalTo:(NSString *)uid;
//- (void) setWindowWasRepositioned: (BOOL) flag;

- (void) getUIElementInfo;
- (id) getUIElementUnderMouse;
- (id) getParentOfUIElement:(AXUIElementRef)element;
- (NSArray *) findScrollAreasInUIElement:(AXUIElementRef)uiElement;
- (id) getScrollAreaFromWhichUIElementIsChildOf:(AXUIElementRef) uiElement;
- (BOOL) isUIElementChildOfMenuBar:(AXUIElementRef) uiElement;
- (BOOL) isUIElementChildOfWindow:(AXUIElementRef) uiElement;
- (id) getMemberFromScrollArea:(AXUIElementRef)scrollArea;
- (NSString *) getTitleOfUIElement:(AXUIElementRef)element;
- (NSString *) getTitleOfFocusedWindow;
- (NSRect) getBoundsOfUIElement:(AXUIElementRef)element;
- (SRUIElementType) getTypeOfUIElement:(AXUIElementRef)element;
- (NSDictionary *) getScrollingInfosOfCurrentWindow;

- (NSRect) getWindowBounds;
- (NSRect) getClippingAreaFromPath:(PathModel *)clippedPath withOriginalPath:(PathModel *)originalPath;
- (int) whatHasChanged;
- (NSPoint) getMovingDelta;
- (SketchView *)getRelatedView;

@end
