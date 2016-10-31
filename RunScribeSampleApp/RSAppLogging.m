//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSAppLogging.h"

DDLogLevel const ddLogLevel = DDLogLevelDebug;

@implementation RSAppLogging

+ (void)initLogging
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    // Test Logging
    DDLogWarn(@"Test Log Warn");
    DDLogInfo(@"Test Log Info");
    DDLogDebug(@"Test Log Debug");
    DDLogVerbose(@"Test Log Verbose");
    DDLogError(@"Test Log Error");
}

@end
