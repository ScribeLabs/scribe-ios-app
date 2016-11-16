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
