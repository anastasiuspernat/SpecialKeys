//
//  LayoutsOnDisk.m
//  SpecialKeys
//
//  Created by Anastasy on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LayoutsOnDisk.h"
#import "Layouts.h"

@implementation LayoutsOnDisk


- (void)writeLayouts:(Layouts *)layouts
{
    //NSMutableDictionary * layouts;
	
	// allocate an NSMutableDictionary to hold our preference data
    //prefs = [[NSMutableDictionary alloc] init];
	
	// our preference data is our client name, hostname, and buddy list
    //[prefs setObject:[m_clientName stringValue] forKey:@"Client"];
    //[prefs setObject:[m_serverName stringValue] forKey:@"Server"];
    //[prefs setObject:m_friends forKey:@"Friends"];
    
    // save our buddy list to the user's home directory/Library/Preferences.
    [layouts writeToFile:[@"~/Library/Preferences/SpecialKeys.plist"
						stringByExpandingTildeInPath] atomically: TRUE];
    //return self;
}


@end
