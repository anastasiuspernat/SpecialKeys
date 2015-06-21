//
//  Layouts.h
//  SpecialKeys
//
//  Created by Anastasius on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OrderedDictionary.h"


@interface Layouts : NSObject {
	OrderedDictionary *_layouts;
	OrderedDictionary *currentLayout;
	NSString *currentLayoutTitle;
	
	NSMutableDictionary *mySpecialKeys;
	
}

@property (copy) NSString *currentLayoutTitle; 
@property (copy) NSMutableDictionary *mySpecialKeys; 

- (void)initWithDefaultData;
+ (Layouts *)initLayoutsWithSpecialKeysCodes:(OrderedDictionary *)od;

- (OrderedDictionary *)getRawLayoutByTitle:(NSString *)title;
- (void)rebuildCurrentLayoutFromTitle:(NSString *)title;

- (OrderedDictionary *)getCurrentLayout;
- (void)setCurrentLayout:(OrderedDictionary *)newCurrentLayout;
- (OrderedDictionary *)getLayouts;
- (void)setLayouts:(OrderedDictionary *)newLayouts;
- (void)initSpecialKeys:(NSMutableDictionary *)specialKeys;

- (bool)loadFromDisk;
- (int)decodeNumber:(NSString*)str;


- (int)decodeSpecialKey:(NSString *)specialKeyName;
- (NSString *)encodeSpecialKey:(int)adbCode;


- (void)saveToDisk;
- (void)deleteLayoutFromDiskByTitle:(NSString *)title;
- (NSArray *)allKeys;
- (NSDictionary *)forKey:(NSString *)key;


@end
