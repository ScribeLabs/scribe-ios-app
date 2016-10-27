//
//  RSSetLEDCmd.h
//  Runscribe
//
//  Created by Mark Handel on 6/21/16.
//  Copyright © 2016 Runscribe. All rights reserved.
//

#import "RSCmd.h"

@interface RSDefaultLEDColorCmd : RSCmd

@property (nonatomic, assign) NSUInteger red;
@property (nonatomic, assign) NSUInteger green;
@property (nonatomic, assign) NSUInteger blue;

@end
