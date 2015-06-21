//
//  keysViewController.h
//  SpecialKeys
//
//  Created by Anastasius on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "keyViewObj.h"

@interface keysViewController : NSControl {
	IBOutlet NSTableView *tableKeys;
	NSMutableArray *keysViewObjArray;
	
}

@property (assign) NSMutableArray * keysViewObjArray;
@property (assign) NSTableView * tableKeys;


- (IBAction)addAtSelectedRow:(id)pId;
- (IBAction)deleteSelectedRow:(id)pId;

- (void)addRow:(keyViewObj *)pDataObj;

//- (void)removeRow:(NSUInteger)pRow;

- (int)numberOfRowsInTableView:(NSTableView *)pTableViewObj;

- (id) tableView:(NSTableView *)pTableViewObj objectValueForTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex;

- (void)tableView:(NSTableView *)pTableViewObj setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(int)pRowIndex;

@end