//
//  FFFeaturedTVC.m
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFFeaturedTVC.h"
#import "FFEventsManager.h"
#import "FFEventImageTitleCell.h"
#import "FFEventInfoTVC.h"
#import "UIStoryboard+Main.h"
#import "GA.h"

@interface FFFeaturedTVC ()

@property (nonatomic, strong) FFEventsManager * eventsManager;
@property (nonatomic, strong) NSArray * featuredEvents;
@property (nonatomic, strong) UIBarButtonItem * refreshBarButton;

@end

@implementation FFFeaturedTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.eventsManager = [FFEventsManager instance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsManagerStateChanged) name:FFEventsManagerStateChanged object:self.eventsManager];
	
	self.refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	self.navigationItem.leftBarButtonItem = self.refreshBarButton;
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self loadFeaturedEvents];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSArray * indexPathsForVisibleRows = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath * indexPath in indexPathsForVisibleRows) {
		FFEventImageTitleCell * cell = (FFEventImageTitleCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		cell.event = cell.event;
	}
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:@"Featured tab"];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}
- (void)eventsManagerStateChanged {
	switch (self.eventsManager.state) {
		case FFEventsManagerStateNoData:
		case FFEventsManagerStateHasData:
			self.refreshBarButton.enabled = YES;
			break;
		case FFEventsManagerStateNotInited:
		case FFEventsManagerStateNoDataAndLoading:
		case FFEventsManagerStateHasDataAndUpdating:
			self.refreshBarButton.enabled = NO;
			break;
	}
	if (self.eventsManager.state == FFEventsManagerStateHasData) {
		[self loadFeaturedEvents];
	}
}
- (void)refreshClicked {
	[self.eventsManager load];
}
- (void)loadFeaturedEvents {
	self.featuredEvents = self.eventsManager.featuredEvents;
//	NSLog(@"self.featuredEvents.count: %d", self.featuredEvents.count);
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self scrollViewDidScroll:self.tableView];
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.featuredEvents.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return FFEventImageTitleCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FFEventImageTitleCell * cell = [tableView dequeueReusableCellWithIdentifier:FFEventImageTitleCellIdentifier forIndexPath:indexPath];
	cell.parallaxEnabled = YES;
    cell.event = self.featuredEvents[indexPath.row];
    return cell;
}

//////////////////////////////////////////////////
#pragma mark - Table view delegate
//////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FFEventInfoTVC * vc = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFEventInfoTVCIdentifier];
	vc.event = self.featuredEvents[indexPath.row];
	[self.navigationController pushViewController:vc animated:YES];
}

//////////////////////////////////////////////////
#pragma mark - Scroll view delegate
//////////////////////////////////////////////////

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.featuredEvents.count) {
		NSArray * visibleCellsIndexes = self.tableView.indexPathsForVisibleRows;
		for (NSIndexPath * cellIndex in visibleCellsIndexes) {
			FFEventImageTitleCell * cell = (id)[self.tableView cellForRowAtIndexPath:cellIndex];
			if (![cell isKindOfClass:[FFEventImageTitleCell class]]) continue;
			CGRect cellRect = [cell convertRect:cell.bounds toView:self.view.window];
			CGFloat cellY = CGRectGetMidY(cellRect);
			float percent = cellY / CGRectGetHeight(self.view.frame);
			[cell updateWithScrollPercentage:percent];
		}
	}
}

@end
