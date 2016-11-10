//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSDeviceFilesViewController.h"
#import "RSDeviceFileDetailsViewController.h"
#import "RSDeviceRequestsHelper.h"
#import "RSMainViewController.h"
#import "MBProgressHUD.h"
#import "RSFileListCmd.h"

NSString * const kRSFileDetailsSegueIdentifier = @"DeviceFileDetailsSegue";

@interface RSDeviceFilesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *filesIndices;
@property (nonatomic, strong) NSDictionary *filesMap;
@property (nonatomic, strong) NSDateFormatter *fileDateFormatter;

@end

@implementation RSDeviceFilesViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.fileDateFormatter = [[NSDateFormatter alloc] init];
        [self.fileDateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak RSDeviceFilesViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [RSDeviceRequestsHelper readFileList:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceFilesViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to read the list of files stored on the device. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Error occurred while reading the list of files stored on the device. Please, try again."];
            }
            else
            {
                RSFileListCmd *fileListCmd = (RSFileListCmd *)sourceCmd;
                strongSelf.filesMap = fileListCmd.fileMap;
                strongSelf.filesIndices = fileListCmd.fileIndices;
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - read the list of files stored on the device", strongSelf.device.name]];
                [strongSelf.tableView reloadData];
            }
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesMap.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"fileInfoCell"];
    
    NSDictionary *fileMap = [self.filesMap objectForKey:self.filesIndices[indexPath.row]];
    NSString *fileIndex = [fileMap objectForKey:kRSIndexKey];
    NSString *fileSize = [fileMap objectForKey:kRSSizeKey];
    NSDate *fileDate = [fileMap objectForKey:kRSDateKey];
    [cell.textLabel setText:[NSString stringWithFormat:@"#%@ (%@ bytes)", fileIndex, fileSize]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [self.fileDateFormatter stringFromDate:fileDate]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kRSFileDetailsSegueIdentifier sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRSFileDetailsSegueIdentifier])
    {
        NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
        NSNumber *fileIndex = [self.filesIndices objectAtIndex:selectedRowIndexPath.row];
        
        RSDeviceFileDetailsViewController *viewController = (RSDeviceFileDetailsViewController *)segue.destinationViewController;
        viewController.device = self.device;
        viewController.fileIndex = fileIndex.integerValue;
    }
}

@end
