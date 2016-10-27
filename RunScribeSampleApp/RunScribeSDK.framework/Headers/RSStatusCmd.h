//
//  RSStatusCmd.h
//  Runscribe
//
//  Created by Adam Hamel on 4/30/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSDiagnosticResult.h"

typedef NS_ENUM(NSInteger, RSDeviceOperationMode)
{
    kRSDeviceModeSleeping = 0,
    kRSDeviceModeWaiting = 1,
    kRSDeviceModeRecording = 2,
    kRSDeviceModePaused = 3,
    kRSDeviceModeErasing = 4,
    kRSDeviceModeSyncing = 5,
    kRSDeviceModeManufacturing = 6,
    kRSDeviceModeError = 7
};

typedef NS_ENUM(NSInteger, RSDeviceBatteryType)
{
    kRSDeviceBatteryNonRechargeable = 0,
    kRSDeviceBatteryRechargeable = 1
};

typedef NS_ENUM(NSInteger, RSDeviceBatteryMode)
{
    kRSDeviceBatteryModeActive = 0,
    kRSDeviceBatteryModeIdle = 1,
    kRSDeviceBatteryModeSleep = 2
};

extern NSInteger const kBatteryUsageTimeMultiplier;

@interface RSStatusCmd : RSDiagnosticResult

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;
@property (nonatomic, assign) uint batteryPercent;
@property (nonatomic, assign) uint fileCount; // number of Undeleted Files
@property (nonatomic, assign) uint flashFreePercent;
@property (nonatomic, assign) uint temperature;
@property (nonatomic, strong) NSDate *lastContacted;
@property (nonatomic, assign) uint operationMode;
@property (nonatomic, assign) uint batteryType;
@property (nonatomic, assign) uint batteryMode;
@property (nonatomic, assign) uint batteryVoltage; // in millivolts
@property (nonatomic, assign) uint batteryUsageTime;
@property (nonatomic, assign) uint batteryChargingTime;
@property (nonatomic, assign) uint fileCountAll; // number of All Files

@end
