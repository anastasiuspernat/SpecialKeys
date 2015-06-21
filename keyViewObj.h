//
//  keyViewObj.h
//  SpecialKeys
//
//  Created by Anastasius on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface keyViewObj : NSObject {
	NSString *keyName; 
	NSString *keyActionName;  
}

@property (copy) NSString *keyName; 
@property (copy) NSString *keyActionName; 

- (id)initWithKeyName:(NSString *)pStr1 keyActionName:(NSString *)pStr2;

@end
