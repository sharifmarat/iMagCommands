//
//  PPSViewController.m
//  iMagCommands
//
//  Created by Marat Sharifullin on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PPSViewController.h"
#import "iMag.h"

@interface PPSViewController ()
- (void) iMagConnected:(NSNotification *)notification;
- (void) iMagDisconnected:(NSNotification *)notification;
- (void) iMagReceivedData:(NSNotification *)notification;
- (void) enableControllers:(BOOL)yesOrNo;
@end

@implementation PPSViewController
@synthesize iMagSwipper;
@synthesize bytesField;
@synthesize statusLabel;
@synthesize bytesFieldEdited;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iMagConnected:) name:@"iMagDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iMagDisconnected:) name:@"iMagDidDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iMagReceivedData:) name:@"iMagDidReceiveDataNotification" object:nil];
    self.iMagSwipper = [[iMag alloc] init];
    self.bytesFieldEdited = NO;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setStatusLabel:nil];
    [self setBytesField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return NO;
    else
        return YES;
}

- (void) enableControllers:(BOOL)yesOrNo
{
}

- (IBAction)sendFirmwareLRC:(id)sender
{
    const uint8_t buf[] = {0x02, 0x52, 0x22, 0x03, 0x71};
    NSData *cmd = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
    [self.iMagSwipper sendCommandWithData:cmd];
}

- (IBAction)sendFirmwareETX:(id)sender
{
    const uint8_t buf[] = {0x02, 0x52, 0x22, 0x03, 0x03};
    NSData *cmd = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
    [self.iMagSwipper sendCommandWithData:cmd];
}

- (IBAction)sendFirmwareNOP:(id)sender
{
    const uint8_t buf[] = {0x02, 0x52, 0x22, 0x03};
    NSData *cmd = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
    [self.iMagSwipper sendCommandWithData:cmd];
}

- (IBAction)sendBytes:(id)sender
{
    [self.bytesField resignFirstResponder];
    NSString *cmdStr = [self.bytesField.text copy];
    if (!self.bytesFieldEdited || cmdStr.length == 0)
    {
        [self showAlert:@"Error" message:@"Enter bytes first"];
        return;
    }
    else if ([cmdStr isEqualToString:@"xx"])
    {
        [[[UIAlertView alloc] initWithTitle:@"Easter Egg"
                                    message:@"My software never has bugs. It just develops random features"
                                   delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:nil] show];
        return;
    }
    cmdStr = [cmdStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *cmd = [[NSMutableData alloc] init];
    
    uint8_t whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [cmdStr length]/2; ++i)
    {
        byte_chars[0] = [cmdStr characterAtIndex:i*2];
        byte_chars[1] = [cmdStr characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [cmd appendBytes:&whole_byte length:1]; 
    }
    [self.iMagSwipper sendCommandWithData:cmd];
    NSLog(@"%@", cmd);
}

#pragma mark - iMagNotifications
- (void) iMagConnected:(NSNotification *)notification
{
    
    if ([[notification object] isKindOfClass:[EAAccessory class]])
    {
        EAAccessory *acc = [notification object];
        self.iMagSwipper = acc.delegate;
        self.statusLabel.text = [NSString stringWithFormat: @"Connected %@ %@", acc.name, acc.firmwareRevision];
    }
    else
    {
        self.statusLabel.text = @"Connected iMag with no EAAcessory support";
    }
}

- (void) iMagDisconnected:(NSNotification *)notification
{
    self.statusLabel.text = @"iMag disconnected";
}

- (void) iMagReceivedData:(NSNotification *)notification
{
    NSData *data = [notification object];
    NSString *log = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@  =>>  %@", data, log);
    [self showAlert:@"Received Data" message:[NSString stringWithFormat:@"Received next bytes: %@ \n\n UTF8 interpretation: %@", data, log]];
}


- (void) showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}




#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!bytesFieldEdited)
    {
        textView.text = @"";
        self.bytesFieldEdited = YES;
    }
    return YES;
}




@end
