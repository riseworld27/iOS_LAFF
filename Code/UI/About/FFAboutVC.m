//
//  FFAboutVC.m
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFAboutVC.h"
#import "FFAboutTextCell.h"
#import "FFLogoFilmIndependentCell.h"
#import "FFLogoLAFFCell.h"
#import "GA.h"

static NSString * const TEXT_0 = @"The Los Angeles Film Festival showcases new American and international cinema that embraces diversity, innovation and unique perspectives. The Festival produces one-of-a-kind events featuring critically acclaimed filmmakers, industry professionals, and award-winning talent from our City of Angels and around the world. The Festival’s signature programs include the Filmmaker Retreat, Music in Film at The GRAMMY Museum®, Celebrating Women Filmmakers, Master Classes, Spirit of Independence Award, Coffee Talks and more. The Festival also screens short films created by high school students and a special section devoted to expanded storytelling across the web, TV and gaming.";
static NSString * const TEXT_1 = @"At Film Independent our mission is to champion the cause of independent film and support a community of artists who embody diversity, innovation and uniqueness of vision. In addition to the Los Angeles Film Festival, Film Independent also produces the Film Independent Spirit Awards, the annual celebration honoring artist-driven films and recognizing the finest achievements of American independent filmmakers, and the Film Independent at LACMA Film Series, a year-round, weekly program that offers unique cinematic experiences for the Los Angeles creative community and the general public.\n\nTo become a Film Independent Member, click here.\nhttp://www.filmindependent.org/membership";

static NSString * const CELL_ID_EMPTY = @"empty";

@interface FFAboutVC ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControll;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FFAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CALayer * greyLineLayer = [CALayer layer];
	greyLineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
	greyLineLayer.frame = CGRectMake(0, CGRectGetHeight(self.topView.frame) - .5f, CGRectGetWidth(self.topView.frame), .5f);
	[self.topView.layer addSublayer:greyLineLayer];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	UIEdgeInsets tableViewInsets = self.tableView.contentInset;
	tableViewInsets.bottom = 50.f;
    self.tableView.scrollIndicatorInsets = tableViewInsets;
    self.tableView.contentInset          = tableViewInsets;
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID_EMPTY];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self trackPageview];
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2; // Logo and text for each section
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0:
			switch (self.segmentedControll.selectedSegmentIndex) {
				case 0:
					return FFLogoLAFFCellHeight;
					break;
				case 1:
					return FFLogoFilmIndependentCellHeight;
					break;
			}
			break;
		case 1:
			switch (self.segmentedControll.selectedSegmentIndex) {
				case 0:
					return [FFAboutTextCell heightWithText:TEXT_0 width:CGRectGetWidth(self.view.frame)];
					break;
				case 1:
					return [FFAboutTextCell heightWithText:TEXT_1 width:CGRectGetWidth(self.view.frame)];
					break;
			}
			break;
	}
	return 0.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell;
	
	switch (indexPath.row) {
		case 0:
			switch (self.segmentedControll.selectedSegmentIndex) {
				case 0: {
					FFLogoLAFFCell * logo1cell = [tableView dequeueReusableCellWithIdentifier:FFLogoLAFFCellIdentifier forIndexPath:indexPath];
					cell = logo1cell;
					break;
				}
				case 1: {
					FFLogoFilmIndependentCell * logo2cell = [tableView dequeueReusableCellWithIdentifier:FFLogoFilmIndependentCellIdentifier forIndexPath:indexPath];
					cell = logo2cell;
					break;
				}
			}
			break;
		case 1: {
			FFAboutTextCell * textCell = [tableView dequeueReusableCellWithIdentifier:FFAboutTextCellIdentifier forIndexPath:indexPath];
			textCell.textView.text = nil;
			switch (self.segmentedControll.selectedSegmentIndex) {
				case 0:
					textCell.textView.text = TEXT_0;
					break;
				case 1:
					textCell.textView.text = TEXT_1;
					break;
			}
			cell = textCell;
			break;
		}
	}
	
	if (!cell) {
		cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_EMPTY forIndexPath:indexPath];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return cell;
}

//////////////////////////////////////////////////
#pragma mark - Segmented Controll
//////////////////////////////////////////////////

- (IBAction)segmentedControllValueChanged:(id)sender {
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self trackPageview];
}
- (void)trackPageview {
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	switch (self.segmentedControll.selectedSegmentIndex) {
		case 0:
			[tracker set:kGAIScreenName value:@"About tab > LA Film Festival"];
			break;
		case 1:
			[tracker set:kGAIScreenName value:@"About tab > Film independent"];
			break;
	}
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
