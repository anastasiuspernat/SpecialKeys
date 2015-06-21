//
//  SpecialKeysPref.h
//  SpecialKeys
//
//  Created by Anastasius on 25/12/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <BWToolkitFramework/BWAnchoredButton.h>
#import <BWToolkitFramework/BWAnchoredPopUpButton.h>
#import <Layouts.h>
#import "keysViewController.h"
#import "NSRecordKey.h"
#import "SheetAddKey.h"
#import "SheetAddKeyController.h"
#import "connectToVoodoo.h"
#import "basics.h"
#import "LogDebug.h"

@interface SpecialKeysPref : NSPreferencePane 
{
	IBOutlet NSTextField *textStatus;
	IBOutlet BWAnchoredButton *buttonAdd;
	IBOutlet BWAnchoredPopUpButton *buttonLayouts;
	IBOutlet keysViewController *keysViewer;
	IBOutlet SheetAddKey *sheetAddKey;
	IBOutlet SheetAddKeyController *sheetAddKeyController;
	IBOutlet NSPanel *sheetError; 
	IBOutlet NSTextField *textSheetError; 
	IBOutlet NSPanel *sheetQuestion;
	IBOutlet NSPanel *sheetEnterText;
	IBOutlet NSTextField *sheetEnterTextField;
	IBOutlet NSTextField * textDuplicateKey;
	BOOL scanCodeModified;
	
	
	
	BOOL resultSheetQuestion;
	SEL OnYesPressed;
	NSPanel *currentSheet;

	
	connectToVoodoo *voodooPS2Keyboard;
	
	Layouts *layouts;
	
}

@property (assign) BWAnchoredPopUpButton * buttonLayouts; 
@property (assign) keysViewController * keysViewer; 
@property (assign) SheetAddKey * sheetAddKey; 
@property (assign) SheetAddKeyController *sheetAddKeyController;
@property (assign) NSPanel * sheetError; 
@property (assign) NSPanel * sheetQuestion;
@property (assign) NSPanel * sheetEnterText; 
@property (assign) NSTextField * sheetEnterTextField; 
@property (assign) NSTextField * textSheetError; 
@property (assign) NSTextField * textDuplicateKey; 




- (IBAction) buttonAddClick: sender;
- (IBAction) buttonDeleteClick: sender;
- (IBAction) cancelAddKey:(id)pId;
- (IBAction) createAddKey:(id)pId;
- (IBAction) dismissError:(id)pId;

- (IBAction) buttonYesPressed: sender;
- (IBAction) buttonNoPressed: sender;

- (IBAction) buttonMoveUp:(id)pId;
- (IBAction) buttonMoveDown:(id)pId;

- (IBAction) buttonAddLayout:(id)pId; 
- (IBAction) buttonDeleteLayout:(id)pId; 
- (IBAction) buttonLayoutClick:(id)pId; 

- (void) debugOutput:(NSString *)text;

- (void) updateTableFromCurrentLayout;
- (void) updateCurrentLayoutFromTable;
- (void) mainViewDidLoad;

- (void) updateAllKeysFromCurrentLayout;

@end
