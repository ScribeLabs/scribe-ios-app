//
//  DeviceTableViewCell.h
//  RunScribeSampleApp
//
//  Created by Vitaliy Parashchak on 10/28/16.
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;

@end
