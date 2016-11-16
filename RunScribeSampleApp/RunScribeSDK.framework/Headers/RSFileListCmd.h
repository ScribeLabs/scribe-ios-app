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

#import "RSFileCmd.h"

extern NSString * const kRSIndexKey;
extern NSString * const kRSSizeKey;
extern NSString * const kRSDateKey;
extern NSString * const kRSCRCKey;
extern NSString * const kRSVoltageKey;
extern NSString * const kRSFileStatusKey;
extern NSString * const kRSCRCStatusKey;

typedef NS_ENUM(NSInteger, RSFileTypes)
{
    kRSFileTypesAllFiles = 1,
    kRSFileTypesNotDeletedFiles = 2
};

@interface RSFileListCmd : RSFileCmd

@property (nonatomic, assign) uint fileCount;
@property (nonatomic, assign) uint fileType;
@property (nonatomic, assign) uint currentIndex;
@property (nonatomic, assign) uint startIndex;
@property (nonatomic, assign) uint endIndex;
@property (nonatomic, assign) uint fileSize;
@property (nonatomic, strong) NSDate *fileDate;
@property (nonatomic, strong) NSArray *fileIndices;
@property (nonatomic, strong) NSDictionary *fileMap;

@end
