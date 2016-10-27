//
//  RSDFUDeviceMgr.h
//  Runscribe
//
//  Created by Adam Hamel on 5/30/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RSDFUDevice.h"

typedef void (^RSFirmwareUpdateCompleted)(RSDFUDevice *device, NSError *error);
typedef void (^RSFirmwareUpdateProgress)(float progress);
typedef void (^RSFirmwareUpdateStarted)();

@interface RSDFUDeviceMgr : NSObject

// Block callback when file transfer starts
@property (nonatomic, copy) RSFirmwareUpdateStarted startedBlock;
// Block callback when firmware upgrade is complete and device is being rebooted
@property (nonatomic, copy) RSFirmwareUpdateCompleted completedBlock;
// Block callback for progress during file transfer
@property (nonatomic, copy) RSFirmwareUpdateProgress progressBlock;

- (id)initWithUUID:(NSString *)uuid serialNumber:(NSString *)serialNumber firmwareFileUrl:(NSURL *)firmwareFileUrl expectedSize:(NSNumber *)expectedSize expectedCrc:(NSNumber *)expectedCrc;

// Start the upgrade process. Device must be advertising in DFU mode before you call this
- (void)startFirmwareUpgrade;

// Cancels firmware Upgrade
- (void)cancelFirmwareUpgrade;

@end
