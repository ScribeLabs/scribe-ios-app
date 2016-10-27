//
//  RSSetModeCmd.h
//  Runscribe
//
//  Created by Mark Handel on 8/10/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

typedef NS_ENUM(NSInteger, RSScribeModeCommand)
{
    kRSScribeModeNA = 0,
    kRSScribeModeCommandRecord = 1,
    kRSScribeModeCommandPause = 2,
    kRSScribeModeCommandSync = 3
};

typedef NS_ENUM(NSInteger, RSScribeModeCommandStatus)
{
    kRSScribeModeCommandStatusOff = 0,
    kRSScribeModeCommandStatusOn = 1
};

@interface RSSetModeCmd : RSCmd

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;
@property (nonatomic, assign) uint command;
@property (nonatomic, assign) uint state;



@end
