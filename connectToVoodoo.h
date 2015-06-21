//
//  connectToVoodoo.h
//  SpecialKeys
//
//  Created by Anastasius on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface connectToVoodoo : NSObject {
    io_service_t	service;
    io_iterator_t 	iterator;
    io_connect_t				connect;
	bool			driverFound;

}

- (void)disconnect;
- (bool)connect;
- (void) messageToPS2Keyboard:(int)messageId
					 callback:(io_user_reference_t)callback;
- (void) updatePS2Keys:(int)messageId
			  scanCode:(int)scanCode
			   adbCode:(int)adbCode
			  callback:(io_user_reference_t)callback;

@end
