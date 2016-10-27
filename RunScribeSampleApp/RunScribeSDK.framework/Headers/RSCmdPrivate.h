//
//  RSCmdPrivate.h
//  Runscribe
//
//  Created by Adam Hamel on 5/2/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

@interface RSCmd (Private)

/** RSDevice calls this when the device responds to this command */
- (void)deviceResponse:(NSData *)data error:(NSError *)error;

// Called by base RSCmd when NSOperation is started by the Queue
- (void)cmdStarted;

// Called when response is received
- (void)cmdEnded:(NSData *)data error:(NSError *)error;

// Called to mark operation as finished
- (void)completeOperation;

@end
