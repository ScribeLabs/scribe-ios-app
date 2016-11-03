//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSBaseModalViewController : UIViewController

/**
 *  Reacts on back button click
 */
- (IBAction)backButtonClicked:(id)sender;

/**
 *  Sends notification to the RSMainViewController in order to present the message in the log view
 */
- (void)writeMessage:(NSString *)message;

/**
 *  Shows an alert with specified title and message
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
