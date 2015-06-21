//
//  SheetAddKeyController.m
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SheetAddKeyController.h"
#import "basics.h"
#import "LogDebug.h"



@implementation SheetAddKeyController
@synthesize comboSpecialActions; 
@synthesize displayListSpecialActions; 

- (void)awakeFromNib {
	
	self.displayListSpecialActions = [[NSMutableArray alloc]init];
	//[self.displayListSpecialActions addObject:@"AAA"];
	[comboSpecialActions reloadData];
	
} // end awakeFromNib


/*- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
	return @"AAA";
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
	return 0;
}*/

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	logDebug(@"numberOfItemsInComboBox");
	if ([aComboBox isEqual:comboSpecialActions])
		return [displayListSpecialActions count]; else
			return 0;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	logDebug(@"objectValueForItemAtIndex");
	if ([aComboBox isEqual:comboSpecialActions])
		return [displayListSpecialActions objectAtIndex:index]; else
			return nil;
}



@end
