//
//  RSLEDCmd.h
//  Runscribe
//
//  Created by Adam Hamel on 6/13/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

/** 
 1.0 protocol color setting
 */
typedef NS_ENUM(NSInteger, RSLEDColor)
{
    kRSLEDColorBlue = 4,
    kRSLEDColorRed = 1,
    kRSLEDColorGreen = 2
};

/** 
 1.0 protocol mode setting
 */
typedef NS_ENUM(NSInteger, RSLEDMode)
{
    kRSLEDModeNormal = 0,
    kRSLEDModeSolid = 1
};

/**
 2.0 protocol LED pattern setting
 */
typedef NS_ENUM(NSInteger, RSLEDPattern)
{
    kRSLEDPatternCancel = 0,
    kRSLEDPatternConnected = 13,
    kRSLEDPatternRecordingStart = 14,
    kRSLEDPatternSyncStart = 15,
    kRSLEDPatternSyncComplete = 16,
    kRSLEDPatternLowBattery = 17,
};

@interface RSDisplayLEDCmd : RSCmd

/**
 1.x protocol properties
 */
@property (nonatomic, assign) RSLEDColor color;
@property (nonatomic, assign) RSLEDMode mode;
@property (nonatomic, assign) NSUInteger duration;

/*
 2,x protocol properties
 */
@property (nonatomic, assign) NSUInteger red;
@property (nonatomic, assign) NSUInteger green;
@property (nonatomic, assign) NSUInteger blue;
@property (nonatomic, assign) NSUInteger cycles;
@property (nonatomic, assign) RSLEDPattern pattern;

@end
