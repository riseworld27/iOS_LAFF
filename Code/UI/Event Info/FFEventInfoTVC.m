//
//  FFEventInfoTVC.m
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFEventInfoTVC.h"
#import "FFEventsManager.h"
#import "FFEventImageTitleCell.h"
#import "FFEventDetailsCell.h"
#import "FFEventGetTicketsCell.h"
#import "FFEventScreeningCell.h"
#import "FFScreeningLocationVC.h"
#import "FFEventDetailsTVC.h"
#import "FFScreeningLocations.h"
#import "FFScreeningLocation.h"
#import "FFEventActionsCell.h"
#import "GA.h"

#import "Event+Description.h"

#import <RegExCategories/RegExCategories.h>
#import <SVWebViewController/SVWebViewController.h>
#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <RegExCategories/RegExCategories.h>

NSString * const FFEventInfoTVCIdentifier = @"Event Info";

static NSString * const CELL_ID_EMPTY = @"empty";
static NSString * const SEGUE_ID_MAP = @"map";
static NSString * const SEGUE_ID_DETAILS = @"details";

@interface FFEventInfoTVC ()

@property (nonatomic, strong) NSArray * screenings;
@property (nonatomic, strong) NSArray * locations;
@property (nonatomic, strong) NSString * detailsText;

@end

@implementation FFEventInfoTVC

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FFEventsManagerStateChanged object:[FFEventsManager instance]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID_EMPTY];
	self.tableView.tableFooterView = [UIView new];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsManagerStateChanged) name:FFEventsManagerStateChanged object:[FFEventsManager instance]];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(shareEvent)];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:[@"Event screen > " stringByAppendingString:self.event.eventTitle]];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}
- (void)setScreening:(Screening *)screening {
	self.event = screening.event;
	_screening = screening;
}
- (void)setEvent:(Event *)event {
	self.screenings = [event.screenings.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"screeningDate" ascending:YES]]];
	self.detailsText = [event.synopsisNote replace:RX(@"<[^>]+>") with:@""];
	_event = event;
}
- (void)setScreenings:(NSArray *)screenings {
	FFScreeningLocations * locationsManager = [FFScreeningLocations instance];
	NSMutableArray * mutableLocations = [NSMutableArray arrayWithCapacity:screenings.count];
	[screenings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Screening * screening = obj;
#ifdef LAFF
		FFScreeningLocation * location = [locationsManager locationWithName:screening.venueName];
#elif NBFF
		FFScreeningLocation * location = [locationsManager locationWithCode:screening.venueCode];
#endif
		mutableLocations[idx] = location;
	}];
	self.locations = mutableLocations;
	_screenings = screenings;
}
- (void)eventsManagerStateChanged {
	self.event = self.event;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)shareEvent {

/*
#ifdef LAFF
	
	FFEventImageTitleCell * imageCell = (FFEventImageTitleCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	
	NSString * title = self.event.eventTitle;
	NSString * description = self.event.description;
	NSString * moreText = self.detailsText;
	UIImage * filmImage = imageCell.image;
	
	NSArray * itemsToShare = @[title, description, moreText, filmImage];
	
	UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
	activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
	[self presentViewController:activityVC animated:YES completion:nil];
	
#elif NBFF
*/
	
	NSSet * screenings = self.event.screenings;
	if (screenings.count > 1) {
		UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"What screening to share?" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] destructiveButtonItem:nil otherButtonItems:nil];
		for (Screening * screening in screenings) {
			NSString * buttonTitle = screening.displayDate;
			[sheet addButtonItem:[RIButtonItem itemWithLabel:buttonTitle action:^{
				[self shareScreening:screening];
			}]];
		}
		[sheet showInView:self.view];
	} else {
		[self shareScreening:(Screening *)screenings.allObjects[0]];
	}
	
//#endif
}
- (void)shareScreening:(Screening *)screening {
	FFEventImageTitleCell * imageCell = (FFEventImageTitleCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

#ifdef LAFF
	NSString * shareText = [NSString stringWithFormat:@"%@ at %@ #LAFF", self.event.eventTitle, screening.venueName];
#elif NBFF
	NSString * shareText = [NSString stringWithFormat:@"%@ at %@ #NBFF", self.event.eventTitle, screening.venueName];
#endif
	
	UIImage * shareImage = imageCell.image;
	NSURL * shareURL = [NSURL URLWithString:screening.ticketPurchaseUrl];
	
	NSArray * itemsToShare = @[shareText, shareImage, shareURL];
	
	UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
	activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
	[self presentViewController:activityVC animated:YES completion:nil];
	
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; // Image, Screenings, Other cells
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			//// Image, actions
			return 2;
			break;
		case 1:
			//// Screenings
			return self.screenings.count;
			break;
		case 2:
			//// Other cells
			return 1; // Details
			break;
	}
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0: {
			switch (indexPath.row) {
				case 0: {
					return FFEventImageTitleCellHeight;
					break;
				}
				case 1: {
					return FFEventActionsCellHeight;
					break;
				}
			}
			break;
		}
		case 1: {
			return FFEventScreeningCellHeight;
			break;
		}
		case 2: {
			switch (indexPath.row) {
				case 0: {
					if (self.detailsText.length) {
						return FFEventDetailsCellHeight;
					} else {
						return FFEventDetailsCellHeightNoText;
					}
					break;
				}
			}
			break;
		}
	}
	return 0.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    
	switch (indexPath.section) {
		case 0: {
			switch (indexPath.row) {
				case 0: {
					FFEventImageTitleCell * imageCell = [tableView dequeueReusableCellWithIdentifier:FFEventImageTitleCellIdentifier forIndexPath:indexPath];
					imageCell.event = self.event;
					cell = imageCell;
					break;
				}
				case 1: {
					FFEventActionsCell * actionsCell = [tableView dequeueReusableCellWithIdentifier:FFEventActionsCellIdentifier forIndexPath:indexPath];
					actionsCell.event = self.event;
					actionsCell.onAddToCart = ^() {
						[self buyTicket];
					};
					cell = actionsCell;
					break;
				}
			}
			break;
		}
		case 1: {
			FFEventScreeningCell * screeningCell = [tableView dequeueReusableCellWithIdentifier:FFEventScreeningCellIdentifier forIndexPath:indexPath];
			Screening * screening = self.screenings[indexPath.row];
			FFScreeningLocation * location = self.locations[indexPath.row];
			BOOL highlight = screening == self.screening;
			[screeningCell updateWithScreening:screening highlighted:highlight hasLocation:location.isKnown];
			cell = screeningCell;
			break;
		}
		case 2:
			switch (indexPath.row) {
				case 0: {
					FFEventDetailsCell * detailsCell = [tableView dequeueReusableCellWithIdentifier:FFEventDetailsCellIdentifier forIndexPath:indexPath];
					detailsCell.cellDescription.text = self.detailsText;
					cell = detailsCell;
					break;
				}
			}
			break;
	}
	
	if (indexPath.section == 0 || indexPath.section == 2) {
		cell.separatorInset = UIEdgeInsetsMake(0.f, CGRectGetWidth(cell.frame), 0.f, 0.f);
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.event.filmClipURL && self.event.filmClipURL.length) return YES;
	
	return indexPath.section != 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (self.event.filmClipURL && self.event.filmClipURL.length) {
			Rx * regex = RX(@"^(?:https?:\\/\\/)?(?:www\\.)?(?:youtu\\.be\\/{1,2}|youtube\\.com(?:\\/embed\\/|\\/v\\/|\\/watch\?v=))([\\w-]{10,12}).*$");
			RxMatch * youtubeIDmatch = [self.event.filmClipURL firstMatchWithDetails:regex];
			NSString * youtubeID = ((RxMatchGroup *)youtubeIDmatch.groups[1]).value;
			
			if (youtubeID && youtubeID.length) {
				XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:youtubeID];
				[[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
				[self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
			} else {
				SVWebViewController * webViewController = [[SVWebViewController alloc] initWithAddress:self.event.filmClipURL];
				webViewController.hidesBottomBarWhenPushed = YES;
				[self.navigationController pushViewController:webViewController animated:YES];
			}
		}
	}
	if (indexPath.section == 1) {
		//// Screening location
		FFScreeningLocation * location = self.locations[indexPath.row];
		if (location.isKnown) {
			[self performSegueWithIdentifier:SEGUE_ID_MAP sender:self];
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)buyTicket {
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:[@"Get tickets for event > " stringByAppendingString:self.event.eventTitle]];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
	NSSet * screenings = self.event.screenings;
	if (screenings.count > 1) {
		UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a screening" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] destructiveButtonItem:nil otherButtonItems:nil];
		for (Screening * screening in screenings) {
				NSString * buttonTitle = screening.displayDate;
				[sheet addButtonItem:[RIButtonItem itemWithLabel:buttonTitle action:^{
					[self showButTicketScreenWithAddress:screening.ticketPurchaseUrl];
				}]];
		}
		[sheet showInView:self.view];
	} else {
		[self showButTicketScreenWithAddress:((Screening *)screenings.allObjects[0]).ticketPurchaseUrl];
	}
}
- (void)showButTicketScreenWithAddress:(NSString *)address {
	SVWebViewController * webViewController = [[SVWebViewController alloc] initWithAddress:address];
	webViewController.hidesBottomBarWhenPushed = YES;
	webViewController.navigationItem.title = @"Get Tickets";
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:SEGUE_ID_MAP]) {
		FFScreeningLocationVC * vc = (FFScreeningLocationVC *)segue.destinationViewController;
		NSIndexPath * selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
		vc.location = self.locations[selectedRowIndexPath.row];
	} else if ([segue.identifier isEqualToString:SEGUE_ID_DETAILS]) {
		FFEventDetailsTVC * vc = (FFEventDetailsTVC *)segue.destinationViewController;
		vc.event = self.event;
	}
}

@end
