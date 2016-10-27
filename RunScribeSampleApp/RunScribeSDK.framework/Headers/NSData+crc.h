//
//  NSData+crc.h
//  Runscribe
//
//  Created by Adam Hamel on 6/8/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface NSData (crc)

- (uint16_t)crc16Checksum;

- (uint32_t)crc32Checksum;

@end
