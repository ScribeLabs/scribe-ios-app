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

#import "RSMainViewController.h"
#import "RSDeviceStatusViewController.h"
#import "RSDeviceConfigViewController.h"
#import "RSDeviceFilesViewController.h"
#import "RSDeviceMotionViewController.h"
#import "RSDeviceRequestsHelper.h"
#import "RSDeviceMgr.h"
#import "RSDeviceTableViewCell.h"
#import "RSAppLogging.h"
#import "RSDisplayLEDCmd.h"
#import "RSEraseDataCmd.h"
#import "RSRunDiagnosticsCmd.h"
#import "RSStatusCmd.h"

NSString * const kRSStatusSegueIdentifier = @"DeviceStatusSegue";
NSString * const kRSConfigSegueIdentifier = @"DeviceConfigSegue";
NSString * const kRSFileListSegueIdentifier = @"DeviceFileListSegue";
NSString * const kRSMotionSegueIdentifier = @"DeviceMotionSegue";

NSString * const RSWriteMessageNotification = @"RSWriteMessageNotification";
NSString * const kRSWriteMessageKey = @"kRSWriteMessageKey";

@interface RSMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDateFormatter *logDateFormatter;

@property (nonatomic, weak) IBOutlet UITextView *logTextView;
@property (nonatomic, weak) IBOutlet UITableView *devicesTableView;
@property (nonatomic, weak) IBOutlet UIButton *changeModeButton;

@property (nonatomic, strong) RSDeviceMgr *deviceMgr;
@property (nonatomic, strong) NSMutableArray *devices; // includes connected and discovered devices
@property (nonatomic, strong) NSMutableArray *recordingDevicesUUIDs; // UUIDs of devices that are in the recording mode at the moment

@end

@implementation RSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.deviceMgr = [RSDeviceMgr sharedInstance];
    self.devices = [NSMutableArray array];
    self.recordingDevicesUUIDs = [NSMutableArray array];
    self.logDateFormatter = [[NSDateFormatter alloc] init];
    [self.logDateFormatter setDateFormat:@"hh:mm:ss"];
    
    // SDK notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimedOut:) name:RSDeviceScanTimedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDiscovered:) name:RSDeviceDiscoveredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnected:) name:RSDeviceConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnected:) name:RSDeviceDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:RSDeviceConnectTimeoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:RSDeviceConnectFailedNotification object:nil];
    
    // Another view controllers send messages using this notification type
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeMessageNotificationReceived:) name:RSWriteMessageNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    RSDevice *selectedDevice = [self getSelectedDevice:NO];
    if ([selectedDevice isDeviceReady])
    {
        [self displayDefaultLedColor:selectedDevice];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)scanButtonClicked:(id)sender
{
    // Removing all devices except connected
    [self.devices removeAllObjects];
    NSArray *connectedDevices = self.deviceMgr.connectedDevices;
    for (RSDevice *device in connectedDevices)
    {
        [self.devices addObject:device];
    }
    [self.devicesTableView reloadData];
    
    [self writeMessage:@"Scanning devices for 5 seconds"];
    [self.deviceMgr scanForScribes:5 force:YES];
}

- (IBAction)displayLEDButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Display LED" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Red" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self lightUpLEDWithRed:255 green:0 blue:0 device:device];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Green" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self lightUpLEDWithRed:0 green:255 blue:0 device:device];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Blue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self lightUpLEDWithRed:0 green:0 blue:255 device:device];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dimLED:device];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (IBAction)eraseButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Erase" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Erase Flash" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self writeMessage:[NSString stringWithFormat:@"[%@] - going to perform chip erase on the device", device.name]];
            [self erase:device eraseType:kRSDeviceChipErase];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Erase EE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self writeMessage:[NSString stringWithFormat:@"[%@] - going to perform EEProm erase on the device", device.name]];
            [self erase:device eraseType:kRSDeviceEEpromErase];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (IBAction)connectButtonClicked:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection: 0];
    [self.devicesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    RSDevice *device = self.devices[indexPath.row];
    
    if ([device isPeripheralConnected])
    {
        [self.recordingDevicesUUIDs removeObject:device.uuidString];
        [self dimLED:device];
        
        // wait a bit to let the device dim its LED
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self writeMessage:[NSString stringWithFormat:@"[%@] - disconnecting the device", device.name]];
            [self.deviceMgr disconnectDevice:device];
        });
    }
    else
    {
        [self writeMessage:[NSString stringWithFormat:@"[%@] - connecting to the device", device.name]];
        [self.deviceMgr connectToDevice:device];
    }
    
    [self updateTitleOfChangeModeButton];
}

- (IBAction)statusButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        [self performSegueWithIdentifier:kRSStatusSegueIdentifier sender:self];
    }
}

- (IBAction)configButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        [self performSegueWithIdentifier:kRSConfigSegueIdentifier sender:self];
    }
}

- (IBAction)changeModeButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        if ([self.recordingDevicesUUIDs containsObject:device.uuidString])
        {
            [self writeMessage:[NSString stringWithFormat:@"[%@] - going to stop recording", device.name]];
            [self updateRecordingState:device state:kRSScribeModeCommandStatusOff];
            [self.recordingDevicesUUIDs removeObject:device.uuidString];
        }
        else
        {
            [self writeMessage:[NSString stringWithFormat:@"[%@] - going to start recording", device.name]];
            [self updateRecordingState:device state:kRSScribeModeCommandStatusOn];
            [self.recordingDevicesUUIDs addObject:device.uuidString];
        }
        [self updateTitleOfChangeModeButton];
    }
}

- (IBAction)filesButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        [self performSegueWithIdentifier:kRSFileListSegueIdentifier sender:self];
    }
}

- (IBAction)motionButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        [self performSegueWithIdentifier:kRSMotionSegueIdentifier sender:self];
    }
}

- (IBAction)diagnosticsButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        [self writeMessage:[NSString stringWithFormat:@"[%@] - going to run diagnostics", device.name]];

        __weak RSMainViewController *weakSelf = self;
        [RSDeviceRequestsHelper runDiagnostics:device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
            if (error)
            {
                RSMainViewController *strongSelf = weakSelf;
                NSString *message = [NSString stringWithFormat:@"[%@] - failed to run diagnostics on the device. Error: %@", device.name, error];
                [strongSelf writeMessage:message];
            }
            else
            {
                RSRunDiagnosticsCmd *runDiagResponse = (RSRunDiagnosticsCmd *)sourceCmd;
                
                NSMutableString *diagResultString = [NSMutableString string];
                [diagResultString appendFormat:@"[%@] - diagnostics results:", device.name];
                
                BOOL gyroDiagPassed = [runDiagResponse diagnosticPassed:kRSDiagnosticsTypeGyro];
                BOOL accelDiagPassed = [runDiagResponse diagnosticPassed:kRSDiagnosticsTypeAccelerometer];
                BOOL magDiagPassed = [runDiagResponse diagnosticPassed:kRSDiagnosticsTypeMagnometer];
                BOOL flashDiagPassed = [runDiagResponse diagnosticPassed:kRSDiagnosticsTypeFlash];
                BOOL eepromDiagPassed = [runDiagResponse diagnosticPassed:kRSDiagnosticsTypeEEPROM];
                BOOL dmpDiagPassed = [runDiagResponse diagnosticPassed:kRSDiagnosticsTypeDMP];
                
                [diagResultString appendFormat:@"\n     GYRO - %@", gyroDiagPassed ? @"✓" : @"✗"];
                [diagResultString appendFormat:@"\n     ACCEL - %@", accelDiagPassed ? @"✓" : @"✗"];
                [diagResultString appendFormat:@"\n     MAG - %@", magDiagPassed ? @"✓" : @"✗"];
                [diagResultString appendFormat:@"\n     FLASH - %@", flashDiagPassed ? @"✓" : @"✗"];
                [diagResultString appendFormat:@"\n     EEPROM - %@", eepromDiagPassed ? @"✓" : @"✗"];
                [diagResultString appendFormat:@"\n     DMP - %@", dmpDiagPassed ? @"✓" : @"✗"];
                
                [self writeMessage:diagResultString];
            }
        }];
    }
}

- (IBAction)moreButtonClicked:(id)sender
{
    RSDevice *device = [self getSelectedDevice:YES];
    if ([self isDeviceReady:device])
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"More features" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Enter DFU mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self writeMessage:[NSString stringWithFormat:@"[%@] - going to enter DFU mode", device.name]];
            [RSDeviceRequestsHelper enterDFUMode:device completionBlock:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Reboot" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self writeMessage:[NSString stringWithFormat:@"[%@] - going to reboot the device", device.name]];
            [RSDeviceRequestsHelper rebootDevice:device completionBlock:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)lightUpLEDWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue device:(RSDevice *)device
{
    [self writeMessage:[NSString stringWithFormat:@"[%@] - going to light up LED on the device using the next values - R:%ld, G:%ld, B:%ld",
                        device.name, (long)red, (long)green, (long)blue]];
    
    __weak RSMainViewController *weakSelf = self;
    [RSDeviceRequestsHelper lightUpLEDWithRed:red
                                        green:green
                                         blue:blue
                                       device:device
                              completionBlock:^(RSCmd *sourceCmd, NSError *error) {
                                  if (error)
                                  {
                                      RSMainViewController *strongSelf = weakSelf;
                                      NSString *message = [NSString stringWithFormat:@"[%@] - failed to light up LED on the device. Error: %@", device.name, error];
                                      [strongSelf writeMessage:message];
                                  }
                              }];
}

- (void)dimLED:(RSDevice *)device
{
    [self writeMessage:[NSString stringWithFormat:@"[%@] - going to dim LED on the device", device.name]];
    
    __weak RSMainViewController *weakSelf = self;
    [RSDeviceRequestsHelper dimLED:device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        if (error)
        {
            RSMainViewController *strongSelf = weakSelf;
            NSString *message = [NSString stringWithFormat:@"[%@] - failed to dim LED on the device. Error: %@", device.name, error];
            [strongSelf writeMessage:message];
        }
    }];
}

- (void)displayDefaultLedColor:(RSDevice *)device
{
    [self writeMessage:[NSString stringWithFormat:@"[%@] - going to light up LED using the default color", device.name]];
    
    __weak RSMainViewController *weakSelf = self;
    [RSDeviceRequestsHelper displayDefaultLedColor:device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        if (error)
        {
            RSMainViewController *strongSelf = weakSelf;
            NSString *message = [NSString stringWithFormat:@"[%@] - failed to light up LED using the default color. Error: %@", device.name, error];
            [strongSelf writeMessage:message];
        }
    }];
}

- (void)erase:(RSDevice *)device eraseType:(RSEraseTypes)eraseType
{
    __weak RSMainViewController *weakSelf = self;
    [RSDeviceRequestsHelper erase:device eraseType:eraseType completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSMainViewController *strongSelf = weakSelf;
        NSString *message = nil;
        if (error)
        {
            message = [NSString stringWithFormat:@"[%@] - failed to erase the device. Error: %@", device.name, error];
        }
        else
        {
            RSEraseDataCmd *sourceEraseCmd = (RSEraseDataCmd *)sourceCmd;
            if (sourceEraseCmd.result == kRSDeviceErased)
            {
                message = [NSString stringWithFormat:@"[%@] - has been successfully erased", device.name];
            }
            else
            {
                message = [NSString stringWithFormat:@"[%@] - device cannot be erased at the moment. Try again later", device.name];
            }
        }
        [strongSelf writeMessage:message];
    }];
}

- (void)updateRecordingState:(RSDevice *)device state:(RSScribeModeCommandStatus)state
{
    __weak RSMainViewController *weakSelf = self;
    [RSDeviceRequestsHelper setMode:device command:kRSScribeModeCommandRecord state:state completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        if (error)
        {
            RSMainViewController *strongSelf = weakSelf;
            [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to set mode on the device. Error: %@", device.name, error]];
        }
    }];
}

- (void)checkDeviceMode:(RSDevice *)device
{
    __weak RSMainViewController *weakSelf = self;
    [RSDeviceRequestsHelper readStatus:device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSMainViewController *strongSelf = weakSelf;
        if (error)
        {
            [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to read the device status. Error: %@", device.name, error]];
        }
        else
        {
            RSStatusCmd *statusResponce = (RSStatusCmd *)sourceCmd;
            if (statusResponce.operationMode == kRSDeviceModeRecording)
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [strongSelf.recordingDevicesUUIDs addObject:device.uuidString];
                    [strongSelf updateTitleOfChangeModeButton];
                });
            }
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RSDeviceTableViewCell";
    
    RSDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[RSDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    RSDevice *device = (RSDevice *)self.devices[indexPath.row];
    [cell.deviceNameLabel setText:device.name];
    cell.connectButton.tag = indexPath.row;
    [cell.connectButton addTarget:self action:@selector(connectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NSString *buttonTitle = [device isDeviceReady] ? @"Disconnect" : @"Connect";
    [cell.connectButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSDevice *device = (RSDevice *)self.devices[indexPath.row];
    [self dimLED:device];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSDevice *device = (RSDevice *)self.devices[indexPath.row];
    if (![device isPeripheralConnected])
    {
        [self writeMessage:[NSString stringWithFormat:@"[%@] - connecting to the device", device.name]];
        [self.deviceMgr connectToDevice:device];
    }
    else
    {
        [self displayDefaultLedColor:device];
    }
    
    [self updateTitleOfChangeModeButton];
}

#pragma mark - Notifications

- (void)deviceDiscovered:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]]) {
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"Found %@ with serial number %@. RSSI %d", device.name, device.serialNumber, device.rssi]];
        
        if ([self isDeviceNew:device])
        {
            [self.devices addObject:device];
            [self.devicesTableView reloadData];
        }
    }
}

- (void)scanTimedOut:(NSNotification *)note
{
    [self writeMessage:@"Scanning devices is completed"];
}

- (void)deviceConnected:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]])
    {
        RSDevice *connectedDevice = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"[%@] - has been connected. Serial %@", connectedDevice.name, connectedDevice.serialNumber]];
        
        if (![self.devices containsObject:connectedDevice])
        {
            [self.devices insertObject:connectedDevice atIndex:0];
        }
        
        NSIndexPath *selectedRowIndexPath = [self.devicesTableView indexPathForSelectedRow];
        [self.devicesTableView reloadData];
        [self.devicesTableView selectRowAtIndexPath:selectedRowIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        RSDevice *selectedDevice = [self getSelectedDevice:NO];
        if ([selectedDevice.uuidString isEqualToString:connectedDevice.uuidString])
        {
            [self displayDefaultLedColor:connectedDevice];
        }
        [self checkDeviceMode:connectedDevice];
    }
}

- (void)deviceDisconnected:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]])
    {
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"[%@] - has been disconnected", device.name]];
        
        NSInteger index = [self getDeviceIndex:device.uuidString];
        if (index != -1)
        {
            [self.devices removeObjectAtIndex:index];
        }
        
        [self.devicesTableView reloadData];
    }
}

- (void)connectionFailed:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]])
    {
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"[%@] - failed to connect to the device", device.name]];
    }
}

- (void)writeMessageNotificationReceived:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSWriteMessageKey];
    if (obj != nil && [obj isKindOfClass:[NSString class]])
    {
        [self writeMessage:(NSString *)obj];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kRSStatusSegueIdentifier])
    {
        RSDeviceStatusViewController *controller = (RSDeviceStatusViewController *)segue.destinationViewController;
        controller.device = [self getSelectedDevice:NO];
    }
    else if ([segue.identifier isEqualToString:kRSConfigSegueIdentifier])
    {
        RSDeviceConfigViewController *controller = (RSDeviceConfigViewController *)segue.destinationViewController;
        controller.device = [self getSelectedDevice:NO];
    }
    else if ([segue.identifier isEqualToString:kRSFileListSegueIdentifier])
    {
        RSDeviceFilesViewController *controller = (RSDeviceFilesViewController *)segue.destinationViewController;
        controller.device = [self getSelectedDevice:NO];
    }
    else if ([segue.identifier isEqualToString:kRSMotionSegueIdentifier])
    {
        RSDeviceMotionViewController *controller = (RSDeviceMotionViewController *)segue.destinationViewController;
        controller.device = [self getSelectedDevice:NO];
    }
}

#pragma mark - Extra

- (BOOL)isDeviceNew:(RSDevice *)discoveredDevice
{
    for (RSDevice *device in self.devices)
    {
        if ([device.uuidString isEqualToString:discoveredDevice.uuidString])
        {
            return NO;
        }
    }
    
    return YES;
}

- (NSInteger)getDeviceIndex:(NSString *)deviceUUID
{
    for (int i = 0; i < self.devices.count; i++)
    {
        RSDevice *device = self.devices[i];
        if ([device.uuidString isEqualToString:deviceUUID])
        {
            return i;
        }
    }
    
    return -1;
}

- (RSDevice *)getSelectedDevice:(BOOL)showError
{
    NSIndexPath *selectedDeviceIndexPath = [self.devicesTableView indexPathForSelectedRow];
    if (selectedDeviceIndexPath != nil && selectedDeviceIndexPath.row > -1)
    {
        RSDevice *device = (RSDevice *)[self.devices objectAtIndex:selectedDeviceIndexPath.row];
        return device;
    }
    
    if (showError)
    {
        [self showAlertWithTitle:@"Error" message:@"No device selected!"];
    }
    
    return nil;    
}

- (BOOL)isDeviceReady:(RSDevice *)device
{
    if (device == nil)
    {
        return NO;
    }
    else if ([device isDeviceReady])
    {
        return YES;
    }
    else
    {
        [self showAlertWithTitle:@"Error" message:@"Your device is not ready to perform this action!"];
        return NO;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [self writeMessage:message];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)updateTitleOfChangeModeButton
{
    RSDevice *selectedDevice = [self getSelectedDevice:NO];
    if (selectedDevice == nil || ![self.recordingDevicesUUIDs containsObject:selectedDevice.uuidString])
    {
        [self.changeModeButton setTitle:@"Start Rec" forState:UIControlStateNormal];
    }
    else
    {
        [self.changeModeButton setTitle:@"Stop Rec" forState:UIControlStateNormal];
    }
}

#pragma mark - Logging

- (void)writeMessage:(NSString *)message
{
    DDLogDebug(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentTime = [self.logDateFormatter stringFromDate:[NSDate date]];
        NSString *newLine = [NSString stringWithFormat:@"%@ %@\n", currentTime, message];
        NSAttributedString* name = [[NSAttributedString alloc] initWithString:newLine];
        [[self.logTextView textStorage] appendAttributedString:name];
        [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
    });
}

@end
