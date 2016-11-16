//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSensorSample : NSObject

@property (nonatomic, strong) NSNumber *x;
@property (nonatomic, strong) NSNumber *y;
@property (nonatomic, strong) NSNumber *z;

- (instancetype)initWithX:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z;

@end
