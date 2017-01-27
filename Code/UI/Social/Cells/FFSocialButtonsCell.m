//
//  FFSocialButtonsCell.m
//  laff
//
//  Created by matata on 29.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFSocialButtonsCell.h"
#import "UIColor+RGB.h"
//#import <BlocksKit/UIView+BlocksKit.h>

NSString * const FFSocialButtonsCellIdentifier = @"socialButtons";
CGFloat const FFSocialButtonsCellHeight = 88.f;

@interface FFSocialButtonsCell ()

@property (weak, nonatomic) IBOutlet UIView *fbHalf;
@property (weak, nonatomic) IBOutlet UIButton *fbButton;

@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;

@end

@implementation FFSocialButtonsCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
#ifdef LAFF
	self.twitterLabel.text = @"@LaFilmFest";
	self.facebookLabel.text = @"/LAFilmFest";
#elif NBFF
	self.twitterLabel.text = @"@nbff";
	self.facebookLabel.text = @"/NewportBeachFilmFest";
#endif
}
- (IBAction)fbTouchDown:(id)sender {
	self.fbButton.backgroundColor = [UIColor colorFromRGB:0xD3D1D4];
}
- (IBAction)fbTouchCancel:(id)sender {
	self.fbButton.backgroundColor = [UIColor colorFromRGB:0xEEECEF];
}
- (IBAction)fbSelected:(id)sender {
	[self fbTouchCancel:sender];
	if (self.onFacebookTaped) {
		self.onFacebookTaped();
	}
}

@end
