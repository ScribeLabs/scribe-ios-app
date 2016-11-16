//
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSMotionData : NSObject

@property (nonatomic, assign) uint mpuDataModeIndex;

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
