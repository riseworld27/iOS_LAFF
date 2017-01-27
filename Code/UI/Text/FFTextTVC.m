//
//  FFTextTVC.m
//  laff
//
//  Created by matata on 19.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFTextTVC.h"
#import "FFAboutTextCell.h"

#import "GA.h"

NSString * const FFTextTVCIdentifier = @"Text";

@interface FFTextTVC ()

@end

@implementation FFTextTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:[@"Text screen > " stringByAppendingString:self.navigationItem.title]];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

//////////////////////////////////////////////////
#pragma mark Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.atext) {
		return [FFAboutTextCell heightWithAText:self.atext width:CGRectGetWidth(self.view.frame)];
	} else {
		return [FFAboutTextCell heightWithText:self.text width:CGRectGetWidth(self.view.frame)];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FFAboutTextCell * cell = [tableView dequeueReusableCellWithIdentifier:FFAboutTextCellIdentifier forIndexPath:indexPath];
	if (self.atext) {
		cell.textView.attributedText = self.atext;
	} else {
		cell.textView.text = self.text;
	}
    return cell;
}

@end
