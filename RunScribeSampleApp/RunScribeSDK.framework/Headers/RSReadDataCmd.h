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

#import "RSMultipartResponseCmd.h"
#import "RSUpdateCRCCmd.h"

@interface RSReadDataCmd : RSMultipartResponseCmd

@property (nonatomic, assign) uint fileIndex;
@property (nonatomic, assign) uint fileSize;
@property (nonatomic, assign) uint blockSize; // always 16
@property (nonatomic, assign) uint filePointReg;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, assign) uint8_t crcHigh;
@property (nonatomic, assign) uint8_t crcLow;
@property (nonatomic, assign) uint16_t crc16;
@property (nonatomic, assign) uint16_t crc16Reference;
@property (nonatomic, assign) uint32_t crc32;
@property (nonatomic, strong) RSUpdateCRCCmd *crcCmd;
@property (nonatomic, assign) BOOL performCRCIntegrityCheck;

@end
