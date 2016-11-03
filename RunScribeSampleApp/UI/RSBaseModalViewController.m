//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSBaseModalViewController.h"
#import "RSMainViewController.h"

@implementation RSBaseModalViewController

- (IBAction)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)writeMessage:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RSWriteMessageNotification
                                                        object:nil
                                                      userInfo:@{kRSWriteMessageKey:message}];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
