//
//  ScreenShotController.m
//  Scribbler
//
//  Created by Thomas Nägele on 28.08.10.
//  Copyright 2010 xonic. All rights reserved.
//

#import "ScreenShotController.h"


@implementation ScreenShotController

- (void)grabScreenShotFromView:(SketchView *)view
{
	activeView = view;
		
	NSThread* myThread = [[NSThread alloc] initWithTarget:self
												 selector:@selector(myThreadMainMethod:)
												   object:nil];
	
	[myThread start];  // Actually create the thread
	
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
	
	// get the hell out of here!
	[bitmapRep release];
	[formatter release];
}

- (void)myThreadMainMethod:(id)param
{
	// create top level auto release pool, that will release objects
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[activeView setScreenShotFlashAlpha:1.0];
	[activeView setNeedsDisplay:YES];

	// load camera sound
	NSSound *cameraSound = [NSSound soundNamed:@"camera"];
	
	if (cameraSound!=nil && ![cameraSound isPlaying]) {
		// play camera sound
		[cameraSound play];
    }
	// draw camera flash
	for(double i=1.0; i>=0.0; i-=0.075) {
		usleep(100000);
		//NSLog(@"in thread - set alpha to %f",i);
		[activeView setScreenShotFlashAlpha:i];
		[activeView setNeedsDisplay:YES];
	}
	
	[activeView setScreenShotFlashAlpha:0.0];
	[activeView setNeedsDisplay:YES];
	
	// release pool
	[pool release];
}

@end
