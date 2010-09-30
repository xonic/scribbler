//
//  WindowModel.m
//  Scribbler
//
//  Created by Thomas Nägele on 17.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "WindowModel.h"


@implementation WindowModel

@synthesize subWindows, activeSubWindow, controller, windowWasRepositioned;

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
	
	// setup the subwindows
	subWindows = [[NSMutableArray alloc] init];
	
	// create and add the first subwindow
	SubWindowModel *newSubWindow = [[SubWindowModel alloc] initWithParent:self];
	[subWindows addObject:newSubWindow];
	
	// set the subwindow as the active window
	activeSubWindow = [newSubWindow retain];
	
	// init with accessibility data
	[self loadAccessibilityData];
	
	// search window for scrollAreas and save their current scrolling positions
	[self initScrollPositionsOfWindow];
	lastWindowChange = SRWindowChangeWasNotSignificant;
	lastMovingDiff = NSZeroPoint;
	windowWasRepositioned = NO;
	
	// bye
	[newSubWindow release];
	
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
 
 // setup the subwindows
 tabs = [[NSMutableArray alloc] init];
 
 // create and add the first subwindow
 SubWindowModel *newSubWindow = [[SubWindowModel alloc] initWithView:theView andParent:self];
 [subWindows addObject:newSubWindow];
 
 // set the subwindow as the active window
 activeSubWindow = [newSubWindow retain];
 
 // bye
 [newSubWindow release];
 
 return self;
 }
 */

- (void) initScrollPositionsOfWindow {
	// search for scrollAreas in focusedWindow
	NSArray *scrollAreas = [self findScrollAreasInUIElement:_focusedWindow];
	//NSLog(@"found these scrollAreas: %@",scrollAreas);
	// create a dictionary for all scrollAreas with their scrollPositions
	NSMutableDictionary *scrollInfos = [[NSMutableDictionary alloc] init];
	
	// get scrollPosition of each scrollArea
	for(int i=0; i<[scrollAreas count]; i++) {
		// get ith scrollArea
		AXUIElementRef scrollArea = (AXUIElementRef)[scrollAreas objectAtIndex:i];
		// ensure that we've got here a scrollArea
		if([self getTypeOfUIElement:scrollArea] == SRUIElementIsScrollArea) {
			// get the corresponding textArea of the scrollArea
			AXUIElementRef member = (AXUIElementRef)[self getMemberFromScrollArea:(AXUIElementRef)[scrollAreas objectAtIndex:i]];
			// ensure that we've got here the corresponding member
			if(member != nil) {
				// get bounds of the member
				NSRect currentMemberBounds = [self getBoundsOfUIElement:member];
				//NSLog(@"the bounds of member%d = (%f,%f)-(%f,%f)",i,currentMemberBounds.origin.x, currentMemberBounds.origin.y, currentMemberBounds.size.width, currentMemberBounds.size.height);
				// since we need an object for saving the bounds in a dictionary, we pack it with the help of NSValue
				NSValue *wrappedMemberBounds = [NSValue valueWithRect:currentMemberBounds];
				// since we need an object for saving the scrollArea which is an AXUIElement we save it's unique id
				NSString *uid = [self getUIDofScrollArea:scrollArea];
				// add srolling infos to dictionary
				[scrollInfos setObject:(id)wrappedMemberBounds forKey:uid];				
			}
		}
	}
	
	// save scrollArea infos to active subWindow
	[activeSubWindow setScrollInfos:scrollInfos];
}

- (BOOL) loadAccessibilityData {
	//NSLog(@"getAccessibilityData");
	
	_systemWideElement = AXUIElementCreateSystemWide();
	
	//Get the app that has the focus
	AXUIElementCopyAttributeValue(_systemWideElement,
								  (CFStringRef)kAXFocusedApplicationAttribute,
								  (CFTypeRef*)&_focusedApp);
	
	NSLog(@"focusedApp=%@",[self getTitleOfUIElement:_focusedApp]);
	if ([[self getTitleOfUIElement:_focusedApp] isEqualToString:@"Scribbler"]) {
		// scribbler was accidently taken for loading AX-Data
		// thus we don't override the last focusedWindow and return YES
		return YES;
	}
	
	//Get the window that has the focus
	if(AXUIElementCopyAttributeValue((AXUIElementRef)_focusedApp,
									 (CFStringRef)NSAccessibilityFocusedWindowAttribute,
									 (CFTypeRef*)&_focusedWindow) == kAXErrorSuccess) {
		
	}else {
		NSLog(@"Couldn't load AXData");
		
		// loading AXData was not successful, return NO
		return NO;
	}
	
	// loading AXData was successful, return YES
	return YES;
}

- (CGPoint)carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint {
    NSScreen *foundScreen = nil;
    CGPoint thePoint;
    
    for (NSScreen *screen in [NSScreen screens])
		if (NSPointInRect(cocoaPoint, [screen frame]))
			foundScreen = screen;
	
    if (foundScreen) {
		CGFloat screenHeight = [foundScreen frame].size.height;
		thePoint = CGPointMake(cocoaPoint.x, screenHeight - cocoaPoint.y - 1);
    } 
	else 
		thePoint = CGPointMake(0.0, 0.0);
	
    return thePoint;
}

- (NSArray *)attributeNamesOfUIElement:(AXUIElementRef)element {
    NSArray *attrNames = nil;
    
    AXUIElementCopyAttributeNames(element, (CFArrayRef *)&attrNames);
    
    return [attrNames autorelease];
}

- (id)valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element {
    id result = nil;
    NSArray *attributeNames = [self attributeNamesOfUIElement:element];
    
    if (attributeNames) {
        if ([attributeNames indexOfObject:(NSString *)attribute] != NSNotFound &&
        	AXUIElementCopyAttributeValue(element, (CFStringRef)attribute, (CFTypeRef *)&result) == kAXErrorSuccess) {
            [result autorelease];
        }
    }
    return result;
}

- (NSString *) getUIDofScrollArea:(AXUIElementRef)scrollArea {
	
	SRUIElementType type = [self getTypeOfUIElement:scrollArea];
	NSString *uid = nil;
	
	// ensure that we've got a scrollbar
	if (type == SRUIElementIsScrollArea) {
		// calc uid in form of pid_typeID_relativeDiffCoords
		// -------------------------------------------------
		// 1st step: get the process id (pid)
		pid_t pid;
		AXUIElementGetPid(scrollArea, &pid);
		// 2nd step: get the type id from the member of the scrollArea
		CFTypeRef member = [self getMemberFromScrollArea:scrollArea];
		if(member==nil) return uid;
		CFTypeID typeID = CFGetTypeID(member);
		// 3rd step: calc the relativeDiffCoords
		// get topLevelUIElement (=window) from scrollArea
		AXUIElementRef window = (AXUIElementRef)[self valueOfAttribute:NSAccessibilityTopLevelUIElementAttribute ofUIElement:scrollArea];
		// get windowBounds and scrollAreaBounds
		NSRect windowBounds = [self getBoundsOfUIElement:window];
		NSRect scrollAreaBounds = [self getBoundsOfUIElement:scrollArea];
		// calc difference (and add .01 to ensure uniqueness in case of zeroValues)
		NSPoint diff;
		diff.x = scrollAreaBounds.origin.x-windowBounds.origin.x+.01;
		diff.y = scrollAreaBounds.origin.y-windowBounds.origin.y+.01;
		// make a relation
		float relativeDiffCoords = diff.x/diff.y;
		// form uid
		uid = [NSString stringWithFormat:@"%d%d%f",pid,typeID,relativeDiffCoords];
		//NSLog(@"uid = %@",uid);
	}
	
	return uid;
}

- (id) getScrollAreaRefWithUID:(NSString *)uid {
	// search for scrollAreas in focusedWindow
	NSArray *scrollAreas = [self findScrollAreasInUIElement:_focusedWindow];
	// get scrollPosition of each scrollArea
	for(int i=0; i<[scrollAreas count]; i++) {
		// get ith scrollArea
		AXUIElementRef scrollArea = (AXUIElementRef)[scrollAreas objectAtIndex:i];
		// calc the uid of this scrollArea
		NSString *cur_uid = [self getUIDofScrollArea:scrollArea];
		// check if we've found the correct one
		if ([uid isEqualToString:cur_uid]) {
			//[cur_uid release];
			return (id)scrollArea;
		}		
	}
	
	return nil;
}

- (BOOL) isUIDOfScrollArea:(AXUIElementRef)scrollArea equalTo:(NSString *)uid {
	if (uid == nil) return NO;
	NSString *scrollUID = [self getUIDofScrollArea:scrollArea];
	if (scrollUID == nil) return NO;
	return [scrollUID isEqualToString:uid];
}

/*- (void) setWindowWasRepositioned: (BOOL) flag {
	windowWasRepositioned = flag;
	[self initScrollPositionsOfWindow];
}*/

- (void) getUIElementInfo {
	[self loadAccessibilityData];
	
	NSString *uiElementTitle;
	NSRect bounds;
	AXUIElementRef focusedUIElement = (AXUIElementRef)[self getUIElementUnderMouse];
	AXUIElementRef parentOfUIElement = (AXUIElementRef)[self getParentOfUIElement:focusedUIElement];
	AXUIElementRef scrollArea;
	
	if (focusedUIElement!=NULL && !windowWasRepositioned) {
		
		uiElementTitle = [self getTitleOfUIElement:focusedUIElement];
		bounds = [self getBoundsOfUIElement:focusedUIElement];
		SRUIElementType type = [self getTypeOfUIElement:parentOfUIElement];
		
		if (type == SRUIElementIsPartOfAScrollbar || type == SRUIElementIsScrollArea) {
			
			// get corresponding scrollaea
			if (type == SRUIElementIsPartOfAScrollbar)
				scrollArea = (AXUIElementRef)[self getParentOfUIElement:parentOfUIElement];
			else if (type == SRUIElementIsScrollArea)
				scrollArea = parentOfUIElement;
			
			// ensure that we've got the scrollArea
			type = [self getTypeOfUIElement:scrollArea];
			if (type == SRUIElementIsScrollArea) {
				// find the member of the scrollArea in order to get the current scrollPosition
				AXUIElementRef member = (AXUIElementRef)[self getMemberFromScrollArea:scrollArea];
				// ensure that we've got a member
				if (member != nil) {
					NSString *currentUID = [self getUIDofScrollArea:scrollArea];
					//NSLog(@"currentUID = %@",currentUID);
					NSValue *boundsBeforeValue = [[activeSubWindow scrollInfos] objectForKey:currentUID];
					
					if (boundsBeforeValue) {
						NSRect boundsBefore = [boundsBeforeValue rectValue];
						NSRect boundsNow = [self getBoundsOfUIElement:member];
						lastMovingDiff.x = boundsNow.origin.x-boundsBefore.origin.x;
						lastMovingDiff.y = boundsNow.origin.y-boundsBefore.origin.y;
						if (lastMovingDiff.x>0 || lastMovingDiff.x<0 || lastMovingDiff.y>0 || lastMovingDiff.y<0) {
							lastWindowChange = SRWindowWasScrolled;
							[self initScrollPositionsOfWindow];
						}
						else {
							lastWindowChange = SRWindowChangeWasNotSignificant;
							lastMovingDiff = NSZeroPoint;
						}
					}
				}
			}
		}
	}
	
	if (windowWasRepositioned) {
		lastWindowChange = SRWindowChangeWasNotSignificant;
		lastMovingDiff = NSZeroPoint;
		[self setWindowWasRepositioned:NO];
	}
}

- (id) getUIElementUnderMouse { 
	
	AXUIElementRef focusedUIElement = NULL;
	
	[self loadAccessibilityData];
	
	if(CFGetTypeID(_focusedWindow) == AXUIElementGetTypeID()) {
		
		// Get the current UI Element
		NSPoint cocoaPoint = [NSEvent mouseLocation];
		CGPoint pointAsCGPoint = [self carbonScreenPointFromCocoaScreenPoint:cocoaPoint];
		// Ask Accessibility API for UI Element under the mouse
		if (AXUIElementCopyElementAtPosition(_systemWideElement, 
											 pointAsCGPoint.x, 
											 pointAsCGPoint.y, 
											 &focusedUIElement) != kAXErrorSuccess) {
			
			NSLog(@"Can't Retrieve UIElement Info");			 
		}
	}
	else 
		NSLog(@"Can't Retrieve UIElement Info");
	
	return (id)focusedUIElement;
	
}

- (id) getParentOfUIElement:(AXUIElementRef)element {
	
	id parentUIElement = NULL;
	
	if(element!=NULL)
		parentUIElement = [self valueOfAttribute:NSAccessibilityParentAttribute ofUIElement:(AXUIElementRef)element];
	
	return parentUIElement;
}

- (NSArray*) findScrollAreasInUIElement:(AXUIElementRef)uiElement {
	
	// init an array to save all scrollArea references we'll find
	NSMutableArray *scrollAreaRefs = [[NSMutableArray alloc] init];
	// get all children of the uiElement
	NSArray *children = [self valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:uiElement];
	// check each child if it's a scrollArea
	for(int i=0; i<[children count]; i++)
		// if so, save it to our array
		if ([self getTypeOfUIElement:(AXUIElementRef)[children objectAtIndex:i]] == SRUIElementIsScrollArea)
			[scrollAreaRefs addObject:[children objectAtIndex:i]];
	// if not, call recursively findScrollAreasInUIElement and save the outcome to our array
		else
			[scrollAreaRefs addObjectsFromArray:[self findScrollAreasInUIElement:(AXUIElementRef)[children objectAtIndex:i]]];
	
	return scrollAreaRefs;
}

- (id) getScrollAreaFromWhichUIElementIsChildOf:(AXUIElementRef) uiElement {
	AXUIElementRef scrollArea = uiElement;
	
	while (scrollArea!=NULL && [self getTypeOfUIElement:scrollArea]!=SRUIElementIsScrollArea)
		scrollArea = (AXUIElementRef)[self getParentOfUIElement:scrollArea];
	
	return (id)scrollArea;
}

- (BOOL) isUIElementChildOfMenuBar:(AXUIElementRef) uiElement {
	
	while (uiElement!=NULL && [self getTypeOfUIElement:uiElement]!=SRUIElementIsMenuBar)
		uiElement = (AXUIElementRef)[self getParentOfUIElement:uiElement];
	
	if(uiElement==NULL) return NO;
	
	return YES;
}

- (BOOL) isUIElementChildOfWindow:(AXUIElementRef) uiElement {
	
	while (uiElement!=NULL && [self getTypeOfUIElement:uiElement]!=SRUIElementIsWindow)
		uiElement = (AXUIElementRef)[self getParentOfUIElement:uiElement];
	
	if(uiElement==NULL) return NO;
	
	return YES;
}

- (id) getMemberFromScrollArea:(AXUIElementRef)scrollArea {
	
	if ([self getTypeOfUIElement:scrollArea] == SRUIElementIsScrollArea) {
		NSArray *children = [self valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:scrollArea];
		//NSLog(@"number of Children in scrollArea: %i",[children count]);
		for(int i=0; i<[children count]; i++) {
			//NSLog(@"child%i:%@",i,[self valueOfAttribute:NSAccessibilityRoleDescriptionAttribute ofUIElement:[children objectAtIndex:i]]);
			SRUIElementType type = [self getTypeOfUIElement:(AXUIElementRef)[children objectAtIndex:i]];
			if (type == SRUIElementIsTextArea || type == SRUIElementIsWebArea)
				return [children objectAtIndex:i];		
		}
	}
	
	return (id) nil;
}

- (NSString *) getTitleOfUIElement:(AXUIElementRef)element {
	NSString *uiElementTitle;
	
	if (element!=NULL)
		uiElementTitle = [self valueOfAttribute:NSAccessibilityTitleAttribute ofUIElement:(AXUIElementRef)element];
	
	return uiElementTitle;
}

- (NSString *) getTitleOfFocusedWindow {
	if (_focusedWindow != NULL)
		return [self getTitleOfUIElement:_focusedWindow];
	else 
		return @"";
}

- (NSRect) getBoundsOfUIElement:(AXUIElementRef)element {
	
	NSRect bounds = NSZeroRect;
	CFTypeRef _position;
	CFTypeRef _size;
	
	// Get the Window's Current Position
	if(AXUIElementCopyAttributeValue((AXUIElementRef)element,
									 (CFStringRef)NSAccessibilityPositionAttribute,
									 (CFTypeRef*)&_position) != kAXErrorSuccess) {
		NSLog(@"Can't Retrieve Window Bounds");
		return bounds;
	}
	else {
		// Get the Window's Current Size
		if(AXUIElementCopyAttributeValue((AXUIElementRef)element,
										 (CFStringRef)NSAccessibilitySizeAttribute,
										 (CFTypeRef*)&_size) != kAXErrorSuccess) {
			NSLog(@"Can't Retrieve Window Bounds");
			return bounds;
		}
	}
	
	AXValueGetValue((AXValueRef)_position, kAXValueCGPointType, (void *) &bounds.origin);
	AXValueGetValue((AXValueRef)_size, kAXValueCGSizeType, (void *) &bounds.size);
	
	return bounds;
}

- (SRUIElementType) getTypeOfUIElement:(AXUIElementRef)element {
	
	//NSString *elementRole = [self valueOfAttribute:NSAccessibilityRoleDescriptionAttribute ofUIElement:element];
	NSString *elementRoleAttribute = [self valueOfAttribute:NSAccessibilityRoleAttribute ofUIElement:element];
	//NSLog(@"elementRole = %@, elementRoleAttribute = %@ of element = %@",elementRole,elementRoleAttribute,element);
	
	if ([elementRoleAttribute isEqualToString:@"AXScrollBar"]) {
		return SRUIElementIsPartOfAScrollbar;
	}
	else if ([elementRoleAttribute isEqualToString:@"AXScrollArea"]) {
		return SRUIElementIsScrollArea;
	}
	else if ([elementRoleAttribute isEqualToString:@"AXTextArea"]) {
		return SRUIElementIsTextArea;
	}
	else if ([elementRoleAttribute isEqualToString:@"AXWebArea"]) {
		return SRUIElementIsWebArea;
	}
	else if ([elementRoleAttribute isEqualToString:@"AXWindow"]) {
		return SRUIElementIsWindow;
	}
	else if ([elementRoleAttribute isEqualToString:@"AXMenuBar"]) {
		return SRUIElementIsMenuBar;
	}
	
	return SRUIElementHasNoRelevance;
}

- (NSDictionary *) getScrollingInfosOfCurrentWindow {
	return [activeSubWindow scrollInfos];
}

- (NSRect) getWindowBounds {
	
	NSRect bounds = NSZeroRect;
	
	[self loadAccessibilityData];
	
	if(CFGetTypeID(_focusedWindow) == AXUIElementGetTypeID()) {
		bounds = [self getBoundsOfUIElement:_focusedWindow];
	}
	else
		NSLog(@"Can't Retrieve Window Bounds");
	
	return bounds;
}

- (NSRect) getClippingAreaFromPath:(PathModel *)clippedPath withOriginalPath:(PathModel *)originalPath {
	//NSLog(@"getClippingAreaFromPath");
	return [self getWindowBounds];
}

- (int) whatHasChanged {
	//NSLog(@"hasChanged");
	[self getUIElementInfo];
	return lastWindowChange;
}

- (NSPoint) getMovingDelta {
	//NSLog(@"getMovingDelta");
	return lastMovingDiff;
}

- (SketchView *)getRelatedView {
	//NSLog(@"getRelatedView");
	return [activeSubWindow view];
}

@end
