//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "MainViewController.h"
#import "RSDeviceMgr.h"
#import "DeviceTableViewCell.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *logTextView;
@property (nonatomic, weak) IBOutlet UITableView *devicesTableView;

@property (nonatomic, strong) RSDeviceMgr *deviceMgr;
@property (nonatomic, strong) NSMutableDictionary *devicesMap; // includes connected and discovered devices

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deviceMgr = [RSDeviceMgr sharedInstance];
    self.devicesMap = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanTimedOut:) name:RSDeviceScanTimedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDiscovered:) name:RSDeviceDiscoveredNotification object:nil];
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
    [self.devicesMap removeAllObjects];
    NSArray *connectedDevices = self.deviceMgr.connectedDevices;
    for (RSDevice *device in connectedDevices)
    {
        [self.devicesMap setObject:device forKey:device.uuidString];
    }
    [self.devicesTableView reloadData];
    
    [self writeMessage:@"Scanning devices for 5 seconds"];
    [self.deviceMgr scanForRunscribes:5 force:YES];
}

- (IBAction)displayLEDButtonClicked:(id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Display LED" message:nil preferredStyle:UIAlertControllerStyleAlert];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"On/Off" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Red" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Green" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Blue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
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
}

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devicesMap.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceTableViewCell";
    
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    RSDevice *device = (RSDevice *) self.devicesMap.allValues[indexPath.row];
    cell.deviceNameLabel.text = device.name;
    cell.connectButton.tag = indexPath.row;
    [cell.connectButton addTarget:self action:@selector(connectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.connectButton.titleLabel.text = [device isDeviceReady] ? @"Disconnect" : @"Connect";
    
    return cell;
}

# pragma mark - Notifications

- (void)deviceDiscovered:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]]) {
        RSDevice *device = (RSDevice *)obj;
        [self writeMessage:[NSString stringWithFormat:@"Found %@ with serial number %@. RSSI %d", device.name, device.serialNumber, device.rssi]];
        
        if (![self.devicesMap.allKeys containsObject:device.uuidString]) {
            [self.devicesMap setObject:device forKey:device.uuidString];
            [self.devicesTableView reloadData];
        }
    }
}

- (void)scanTimedOut:(NSNotification *)note
{
    [self writeMessage:@"Scanning devices is completed"];
}

# pragma mark - Logging

- (void)writeMessage:(NSString *)message
{
    NSLog(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* newLine = [message stringByAppendingString:@"\n"];
        NSAttributedString* name = [[NSAttributedString alloc] initWithString:newLine];
        [[self.logTextView textStorage] appendAttributedString:name];
        [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
    });
}

@end
