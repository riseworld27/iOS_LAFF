//
//  FFLatestNewsTVC.m
//  laff
//
//  Created by matata on 16.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFLatestNewsTVC.h"
#import "FFFeaturedFilmSwipeCell.h"
#import "FFEventsManager.h"
#import "FFEventInfoTVC.h"
#import "FFConstants.h"
#import "FFLatestNewsTitleCell.h"
#import "FFLastTweetCell.h"
#import "FFPlayingScreeningCell.h"

#import "GA.h"
#import "UIStoryboard+Main.h"

#import <STTwitter/STTwitter.h>
#import <SVWebViewController/SVWebViewController.h>

typedef NS_ENUM(NSUInteger, LoadingStatus) {
	LoadingStatusUnknown = 0,
	LoadingStatusLoading,
	LoadingStatusLoaded,
	LoadingStatusFailed,
};

@interface FFLatestNewsTVC ()

@property (nonatomic, strong) FFEventsManager * eventsManager;
@property (nonatomic, strong) UIBarButtonItem * refreshBarButton;

@property (nonatomic, assign) BOOL eventWasOpened;
@property (nonatomic, assign) BOOL firstTimeRefresh;

@property (nonatomic, strong) STTwitterAPI * twitter;
@property (nonatomic, strong) NSDictionary * tweet;
@property (nonatomic, assign) LoadingStatus tweetLoadingStatus;

@property (nonatomic, strong) NSArray * screenings;

@end

@implementation FFLatestNewsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//// Table view
	self.tableView.tableFooterView = [UIView new];
	
	//// Events manager
	self.eventsManager = [FFEventsManager instance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsManagerStateChanged) name:FFEventsManagerStateChanged object:self.eventsManager];
	
	//// Refresh button
	self.refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	self.navigationItem.leftBarButtonItem = self.refreshBarButton;
	
	self.firstTimeRefresh = YES;
	[self eventsManagerStateChanged];
	
	[self loadLatestTweet];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.eventWasOpened) {
		self.eventWasOpened = NO;
		FFFeaturedFilmSwipeCell * swipeCell = (FFFeaturedFilmSwipeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		[swipeCell updateStatuses];
	}
}

//////////////////////////////////////////////////
#pragma mark - Latest tweet
//////////////////////////////////////////////////

- (void)loadLatestTweet {
	self.tweetLoadingStatus = LoadingStatusLoading;
	
	self.twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:FFConstantTwitterKey consumerSecret:FFConstantTwitterSecret];
	
	__weak FFLatestNewsTVC * weakself = self;
	
	[self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
		[weakself.twitter getUserTimelineWithScreenName:FFConstantTwitterUsername count:1 successBlock:^(NSArray *statuses) {
			weakself.tweet = statuses[0];
//			NSLog(@"Loaded tweet: %@", weakself.tweet);
			NSLog(@"Loaded tweet");
			weakself.tweetLoadingStatus = LoadingStatusLoaded;
			
			[weakself.tableView beginUpdates];
			[weakself.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
			[weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
			[weakself.tableView endUpdates];
			
		} errorBlock:^(NSError *error) {
			NSLog(@"Failed to load tweet");
			weakself.tweetLoadingStatus = LoadingStatusFailed;
			[weakself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
		}];
	} errorBlock:^(NSError *error) {
		NSLog(@"Failed to connect to twitter");
		weakself.tweetLoadingStatus = LoadingStatusFailed;
		[weakself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}];

}

//////////////////////////////////////////////////
#pragma mark - Events
//////////////////////////////////////////////////

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
	if (self.eventsManager.state == FFEventsManagerStateHasData || (self.eventsManager.state == FFEventsManagerStateHasDataAndUpdating && self.firstTimeRefresh)) {
		self.firstTimeRefresh = NO;
		[self refreshFeaturedEvents];
	}
}
- (void)refreshFeaturedEvents {
	NSArray * featuredEvents = self.eventsManager.featuredEvents;
	self.screenings = [self.eventsManager upcomingScreeningsLimitedBy:5];
	
	/*
	for (Screening * screening in self.screenings) {
		NSLog(@"screening date: %@", screening.screeningDate);
	}
	 */
	
//	NSLog(@"self.screenings: %@", self.screenings);
	
	NSMutableIndexSet * sectionsSet = [NSMutableIndexSet indexSet];
	[sectionsSet addIndex:0];
	[sectionsSet addIndex:2];
	
	[self.tableView reloadSections:sectionsSet withRowAnimation:UITableViewRowAnimationAutomatic];
	
	FFFeaturedFilmSwipeCell * swipeCell = (FFFeaturedFilmSwipeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[swipeCell initWithFeaturedEvents:featuredEvents];
}

//////////////////////////////////////////////////
#pragma mark - Refresh
//////////////////////////////////////////////////

- (void)refreshClicked {
	[self.eventsManager load];
}

//////////////////////////////////////////////////
#pragma mark - Table view data source and delegate
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			switch (self.tweetLoadingStatus) {
				case LoadingStatusUnknown:
				case LoadingStatusLoading:
					return 1;
					break;
				case LoadingStatusLoaded:
					return 2;
					break;
				case LoadingStatusFailed:
					return 0;
					break;
			}
			break;
		case 2: {
			return self.screenings ? 1 + self.screenings.count : 1;
			break;
		}
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return self.eventsManager.hasFeaturedEvents ? FFFeaturedFilmSwipeCellHeight : 0.f;
		case 1:
			switch (indexPath.row) {
				case 0:
					return 50.f;
				case 1:
					switch (self.tweetLoadingStatus) {
						case LoadingStatusUnknown:
						case LoadingStatusLoading:
						case LoadingStatusFailed:
							return 0.f;
						case LoadingStatusLoaded:
							return [FFLastTweetCell heightWithTweet:self.tweet width:CGRectGetWidth(self.view.frame)];
					}
			}
		case 2:
			switch (indexPath.row) {
				case 0:
					return 50.f;
					break;
				default:
					return FFPlayingScreeningCellHeight;
					break;
			}
	}
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell;
	
	switch (indexPath.section) {
		case 0: {
			__weak FFFeaturedFilmSwipeCell * swipeCell = [tableView dequeueReusableCellWithIdentifier:FFFeaturedFilmSwipeCellIdentifier forIndexPath:indexPath];
			
			swipeCell.onSelect = ^() {
				[self showEvent:swipeCell.currentEvent];
			};
			
			cell = swipeCell;
			break;
		}
		case 1: {
			switch (indexPath.row) {
				case 0: {
					FFLatestNewsTitleCell * titleCell = [tableView dequeueReusableCellWithIdentifier:FFLatestNewsTitleCellIdentifier forIndexPath:indexPath];
					
					switch (self.tweetLoadingStatus) {
						case LoadingStatusUnknown:
						case LoadingStatusLoading:
							titleCell.field.text = @"Loading Latest News ...";
							break;
						case LoadingStatusLoaded:
							titleCell.field.text = @"Latest News";
							break;
						default:
							break;
					}
					
					cell = titleCell;
					break;
				}
				case 1: {
					FFLastTweetCell * tweetCell = [tableView dequeueReusableCellWithIdentifier:FFLastTweetCellIdentifier forIndexPath:indexPath];
					[tweetCell updateWithTweet:self.tweet];
					cell = tweetCell;
					break;
				}
			}
			break;
		}
		case 2: {
			switch (indexPath.row) {
				case 0: {
					FFLatestNewsTitleCell * titleCell = [tableView dequeueReusableCellWithIdentifier:FFLatestNewsTitleCellIdentifier forIndexPath:indexPath];
					
					switch (self.eventsManager.state) {
						case FFEventsManagerStateNotInited:
						case FFEventsManagerStateNoData:
							titleCell.field.text = @"";
							break;
						case FFEventsManagerStateNoDataAndLoading:
							titleCell.field.text = @"Loading upcoming screenings ...";
							
							break;
						case FFEventsManagerStateHasData:
						case FFEventsManagerStateHasDataAndUpdating:
							if (self.screenings && self.screenings.count) {
								titleCell.field.text = @"Upcoming screenings";
							} else {
								titleCell.field.text = @"No upcoming screenings";
							}
							
							break;
					}
					
					cell = titleCell;
					break;
				}
				default: {
					FFPlayingScreeningCell * screeningCell = [tableView dequeueReusableCellWithIdentifier:FFPlayingScreeningCellIdentifier forIndexPath:indexPath];
					
					NSUInteger screeningNum = indexPath.row - 1;
					Screening * screening = self.screenings[screeningNum];
					[screeningCell updateWithScreening:screening];
					cell = screeningCell;
					break;
				}
			}
			break;
		}
	}
	
	if (!cell) {
		cell = [UITableViewCell new];
	}
	
	cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.view.frame), 0, 0);
	
    return cell;
}

//////////////////////////////////////////////////
#pragma mark - Select
//////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1 && indexPath.row == 1) {
		id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
		
		NSNumber * tweetID = self.tweet[@"id"];
		
		NSString * urlStringToOpenTwitterApp = [NSString stringWithFormat:@"twitter://status?id=%@", tweetID];
		NSURL * urlToOpenTwitterApp = [NSURL URLWithString:urlStringToOpenTwitterApp];
		UIApplication * app = [UIApplication sharedApplication];
		
		if ([app canOpenURL:urlToOpenTwitterApp]) {
			// Open in twitter app
			[tracker set:kGAIScreenName value:@"Tweet in twitter application"];
			[app openURL:urlToOpenTwitterApp];
		} else {
			// Open in embedded browser
			[tracker set:kGAIScreenName value:@"Tweet in internal browser"];
			NSString * tweetUrlString = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@", FFConstantTwitterUsername, tweetID];
			SVWebViewController * webViewController = [[SVWebViewController alloc] initWithAddress:tweetUrlString];
			webViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:webViewController animated:YES];
		}
		
		[tracker send:[[GAIDictionaryBuilder createAppView] build]];
	} else if (indexPath.section == 2 && indexPath.row > 0) {
		NSUInteger screeningIndex = indexPath.row - 1;
		Screening * screening = self.screenings[screeningIndex];
		
		FFEventInfoTVC * vc = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFEventInfoTVCIdentifier];
		vc.screening = screening;
		[self.navigationController pushViewController:vc animated:YES];
		
	}
}
- (void)showEvent:(Event *)event {
	FFEventInfoTVC * vc = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFEventInfoTVCIdentifier];
	vc.event = event;
	self.eventWasOpened = YES;
	[self.navigationController pushViewController:vc animated:YES];
}


@end
