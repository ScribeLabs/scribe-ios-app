//
//  RSDiagnosticResult.h
//  Runscribe
//
//  Created by Mark Handel on 2/17/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import "RSCmd.h"

typedef NS_ENUM(NSInteger, RSDiagnosticType)
{
    kRSDiagnosticsTypeGyro              = 1 << 0,
    kRSDiagnosticsTypeAccelerometer     = 1 << 1,
    kRSDiagnosticsTypeMagnometer        = 1 << 2,
    kRSDiagnosticsTypeReserved1         = 1 << 3,
    kRSDiagnosticsTypeFlash             = 1 << 4,
    kRSDiagnosticsTypeEEPROM            = 1 << 5,
    kRSDiagnosticsTypeDMP               = 1 << 6,
    kRSDiagnosticsTypeReserved3         = 1 << 7
};

@interface RSDiagnosticResult : RSCmd

@property (nonatomic, assign) uint diagnosticResult;

- (NSInteger)successCode;
- (BOOL)diagnosticPassed:(RSDiagnosticType) diagType;
- (BOOL)diagnosticsPassed;
- (void)logDiagnosticResults;

@end
