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
