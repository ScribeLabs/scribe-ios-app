//
//  RSFileListCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/2/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
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
