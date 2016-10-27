//
//  RSEraseDataCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/18/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

typedef NS_ENUM(NSInteger, RSEraseStatus)
{
    kRSDeviceErasing = 1,
    kRSDeviceErased = 2,
    kRSDeviceNotErased = 3,
};

typedef NS_ENUM(NSInteger, RSEraseTypes)
{
    kRSDeviceDefaultErase = 0,
    kRSDeviceTargetedErase = 1,
    kRSDeviceChipErase = 2,
    kRSDeviceMarkedErase = 3,
    kRSDeviceEEpromErase = 4
};

@interface RSEraseDataCmd : RSCmd

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;
@property (nonatomic, assign) uint result;
@property (nonatomic, assign) uint fileSize;
@property (nonatomic, assign) uint filePointReg;
@property (nonatomic, assign) uint crcHigh;
@property (nonatomic, assign) uint crcLow;
@property (nonatomic, assign) uint eraseType;
@property (nonatomic, assign) BOOL blockTillCleared;
@property (nonatomic, assign) BOOL eraseFiles;

@end
