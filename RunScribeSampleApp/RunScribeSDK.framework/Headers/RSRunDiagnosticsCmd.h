//
//  RSRunDiagnosticsCmd.h
//  Runscribe
//
//  Created by Mark Handel on 10/23/15.
//  Copyright © 2015 Runscribe. All rights reserved.
//

#import "RSDiagnosticResult.h"

typedef NS_ENUM(NSInteger, RSDiagnosticsMode)
{
    kRSDiagnosticsReadMode = 0,
    kRSDiagnosticsSetMode = 1
};

typedef NS_ENUM(NSInteger, RSDiagnosticsStatus)
{
    kRSDiagnosticsStatusRunning = 1,
    kRSDiagnosticsStatusComplete = 2,
    kRSDiagnosticsStatusNotRunning = 3
};


@interface RSRunDiagnosticsCmd : RSDiagnosticResult

@property (nonatomic, assign) uint mode;
@property (nonatomic, assign) uint status;
@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;

@end
