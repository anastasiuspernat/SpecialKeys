//
//  SheetAddKeyController.h
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SheetAddKeyController : NSControl {
	IBOutlet NSComboBox *comboSpecialActions;
	
	NSMutableArray *displayListSpecialActions;
	
}

@property (assign) NSComboBox * comboSpecialActions; 
@property (assign) NSMutableArray * displayListSpecialActions; 

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
 - (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index;
/* - (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString;
 - (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString;
 */


@end
