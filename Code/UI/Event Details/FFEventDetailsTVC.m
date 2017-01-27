//
//  FFEventDetailsTVC.m
//  laff
//
//  Created by matata on 5.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFEventDetailsTVC.h"
#import "FFDetailsItemCell.h"
#import "FFAttributedStringUtils.h"

#import "GA.h"

#import "UIColor+RGB.h"

static NSString * const KEY_TITLE = @"title";
static NSString * const KEY_DESCR = @"description";
static NSString * const KEY_HTML_DESCR = @"html-description";
static NSString * const KEY_USE_HTML = @"use_html";

static NSUInteger const descriptionColorNum = 0x4c4c4c;

@interface FFEventDetailsTVC ()

@property (nonatomic, strong) NSArray * items;

@end

@implementation FFEventDetailsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.tableView.tableFooterView = [UIView new];
	
	self.items = @[
				   @{
					   KEY_TITLE: @"Full Title",
					   KEY_DESCR: self.event.eventTitle ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Foreign Title",
					   KEY_DESCR: self.event.foreignTitle ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Synopsis Note",
					   KEY_DESCR: self.event.synopsisNote ?: @"",
					   KEY_USE_HTML: @(YES),
					   },
				   @{
					   KEY_TITLE: @"Directors",
					   KEY_DESCR: self.event.directors ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Year",
					   KEY_DESCR: self.event.year.intValue ? [self.event.year stringValue] : @"",
					   },
				   @{
					   KEY_TITLE: @"RunTime",
					   KEY_DESCR: self.event.runTime ? [NSString stringWithFormat:@"%@ min", self.event.runTime] : @"",
					   },
				   @{
					   KEY_TITLE: @"Color",
					   KEY_DESCR: self.event.colour ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Section Name",
					   KEY_DESCR: self.event.sectionName ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Cast Credit",
					   KEY_DESCR: self.event.castCredit ?: @"",
					   KEY_USE_HTML: @(YES),
					   },
				   @{
					   KEY_TITLE: @"Countries",
					   KEY_DESCR: self.event.countries ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Premiere",
					   KEY_DESCR: self.event.premiere ?: @"",
					   },
				   @{
					   KEY_TITLE: @"Event Note",
					   KEY_DESCR: self.event.eventNote ?: @"",
					   KEY_USE_HTML: @(YES),
					   },
				   ];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K.length > 0", KEY_DESCR];
	self.items = [self.items filteredArrayUsingPredicate:predicate];
	
	NSMutableArray * mitems = [NSMutableArray arrayWithArray:self.items];
	NSDictionary * attributes = [FFEventDetailsTVC htmlTextAttributes];
	NSUInteger index = 0;
	for (NSDictionary * item in self.items) {
		BOOL useHtml = [item[KEY_USE_HTML] boolValue];
		if (useHtml) {
			NSMutableDictionary * mitem = [NSMutableDictionary dictionaryWithDictionary:item];
			mitem[KEY_HTML_DESCR] = [FFAttributedStringUtils attributedStringWithTextParams:attributes andHTML:mitem[KEY_DESCR]];
			[mitems replaceObjectAtIndex:index withObject:mitem];
		}
		index++;
	}
	self.items = mitems;
}
+ (NSDictionary *)htmlTextAttributes {
	static NSDictionary * attributes;
	if (!attributes) {
		attributes = @{
					   NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.f],
					   NSForegroundColorAttributeName: [UIColor colorFromRGB:descriptionColorNum],
					   };
	}
	return attributes;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:[@"Event details > " stringByAppendingString:self.event.eventTitle]];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary * dataItem = self.items[indexPath.row];
	BOOL useHTML = [dataItem[KEY_USE_HTML] boolValue];
	if (useHTML) {
		return [FFDetailsItemCell heightWithAttributedText:dataItem[KEY_HTML_DESCR] width:CGRectGetWidth(self.view.frame)];
	} else {
		return [FFDetailsItemCell heightWithText:dataItem[KEY_DESCR] width:CGRectGetWidth(self.view.frame)];
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FFDetailsItemCell * cell = [tableView dequeueReusableCellWithIdentifier:FFDetailsItemCellIdentifier forIndexPath:indexPath];
	NSDictionary * itemData = self.items[indexPath.row];
	BOOL useHTML = [itemData[KEY_USE_HTML] boolValue];
	if (useHTML) {
		[cell updateWithTitle:itemData[KEY_TITLE] attributedDescription:itemData[KEY_HTML_DESCR]];
	} else {
		[cell updateWithTitle:itemData[KEY_TITLE] description:itemData[KEY_DESCR]];
	}
	
    return cell;
}

//////////////////////////////////////////////////
#pragma mark - Table view delegate
//////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
