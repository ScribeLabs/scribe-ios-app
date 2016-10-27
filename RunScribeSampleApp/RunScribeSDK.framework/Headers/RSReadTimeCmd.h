//
//  RSReadTimeCmd.h
//  Runscribe
//
//  Created by Vitaliy Parashchak on 1/20/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import "RSCmd.h"

@interface RSReadTimeCmd : RSCmd

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;
@property (nonatomic, strong) NSDate *systemTime;
@property (nonatomic, strong) NSDate *lastAccessTime;
@property (nonatomic, strong) NSDate *lastBootTime;
@property (nonatomic, assign) uint timeSinceLastBoot; // in secs

@end
