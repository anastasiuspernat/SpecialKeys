//
//  SpecialKeysTrayAppDelegate.h
//  SpecialKeysTray
//
//  Created by Anastasy on 29/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SpecialKeysTrayAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
