//
//  AwfulStopwatch.h
//  Awful
//
//  Created by Nolan Waite on 2013-01-23.
//  Copyright (c) 2013 Regular Berry Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AwfulStopwatch : NSObject

- (instancetype)initWithName:(NSString *)name;

@property (readonly, copy, nonatomic) NSString *name;

- (void)start;

+ (instancetype)startWithName:(NSString *)name;

- (void)recordCheckpoint:(NSString *)checkpointName;

// Array of AwfulStopwatchCheckpoint instances.
@property (readonly, nonatomic) NSArray *checkpoints;

- (NSString *)summary;

- (void)presentSummary;

@end


@interface AwfulStopwatchCheckpoint : NSObject

@property (readonly, copy, nonatomic) NSString *name;

@property (readonly, nonatomic) NSTimeInterval timeInterval;

@end
