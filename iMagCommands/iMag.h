//
//  iMag.h
//  IDTech
//
//  Created by Randy Palermo on 5/4/10.
//  Copyright 2010 ID_Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import	<ExternalAccessory/ExternalAccessory.h>





@interface iMag : NSObject <EAAccessoryDelegate> {

	NSStream *os;

	
}


-(id)init;

- (void) sendCommand: (NSString*)cmd;
- (void) sendCommandWithData: (NSData*)cmd;


@property (nonatomic, retain) NSStream	*os;
@property (readonly) BOOL iMagConnected;


@end
