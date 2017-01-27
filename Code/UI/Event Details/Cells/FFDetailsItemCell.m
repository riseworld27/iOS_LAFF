//
//  FFDetailsItemCell.m
//  laff
//
//  Created by matata on 5.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFDetailsItemCell.h"
#import "FFAttributedStringUtils.h"

NSString * const FFDetailsItemCellIdentifier = @"Details Item";

@interface FFDetailsItemCell ()

@property (weak, nonatomic) IBOutlet UILabel    * titleLabel;
@property (weak, nonatomic) IBOutlet UITextView * descriptionView;

@end

@implementation FFDetailsItemCell

- (void)awakeFromNib {
	[super awakeFromNib];
	self.descriptionView.backgroundColor = [UIColor clearColor];
	self.descriptionView.textContainer.lineFragmentPadding = 0;
	self.descriptionView.textContainerInset = UIEdgeInsetsZero;
}
- (void)updateWithTitle:(NSString *)title description:(NSString *)description {
	self.titleLabel.text = title;
	self.descriptionView.text = description;
}
- (void)updateWithTitle:(NSString *)title attributedDescription:(NSAttributedString *)description {
	self.titleLabel.text = title;
	self.descriptionView.attributedText = description;
}
+ (CGFloat)heightWithText:(NSString *)text width:(CGFloat)width {
	CGSize maxSize = CGSizeMake(width - 16.f - 16.f, CGFLOAT_MAX);
	CGRect textSize = [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:15.f]} context:nil];
	return ceilf(CGRectGetHeight(textSize)) + 32.f + 13.f + 1.f;
}
+ (CGFloat)heightWithAttributedText:(NSAttributedString *)atext width:(CGFloat)width {
	CGSize maxSize = CGSizeMake(width - 16.f - 16.f, CGFLOAT_MAX);
	CGRect textSize = [atext boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
	return ceilf(CGRectGetHeight(textSize)) + 32.f + 13.f + 1.f;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	if (!selected) return;
	
	[self becomeFirstResponder];
	
	UIMenuController * copyMenu = [UIMenuController sharedMenuController];
	[copyMenu setTargetRect:self.bounds inView:self];
	[copyMenu setMenuVisible:YES animated:YES];
}
- (BOOL)canBecomeFirstResponder {
	return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	return (action == @selector(copy:));
}
- (void)copy:(id)sender {
	[UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@: %@", self.titleLabel.text, self.descriptionView.text];
}

@end
