//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import <CorePlot/CorePlot.h>
#import "RSSensorSample.h"

typedef struct _NSSignedRange {
    NSInteger location;
    NSUInteger length;
} NSSignedRange;

@interface RSCoreXYZGraph : NSObject

- (instancetype)initWithHostingView:(CPTGraphHostingView *)hostingView
                              theme:(CPTTheme *)theme
                              title:(NSString *)title
                         yAxisRange:(NSSignedRange)yAxisRange;

- (void)addNewData:(RSSensorSample *)sample;

@end
