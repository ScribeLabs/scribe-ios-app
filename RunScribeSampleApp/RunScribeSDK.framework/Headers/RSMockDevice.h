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

#import "RSDevice.h"

typedef NS_ENUM(NSInteger, RSMockDeviceState)
{
    kRSMockDeviceStateConnected,
    kRSMockDeviceStateDisconnected,
    kRSMockDeviceStateReady
};

extern NSString * const kConfigDeviceState;                     // NSNumber RSMockDeviceState
extern NSString * const kConfigDeviceBatteryPct;                // NSNumber integer
extern NSString * const kConfigDeviceMemoryPct;                 // NSNumber integer
extern NSString * const kConfigDeviceDelayConnectSeconds;       // NSNumber seconds until connected
extern NSString * const kConfigDeviceDelayDisconnectSeconds;    // NSNumber seconds until disconnect

@interface RSMockDevice : RSDevice

- (id)initWithName:(NSString *)name uuid:(NSString *)uuid serialNumber:(NSString *)serialNumber protocolVersion:(NSString *)protocolVersion firmwareVersion:(NSString *)firmwareVersion configuration:(NSDictionary *)config hardwareVersion:(NSString *)hardwareVersion;

- (void)connectAfterDelay:(int)seconds;

// Mock instances
+ (RSMockDevice *)createMockSyncDeviceWithName:(NSString *)name uuid:(NSString *)uuid serialNumber:(NSString *)serialNumber protocolVersion:(NSString *)protocolVersion firmwareVersion:(NSString *)firmwareVersion hardwareVersion:(NSString *)hardwareVersion atIndex:(int)index;
+ (RSMockDevice *)createConnectedMock:(NSString *)name uuid:(NSString *)uuid serialNumber:(NSString *)serialNumber protocolVersion:(NSString *)protocolVersion firmwareVersion:(NSString *)firmwareVersion hardwareVersion:(NSString *)hardwareVersion;

@end
