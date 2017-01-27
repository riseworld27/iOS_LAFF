//
//  FFMoreTVC.m
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFMoreTVC.h"
#import "FFEventsManager.h"
#import "FFTextTVC.h"
#import "GA.h"
#import "FFAppVersion.h"
#import "FFAttributedStringUtils.h"

#import "UIStoryboard+Main.h"

#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import <SVWebViewController/SVWebViewController.h>

static NSString * const CELL_ID_BUTTON = @"button";

#ifdef LAFF
static NSString * const HEADER_TITLE_0 = @"More from the LA Film Festival";
#elif NBFF
static NSString * const HEADER_TITLE_0 = @"More from the Newport Beach Film Festival";
#endif
static NSString * const HEADER_TITLE_1 = @"App utils";

//static NSString * const URL_PRIVACY_POLICY = @"http://www.filmindependent.org/privacy-policy";
//static NSString * const URL_CONTACT_US = @"http://www.filmindependent.org/about/contact";
static NSString * const kURLVenuesAndParking = @"http://www.lafilmfest.com/venues-parking/";
static NSString * const kURLPassInfo         = @"http://www.lafilmfest.com/ticket-info/";
static NSString * const kURLTicketingFAQ     = @"http://www.lafilmfest.com/faq/";
static NSString * const kURLSponsors         = @"http://www.lafilmfest.com/2015-sponsors/";

#ifdef LAFF

static NSUInteger const LAFF_ITEM_NUM_SPONSORS           = 0;
static NSUInteger const LAFF_ITEM_NUM_PRIVACY            = 1;
static NSUInteger const LAFF_ITEM_NUM_CONTACT            = 2;
static NSUInteger const LAFF_ITEM_NUM_VENUES_AND_PARKING = 3;
static NSUInteger const LAFF_ITEM_NUM_PASS_INFO          = 4;
static NSUInteger const LAFF_ITEM_NUM_TICKETING_FAQ      = 5;

#elif NBFF

static NSUInteger const NBFF_ITEM_NUM_SPONSORS		= 0;
static NSUInteger const NBFF_ITEM_NUM_CONTACT		= 1;
static NSUInteger const NBFF_ITEM_NUM_HOW_TO_FEST	= 2;
static NSUInteger const NBFF_ITEM_NUM_PRIVACY		= 3;
static NSUInteger const NBFF_ITEM_NUM_VENUES		= 4;

#endif

static NSString * const SEGUE_ID_SPONSORS = @"Sponsors";

@interface FFMoreTVC ()

@end

@implementation FFMoreTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:@"More tab"];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1; // No Beta
	
	if ([FFAppVersion instance].isBeta) {
		return 2; // More, utils
	} else {
		return 1; // More
	}
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
#ifdef LAFF
			return 6; // Sponsors, Privacy policy, Contact us, Venues & Parking, Pass Info, Ticketing FAQ's
#elif NBFF
			return 5;
#endif
			break;
		case 1:
			return 1; // Delete data
			break;
	}
    return 0;
}

//////////////////////////////////////////////////
#pragma mark Headers
//////////////////////////////////////////////////

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return HEADER_TITLE_0;
			break;
		case 1:
			return HEADER_TITLE_1;
			break;
	}
	return @"";
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	UITableViewHeaderFooterView * header = (UITableViewHeaderFooterView *)view;
//	header.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.f];
//	header.textLabel.textAlignment = NSTextAlignmentCenter;
	switch (section) {
		case 0:
			header.textLabel.text = HEADER_TITLE_0;
			break;
		case 1:
			header.textLabel.text = HEADER_TITLE_1;
			break;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [NSString stringWithFormat:@"Version %@", [FFAppVersion instance].versionAndBuild];
			break;
			/*
		case 1:
			return @"This section is visible in a Beta app versions only";
			break;
			 */
	}
	return @"";
}
- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
#ifdef LAFF
				case LAFF_ITEM_NUM_SPONSORS:
					return @"Sponsors";
					break;
				case LAFF_ITEM_NUM_PRIVACY:
					return @"Privacy Policy";
					break;
				case LAFF_ITEM_NUM_CONTACT:
					return @"Contact Us";
					break;
				case LAFF_ITEM_NUM_VENUES_AND_PARKING:
					return @"Venues & Parking";
					break;
				case LAFF_ITEM_NUM_PASS_INFO:
					return @"Pass & Ticket Info";
					break;
				case LAFF_ITEM_NUM_TICKETING_FAQ:
					return @"Ticketing FAQ's";
					break;
#elif NBFF
				case NBFF_ITEM_NUM_SPONSORS:
					return @"Sponsors";
					break;
				case NBFF_ITEM_NUM_CONTACT:
					return @"Contact Us";
					break;
				case NBFF_ITEM_NUM_HOW_TO_FEST:
					return @"How to fest";
					break;
				case NBFF_ITEM_NUM_PRIVACY:
					return @"Privacy Policy";
					break;
				case NBFF_ITEM_NUM_VENUES:
					return @"Venues";
					break;
#endif
			}
			break;
		case 1:
			return @"Delete cache";
			break;
	}
	return @"";
}

//////////////////////////////////////////////////
#pragma mark Cells
//////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_BUTTON forIndexPath:indexPath];
	cell.textLabel.text = [self titleForIndexPath:indexPath];
    return cell;
}

//////////////////////////////////////////////////
#pragma mark - Table view delegate
//////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
#ifdef LAFF
				case LAFF_ITEM_NUM_SPONSORS:
					[self showWebViewWithURL:[NSURL URLWithString:kURLSponsors] title:[self titleForIndexPath:indexPath]];
					break;
				case LAFF_ITEM_NUM_PRIVACY:
					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"txt"] screenTitle:@"Privacy Policy"];
					break;
				case LAFF_ITEM_NUM_CONTACT:
					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"contact" ofType:@"txt"] screenTitle:@"Contact Us"];
					break;
				case LAFF_ITEM_NUM_VENUES_AND_PARKING:
					[self showWebViewWithURL:[NSURL URLWithString:kURLVenuesAndParking] title:[self titleForIndexPath:indexPath]];
//					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"laff_venues" ofType:@"txt"] screenTitle:@"Venues & Parking" useHTML:YES];
					break;
				case LAFF_ITEM_NUM_PASS_INFO:
					[self showWebViewWithURL:[NSURL URLWithString:kURLPassInfo] title:[self titleForIndexPath:indexPath]];
					break;
				case LAFF_ITEM_NUM_TICKETING_FAQ:
					[self showWebViewWithURL:[NSURL URLWithString:kURLTicketingFAQ] title:[self titleForIndexPath:indexPath]];
					break;
#elif NBFF
				case NBFF_ITEM_NUM_SPONSORS: {
					[self performSegueWithIdentifier:@"sponsors" sender:self];
					break;
				}
				case NBFF_ITEM_NUM_CONTACT:
					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"nbff_contact" ofType:@"txt"] screenTitle:@"Contact Us" useHTML:YES];
					break;
				case NBFF_ITEM_NUM_HOW_TO_FEST:
					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"nbff_how-to-fest" ofType:@"txt"] screenTitle:@"How to fest" useHTML:YES];
					break;
				case NBFF_ITEM_NUM_PRIVACY:
					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"nbff_privacy" ofType:@"txt"] screenTitle:@"Privacy" useHTML:YES];
					break;
				case NBFF_ITEM_NUM_VENUES:
					[self showTextViewWithFilepath:[[NSBundle mainBundle] pathForResource:@"nbff_venues" ofType:@"txt"] screenTitle:@"Venues" useHTML:YES];
					break;
#endif
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					[[[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all saved data?" message:@"You can't undo that" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:@"Delete" action:^{
						[[FFEventsManager instance] deleteAllSynchronous:NO];
					}], nil] show];
					break;
			}
			break;
	}
}

//////////////////////////////////////////////////
#pragma mark - Navigating
//////////////////////////////////////////////////

- (void)showTextViewWithFilepath:(NSString *)filepath screenTitle:(NSString *)screenTitle {
	[self showTextViewWithFilepath:filepath screenTitle:screenTitle useHTML:NO];
}
- (void)showTextViewWithFilepath:(NSString *)filepath screenTitle:(NSString *)screenTitle useHTML:(BOOL)useHTML {
	NSString * text = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
	FFTextTVC * textVC = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFTextTVCIdentifier];
	
	if (useHTML) {
		text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
		
		NSDictionary * attributes = [FFMoreTVC htmlTextAttributes];
		NSAttributedString * atext = [FFAttributedStringUtils attributedStringWithTextParams:attributes andHTML:text];
		textVC.atext = atext;
	} else {
		textVC.text = text;
	}
	
	textVC.navigationItem.title = screenTitle;
	[self.navigationController pushViewController:textVC animated:YES];
}
+ (NSDictionary *)htmlTextAttributes {
	static NSDictionary * attributes;
	if (!attributes) {
		attributes = @{
					   NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f],
//					   NSForegroundColorAttributeName: [UIColor blackColor],
					   };
	}
	return attributes;
}

//////////////////////////////////////////////////
// Unused
//////////////////////////////////////////////////

- (void)showWebViewWithURL:(NSURL *)url title:(NSString *)title {
	SVWebViewController * webViewController = [[SVWebViewController alloc] initWithURL:url];
	webViewController.hidesBottomBarWhenPushed = YES;
	webViewController.navigationItem.title = title;
	[self.navigationController pushViewController:webViewController animated:YES];
}

@end
