//
//  PPSViewController.h
//  iMagCommands
//
//  Created by Marat Sharifullin on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iMag;

@interface PPSViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) iMag *iMagSwipper;
@property (nonatomic) BOOL bytesFieldEdited;
@property (weak, nonatomic) IBOutlet UITextView *bytesField;
- (IBAction)sendFirmwareLRC:(id)sender;
- (IBAction)sendFirmwareETX:(id)sender;

- (IBAction)sendBytes:(id)sender;

@end
