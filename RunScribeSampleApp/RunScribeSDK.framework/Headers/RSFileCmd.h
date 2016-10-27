//
//  RSFileCmd.h
//  Runscribe
//
//  Created by Mark Handel on 2/11/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//
#import "RSCmd.h"

typedef NS_ENUM(NSInteger, RSScribeFileCRCStatus)
{
    kRSFileCRCValid = 1,
    kRSFileCRCInvalid = 2,
};

typedef NS_ENUM(NSInteger, RSScribeFileStatus)
{
    kRSFileNotDeleted = 1,
    kRSFileDeleted = 2,
};

@interface RSFileCmd : RSCmd

@property (nonatomic, assign) uint crcHigh;
@property (nonatomic, assign) uint crcLow;
@property (nonatomic, assign) uint crcStatus;
@property (nonatomic, assign) uint fileStatus;

- (void)setFileStatusFromByte:(uint)status;
- (void)setCRCStatusFromByte:(uint)status;
- (uint)crc16;


@end