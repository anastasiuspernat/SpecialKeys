//
//  main.m
//  SpecialKeysTray
//
//  Created by Anastasius on 29/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "connectToVoodoo.h"
#import "UserKernelShared.h"
#import "LogDebug.h"

NSAutoreleasePool *      pool;
connectToVoodoo * voodooPS2Keyboard;

@interface CatchApplication : NSObject 
-(void)appFrontSwitched:(id)param;

@end

@implementation CatchApplication
-(void)appFrontSwitched:(id)param{

    NSLog(@"SpecialKeysTray: %@", [[NSWorkspace sharedWorkspace] activeApplication]);

}
@end

static OSStatus AppFrontSwitchedHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
	//NSLog(@"SpecialKeysTray: %@", [[NSWorkspace sharedWorkspace] activeApplication]);
    //[(id)inUserData appFrontSwitched];
    return 0;
}

BOOL NEXT;

void callback2(void *refcon, IOReturn result, void **args, uint32_t numArgs)
{
	NSLog(@"SpecialKeysTray: key callback triggered\n");
	NEXT = TRUE;
}

int main(int argc, char *argv[])
{
	pool = [[NSAutoreleasePool alloc] init];
	CatchApplication * catchApplication = [[CatchApplication alloc] init];
	EventTypeSpec spec = { kEventClassApplication,  kEventAppFrontSwitched };
	NSLog(@"SpecialKeysTray: registering handlers");
    OSStatus err = InstallApplicationEventHandler(NewEventHandlerUPP(AppFrontSwitchedHandler), 1, &spec, (void*)catchApplication, NULL);
	NSString * path = @"~/Library/Preferences/SpecialKeys";
	NSString * filePath = [NSString stringWithFormat:@"%@/%@",path,@"currentlayout"];
	
	voodooPS2Keyboard = [[connectToVoodoo alloc] init];
	
	NSLog(@"SpecialKeysTray: reading currentlayout: %@",filePath);
	NSError  *fileError;
	NSString * currentLayoutData = [NSString stringWithContentsOfFile:[filePath stringByExpandingTildeInPath] encoding:NSASCIIStringEncoding error:&fileError];
	if(currentLayoutData == nil) {
		NSLog(@"SpecialKeysTray: FileError: %@", [fileError localizedDescription]);
	} else {
		NSArray * currentlayout = [currentLayoutData componentsSeparatedByString:@"\n"];
		NSLog(@"SpecialKeysTray: currentLayoutData: %@ ",currentLayoutData);
		NSString *temp = [currentlayout objectAtIndex:1];
		NSRange startCodes = [temp rangeOfString:@","];
		NSString * reallycurrentlayout = [temp substringWithRange:NSMakeRange(startCodes.location+1,[temp length]-startCodes.location-1)];
		NSLog(@"SpecialKeysTray: current keycodes: %@ ",reallycurrentlayout);
		NSArray * keycodes = [reallycurrentlayout componentsSeparatedByString:@","];
		NSLog(@"SpecialKeysTray: updating %d keycodes",[keycodes count]);
		
		
		if ([voodooPS2Keyboard connect])
		{
			int i;
			int count = [keycodes count]/2;
			for (i=0;i<count;i++)
			{
				int scanCode = [[keycodes objectAtIndex:i*2] intValue];
				int adbCode = [[keycodes objectAtIndex:i*2+1] intValue];
				if (adbCode>0 && scanCode>0)
				{
					NSLog(@"SpecialKeysTray: updating: %d -> %d",scanCode,adbCode);
					NEXT = FALSE;
					[voodooPS2Keyboard updatePS2Keys:kMyUserUpdateKeys scanCode:(int)scanCode adbCode:(int)adbCode callback:(io_user_reference_t)callback2];
					NSLog(@"SpecialKeysTray: updated OK");
				}
				//sleep(1);
			}
			NSLog(@"SpecialKeysTray: disconnecting from driver");
			[voodooPS2Keyboard disconnect];
		} else {
			NSLog(@"SpecialKeysTray: could not connect to VoodooPS2Keyboard");
		}
		
	}
	CFRunLoopRun();
	NSLog(@"SpecialKeysTray: exit");
	[pool drain];
}
