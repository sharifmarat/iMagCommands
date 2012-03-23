//
//  iMag.m
//  IDTech
//
//  Created by Randy Palermo on 5/4/10.
//  Copyright 2010 ID_Tech. All rights reserved.
//

#import "iMag.h"

@implementation iMag

static BOOL _connected = FALSE;


@synthesize os;


// private routines

- (void)accessoryConnected:(NSNotification *)notification {
	
	EAAccessoryManager *p2 = [EAAccessoryManager sharedAccessoryManager];
	[p2 registerForLocalNotifications];
	

	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:) name:@"EAAccessoryDidConnectNotification" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:) name:@"EAAccessoryDidDisconnectNotification" object:nil];
	
	
	for (EAAccessory *acc2 in [p2 connectedAccessories])
	{
		
		NSArray *str = acc2.protocolStrings;
		
		if ([str indexOfObject:@"com.idtechproducts.reader"] != NSNotFound) {
			
		
		
		//if ([[acc2.protocolStrings objectAtIndex:0] isEqualToString:@"com.idtechproducts.reader"]  ) 
			
		//{
			
			acc2.delegate = self;
			_connected = TRUE;
			EASession *session = [[EASession alloc] initWithAccessory:acc2 forProtocol:@"com.idtechproducts.reader"];
			[session.outputStream setDelegate:(id)self];
			[session.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[session.outputStream open];
			[session.inputStream setDelegate:(id)self];
			[session.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[session.inputStream open];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"iMagDidConnectNotification" object:acc2];
			
		//}		
		}
	}		
	
	
	
}

- (void)accessoryDisconnected:(NSNotification *)notification {
	
	_connected = FALSE;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"iMagDidDisconnectNotification" object:nil];
	
}


///////////




-(id)init
{
    if (self = [super init])
    {
		EAAccessoryManager *p = [EAAccessoryManager sharedAccessoryManager];
		
		[p registerForLocalNotifications];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:) name:@"EAAccessoryDidConnectNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:) name:@"EAAccessoryDidDisconnectNotification" object:nil];
		
		_connected = FALSE;
		for (EAAccessory *acc in [p connectedAccessories])
		{
			
			acc.delegate = self;
			
			if ([acc.protocolStrings count] > 0 && [[acc.protocolStrings objectAtIndex:0] isEqualToString:@"com.idtechproducts.reader"]  ) 
				//if ([[acc.protocolStrings objectAtIndex:0] isEqualToString:@"com.idtechproducts.reader"]  ) 
			{
				
				_connected = TRUE;
				EASession *session = [[EASession alloc] initWithAccessory:acc forProtocol:@"com.idtechproducts.reader"];
				NSLog(@"session: %@", session);
				NSLog(@"input stream: %@", session.inputStream);
				NSLog(@"output stream: %@", session.outputStream);
				[session.outputStream setDelegate:(id)self];
				[session.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
				[session.outputStream open];
				[session.inputStream setDelegate:(id)self];
				[session.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
				[session.inputStream open];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"iMagDidConnectNotification" object:acc];
				
			}		
			
		}
    }
    return self;
}



- (void) sendCommand: (NSString*)cmd
{
	NSLog(@"Sending Command: %@",cmd );
	const uint8_t *rawString=(const uint8_t *)[cmd UTF8String];
	
	[(NSOutputStream *)os write:rawString maxLength:[cmd length]];	
}

- (void) sendCommandWithData: (NSData*)cmd
{
    NSLog(@"Sending Command: %@",cmd );
	const uint8_t *rawString=(const uint8_t *)[cmd bytes];
    
	if ( [(NSOutputStream *)os hasSpaceAvailable])
    {
        NSInteger written_data = [(NSOutputStream *)os write:rawString maxLength:[cmd length]];	
        NSLog( @"Data written: %i to stream %@", written_data, os );
    }
}


- (void)stream:(NSStream*)theStream handleEvent:(NSStreamEvent)streamEvent  
{  
	switch (streamEvent)  
	{  
		case NSStreamEventNone:  //Sent when open complete
			NSLog(@"NSStreamEventNone");
			break;		
            
		case NSStreamEventOpenCompleted:  //Sent when open complete
			NSLog(@"NStreamEventOpenCompleted: %@", theStream);
			break;
			
		case NSStreamEventHasBytesAvailable:
		{
			NSLog(@"NSStreamEventHasBytesAvailable");
			
			uint8_t buffer[1024];
			unsigned int len=0;
			
			len=[(NSInputStream *)theStream  read:buffer maxLength:1024];
			if(len>0){      
				NSData* data=[NSData dataWithBytes:buffer length:len];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"iMagDidReceiveDataNotification" object:data];
			}
            break;
        }
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable with theStream = %@", theStream);
			self.os = theStream;
			break;
			
		case NSStreamEventErrorOccurred:  
			NSLog(@"NSStreamEventErrorOccurred");
			break;			
			
		case NSStreamEventEndEncountered:  
			NSLog(@"NSStreamEventEndEncountered");
			break;			
			
        default:
            NSLog(@"stream-switch-default");
			break;  
	}  
} 



-(BOOL) iMagConnected{
	return _connected;
}



@end
