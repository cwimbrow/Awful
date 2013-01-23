//
//  AwfulStopwatch.m
//  Awful
//
//  Created by Nolan Waite on 2013-01-23.
//  Copyright (c) 2013 Regular Berry Software LLC. All rights reserved.
//

#import "AwfulStopwatch.h"
#import <mach/mach_time.h>

@interface AwfulStopwatchCheckpoint ()

@property (copy, nonatomic) NSString *name;

@property (nonatomic) NSTimeInterval timeInterval;

@end


@interface AwfulStopwatch ()

@property (copy, nonatomic) NSString *name;

@property (nonatomic) NSMutableArray *mutableCheckpoints;

@property (nonatomic) uint64_t absoluteStartTime;

@property (readonly, nonatomic) dispatch_queue_t queue;

@end


@implementation AwfulStopwatch

- (instancetype)initWithName:(NSString *)name
{
    if (!(self = [super init])) return nil;
    _name = [name copy];
    _mutableCheckpoints = [NSMutableArray new];
    _queue = dispatch_queue_create("com.awfulapp.Awful.Stopwatch", 0);
    return self;
}

- (void)dealloc
{
    dispatch_release(_queue);
}

- (void)start
{
    uint64_t start = mach_absolute_time();
    dispatch_async(self.queue, ^{ self.absoluteStartTime = start; });
}

+ (instancetype)startWithName:(NSString *)name
{
    AwfulStopwatch *stopwatch = [[self alloc] initWithName:name];
    [stopwatch start];
    return stopwatch;
}

- (void)recordCheckpoint:(NSString *)checkpointName
{
    static mach_timebase_info_data_t info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kern_return_t err = mach_timebase_info(&info);
        if (err != KERN_SUCCESS) {
            NSLog(@"could not get timebase info [error code %d]", err);
            return;
        }
    });
    uint64_t now = mach_absolute_time();
    dispatch_async(self.queue, ^{
        uint64_t ns = (now - self.absoluteStartTime) * info.numer / info.denom;
        AwfulStopwatchCheckpoint *checkpoint = [AwfulStopwatchCheckpoint new];
        checkpoint.name = checkpointName;
        checkpoint.timeInterval = (NSTimeInterval)ns / NSEC_PER_SEC;
        [self.mutableCheckpoints addObject:checkpoint];
    });
}

- (NSArray *)checkpoints
{
    __block NSArray *checkpoints;
    dispatch_sync(self.queue, ^{ checkpoints = [self.mutableCheckpoints copy]; });
    return checkpoints;
}

- (NSString *)summary
{
    NSMutableString *summary = [NSMutableString stringWithFormat:@"Stopwatch for %@\n", self.name];
    for (AwfulStopwatchCheckpoint *checkpoint in self.checkpoints) {
        [summary appendFormat:@"  at %.3fs %@\n", checkpoint.timeInterval, checkpoint.name];
    }
    return summary;
}

- (void)presentSummary
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self presentSummary]; });
    }
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){
        .origin.y = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame),
        .size.width = 200
    }];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.text = [self summary];
    [label sizeToFit];
    label.backgroundColor = [UIColor darkGrayColor];
    label.textColor = [UIColor lightTextColor];
    label.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [UIView animateWithDuration:0.3 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:5 options:0 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}

@end


@implementation AwfulStopwatchCheckpoint @end
