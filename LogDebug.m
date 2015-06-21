/*
 *  LogDebug.c
 *  SpecialKeys
 *
 *  Created by Anastasy on 1/1/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "LogDebug.h"

void _logDebug(NSString *pName, NSString *format,...) {
    va_list ap;
    va_start (ap, format);
    if (![format hasSuffix: @"\n"]) {
		format = [format stringByAppendingString: @"\n"];
    }
    NSString *body =  [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
    fprintf(stderr,"%s: %s",[pName UTF8String], [body UTF8String]);
    [body release];
}