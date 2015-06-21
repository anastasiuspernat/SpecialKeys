//
//  connectToVoodoo.m
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "connectToVoodoo.h"
#include "UserKernelShared.h"
#import "basics.h"
#import "LogDebug.h"



@implementation connectToVoodoo


- (void) debugOutput:(NSString *)text
{
	logDebug(@"%@",text);
	//[textStatus setStringValue:text];
}

- (void)disconnect
{
    kern_return_t kernResult = IOServiceClose(connect);

	// Release the io_iterator_t now that we're done with it.
    IOObjectRelease(iterator);
	
	if (driverFound == false) {
		[self debugOutput:@"No matching drivers found."];
	}
	
}

- (bool)connect
{
	kern_return_t	res;
	//mach_port_t		masterPort;
	//sig_t			oldHandler;
	res = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("ApplePS2Keyboard"), &iterator);
    driverFound = false;
    if (res != KERN_SUCCESS) {
		[self debugOutput:@"Error connecting to IO subsystem"];
        //fprintf(stderr, "IOServiceGetMatchingServices returned 0x%08x\n\n", res);
        return false;
    }
	int i=0;
    while ((service = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
		i++;
		driverFound = true;
		[self debugOutput:[NSString stringWithFormat:@"Found a device of class ApplePS2Keyboard, instance: %d",i]];
		break;
		//[self sendMessageTo:service messageId:message_id callback:callback];
	}
    kern_return_t kernResult = IOServiceOpen(service, mach_task_self(), 0, &connect);
    if (kernResult != KERN_SUCCESS) {
        //[self debugOutput:["IOServiceOpen returned 0x%08x\n", kernResult);
		[self debugOutput:[NSString stringWithFormat:@"IOServiceOpen error: 0x%08x", kernResult]];
		return false;
    }
	return true;
	
}


- (void) messageToPS2Keyboard:(int)messageId
			  callback:(io_user_reference_t)callback


{
	kern_return_t kernResult;
	/*kernResult = IOConnectCallScalarMethod(connect, kMyUserClientOpen, NULL, 0, NULL, NULL);
	 if (kernResult != KERN_SUCCESS) {
	 //fprintf(stderr, "kMyUserClientOpen returned 0x%08x\n", kernResult);
	 [self debugOutput:[NSString stringWithFormat:@"IOConnectCallScalarMethod error: 0x%08x", kernResult]];
	 //[self debugOutput:@"IOConnectCallScalarMethod error"];
	 
	 return;
	 }*/
	
	// next 2 lines are same
	//IONotificationPortRef wakePort = IONotificationPortCreate(masterPort);
	IONotificationPortRef wakePort = IONotificationPortCreate(kIOMasterPortDefault);
	mach_port_t wakePortMach = IONotificationPortGetMachPort(wakePort);
	//OSAsyncReference64 asyncRef; // does not work on 32bit(or 10.5?)!!!
	uint64_t asyncRef[8];
	asyncRef[kIOAsyncReservedIndex] = wakePortMach;
	asyncRef[kIOAsyncCalloutFuncIndex] = callback; //(io_user_reference_t) callback;
	asyncRef[kIOAsyncCalloutRefconIndex] = 0;
	[self debugOutput:@"3"];
	
	// send notification
	kernResult = IOConnectCallAsyncMethod(connect, 	//mach_port_t	 connection,		// In
										  messageId, // uint32_t	 selector,		// In
										  wakePortMach, // mach_port_t	 wake_port,		// In
										  asyncRef, // uint64_t	*reference,		// In
										  kOSAsyncRef64Count, // uint32_t	 referenceCnt,		// In
										  NULL,
										  0,
										  NULL,
										  0,
										  NULL,
										  NULL,
										  NULL,
										  NULL
										  );
	if (kernResult != KERN_SUCCESS) {
        fprintf(stderr, "IOConnectCallAsyncMethod returned 0x%08x\n", kernResult);
		return;
    }
	
	[self debugOutput:@"OK"];
	
	CFRunLoopSourceRef runloopSource = IONotificationPortGetRunLoopSource(wakePort);
	CFRunLoopRef runloop = CFRunLoopGetCurrent();
	CFRunLoopAddSource(runloop, runloopSource, kCFRunLoopDefaultMode);
	CFRunLoopRun();
	
	// We should never get here
    fprintf(stderr, "Unexpectedly back from CFRunLoopRun()!\n");
}

dataRefCon * dataRefcon;// = (dataRefCon *)malloc(sizeof(dataRefCon));

void callbackSetData(void *refcon, IOReturn result, void **args, uint32_t numArgs)
{
	//dataRefCon *data = (dataRefCon*)args;
	char * buffer = (char *)args;
	logDebug(@"CALLBACK TRIGGERED (address=%p)\n", buffer);
	//[mySelf scanCodeReceived:scanCode];
}


- (void) updatePS2Keys:(int)messageId
			  scanCode:(int)scanCode
			   adbCode:(int)adbCode
			  callback:(io_user_reference_t)callback




{
	kern_return_t kernResult;
	/*kernResult = IOConnectCallScalarMethod(connect, kMyUserClientOpen, NULL, 0, NULL, NULL);
	 if (kernResult != KERN_SUCCESS) {
	 //fprintf(stderr, "kMyUserClientOpen returned 0x%08x\n", kernResult);
	 [self debugOutput:[NSString stringWithFormat:@"IOConnectCallScalarMethod error: 0x%08x", kernResult]];
	 //[self debugOutput:@"IOConnectCallScalarMethod error"];
	 
	 return;
	 }*/
	
	// next 2 lines are same
	//IONotificationPortRef wakePort = IONotificationPortCreate(masterPort);
	mach_port_t masterPort;
	IOMasterPort(MACH_PORT_NULL, &masterPort);
	IONotificationPortRef wakePort = IONotificationPortCreate(masterPort);
	mach_port_t wakePortMach = IONotificationPortGetMachPort(wakePort);
	//OSAsyncReference64 asyncRef; // does not work on 32bit(or 10.5?)!!!
	//OSAsyncReference64 *iii;
	uint64_t *asyncRef = malloc(8*sizeof(uint64_t));
	asyncRef[kIOAsyncReservedIndex] = wakePortMach;

	/*dataRefcon = (dataRefCon *)malloc(sizeof(dataRefCon));

	dataRefcon->buffer = buffer;*/
	asyncRef[3] = adbCode;
	asyncRef[kIOAsyncCalloutRefconIndex] = scanCode;
	asyncRef[kIOAsyncCalloutFuncIndex] = (io_user_reference_t) callback; //adbCode; //((uint64_t)dataRefcon & (uint64_t)0xffffffff00000000) >> 32; //(io_user_reference_t) callback;
	logDebug(@"messageToPS2Keyboard SENDING DATA: %x",asyncRef[kIOAsyncCalloutRefconIndex]);
//	logDebug(@"messageToPS2Keyboard SENDING DATA: %p %p %p %p %p %p %p %p",dataRefcon,asyncRef[0],asyncRef[1],asyncRef[2],asyncRef[3],asyncRef[4],asyncRef[5],asyncRef[6],asyncRef[7]);
//	[self debugOutput:@"3"];
	
	// send notification
	kernResult = IOConnectCallAsyncMethod(connect, 	//mach_port_t	 connection,		// In
										  messageId, // uint32_t	 selector,		// In
										  wakePortMach, // mach_port_t	 wake_port,		// In
										  asyncRef, // uint64_t	*reference,		// In
										  kOSAsyncRef64Count, // uint32_t	 referenceCnt,		// In
										  NULL,
										  0,
										  NULL,
										  0,
										  NULL,
										  NULL,
										  NULL,
										  NULL
										  );
	/*kernResult = IOConnectCallMethod(connect, 	//mach_port_t	 connection,		// In
										  messageId, // uint32_t	 selector,		// In
										  asyncRef, // uint64_t	*reference,		// In
										  kOSAsyncRef64Count, // uint32_t	 referenceCnt,		// In
										  NULL,
										  0,
										  NULL,
										  0,
										  NULL,
										 0
										  );*/
	if (kernResult != KERN_SUCCESS) {
        fprintf(stderr, "IOConnectCallAsyncMethod returned 0x%08x\n", kernResult);
		return;
    }
	
	[self debugOutput:@"OK"];
	

	
	CFRunLoopSourceRef runloopSource = IONotificationPortGetRunLoopSource(wakePort);
	CFRunLoopRef runloop = CFRunLoopGetCurrent();
	CFRunLoopAddSource(runloop, runloopSource, kCFRunLoopDefaultMode);
	//CFRunLoopRun();
	
	// We should never get here
    fprintf(stderr, "Unexpectedly back from CFRunLoopRun()!\n");
}



@end
