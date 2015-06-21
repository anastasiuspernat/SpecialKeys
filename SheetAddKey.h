//
//  PanelAddKey.h
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSRecordKey.h"
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "SheetAddKeyController.h"
#import "OrderedDictionary.h"

@interface SheetAddKey : NSPanel {
	BOOL recorderIsFirstResponder, recorderBecameFirstResponder;
	IBOutlet NSRecordKey *textScanCode;
	IBOutlet NSTextField * textKeyTitle;
	IBOutlet SRRecorderControl *shortcutRecorder;
	IBOutlet SheetAddKeyController *controller;
	OrderedDictionary * listSpecialKeys;
	IBOutlet NSMatrix *matrixActionType;
	IBOutlet NSTextField *textKeyAssigned;
	IBOutlet NSButton *buttonCreate;
}

@property (assign) NSRecordKey * textScanCode; 
@property (assign) NSTextField * textKeyTitle; 
@property (assign) SRRecorderControl * shortcutRecorder; 
@property (assign) SheetAddKeyController * controller; 
@property (assign) OrderedDictionary * listSpecialKeys; 
@property (nonatomic, readwrite, assign) BOOL recorderBecameFirstResponder;
@property (assign) NSMatrix * matrixActionType;
@property (assign) NSTextField * textKeyAssigned;
@property (assign) NSButton *buttonCreate;

- (BOOL) recorderIsFocused;
//- (IBAction) shortcutChanged:(id)pId;

@end
