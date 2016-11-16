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

@interface RSMotionData : NSObject

@property (nonatomic, assign) uint mpuDataModeIndex;

@property (nonatomic, assign) uint accelX;
@property (nonatomic, assign) uint accelY;
@property (nonatomic, assign) uint accelZ;

@property (nonatomic, assign) uint gyroX;
@property (nonatomic, assign) uint gyroY;
@property (nonatomic, assign) uint gyroZ;

@property (nonatomic, assign) uint compassX;
@property (nonatomic, assign) uint compassY;
@property (nonatomic, assign) uint compassZ;

@property (nonatomic, assign) uint quat1;
@property (nonatomic, assign) uint quat2;
@property (nonatomic, assign) uint quat3;
@property (nonatomic, assign) uint quat4;

@property (nonatomic, assign) double pitch;
@property (nonatomic, assign) double roll;
@property (nonatomic, assign) double yaw;

@end
