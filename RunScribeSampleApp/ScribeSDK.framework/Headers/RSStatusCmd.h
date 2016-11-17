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
    kRSDeviceBatteryRechargeable = 1,
    kRSDeviceBatteryLiPoly = 2
};

typedef NS_ENUM(NSInteger, RSDeviceBatteryMode)
{
    kRSDeviceBatteryModeActive = 0,
    kRSDeviceBatteryModeIdle = 1,
    kRSDeviceBatteryModeSleep = 2,
    kRSDeviceBatteryModeCharge = 3
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
