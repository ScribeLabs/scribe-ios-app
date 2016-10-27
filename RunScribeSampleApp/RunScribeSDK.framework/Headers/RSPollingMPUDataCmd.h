//
//  RSPollingMPUDataCmd.h
//  Runscribe
//
//  Created by Vitaliy Parashchak on 10/26/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import "RSCmd.h"

typedef NS_ENUM(NSInteger, RSPollingMPUDataMode)
{
    kRSMPUModeAccel = 80,
    kRSMPUModeGyro = 81,
    kRSMPUModeCompass = 82
};

@interface RSPollingMPUDataCmd : RSCmd

@property (nonatomic, assign) uint newMPUDataModeIndex;

@property (nonatomic, assign) uint accelX;
@property (nonatomic, assign) uint accelY;
@property (nonatomic, assign) uint accelZ;

@property (nonatomic, assign) uint gyroX;
@property (nonatomic, assign) uint gyroY;
@property (nonatomic, assign) uint gyroZ;

@property (nonatomic, assign) uint compassX;
@property (nonatomic, assign) uint compassY;
@property (nonatomic, assign) uint compassZ;

@property (nonatomic, assign) uint quat1;
@property (nonatomic, assign) uint quat2;
@property (nonatomic, assign) uint quat3;
@property (nonatomic, assign) uint quat4;

@property (nonatomic, assign) double pitch;
@property (nonatomic, assign) double roll;
@property (nonatomic, assign) double yaw;

@end
