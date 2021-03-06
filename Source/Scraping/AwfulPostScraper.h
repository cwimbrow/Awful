//  AwfulPostScraper.h
//
//  Copyright 2014 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

#import "AwfulScraper.h"

/**
 * An AwfulPostScraper scrapes a single AwfulPost object.
 */
@interface AwfulPostScraper : AwfulScraper

@property (readonly, strong, nonatomic) AwfulPost *post;

@end
