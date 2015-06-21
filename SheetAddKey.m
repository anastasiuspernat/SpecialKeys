//
//  PanelAddKey.m
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SheetAddKey.h"
#import "basics.h"
#import "LogDebug.h"


@implementation SheetAddKey

@synthesize textKeyTitle;
@synthesize recorderBecameFirstResponder;
@synthesize textScanCode;
@synthesize shortcutRecorder; 
@synthesize controller; 
@synthesize listSpecialKeys; 
@synthesize matrixActionType;
@synthesize textKeyAssigned;
@synthesize buttonCreate;


-(id)init {
    if (self = [super init]) {
        recorderIsFirstResponder = NO;
    }
	//displayListSpecialActions = [[NSMutableArray alloc] init];
    return self;
}


- (NSResponder *)firstResponder {
    id fr = [super firstResponder];
	
    if ([fr isEqualTo:textScanCode]) {
        recorderIsFirstResponder = YES;
		logDebug(@"firstResponder %p %p",fr,self);
    } else {
		
        if (recorderIsFirstResponder && recorderBecameFirstResponder && fr != nil) {
            logDebug(@"the text field stopped being first responder, new responder: %p",fr);
            recorderBecameFirstResponder = NO;
        }
        recorderIsFirstResponder = NO;
    }
	
    return fr;
}

- (BOOL) recorderIsFocused
{
	
		return   [[[textScanCode window] firstResponder] isKindOfClass:[NSTextView class]]
		&&        [[textScanCode window] fieldEditor:NO forObject:nil]!=nil
		&& ( (id) [[textScanCode window] firstResponder]          ==textScanCode
			||  [(id) [[textScanCode window] firstResponder] delegate]==textScanCode); 
}


@end
