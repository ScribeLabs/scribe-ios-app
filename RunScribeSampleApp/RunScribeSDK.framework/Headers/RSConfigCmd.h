//
//  RSConfigCmd.h
//  Runscribe
//
//  Created by Adam Hamel on 5/5/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

typedef NS_ENUM(NSInteger, RSDevicePlacement)
{
    kRSDevicePlacementUnknown = -1,
    kRSDevicePlacementHeel = 0,
    kRSDevicePlacementLaces = 1
};

typedef NS_ENUM(NSInteger, RSDeviceSide)
{
    kRSDeviceSideUnknown = -1,
    kRSDeviceSideRightFoot = 1,
    kRSDeviceSideLeftFoot = 0
};

typedef NS_ENUM(NSInteger, RSDeviceConfigPoints)
{
    kRSLegacyConfig = 0xAA02,
    kRSScribeConfig = 0xAA04,
    kRSBluetoothConfig = 0xAA05,
    kRSDataCollectionConfig = 0xAA06
};

typedef NS_ENUM(NSInteger, RSDeviceRawData)
{
    kRSRawDataCollectionDisabled = 0,
    kRSRawDataCollectionEnabled = 1
};

@interface RSConfigCmd : RSCmd

@property (nonatomic, assign) uint blockSize; // always 16
@property (nonatomic, assign) uint configPoint;
@property (nonatomic, assign) uint ledColor;
@property (nonatomic, assign) uint placement;
@property (nonatomic, assign) uint side;
@property (nonatomic, strong) NSDate *deviceTime;
@property (nonatomic, assign) uint sampleRate;
@property (nonatomic, assign) uint sensitivity;
@property (nonatomic, assign) uint timeOut;
@property (nonatomic, assign) uint minConnInterval;
@property (nonatomic, assign) uint maxConnInterval;
@property (nonatomic, assign) uint slaveLatency;
@property (nonatomic, assign) uint strideRate;
@property (nonatomic, assign) uint scaleFactorA;
@property (nonatomic, assign) uint scaleFactorB;
@property (nonatomic, assign) uint rawData;
@property (nonatomic, assign) uint recordingVoltageThreshold; // in millivolts
@property (nonatomic, assign) uint sleepVoltageThreshold; // in millivolts
// protocol 2.0 and later
@property (nonatomic, assign) uint ledRed;
@property (nonatomic, assign) uint ledGreen;
@property (nonatomic, assign) uint ledBlue;
@end
