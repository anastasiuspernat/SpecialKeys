//
//  keyViewObj.m
//  SpecialKeys
//
//  Created by Anastasius on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "keyViewObj.h"
#import "basics.h"
#import "LogDebug.h"


@implementation keyViewObj

@synthesize keyName; 
@synthesize keyActionName;

- (id)initWithKeyName:(NSString *)pStr1 keyActionName:(NSString *)pStr2; 
{ 
	if (! (self = [super init])) 
	{ logDebug(@"keyViewObj **** ERROR : [super init] failed ***"); return self; 
	} 
	// end if 
	self.keyName = pStr1; 
	self.keyActionName = pStr2; 
	return self; 
} // end initWithKeyName:andString2:andString3: 

@end
