//
//  FFTweetCell.m
//  laff
//
//  Created by matata on 29.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFTweetCell.h"

#import <STTwitter/NSDateFormatter+STTwitter.h>
#import <DateTools/NSDate+DateTools.h>
#import <SDiPhoneVersion/SDiPhoneVersion.h>

NSString * const FFTweetCellIdentifier = @"tweet";

@interface FFTweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView * accountIconImageView;
@property (weak, nonatomic) IBOutlet UILabel     * accountNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     * tweetTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView  * tweetTextView;

@end

@implementation FFTweetCell

- (void)awakeFromNib {
	[super awakeFromNib];
	self.tweetTextView.backgroundColor = [UIColor clearColor];
	self.tweetTextView.textContainer.lineFragmentPadding = 0;
	self.tweetTextView.textContainerInset = UIEdgeInsetsZero;
	
#ifdef LAFF
	self.accountNameLabel.text = @"@LAFilmFest";
	self.accountIconImageView.image = [UIImage imageNamed:@"laff-logo-twitter"];
#elif NBFF
	self.accountNameLabel.text = @"Newport Beach Film Festival";
	self.accountIconImageView.image = [UIImage imageNamed:@"nbff_logo_twitter"];
#endif
}

- (void)updateWithTweet:(NSDictionary *)tweet {
	self.tweetTextView.text = tweet[@"text"];
	
	NSString * tweetDateRawSting = tweet[@"created_at"];
	NSDate * tweetDate = [[NSDateFormatter st_TwitterDateFormatter] dateFromString:tweetDateRawSting];
	
	DeviceSize deviceSize = [SDiPhoneVersion deviceSize];
	if (deviceSize == iPhone4inch || deviceSize == iPhone35inch) {
		self.tweetTimeLabel.text = tweetDate.shortTimeAgoSinceNow;
	} else {
		self.tweetTimeLabel.text = tweetDate.timeAgoSinceNow;
	}
}

+ (CGFloat)heightWithTweet:(NSDictionary *)tweet width:(CGFloat)width {
	CGSize maxSize = CGSizeMake(width - 75.f, CGFLOAT_MAX);
	NSString * text = tweet[@"text"];
	CGRect textSize = [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13.f]} context:nil];
	return ceilf(CGRectGetHeight(textSize)) + 24.f + 8.f + 1.f;
}

@end
