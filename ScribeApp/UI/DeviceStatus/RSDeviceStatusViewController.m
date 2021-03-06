//
// MIT License
//
// Copyright (c) 2016 Scribe Labs Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "RSDeviceStatusViewController.h"
#import "MBProgressHUD.h"
#import "RSDeviceRequestsHelper.h"
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
    [super viewWillAppear:animated];
    
    __weak RSDeviceStatusViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    // We are going to read the device status and then present values in the specific text fields.
    [RSDeviceRequestsHelper readStatus:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceStatusViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error == nil)
            {
                RSStatusCmd *statusResponse = (RSStatusCmd *)sourceCmd;
                [strongSelf updateUI:statusResponse];
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - successfully read the device status", strongSelf.device.name]];
            }
            else
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to read the device status. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Error occurred while reading the device status. Please, try again."];
            }
        });
    }];
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
            return @"Primary";
            
        case kRSDeviceBatteryRechargeable:
            return @"Li-ion";
            
        case kRSDeviceBatteryLiPoly:
            return @"Li-poly";
            
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
            
        case kRSDeviceBatteryModeCharge:
            return @"Charge";
            
        default:
            return @"Unknown";
    }
}

@end
