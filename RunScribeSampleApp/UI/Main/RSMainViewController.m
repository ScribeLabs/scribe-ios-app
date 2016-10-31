//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSMainViewController.h"
#import "RSDeviceMgr.h"
#import "RSDeviceTableViewCell.h"
#import "RSAppLogging.h"
#import "RSCommandFactory.h"
#import "RSDisplayLEDCmd.h"

@interface RSMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *logTextView;
@property (nonatomic, weak) IBOutlet UITableView *devicesTableView;

@property (nonatomic, strong) RSDeviceMgr *deviceMgr;
@property (nonatomic, strong) NSMutableArray *devices; // includes connected and discovered devices

@end

@implementation RSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deviceMgr = [RSDeviceMgr sharedInstance];
    self.devices = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimedOut:) name:RSDeviceScanTimedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDiscovered:) name:RSDeviceDiscoveredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnected:) name:RSDeviceConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnected:) name:RSDeviceDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:RSDeviceConnectTimeoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:RSDeviceConnectFailedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.deviceMgr scanForRunscribes:5 force:YES];
}

- (IBAction)displayLEDButtonClicked:(id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Display LED" message:nil preferredStyle:UIAlertControllerStyleAlert];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Red" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self lightUpLED:kRSLEDColorRed];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Green" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self lightUpLED:kRSLEDColorGreen];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Blue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self lightUpLED:kRSLEDColorBlue];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dimLED];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)eraseButtonClicked:(id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Erase" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Erase Flash" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Erase EE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)connectButtonClicked:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection: 0];
    [self.devicesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    RSDevice *device = self.devices[indexPath.row];
    
    if ([device isPeripheralConnected])
    {
        [self writeMessage:[NSString stringWithFormat:@"Disconnecting the %@", device.name]];
        [self.deviceMgr disconnectDevice:device];
    }
    else
    {
        [self writeMessage:[NSString stringWithFormat:@"Connecting to %@", device.name]];
        [self.deviceMgr connectToDevice:device];
    }
}

# pragma mark - Device requests

- (void)lightUpLED:(RSLEDColor)ledColor
{
    RSDevice *device = [self getSelectedDevice];
    if ([self isDeviceReady:device])
    {
        NSArray *colorRGB;
        switch (ledColor)
        {
            case kRSLEDColorRed:
                colorRGB = @[@255, @0, @0];
                [self writeMessage:[NSString stringWithFormat:@"Light up red LED on %@", device.name]];
                break;
            case kRSLEDColorGreen:
                colorRGB = @[@0, @255, @0];
                [self writeMessage:[NSString stringWithFormat:@"Light up green LED on %@", device.name]];
                break;
            case kRSLEDColorBlue:
                colorRGB = @[@0, @0, @255];
                [self writeMessage:[NSString stringWithFormat:@"Light up blue LED on %@", device.name]];
                break;
        }
        
        RSDisplayLEDCmd *cmd = (RSDisplayLEDCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdDisplayLED forDevice:device];
        if ([device isAtProtocolVersion:kProtocolVer2_0])
        {
            cmd.pattern = kRSLEDPatternConnected;
            cmd.cycles = 150; // keep in on for 5 minutes -- ie, 150 cycles of 2 second animations.
            cmd.red = (int)((NSNumber *)colorRGB[0]).integerValue;
            cmd.green = (int)((NSNumber *)colorRGB[1]).integerValue;
            cmd.blue = (int)((NSNumber *)colorRGB[2]).integerValue;
        }
        else
        {
            cmd.mode = kRSLEDModeSolid;
            cmd.color = ledColor;
        }
        [cmd setCompletedBlock:nil];
        [device runCmd:cmd];
    }
}

- (void)dimLED
{
    RSDevice *device = [self getSelectedDevice];
    if ([self isDeviceReady:device])
    {
        RSDisplayLEDCmd *cmd = (RSDisplayLEDCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdDisplayLED forDevice:device];
        if ([device isAtProtocolVersion:kProtocolVer2_0])
        {
            cmd.pattern = kRSLEDPatternCancel;
        }
        else
        {
            cmd.mode = kRSLEDModeNormal;
            cmd.color = kRSLEDColorBlue;
        }
        [cmd setCompletedBlock:nil];
        [device runCmd:cmd];
    }
}

# pragma mark - UITableViewDataSource

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

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSDevice *device = (RSDevice *)self.devices[indexPath.row];
    if (![device isPeripheralConnected])
    {
        [self writeMessage:[NSString stringWithFormat:@"Connecting to %@", device.name]];
        [self.deviceMgr connectToDevice:device];
    }
}

# pragma mark - Notifications

- (void)deviceDiscovered:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]]) {
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"Found %@ with serial number %@. RSSI %d", device.name, device.serialNumber, device.rssi]];
        
        if ([self isDeviceNew:device]) {
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
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"Connected %@ (v%@) with serial %@", device.name, device.hardwareVersion, device.serialNumber]];
        
        NSIndexPath *selectedRowIndexPath = [self.devicesTableView indexPathForSelectedRow];
        [self.devicesTableView reloadData];
        [self.devicesTableView selectRowAtIndexPath:selectedRowIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)deviceDisconnected:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]])
    {
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"Device %@ has been disconnected", device.name]];
        
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
        [self writeMessage:[NSString stringWithFormat:@"Failed connecting to %@", device.name]];
    }
}

# pragma mark - Extra

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

- (RSDevice *)getSelectedDevice
{
    NSIndexPath *selectedDeviceIndexPath = [self.devicesTableView indexPathForSelectedRow];
    if (selectedDeviceIndexPath != nil && selectedDeviceIndexPath.row > -1)
    {
        RSDevice *device = (RSDevice *)[self.devices objectAtIndex:selectedDeviceIndexPath.row];
        return device;
    }
    else
    {
        [self showAlertWithTitle:@"Error" message:@"No device selected!"];
        return nil;
    }
}

- (BOOL)isDeviceReady:(RSDevice *)device
{
    if (device != nil && [device isDeviceReady])
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

# pragma mark - Logging

- (void)writeMessage:(NSString *)message
{
    DDLogDebug(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* newLine = [message stringByAppendingString:@"\n"];
        NSAttributedString* name = [[NSAttributedString alloc] initWithString:newLine];
        [[self.logTextView textStorage] appendAttributedString:name];
        [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
    });
}

@end
