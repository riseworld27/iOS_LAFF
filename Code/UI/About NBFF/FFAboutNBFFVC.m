//
//  FFAboutNBFFVC.m
//  laff
//
//  Created by matata on 08.04.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFAboutNBFFVC.h"
#import "FFAboutNBFFHeaderCell.h"
#import "FFAboutTextCell.h"

@interface FFAboutNBFFVC ()

@property (nonatomic, strong) NSString * text;

@end

@implementation FFAboutNBFFVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

//////////////////////////////////////////////////
#pragma mark - Text
//////////////////////////////////////////////////

- (NSString *)text {
	static NSString * stext;
	if (!stext) {
		// TODO: load from txt
		NSString * filepath = [[NSBundle mainBundle] pathForResource:@"nbff_about" ofType:@"txt"];
		stext = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
	}
	return stext;
}

//////////////////////////////////////////////////
#pragma mark - Table view data source and delegate
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0:
			return FFAboutNBFFHeaderCellHeight;
			break;
		case 1:
			return [FFAboutTextCell heightWithText:self.text font:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.f] width:CGRectGetWidth(self.view.frame)];
			break;
	}
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell;
	
	switch (indexPath.row) {
		case 0: {
			FFAboutNBFFHeaderCell * headerCell = [tableView dequeueReusableCellWithIdentifier:FFAboutNBFFHeaderCellIdentifier forIndexPath:indexPath];
			cell = headerCell;
			break;
		}
		case 1: {
			FFAboutTextCell * textCell = [tableView dequeueReusableCellWithIdentifier:FFAboutTextCellIdentifier forIndexPath:indexPath];
			textCell.textView.text = self.text;
			cell = textCell;
			break;
		}
	}
	
	if (!cell) {
		cell = [UITableViewCell new];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return cell;
}

@end
