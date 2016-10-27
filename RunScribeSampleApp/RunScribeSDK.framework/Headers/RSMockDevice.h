//
//  RSMockDevice.h
//  Runscribe
//
//  Created by Adam Hamel on 6/11/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
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
