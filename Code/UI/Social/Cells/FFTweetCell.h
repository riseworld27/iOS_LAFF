//
//  FFTweetCell.h
//  laff
//
//  Created by matata on 29.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FFTweetCellIdentifier;

@interface FFTweetCell : UITableViewCell

+ (CGFloat)heightWithTweet:(NSDictionary *)tweet width:(CGFloat)width;
- (void)updateWithTweet:(NSDictionary *)tweet;

@end
