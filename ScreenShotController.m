//
//  ScreenShotController.m
//  Scribbler
//
//  Created by Thomas Nägele on 28.08.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "ScreenShotController.h"


@implementation ScreenShotController

- (void)grabScreenShot
{
	// Grab the screen with all visible windows
	CGImageRef screenShot = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	// Convert into a bitmap representation
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:screenShot];
	
	// Get the path to the desktop
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
	NSMutableString *desktopPath = [NSMutableString stringWithString:[paths objectAtIndex:0]];
	[desktopPath appendString:@"/"];
	
	// Get date and time and format them
	NSDate *now = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"YYYY-MM-dd 'um' HH 'Uhr' mm 'und' ss 'Sekunden'"];
	NSString *dateString = [formatter stringFromDate:now];
	
	// Define the file name e.g. "Scribbler 2010-08-27 12.30.45.png"
	NSMutableString *fileName = [NSMutableString stringWithString:@"Scribblerfoto "];
	[fileName appendString:dateString];
	[fileName appendString:@".png"];
	
	// Append file name to desktop path
	[desktopPath appendString:fileName];
	
	NSData *data = [bitmapRep representationUsingType:NSPNGFileType properties:nil];
	[data writeToFile:desktopPath atomically:NO]; 
	
	NSLog(@"Saved PNG to Desktop");
	NSLog(@"wtf");
	
	// get the hell out of here!
	[bitmapRep release];
	[formatter release];

}

@end
