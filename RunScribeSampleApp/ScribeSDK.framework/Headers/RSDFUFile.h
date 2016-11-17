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
