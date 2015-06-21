//
//  keysViewController.m
//  SpecialKeys
//
//  Created by Anastasius on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "keysViewController.h"
#import "basics.h"
#import "LogDebug.h"


@implementation keysViewController
@synthesize keysViewObjArray;
@synthesize tableKeys;

- (void)awakeFromNib {
	
	self.keysViewObjArray = [[NSMutableArray alloc]init];
	
	[tableKeys reloadData];
	
} // end awakeFromNib


- (IBAction)addAtSelectedRow:(id)pId {
	if ([tableKeys selectedRow] > -1) {
		NSString * zStr1 = @"Text Cell 1";
		NSString * zStr2 = @"Text Cell 2";
		keyViewObj * zDataObject = [[keyViewObj alloc]initWithKeyName:zStr1 
														keyActionName:zStr2];
		[self.keysViewObjArray insertObject:zDataObject atIndex:[tableKeys selectedRow]];
		[tableKeys reloadData];
	} // end if
	
} // end deleteSelectedRow

- (IBAction)deleteSelectedRow:(id)pId {
} // end deleteSelectedRow


- (void)addRow:(keyViewObj *)pDataObj {
	[self.keysViewObjArray addObject:pDataObj];
	[tableKeys reloadData];
} // end addRow


- (int)numberOfRowsInTableView:(NSTableView *)pTableViewObj {
	return [self.keysViewObjArray count];
} // end numberOfRowsInTableView

- (id) tableView:(NSTableView *)pTableViewObj objectValueForTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex {
	keyViewObj * zDataObject	= (keyViewObj *)[self.keysViewObjArray objectAtIndex:pRowIndex];
	if (! zDataObject) {
		logDebug(@"tableView:objectValueForTableColumn:row: objectAtIndex:%d = NULL",pRowIndex);
		return NULL;
	} // end if
	//logDebug(@"pTableColumn identifier = %@",[pTableColumn identifier]);
	
	if ([[pTableColumn identifier] isEqualToString:@"columnKeyTitle"]) {
		return [zDataObject keyName];
	}
	
	if ([[pTableColumn identifier] isEqualToString:@"columnAction"]) {
		return [zDataObject keyActionName];
	}
		
	logDebug(@"***ERROR** dropped through pTableColumn identifiers");
	return NULL;
	
} // end tableView:objectValueForTableColumn:row:

- (void)tableView:(NSTableView *)pTableViewObj setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex {
	keyViewObj * zDataObject	= (keyViewObj *)[self.keysViewObjArray objectAtIndex:pRowIndex];
	if ([[pTableColumn identifier] isEqualToString:@"columnKeyTitle"]) {
		[zDataObject setKeyName:(NSString *)pObject];
	}
	
	if ([[pTableColumn identifier] isEqualToString:@"columnAction"]) {
		[zDataObject setKeyActionName:(NSString *)pObject];
	}
	
} // end tableView:setObjectValue:forTableColumn:row:

@end
