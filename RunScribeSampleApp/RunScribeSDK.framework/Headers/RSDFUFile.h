//
//  RSDFUFile.h
//  Runscribe
//
//  Created by Adam Hamel on 5/31/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+crc.h"

@interface RSDFUFile : NSObject

@property (nonatomic, strong, readonly) NSData *binFileData;
@property (nonatomic, assign, readonly) int bytesInLastPacket;
@property (nonatomic, assign, readonly) int numberOfPackets;
@property (nonatomic, assign, readonly) int writingPacketNumber;
@property (nonatomic, assign, readonly) NSUInteger binFileSize;
@property (nonatomic, strong, readonly) NSNumber *expectedSize;
@property (nonatomic, strong, readonly) NSNumber *expectedCrc;

- (id)initWithFileUrl:(NSURL *)fileUrl expectedSize:(NSNumber *)expectedSize expectedCrc:(NSNumber *)expectedCrc;

- (void)openFile;

- (BOOL)isValid;

- (void)increasePacketNumber;

@end
