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
