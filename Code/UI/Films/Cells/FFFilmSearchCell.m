//
//  FFFilmSearchCell.m
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFFilmSearchCell.h"

NSString * const FFFilmSearchCellIdentifier = @"search";
CGFloat const FFFilmSearchCellHeight = 44.f;

@interface FFFilmSearchCell ()

@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation FFFilmSearchCell

- (void)dealloc {
	if (self.tapGestureRecognizer) {
		[self.window removeGestureRecognizer:self.tapGestureRecognizer];
		[self.tapGestureRecognizer removeTarget:self action:@selector(tapOutside)];
		self.tapGestureRecognizer = nil;
	}
}
- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside)];
	self.tapGestureRecognizer.cancelsTouchesInView = NO;
	
	self.searchBar.delegate = self;
}
- (void)tapOutside {
	[self.searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	if (self.onFocus) {
		self.onFocus();
	}
	[self.window addGestureRecognizer:self.tapGestureRecognizer];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self.window removeGestureRecognizer:self.tapGestureRecognizer];
	if (self.onUnfocus) {
		self.onUnfocus();
	}
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if (self.onTextDidChange) {
		self.onTextDidChange(searchText);
	}
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"searchBarSearchButtonClicked");
	[searchBar resignFirstResponder];
}

@end
