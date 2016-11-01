//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSDeviceStatusViewController.h"
#import "RSMainViewController.h"
#import "MBProgressHUD.h"
#import "RSCommandFactory.h"
#import "RSStatusCmd.h"

@interface RSDeviceStatusViewController ()

@property (nonatomic, weak) IBOutlet UITextField *firmwareVersionField;
@property (nonatomic, weak) IBOutlet UITextField *modeField;
@property (nonatomic, weak) IBOutlet UITextField *diagnosticResultField;
@property (nonatomic, weak) IBOutlet UITextField *fileCountField;
@property (nonatomic, weak) IBOutlet UITextField *fileCountAllField;
@property (nonatomic, weak) IBOutlet UITextField *freeFlashPercentField;
@property (nonatomic, weak) IBOutlet UITextField *temperatureField;
@property (nonatomic, weak) IBOutlet UITextField *lastBootTimeField;
@property (nonatomic, weak) IBOutlet UITextField *batteryTypeField;
@property (nonatomic, weak) IBOutlet UITextField *batteryModeField;
@property (nonatomic, weak) IBOutlet UITextField *batteryVoltageField;
@property (nonatomic, weak) IBOutlet UITextField *batteryPercentField;
@property (nonatomic, weak) IBOutlet UITextField *batteryUsageTimeField;
@property (nonatomic, weak) IBOutlet UITextField *batteryChargingField;

@end

@implementation RSDeviceStatusViewController

- (void)viewWillAppear:(BOOL)animated
{
    __weak RSDeviceStatusViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    // sending the command to device in order to receive its status
    RSStatusCmd *statusCmd = (RSStatusCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdStatus forDevice:self.device];
    [statusCmd setCompletedBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceStatusViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error == nil)
            {
                RSStatusCmd *sCmd = (RSStatusCmd *)sourceCmd;
                [self updateUI:sCmd];
                [self writeMessage:[NSString stringWithFormat:@"Successfully read status of %@", self.device.name]];
            }
            else
            {
                [self writeMessage:[NSString stringWithFormat:@"Failed to read status of %@. Error: %@", self.device.name, error]];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                    message:@"Error occurred while reading device status. Please, try again."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:controller animated:YES completion:nil];
            }
        });
    }];
    [self.device runCmd:statusCmd];
}

- (void)updateUI:(RSStatusCmd *)statusResponse
{
    [self.firmwareVersionField setText:[NSString stringWithFormat:@"%i.%i", statusResponse.versionMajor, statusResponse.versionMinor]];
    [self.modeField setText:[self getOperationModeString:statusResponse.operationMode]];
    [self.diagnosticResultField setText:[NSString stringWithFormat:@"0x%X", statusResponse.diagnosticResult]];
    [self.fileCountField setText:[NSString stringWithFormat:@"%i", statusResponse.fileCount]];
    [self.fileCountAllField setText:[NSString stringWithFormat:@"%i", statusResponse.fileCountAll]];
    [self.freeFlashPercentField setText:[NSString stringWithFormat:@"%i %%", statusResponse.flashFreePercent]];
    [self.temperatureField setText:[NSString stringWithFormat:@"%i", statusResponse.temperature]];
    [self.lastBootTimeField setText:[NSString stringWithFormat:@"%@", statusResponse.lastContacted]];
    [self.batteryTypeField setText:[self getBatteryTypeString:statusResponse.batteryType]];
    [self.batteryModeField setText:[self getBatteryModeString:statusResponse.batteryMode]];
    [self.batteryVoltageField setText:[NSString stringWithFormat:@"%i mV", statusResponse.batteryVoltage]];
    [self.batteryPercentField setText:[NSString stringWithFormat:@"%i %%", statusResponse.batteryPercent]];
    [self.batteryUsageTimeField setText:[NSString stringWithFormat:@"%i min", statusResponse.batteryUsageTime]];
    [self.batteryChargingField setText:[NSString stringWithFormat:@"%i min", statusResponse.batteryChargingTime]];
}

#pragma mark - IBActions

- (IBAction)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Extra

- (NSString *)getOperationModeString:(NSInteger)operationMode
{
    switch (operationMode) {
        case kRSDeviceModeSleeping:
            return @"Sleeping";
            
        case kRSDeviceModeWaiting:
            return @"Waiting";
            
        case kRSDeviceModeRecording:
            return @"Recording";
            
        case kRSDeviceModePaused:
            return @"Paused";
            
        case kRSDeviceModeErasing:
            return @"Erasing";
            
        case kRSDeviceModeSyncing:
            return @"Syncing";
            
        case kRSDeviceModeManufacturing:
            return @"Manufacturing";
            
        case kRSDeviceModeError:
            return @"Error";
            
        default:
            return @"Unknown";
    }
}

- (NSString *)getBatteryTypeString:(NSInteger)batteryType
{
    switch (batteryType) {
        case kRSDeviceBatteryNonRechargeable:
            return @"Lithium";
            
        case kRSDeviceBatteryRechargeable:
            return @"Li-ion";
            
        default:
            return @"Unknown";
    }
}

- (NSString *)getBatteryModeString:(NSInteger)batteryMode
{
    switch (batteryMode) {
        case kRSDeviceBatteryModeActive:
            return @"Active";
            
        case kRSDeviceBatteryModeIdle:
            return @"Idle";
            
        case kRSDeviceBatteryModeSleep:
            return @"Sleep";
            
        default:
            return @"Unknown";
    }
}

#pragma mark - Logging

/**
 *  Sends notification to the RSMainViewController in order to present the message in the log view
 */
- (void)writeMessage:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RSWriteMessageNotification
                                                        object:nil
                                                      userInfo:@{kRSWriteMessageKey:message}];
}

@end
