//
//  ColorController.h
//  Scribbler
//
//  Created by Thomas Nägele on 26.07.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PointerModel.h"


@interface ColorController : NSObject <NSXMLParserDelegate> {
	
	NSMutableArray		* colorPalette;
	NSMutableDictionary * pointerColors;
	int					  returnColorIndex;
	
	NSString			* currentXMLTag;
	NSNumber			* currentPointerID;
	NSNumber			* currentRedComponent;
	NSNumber			* currentGreenComponent;
	NSNumber			* currentBlueComponent;
}

@property (retain, readonly) NSMutableArray *colorPalette;

- (NSColor *)getColorFromPalette;
- (NSColor *)getColorForPointerID:(NSNumber *)uniqueID;
- (void)loadColors;

// xml parser delegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end
