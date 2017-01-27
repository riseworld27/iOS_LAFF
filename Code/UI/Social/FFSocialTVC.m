//
//  FFSocialTVC.m
//  laff
//
//  Created by matata on 29.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFSocialTVC.h"
#import "FFConstants.h"
#import "FFSocialButtonsCell.h"
#import "FFTweetsTitleCell.h"
#import "FFTweetCell.h"

#import "GA.h"

#import <STTwitter/STTwitter.h>
#import <SVWebViewController/SVWebViewController.h>
#import <M13ProgressSuite/UINavigationController+M13ProgressViewBar.h>
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

static NSString * const CELL_ID_EMPTY = @"empty";
static NSUInteger const NUM_TWEETS_TO_LOAD = 20;

typedef NS_ENUM(NSUInteger, FFSocialTVCState) {
    FFSocialTVCStateUnknown = 0,
    FFSocialTVCStateLoading,
    FFSocialTVCStateLoaded,
    FFSocialTVCStateFailed,
};

@interface FFSocialTVC ()

@property (nonatomic, strong) UIBarButtonItem * refreshBarButton;

@property (nonatomic, strong) STTwitterAPI * twitter;
@property (nonatomic, strong) NSArray * tweets;

@property (nonatomic, assign) FFSocialTVCState state;

@end

@implementation FFSocialTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	self.navigationItem.leftBarButtonItem = self.refreshBarButton;
	
	self.tableView.tableFooterView = [UIView new];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID_EMPTY];
	
	[self loadTweets];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:@"Social tab"];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

//////////////////////////////////////////////////
#pragma mark - Getting data
//////////////////////////////////////////////////

- (void)refreshClicked {
	[self loadTweets];
}
- (void)loadTweets {
	self.state = FFSocialTVCStateLoading;
	self.twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:FFConstantTwitterKey consumerSecret:FFConstantTwitterSecret];
	
	__weak FFSocialTVC * weakself = self;
	
	[self.twitter verifyCredentialsWithSuccessBlock:^(NSString * bearerToken) {
		[weakself.twitter getUserTimelineWithScreenName:FFConstantTwitterUsername count:NUM_TWEETS_TO_LOAD successBlock:^(NSArray *statuses) {
			NSLog(@"Loaded tweets: %@", statuses);
			weakself.tweets = statuses;
			[weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
			self.state = FFSocialTVCStateLoaded;
		} errorBlock:^(NSError *error) {
			self.state = FFSocialTVCStateFailed;
			[self showTweetsLoadErrorWithTitle:@"Failed to load tweets" andDescription:error.localizedDescription];
		}];
	} errorBlock:^(NSError * error) {
		self.state = FFSocialTVCStateFailed;
		[self showTweetsLoadErrorWithTitle:@"Failed to connect to twitter" andDescription:error.localizedDescription];
	}];
}
- (void)showTweetsLoadErrorWithTitle:(NSString *)title andDescription:(NSString *)description {
	__weak FFSocialTVC * weakself = self;
	[[[UIAlertView alloc] initWithTitle:title message:description cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:@"Retry" action:^{
		[weakself loadTweets];
	}], nil] show];
}
- (void)setState:(FFSocialTVCState)state {
	switch (state) {
		case FFSocialTVCStateUnknown:
			
			break;
		case FFSocialTVCStateLoading:
			self.refreshBarButton.enabled = NO;
			[self.navigationController setIndeterminate:YES];
			[self.navigationController showProgress];
			break;
		case FFSocialTVCStateLoaded:
			self.refreshBarButton.enabled = YES;
			[self.navigationController finishProgress];
			break;
		case FFSocialTVCStateFailed:
			self.refreshBarButton.enabled = YES;
			[self.navigationController cancelProgress];
			if (self.tweets) {
				self.state = FFSocialTVCStateLoaded;
				return;
			}
			break;
	}
	_state = state;
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // Buttons and title, tweets
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return self.tweets.count;
			break;
	}
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					return FFSocialButtonsCellHeight;
					break;
				case 1:
					return FFTweetsTitleCellHeight;
					break;
			}
			break;
		case 1:
			return [FFTweetCell heightWithTweet:self.tweets[indexPath.row] width:CGRectGetWidth(self.view.frame)];
			break;
	}
	return 0.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
	
	__weak FFSocialTVC * weakself = self;
	
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0: {
					//// Social icons
					FFSocialButtonsCell * socialButtonsCell = [tableView dequeueReusableCellWithIdentifier:FFSocialButtonsCellIdentifier forIndexPath:indexPath];
					socialButtonsCell.onFacebookTaped = ^() {
						[weakself showFacebookPage];
					};
					cell = socialButtonsCell;
					break;
				}
				case 1: {
					//// Title
					FFTweetsTitleCell * tweetsTitleCell = [tableView dequeueReusableCellWithIdentifier:FFTweetsTitleCellIdentifier forIndexPath:indexPath];
					switch (self.state) {
						default:
						case FFSocialTVCStateUnknown:
							tweetsTitleCell.titleLabel.text = @"";
							break;
						case FFSocialTVCStateLoading:
							tweetsTitleCell.titleLabel.text = @"Loading Tweets ...";
							break;
						case FFSocialTVCStateLoaded:
							tweetsTitleCell.titleLabel.text = @"Latest Tweets";
							break;
						case FFSocialTVCStateFailed:
							tweetsTitleCell.titleLabel.text = @"Failed to load tweets";
							break;
					}
					cell = tweetsTitleCell;
					break;
				}
			}
			if (cell) {
				cell.separatorInset = UIEdgeInsetsMake(0.f, CGRectGetWidth(cell.frame), 0.f, 0.f);
			}
			break;
		case 1: {
			//// Tweet
			FFTweetCell * tweetCell = [tableView dequeueReusableCellWithIdentifier:FFTweetCellIdentifier forIndexPath:indexPath];
			[tweetCell updateWithTweet:self.tweets[indexPath.row]];
			cell = tweetCell;
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
#pragma mark - Table view delegate
//////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 1) {
		id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
		
		NSDictionary * tweet = self.tweets[indexPath.row];
		NSNumber * tweetID = tweet[@"id"];
		
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
	}
}
- (void)showFacebookPage {
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:@"Facebook screen"];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];

	/*/
	NSString * urlStringToOpenFBApp = [NSString stringWithFormat:@"fb://profile/%@", FFConstantFacebookID];
	NSURL * urlToOpenFBApp = [NSURL URLWithString:urlStringToOpenFBApp];
	UIApplication * app = [UIApplication sharedApplication];
	
	if ([app canOpenURL:urlToOpenFBApp]) {
		// Open in facebook app
		[app openURL:urlToOpenFBApp];
	} else {
		// Open in embedded browser
		NSString * tweetUrlString = [NSString stringWithFormat:@"https://facebook.com/%@", FFConstantFacebookUsername];
		SVWebViewController * webViewController = [[SVWebViewController alloc] initWithAddress:tweetUrlString];
		webViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:webViewController animated:YES];
	}
	/*/
	
	NSString * tweetUrlString = [NSString stringWithFormat:@"https://facebook.com/%@", FFConstantFacebookUsername];
	SVWebViewController * webViewController = [[SVWebViewController alloc] initWithAddress:tweetUrlString];
	webViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:webViewController animated:YES];
	
	//*/
}

@end
