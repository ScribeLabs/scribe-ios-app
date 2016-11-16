//
//  RSPollingMPUDataCmd.h
//  Runscribe
//
//  Created by Vitaliy Parashchak on 10/26/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import "RSCmd.h"
#import "RSMotionData.h"

typedef NS_ENUM(NSInteger, RSPollingMPUDataMode)
{
    kRSMPUModeAccel = 0x80,
    kRSMPUModeGyro = 0x81,
    kRSMPUModeCompass = 0x82
};

typedef void (^RSMotionDataStreamCallback)(RSMotionData *motionData);

@interface RSPollingMPUDataCmd : RSCmd

@property (nonatomic, copy) RSMotionDataStreamCallback motionDataCallback;
@property (nonatomic, assign) uint mode;

@end
