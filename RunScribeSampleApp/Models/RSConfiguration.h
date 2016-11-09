//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSConfiguration : NSObject

@property (nonatomic, assign) NSInteger placement;
@property (nonatomic, assign) NSInteger side;
@property (nonatomic, assign) NSInteger timeOut;
@property (nonatomic, assign) NSInteger strideRate;
@property (nonatomic, assign) NSInteger scaleFactorA;
@property (nonatomic, assign) NSInteger scaleFactorB;
@property (nonatomic, assign) NSInteger recordingVoltageThreshold;
@property (nonatomic, assign) NSInteger sleepVoltageThreshold;
@property (nonatomic, assign) NSInteger ledRed;
@property (nonatomic, assign) NSInteger ledGreen;
@property (nonatomic, assign) NSInteger ledBlue;

@end
