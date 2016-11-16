//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSSensorSample.h"

@implementation RSSensorSample

- (instancetype)initWithX:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z
{
    self = [super init];
    if (self)
    {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}

@end
