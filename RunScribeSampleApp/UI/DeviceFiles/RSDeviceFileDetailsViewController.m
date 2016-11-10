//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSDeviceFileDetailsViewController.h"
#import "RSMainViewController.h"
#import "RSDeviceRequestsHelper.h"
#import "MBProgressHUD.h"
#import "RSFileInfoCmd.h"

@interface RSDeviceFileDetailsViewController ()

@property (nonatomic, weak) IBOutlet UITextField *indexTextField;
@property (nonatomic, weak) IBOutlet UITextField *sizeTextField;
@property (nonatomic, weak) IBOutlet UITextField *statusTextField;
@property (nonatomic, weak) IBOutlet UITextField *minVoltageTextField;
@property (nonatomic, weak) IBOutlet UITextField *crcStatusTextField;

@end

@implementation RSDeviceFileDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak RSDeviceFileDetailsViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [RSDeviceRequestsHelper readFileInformation:self.fileIndex device:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceFileDetailsViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to read file information. Error: %@", strongSelf.device.name, error]];
                [strongSelf showErrorAlertWithMessage:@"Error occurred while reading file information. Please, try again."];
            }
            else
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - read information about file with index %li", strongSelf.device.name, (long)strongSelf.fileIndex]];
                RSFileInfoCmd *fileInfoResponse = (RSFileInfoCmd *)sourceCmd;
                [strongSelf updateUI:fileInfoResponse];
            }
        });
    }];
}

- (void)updateUI:(RSFileInfoCmd *)fileInfoResponse
{
    [self.indexTextField setText:[NSString stringWithFormat:@"%i", fileInfoResponse.fileIndex]];
    [self.sizeTextField setText:[NSString stringWithFormat:@"%i bytes", fileInfoResponse.fileSize]];
    [self.statusTextField setText:[self getFileStatusString:fileInfoResponse.fileStatus]];
    [self.minVoltageTextField setText:[NSString stringWithFormat:@"%i mV", fileInfoResponse.voltage]];
    [self.crcStatusTextField setText:[self getCRCStatusString:fileInfoResponse.crcStatus]];
}

#pragma mark - Extra

- (NSString *)getFileStatusString:(RSScribeFileStatus)fileStatus
{
    switch (fileStatus) {
        case kRSFileNotDeleted:
            return @"Not Deleted";
            
        case kRSFileDeleted:
            return @"Deleted";
    }
}

- (NSString *)getCRCStatusString:(RSScribeFileCRCStatus)crcStatus
{
    switch (crcStatus) {
        case kRSFileCRCValid:
            return @"Valid";
            
        case kRSFileCRCInvalid:
            return @"Invalid";
    }
}

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

- (void)showErrorAlertWithMessage:(NSString *)message
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
