//
//  RSAnnotateFileCmd.h
//  Runscribe
//
//  Created by Vitaliy Parashchak on 3/30/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import "RSCmd.h"

@interface RSAnnotateFileCmd : RSCmd

typedef NS_ENUM(NSInteger, RSAnnotateFileType)
{
    kRSAnnotateFileTypeMotionEvent = 2
};

typedef NS_ENUM(NSInteger, RSAnnotateFileEventType)
{
    kRSAnnotateFileEventTypeTimestamp = 52
};

typedef NS_ENUM(NSInteger, RSAnnotateFileFitEventType)
{
    kRSAnnotateFileFitEventTypeTimestampType1 = 1,
    kRSAnnotateFileFitEventTypeTimestampType2 = 2
};

typedef NS_ENUM(NSInteger, RSAnnotateFileEventGroup)
{
    kRSAnnotateFileEventGroupGeneral = 1
};

typedef NS_ENUM(NSInteger, RSAnnotateFileResult)
{
    kRSAnnotateFileSuccess = 1,
    kRSAnnotateFileFailure = 2
};

@property (nonatomic, assign) uint8_t type;
@property (nonatomic, assign) uint8_t eventType;
@property (nonatomic, assign) uint8_t fitEventType;
@property (nonatomic, assign) uint8_t eventGroup;
@property (nonatomic, assign) uint32_t data1;
@property (nonatomic, assign) uint16_t data2;

@property (nonatomic, assign) uint8_t versionMajor;
@property (nonatomic, assign) uint8_t versionMinor;
@property (nonatomic, assign) uint8_t result;

@end
