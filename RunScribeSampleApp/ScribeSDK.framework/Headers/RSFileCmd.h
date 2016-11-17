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

typedef NS_ENUM(NSInteger, RSScribeFileCRCStatus)
{
    kRSFileCRCValid = 1,
    kRSFileCRCInvalid = 2,
};

typedef NS_ENUM(NSInteger, RSScribeFileStatus)
{
    kRSFileNotDeleted = 1,
    kRSFileDeleted = 2,
};

@interface RSFileCmd : RSCmd

@property (nonatomic, assign) uint crcHigh;
@property (nonatomic, assign) uint crcLow;
@property (nonatomic, assign) uint crcStatus;
@property (nonatomic, assign) uint fileStatus;

- (void)setFileStatusFromByte:(uint)status;
- (void)setCRCStatusFromByte:(uint)status;
- (uint)crc16;


@end