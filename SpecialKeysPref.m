//
//  SpecialKeysPref.m
//  SpecialKeys
//
//  Created by Anastasius on 25/12/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "SpecialKeysPref.h"
#import "Layouts.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <IOKit/IOKitLib.h>
#include "keysViewController.h"
#include "keyViewObj.h"
#include "OrderedDictionary.h"
#include "UserKernelShared.h"
#include <ShortcutRecorder/ShortcutRecorder.h>
#include "SheetAddKeyController.h"
#include "NSMutableArrayExtensions.h"
#include "basics.h"
#include "LogDebug.h"



@implementation SpecialKeysPref

@synthesize buttonLayouts; 
@synthesize keysViewer; 
@synthesize sheetAddKey; 
@synthesize sheetAddKeyController; 
@synthesize sheetError; 
@synthesize sheetQuestion; 
@synthesize sheetEnterText;
@synthesize sheetEnterTextField;
@synthesize textSheetError;
@synthesize textDuplicateKey;

char bufferKeys[] = "hellooo";


- (void) mainViewDidLoad
{
		
	logDebug(@"-------------------------------------------------------");
	voodooPS2Keyboard = [[connectToVoodoo alloc] init];

	
	NSMutableDictionary * d = [[[NSBundle bundleForClass:[self class]] infoDictionary] 
							   objectForKey:@"specialKeysCodes"];
	SheetAddKeyController *controller = sheetAddKey.controller;
	OrderedDictionary * od;
	od = [OrderedDictionary dictionaryWithCapacity:0];
	[od addEntriesFromDictionary:d];
	layouts = [Layouts initLayoutsWithSpecialKeysCodes:od];
	// save new currentlayout file for SpecialKeysTray
	[layouts saveToDisk];

	logDebug(@"1111111111111111111111111111111111111");
	logDebug(@"mainViewDidLoad: updateAllKeysFromCurrentLayout....");
	logDebug(@"2222222222222222222222222222222222222");
	[self updateAllKeysFromCurrentLayout];
	logDebug(@"mainViewDidLoad: updateAllKeysFromCurrentLayout... OK");
	logDebug(@"3333333333333333333333333333333333333");

	logDebug(@"-------------------------------------------------------");
	
	NSMutableArray *lKeys = [[layouts getLayouts] allKeys];
	int i;
	for (i=0;i<[lKeys count];i++)
		[buttonLayouts insertItemWithTitle:[lKeys objectAtIndex:i] atIndex:i+1];

	[self updateTableFromCurrentLayout];
	
	
	sheetAddKey.listSpecialKeys = od;
	lKeys = [od allKeys];
	
	NSSortDescriptor *sort=[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]autorelease];
	NSArray *sortedDesc = [NSArray arrayWithObject:sort];
	[lKeys sortUsingDescriptors:sortedDesc];
	
	
	for (i=0;i<[lKeys count];i++)
	{
		[controller.displayListSpecialActions addObject:[lKeys objectAtIndex:i]];
	}
	
	logDebug(@"-------------------------------------------------------");
	
	[controller.comboSpecialActions reloadData];
	if ([lKeys count]>0)
	{
			[controller.comboSpecialActions selectItemAtIndex:0];
		//[controller.comboSpecialActions setObjectValue:[controller.comboSpecialActions objectValueOfSelectedItem]];
	}
	
	logDebug(@"-------------------------------------------------------");
}

void callback1(void *refcon, IOReturn result, void **args, uint32_t numArgs)
{
	logDebug(@"SpecialKeys: updateKeys callback triggered\n");
}

- (void) updateTableFromCurrentLayout;
{
	logDebug(@"Special Keys: updateTableFromCurrentLayout");
	int i;
	NSArray *lKeys;
	lKeys = [[layouts getCurrentLayout] allKeys];
	keysViewer.keysViewObjArray = [[NSMutableArray alloc] init];
	//OrderedDictionary *od = [layouts getCurrentLayout];
	/*for (i=0;i<[lKeys count];i++)
	{
		NSString *key = [od keyAtIndex:i];
	}*/
	
	for (i=0;i<[lKeys count];i++)
	{
		NSString *key = [lKeys objectAtIndex:i];
		NSString *action = [[layouts getCurrentLayout] objectForKey:key];
		action = [[action componentsSeparatedByString:@","] objectAtIndex:1];
		
		keyViewObj *keyView = [[keyViewObj alloc] initWithKeyName:key keyActionName:action];
		[keysViewer addRow:keyView];
	}
	logDebug(@"Special Keys: updateTableFromCurrentLayout 2");
	[buttonLayouts setTitle:[NSString stringWithFormat:@"Layout: %@", layouts.currentLayoutTitle]];
	[keysViewer.tableKeys reloadData];

	NSArray *menu = [[buttonLayouts menu] itemArray];
	for (i=0;i<[menu count];i++)
	{
		NSMenuItem *menuItem = [[buttonLayouts menu] itemAtIndex:i];
		NSString *title = [menuItem title];
		if (![title isEqualToString:@"Add layout"] && ![title isEqualToString:@"Delete layout"])
			[menuItem setImage:nil];
	}
	logDebug(@"Special Keys: updateTableFromCurrentLayout: %@ : %d",layouts.currentLayoutTitle,[lKeys count]);
	NSMenuItem *menuItem = [[buttonLayouts menu] itemWithTitle:layouts.currentLayoutTitle];
	[menuItem setImage:[NSImage imageNamed:NSImageNameMenuOnStateTemplate]];
	
}

- (void) updateCurrentLayoutFromTable
{
	int i;
	//OrderedDictionary * rawCurrentLayout = [layouts getRawLayoutByTitle:layouts.currentLayoutTitle];
	
	// currentLayout contains title->action pairs without leading numbers
	OrderedDictionary * currentLayout = [layouts getCurrentLayout];
	// newCurrentLayout will contain leading number,title->action pairs with new order
	OrderedDictionary * newRawCurrentLayout = [[OrderedDictionary alloc] init];
	for (i=0;i<[keysViewer.tableKeys numberOfRows];i++)
	{
		keyViewObj *keyView = [keysViewer.keysViewObjArray objectAtIndex:i];
		NSString *title = keyView.keyName;
		NSString *newKey = [NSString stringWithFormat:@"%03d,%@",(i+1),title];
		NSString *action = [currentLayout objectForKey:title];
		[newRawCurrentLayout insertObject:action forKey:newKey atIndex:i];
	}
	OrderedDictionary * layoutsData = [layouts getLayouts];
	[layoutsData setObject:newRawCurrentLayout forKey:layouts.currentLayoutTitle];
	[layouts rebuildCurrentLayoutFromTitle:layouts.currentLayoutTitle];
	[layouts saveToDisk];
}

- (void) updateAllKeysFromCurrentLayout
{
	logDebug(@"updateAllKeysFromCurrentLayout: connecting to voodoo");
	if ([voodooPS2Keyboard connect])
	{
		logDebug(@"updateAllKeysFromCurrentLayout: connecting to voodoo OK");
		OrderedDictionary * currentLayout = [layouts getCurrentLayout];
		NSArray * keys = [currentLayout allKeys];
		int i;
		logDebug(@"updateAllKeysFromCurrentLayout: updating %d voodoo keys",[keys count]);
		for (i=0;i<[keys count];i++)
		{
			logDebug(@"updateAllKeysFromCurrentLayout: key: %d",i);
			NSString * keyPair = [currentLayout objectForKey:[keys objectAtIndex:i]];
			logDebug(@"updateAllKeysFromCurrentLayout: keyPair(%@): %@",[keys objectAtIndex:i],keyPair);
			NSArray * keys = [keyPair componentsSeparatedByString:@","];
			int scanCode = [layouts decodeNumber:[keys objectAtIndex:0]];
			NSString * adbCodeStr = [keys objectAtIndex:1];
			logDebug(@"updateAllKeysFromCurrentLayout: adbCodeStr: %@",adbCodeStr);
			int adbCode = 0;
			if (adbCodeStr && ![adbCodeStr isEqualToString:@""])
			{
			if ([adbCodeStr characterAtIndex:0]=='{')
			{
				logDebug(@"updateAllKeysFromCurrentLayout: adbCode: decode 1");
				adbCode = [layouts decodeSpecialKey:adbCodeStr];
			} else {
				logDebug(@"updateAllKeysFromCurrentLayout: adbCode: decode 2");
				adbCode = [layouts decodeNumber:adbCodeStr];
				
			}
			}
			logDebug(@"updateAllKeysFromCurrentLayout: adbCode: %d",adbCode);

			if (adbCode>0 && scanCode>0)
			{
				logDebug(@"updateAllKeysFromCurrentLayout: updating: %d -> %d",scanCode,adbCode);
				[voodooPS2Keyboard updatePS2Keys:kMyUserUpdateKeys scanCode:(int)scanCode adbCode:(int)adbCode callback:(io_user_reference_t)callback1];
			} else
			{

			}
		}
		logDebug(@"updateAllKeysFromCurrentLayout: voodoo disconnect...");
		[voodooPS2Keyboard disconnect];
		logDebug(@"updateAllKeysFromCurrentLayout: voodoo disconnect...OK");
	} else {
		logDebug(@"updateAllKeysFromCurrentLayout: connecting to voodoo ERROR");
		
		[NSApp beginSheet:sheetError modalForWindow:[NSApp mainWindow]
			modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
	}
}


- (void) sendKeyPairToVoodoo:(int)scanKey
					  adbKey:(int)adbKey
{
	if ([voodooPS2Keyboard connect])
	{
		[voodooPS2Keyboard updatePS2Keys:kMyUserUpdateKeys scanCode:(int)scanKey adbCode:(int)adbKey callback:(io_user_reference_t)callback1];
		[voodooPS2Keyboard disconnect];
	} else {
		[NSApp beginSheet:sheetError modalForWindow:[NSApp mainWindow]
			modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
	}
	
}

- (void) insertToCurrentLayout:(NSString *)title
					   scanKey:(int)scanKey
						adbKey:(int)adbKey
					  position:(int)pos
{
	OrderedDictionary *currentRawLayout = [layouts getRawLayoutByTitle:layouts.currentLayoutTitle];
	NSArray * keys = [currentRawLayout allKeys];
	int i;
	NSString *key;
	NSString *action;
	int position = pos+1;
	logDebug(@"insertToCurrentLayout: keys");
	for (i=0;i<[keys count];i++)
	{
		logDebug(@"insertToCurrentLayout: key: %@", [keys objectAtIndex:i]);
	}
	
	for (i=0;i<[keys count];i++)
	{
		key = [keys objectAtIndex:i];
		NSArray *keyPair = [key componentsSeparatedByString:@","];
		action = [currentRawLayout objectForKey:key];
	    int index = [[keyPair objectAtIndex:0] intValue];
		logDebug(@"insertToCurrentLayout: old: %@ -> %@", key, action);
		if (index >= position)
		{
			index++;
		}
		[currentRawLayout removeObjectForKey:key];
		[currentRawLayout setObject:action forKey:[NSString stringWithFormat:@"%03d,%@",index,[keyPair objectAtIndex:1]]];
		logDebug(@"insertToCurrentLayout: new: %03d,%@ -> %@",index,[keyPair objectAtIndex:1], action);
	}
	
	key = [NSString stringWithFormat:@"%03d,%@",position,title];
	action = [NSString stringWithFormat:@"%d,%@",scanKey,[layouts encodeSpecialKey:adbKey]];
	[currentRawLayout setObject:action forKey:key];
	logDebug(@"insertToCurrentLayout: insert: %@ -> %@",key, action);
	[layouts rebuildCurrentLayoutFromTitle:layouts.currentLayoutTitle];
	[layouts saveToDisk];
	[self sendKeyPairToVoodoo:scanKey adbKey:adbKey];
	
}



- (void) deleteCurrentLayout
{
	OrderedDictionary * layoutsData = [layouts getLayouts];
	[layoutsData removeObjectForKey:layouts.currentLayoutTitle];
	[[buttonLayouts menu] removeItem:[[buttonLayouts menu] itemWithTitle:layouts.currentLayoutTitle]];
	NSString *oldCurrentLayout = layouts.currentLayoutTitle;
	layouts.currentLayoutTitle = [[layouts allKeys] objectAtIndex:0];
	[layouts rebuildCurrentLayoutFromTitle:layouts.currentLayoutTitle];
	[layouts saveToDisk];
	[self updateTableFromCurrentLayout];
	[layouts deleteLayoutFromDiskByTitle:oldCurrentLayout];
	[self updateAllKeysFromCurrentLayout];
}


- (void) debugOutput:(NSString *)text
{
	logDebug(@"%@",text);
	//[textStatus setStringValue:text];
}

- (void) addLayout
{
	if (![[sheetEnterTextField stringValue] isEqualToString:@""])
	{
		logDebug(@"SpecialKeys: addLayout");
		OrderedDictionary * allLayouts = [layouts getLayouts];
		[allLayouts insertObject:[[OrderedDictionary alloc] init] forKey:[sheetEnterTextField stringValue] atIndex:[[allLayouts allKeys] count]];
		layouts.currentLayoutTitle = [sheetEnterTextField stringValue];
		logDebug(@"SpecialKeys: addLayout: %@",layouts.currentLayoutTitle);
		[layouts rebuildCurrentLayoutFromTitle:layouts.currentLayoutTitle];
		[layouts saveToDisk];
		[buttonLayouts insertItemWithTitle:[sheetEnterTextField stringValue] atIndex:[[[buttonLayouts menu] itemArray] count]-3];
		[self updateTableFromCurrentLayout];
	}
}

- (IBAction) buttonLayoutClick:(id)pId
{
	logDebug(@"SpecialKeys: buttonLayoutClick");
	NSString *currentSelectedLayout = [[buttonLayouts selectedItem] title];
	layouts.currentLayoutTitle = currentSelectedLayout;
	[layouts rebuildCurrentLayoutFromTitle:layouts.currentLayoutTitle];
	[layouts saveToDisk];
	[self updateTableFromCurrentLayout];
	[self updateAllKeysFromCurrentLayout];
	
}

- (IBAction) buttonAddLayout:(id)pId
{
	[sheetEnterTextField setStringValue:@"New layout"];
	OnYesPressed = NSSelectorFromString(@"addLayout");
	currentSheet = sheetEnterText;
	[NSApp beginSheet:sheetEnterText modalForWindow:[NSApp mainWindow]
		modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
}

- (IBAction) buttonDeleteLayout:(id)pId
{
	 if ([[layouts getLayouts] count]<=1)
	 {
		 [textSheetError setStringValue:@"Error: cannot delete an only one layout."];
		 [NSApp beginSheet:sheetError modalForWindow:[NSApp mainWindow]
			 modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
		 
	 } else {
			 resultSheetQuestion = NO;
			 OnYesPressed = NSSelectorFromString(@"deleteCurrentLayout");
			 currentSheet = sheetQuestion;
			 [NSApp beginSheet:sheetQuestion modalForWindow:[NSApp mainWindow]
				 modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
		 
	 }

	
}



- (IBAction) cancelAddKey:(id)pId
{
	[sheetAddKey orderOut:nil];
    [NSApp endSheet:sheetAddKey];
	[voodooPS2Keyboard messageToPS2Keyboard:kMyUserClientStopRecording callback:0];
	[voodooPS2Keyboard disconnect];


}


- (IBAction) createAddKey:(id)pId
{
	if (!scanCodeModified)
	{
		[sheetAddKey.textKeyAssigned setStringValue:[NSString stringWithFormat:@"Key is undefined"]];
		[sheetAddKey.textKeyAssigned setHidden:NO];
		return;
	}
	OrderedDictionary * currentLayout = [layouts getCurrentLayout];
	if ([currentLayout objectForKey:[sheetAddKey.textKeyTitle stringValue]] != nil)
	{
		[textDuplicateKey setHidden:NO];
		return;
	}
	
	[sheetAddKey orderOut:nil];
    [NSApp endSheet:sheetAddKey];
	[voodooPS2Keyboard messageToPS2Keyboard:kMyUserClientStopRecording callback:0];
	[voodooPS2Keyboard disconnect];
	KeyCombo keyCombo = [sheetAddKey.shortcutRecorder keyCombo];
	logDebug(@"SHORTCUT RECEIVED: %x/%x",keyCombo.code,keyCombo.flags);
	// now add this data to table
	int adbCode;
	if ([sheetAddKey.matrixActionType selectedRow]==1)
	{
		logDebug(@"KEYCOMBO SHORTCUT");
		adbCode = keyCombo.code; 
	}else
		{
			int i = [sheetAddKeyController.comboSpecialActions indexOfSelectedItem];
			NSString *specialKey = [NSString stringWithFormat:@"{%@}",[sheetAddKeyController.displayListSpecialActions objectAtIndex:i]];
			adbCode = [layouts decodeSpecialKey:specialKey];
			logDebug(@"SPECIAL SHORTCUT: %@",specialKey);
		}
	keyViewObj * zDataObject = [[keyViewObj alloc]initWithKeyName:[sheetAddKey.textKeyTitle stringValue] 
													keyActionName:[layouts encodeSpecialKey:adbCode]];
	logDebug(@"ADDING NEW SHORTCUT: %@ %d,0x%x",[sheetAddKey.textKeyTitle stringValue],[[sheetAddKey.textScanCode stringValue] intValue],adbCode);

	int index = ([keysViewer.tableKeys selectedRow]>=0 ? [keysViewer.tableKeys selectedRow] : 0 );
	[keysViewer.keysViewObjArray insertObject:zDataObject atIndex:index];
	[keysViewer.tableKeys reloadData];
	// and add it to the real layout data
	[self insertToCurrentLayout:[sheetAddKey.textKeyTitle stringValue] scanKey:[[sheetAddKey.textScanCode stringValue] intValue] adbKey:adbCode position:[keysViewer.tableKeys selectedRow]];
	
}

- (IBAction) dismissError:(id)pId
{
	[sheetError orderOut:nil];
    [NSApp endSheet:sheetError];
}


SpecialKeysPref *mySelf;

- (NSString *)findKeyTitleByScanCode:(int)scanCode
{
	OrderedDictionary *currentLayout = [layouts getRawLayoutByTitle:layouts.currentLayoutTitle];
	NSArray *keys = [currentLayout allKeys];
	int i;
	for (i=0;i<[keys count];i++)
	{
		NSString *key = [keys objectAtIndex:i];
		NSArray *codes = [[currentLayout objectForKey:key] componentsSeparatedByString:@","];
		int keyScanCode = [layouts decodeNumber:[codes objectAtIndex:0]];
		logDebug(@"check: %d (%@) against: %d",keyScanCode,key,scanCode);
		if (keyScanCode == scanCode)
			return key;
	}
	return nil;
}

- (void)scanCodeReceived:(int)scanCode
{
	logDebug(@"Special Keys: received scan code: %d",scanCode);
	if ([sheetAddKey recorderIsFocused])
	{
		scanCodeModified = true;
		[sheetAddKey.textScanCode setStringValue:[NSString stringWithFormat:@"%d",scanCode]];
		[sheetAddKey.textScanCode setTextColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1]];
		NSString * keyTitle = [self findKeyTitleByScanCode:scanCode];
		if (keyTitle)
		{
			[sheetAddKey.textKeyAssigned setStringValue:[NSString stringWithFormat:@"Key is already assigned to \"%@\"",keyTitle]];
			[sheetAddKey.buttonCreate setEnabled:NO];
			[sheetAddKey.textKeyAssigned setHidden:NO];
		} else
		{
			[sheetAddKey.textKeyAssigned setHidden:YES];
			[sheetAddKey.buttonCreate setEnabled:YES];
		}
	}
}

void callback2(void *refcon, IOReturn result, void **args, uint32_t numArgs)
{
	logDebug(@"SpecialKeys: key callback triggered. (key=0x%x)\n", (int)args);
	int scanCode = (int)args;
	[mySelf scanCodeReceived:scanCode];
}

- (IBAction) buttonYesPressed: sender
{
	[currentSheet orderOut:nil];
    [NSApp endSheet:currentSheet];
	[self performSelector: OnYesPressed withObject: nil]; 
}

- (IBAction) buttonNoPressed: sender
{
	[currentSheet orderOut:nil];
    [NSApp endSheet:currentSheet];
}

- (void)deleteTableRow;
{
	[keysViewer.keysViewObjArray removeObjectAtIndex:[keysViewer.tableKeys selectedRow]];
	[keysViewer.tableKeys reloadData];	
	[self updateCurrentLayoutFromTable];
}


- (IBAction) buttonDeleteClick:sender
{
	logDebug(@"SpecialKeys: Delete clicked");
	if ([keysViewer.tableKeys selectedRow] > -1) {
		resultSheetQuestion = NO;
		OnYesPressed = NSSelectorFromString(@"deleteTableRow");
		currentSheet = sheetQuestion;
		[NSApp beginSheet:sheetQuestion modalForWindow:[NSApp mainWindow]
			modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
		
	} // end if
}

- (IBAction) buttonMoveUp:sender
{
	if ([keysViewer.tableKeys selectedRow] > 0) {
		[keysViewer.keysViewObjArray moveObjectFromIndex:[keysViewer.tableKeys selectedRow] toIndex:[keysViewer.tableKeys selectedRow]-1];
		NSIndexSet * idx = [NSIndexSet indexSetWithIndex:[keysViewer.tableKeys selectedRow]-1];
		[keysViewer.tableKeys selectRowIndexes:idx byExtendingSelection:NO];
		[keysViewer.tableKeys reloadData];		
		[self updateCurrentLayoutFromTable];
	}
}

- (IBAction) buttonMoveDown:sender
{
	if ([keysViewer.tableKeys selectedRow] > -1 && [keysViewer.tableKeys selectedRow]<[keysViewer.tableKeys numberOfRows]-1) {
		[keysViewer.keysViewObjArray moveObjectFromIndex:[keysViewer.tableKeys selectedRow] toIndex:[keysViewer.tableKeys selectedRow]+1];
		NSIndexSet * idx = [NSIndexSet indexSetWithIndex:[keysViewer.tableKeys selectedRow]+1];
		[keysViewer.tableKeys selectRowIndexes:idx byExtendingSelection:NO];
		[keysViewer.tableKeys reloadData];		
		[self updateCurrentLayoutFromTable];
	}
}

- (IBAction) buttonAddClick:sender
{
	mySelf = self;
	[sheetAddKey.textScanCode setStringValue:[NSString stringWithFormat:@"Click to record"]];
	[sheetAddKey.textScanCode setTextColor:[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1]];
	[sheetAddKey.textKeyTitle setStringValue:[NSString stringWithFormat:@"New key %d",[keysViewer.tableKeys numberOfRows]+1]];
	[sheetAddKey.textKeyAssigned setHidden:YES];
	[textDuplicateKey setHidden:YES];
	scanCodeModified = false;
	if (![voodooPS2Keyboard connect])
	{
		[textSheetError setStringValue:@"Error: cannot connect to keyboard subsystem. Try to restart, reload VoodooPS2Keyboard.kext, or reinstall drivers."];
		[NSApp beginSheet:sheetError modalForWindow:[NSApp mainWindow]
			modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
	} else
	{
		[voodooPS2Keyboard messageToPS2Keyboard:kMyUserClientStartRecording callback:(io_user_reference_t)callback2];
		[NSApp beginSheet:sheetAddKey modalForWindow:[NSApp mainWindow]
        modalDelegate:NULL didEndSelector:NULL contextInfo:nil];
	}
}



@end
	 

