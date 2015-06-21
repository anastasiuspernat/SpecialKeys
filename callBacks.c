/*
 *  callBacks.c
 *  SpecialKeys
 *
 *  Created by Anastasy on 27/12/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "callBacks.h"

void callbackX(void *refcon, IOReturn result, void **args, uint32_t numArgs)
{
	fprintf(stdout, "callback triggered. (key=0x%x)\n", (int)args);
}	 
