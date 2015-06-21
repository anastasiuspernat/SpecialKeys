//
//  NSRecordKey.m
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSRecordKey.h"
#import "SpecialKeysPref.h"


@implementation NSRecordKey


-(BOOL)becomeFirstResponder
{
	[(SheetAddKey*)[self window] setRecorderBecameFirstResponder:YES];
    return [super becomeFirstResponder];
}
-(BOOL)resignFirstResponder
{
return [super resignFirstResponder];
}
@end
