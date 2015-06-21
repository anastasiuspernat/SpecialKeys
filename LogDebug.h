/*
 *  LogDebug.h
 *  SpecialKeys
 *
 *  Created by Anastasy on 1/1/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

//#define DEBUG

#ifdef DEBUG
#define logDebug(args...) _logDebug(progName,args);
#else
#define logDebug(x...)
#endif




void _logDebug(NSString *pName, NSString *format,...);
