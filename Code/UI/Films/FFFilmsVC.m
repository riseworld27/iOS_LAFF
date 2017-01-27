//
//  FFFilmsVC.m
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFFilmsVC.h"
#import "FFEventsManager.h"

#import "FFFilmSearchCell.h"
#import "FFScreeningScheduleCell.h"
#import "FFOneLineInfoCell.h"
#import "FFEventImageTitleCell.h"
#import "FFWeekCell.h"
#import "FFTodayScreeningCell.h"

#import "UIStoryboard+Main.h"
#import "FFEventInfoTVC.h"
#import "GA.h"

static NSString * const CELL_ID_EMPTY = @"empty";

typedef NS_ENUM(NSUInteger, FFFilmsVCState) {
    FFFilmsVCStateFullSchedule,
    FFFilmsVCStateMySchedule,
    FFFilmsVCStateFavorites,
};

typedef NS_ENUM(NSUInteger, FFSearchState) {
	FFSearchStateUnfocused = 0,
	FFSearchStateFocused,
};

@interface FFFilmsVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stateSegmentController;

@property (nonatomic, assign) FFFilmsVCState state;
@property (nonatomic, strong) FFEventsManager * eventsManager;

@property (nonatomic, strong) NSMutableArray * scrollPositions;

@property (nonatomic, strong) UIBarButtonItem * refreshBarButton;

//@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;

// Full Schedule

@property (nonatomic, assign) BOOL scheduleDataUpdated;
@property (nonatomic, strong) NSArray * screeningsSortedByDate;
@property (nonatomic, strong) NSString * searchText;

// My Schedule

@property (nonatomic, strong) NSArray * fullScheduleScreenings;
@property (nonatomic, strong) NSArray *   myScheduleScreenings;

@property (nonatomic, strong) NSDate * fullScheduleSelectedDay;
@property (nonatomic, strong) NSDate *   myScheduleSelectedDay;

// Favorites

@property (nonatomic, strong) NSArray * favoriteEvents;

@property (nonatomic, assign) FFSearchState searchState;

@end

@implementation FFFilmsVC

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FFEventsManagerStateChanged object:self.eventsManager];
	
	/*
	if (self.tapGestureRecognizer) {
		[self.view.window removeGestureRecognizer:self.tapGestureRecognizer];
		[self.tapGestureRecognizer removeTarget:self action:@selector(tapOutside)];
		self.tapGestureRecognizer = nil;
	}
	 */
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//// Controller setup
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	//// Events Manager
	
	self.eventsManager = [FFEventsManager instance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsManagerStateChanged) name:FFEventsManagerStateChanged object:self.eventsManager];
	
	//// Navigation Item
	
	self.refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	self.navigationItem.leftBarButtonItem = self.refreshBarButton;
	
	//// Setup Table View
	
	UIEdgeInsets tableViewInsets = self.tableView.contentInset;
	tableViewInsets.top = CGRectGetMaxY(self.topView.frame);
	tableViewInsets.bottom = 50.f;
	
	self.tableView.dataSource = self;
	self.tableView.delegate   = self;
	self.tableView.scrollIndicatorInsets = tableViewInsets;
	self.tableView.contentInset          = tableViewInsets;
//	self.tableView.contentOffset = CGPointMake(0, 40.f);
	self.tableView.tableFooterView = [UIView new];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
//	[self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
	
	/*
	//// Searchbar and gestures
	
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside)];
	self.tapGestureRecognizer.cancelsTouchesInView = NO;
	
	self.searchBar.delegate = self;
	 */

	//// Scroll offsets
	
	CGFloat scrollOffsetY = -CGRectGetMaxY(self.topView.frame);
	CGFloat scheduleScrollOffsetY = scrollOffsetY + FFFilmSearchCellHeight;
	self.scrollPositions = [NSMutableArray arrayWithArray:@[@(scheduleScrollOffsetY), @(scrollOffsetY), @(scrollOffsetY)]];
	
	self.tableView.contentOffset = CGPointMake(0.f, scheduleScrollOffsetY);
	
	//// State init
	
	[self stateSegmentControllerValueChanged:self.stateSegmentController];
	
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.tableView && self.state == FFFilmsVCStateFullSchedule && [keyPath isEqualToString:@"contentSize"]) {
		CGFloat tableViewVisibleHeight = CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.top - self.tableView.contentInset.bottom + FFFilmSearchCellHeight;
		if (self.tableView.contentSize.height < tableViewVisibleHeight) {
			CGSize contentSize = self.tableView.contentSize;
			contentSize.height = tableViewVisibleHeight;
			self.tableView.contentSize = contentSize;
			self.tableView.contentOffset = CGPointMake(0.f, FFFilmSearchCellHeight - self.tableView.contentInset.top);
		}
	}
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.state == FFFilmsVCStateFavorites || self.state == FFFilmsVCStateMySchedule) {
		self.state = self.state;
	}
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
		self.scheduleDataUpdated = YES;
		[self stateSegmentControllerValueChanged:self.stateSegmentController];
	}
}
- (void)refreshClicked {
	[self.eventsManager load];
}

//////////////////////////////////////////////////
#pragma mark - iOS8 margins fix
//////////////////////////////////////////////////

- (void)viewDidLayoutSubviews {
	if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
		[self.tableView setSeparatorInset:UIEdgeInsetsZero];
	}
	if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
		[self.tableView setLayoutMargins:UIEdgeInsetsZero];
	}
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
}

//////////////////////////////////////////////////
#pragma mark - States management
//////////////////////////////////////////////////

- (IBAction)stateSegmentControllerValueChanged:(id)sender {
	switch (self.stateSegmentController.selectedSegmentIndex) {
		case 0:
			self.state = FFFilmsVCStateFullSchedule;
			break;
		case 1:
			self.state = FFFilmsVCStateMySchedule;
			break;
		case 2:
			self.state = FFFilmsVCStateFavorites;
			break;
	}
}
- (void)setState:(FFFilmsVCState)state {
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	
	self.scrollPositions[_state] = @(self.tableView.contentOffset.y);
	
	switch (state) {
		case FFFilmsVCStateFullSchedule:
			[self loadScreeningsSortedByDate:NO];
			self.scheduleDataUpdated = NO;
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			[tracker set:kGAIScreenName value:@"Films tab > Schedule"];
			break;
		case FFFilmsVCStateMySchedule:
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
			[tracker set:kGAIScreenName value:@"Films tab > Calendar"];
			break;
		case FFFilmsVCStateFavorites:
			[self loadFavoriteEvents];
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			[tracker set:kGAIScreenName value:@"Films tab > Favorites"];
			break;
	}
	
	/*
	UIEdgeInsets tableViewInsets = self.tableView.contentInset;
	if (state == FFFilmsVCStateSchedule) {
		self.searchBar.hidden = NO;
		tableViewInsets.top = CGRectGetMaxY(self.searchBar.frame);
	} else {
		self.searchBar.hidden = YES;
		tableViewInsets.top = CGRectGetMaxY(self.topView.frame);
	}
	 */
	
	/*
	UIEdgeInsets tableViewInsets = self.tableView.contentInset;
	tableViewInsets.top = CGRectGetMaxY(self.topView.frame);
    self.tableView.scrollIndicatorInsets = tableViewInsets;
    self.tableView.contentInset          = tableViewInsets;
	 */
	
	_state = state;
	[self.tableView reloadData];
	
	[self updateWeekCellDate];
	
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];

	//// Loading scroll offset (with check if content height changed)
	
	CGFloat targetContentOffsetY = ((NSNumber *)self.scrollPositions[state]).floatValue;
	CGFloat bottomOffset = CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom - self.tableView.contentSize.height + targetContentOffsetY;
	
	if (bottomOffset > 0) {
		targetContentOffsetY -= bottomOffset;
	}
	targetContentOffsetY = MAX(targetContentOffsetY, -self.tableView.contentInset.top);
		
	self.tableView.contentOffset = CGPointMake(0.f, targetContentOffsetY);
	
	if (state == FFFilmsVCStateFavorites) {
		[self scrollViewDidScroll:self.tableView];
	}
}
- (void)updateWeekCellDate {
	if (self.state == FFFilmsVCStateMySchedule && self.eventsManager.hasMyScreenings) {
		FFWeekCell * weekCell = (FFWeekCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		if (self.myScheduleScreenings) {
			[weekCell selectDate:self.myScheduleSelectedDay];
		} else {
			[weekCell selectActualDay];
		}
	} else if (self.state == FFFilmsVCStateFullSchedule) {
		FFWeekCell * weekCell = (FFWeekCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
		if (self.fullScheduleScreenings) {
			[weekCell selectDate:self.fullScheduleSelectedDay];
		} else {
			[weekCell selectActualDay];
		}
	}
}
- (void)loadScreeningsSortedByDate:(BOOL)force {
	BOOL shouldLoad = force || self.scheduleDataUpdated || !self.screeningsSortedByDate;
	if (!shouldLoad) return;
	
	if (self.searchText.length) {
		self.screeningsSortedByDate = [self.eventsManager screeningsSortedByDateWithTextInTitle:self.searchText];
	} else {
		self.screeningsSortedByDate = self.eventsManager.screeningsSortedByDate;
	}
}
- (void)loadFavoriteEvents {
	self.favoriteEvents = self.eventsManager.favoriteEvents;
}

//////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (self.state) {
		case FFFilmsVCStateFullSchedule:
			return 2; // Search + Week, List
			break;
		case FFFilmsVCStateMySchedule:
			if (self.eventsManager.hasMyScreenings) {
				return 2; // Week, List
			} else {
				return 1; // Info
			}
			break;
		case FFFilmsVCStateFavorites:
			return 1; // List
			break;
	}
	return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (self.state) {
		case FFFilmsVCStateFullSchedule:
			switch (section) {
				case 0:
					//// Search + Week
					switch (self.searchState) {
						case FFSearchStateFocused:
							return 1;
							break;
						case FFSearchStateUnfocused:
							return 2;
							break;
					}
					break;
				case 1:
					//// List
					switch (self.searchState) {
						case FFSearchStateFocused:
							return self.screeningsSortedByDate.count;
							break;
						case FFSearchStateUnfocused:
							return self.fullScheduleScreenings.count;
							break;
					}
					break;
			}
			break;
		case FFFilmsVCStateMySchedule:
			if (self.eventsManager.hasMyScreenings) {
				switch (section) {
					case 0:
						//// Week
						return 1;
						break;
					case 1:
						//// Num screenings on selected day
						return self.myScheduleScreenings.count;
						break;
				}
			} else {
				//// Info
				return 1;
			}
			break;
		case FFFilmsVCStateFavorites:
			//// List count or info cell
			return self.favoriteEvents.count ?: 1;
			break;
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (self.state) {
		case FFFilmsVCStateFullSchedule:
			switch (indexPath.section) {
				case 0:
					switch (indexPath.row) {
						case 0:
							return FFFilmSearchCellHeight;
							break;
						case 1:
							return FFWeekCellHeight + 10.f;
							break;
					}
					break;
				case 1:
					//// List
					return FFScreeningScheduleCellHeight;
					break;
			}
			break;
		case FFFilmsVCStateMySchedule:
			if (self.eventsManager.hasMyScreenings) {
				switch (indexPath.section) {
					case 0:
						//// Week
						return FFWeekCellHeight;
						break;
					case 1:
						//// List items
						return FFTodayScreeningCellHeight;
						break;
				}
			} else {
				//// Info
				return FFOneLineInfoCellHeight;
			}
			break;
		case FFFilmsVCStateFavorites:
			//// List
			return self.favoriteEvents.count ? FFEventImageTitleCellHeight : FFOneLineInfoCellHeight;
			break;
	}
	return 0;
	
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell;
	
	__weak FFFilmsVC * weakself = self;
	
	switch (self.state) {
		case FFFilmsVCStateFullSchedule:
			switch (indexPath.section) {
				case 0: {
					switch (indexPath.row) {
						case 0: {
							FFFilmSearchCell * searchCell = [tableView dequeueReusableCellWithIdentifier:FFFilmSearchCellIdentifier forIndexPath:indexPath];
							searchCell.onFocus = ^() {
							};
							searchCell.onUnfocus = ^() {
//								if (weakself.searchText.length) return;
							};
							searchCell.onTextDidChange = ^(NSString * text) {
								if (text.length) {
									weakself.searchState = FFSearchStateFocused;
									if ([weakself.tableView numberOfRowsInSection:0] != 1) {
									
										[weakself.tableView beginUpdates];
										[weakself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
										[weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
										[weakself.tableView endUpdates];
									}
								} else {
									weakself.searchState = FFSearchStateUnfocused;
									
									[weakself.tableView beginUpdates];
									[weakself.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
									[weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
									[weakself.tableView endUpdates];
									
									[weakself updateWeekCellDate];
								}
								
								self.searchText = text;
								[self loadScreeningsSortedByDate:YES];
								[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
							};
							cell = searchCell;
							break;
						}
						case 1: {
							FFWeekCell * weekCell = [tableView dequeueReusableCellWithIdentifier:FFWeekCellIdentifier forIndexPath:indexPath];
							weekCell.tableWidth = CGRectGetWidth(self.view.frame);
							[weekCell initDates];
							weekCell.onDayChange = nil;
							if (self.fullScheduleScreenings) {
								[weekCell selectDate:self.fullScheduleSelectedDay];
							} else {
								[weekCell selectActualDay];
							}
							weekCell.onDayChange = ^(NSDate * date) {
								[weakself updateFullScheduleEventsWithDay:date];
							};
							cell = weekCell;
							break;
						}
					}
					break;
				}
				case 1: {
					FFScreeningScheduleCell * screeningScheduleCell = [tableView dequeueReusableCellWithIdentifier:FFScreeningScheduleCellIdentifier forIndexPath:indexPath];
					
					Screening * screening;
					switch (self.searchState) {
						case FFSearchStateFocused:
							screening = self.screeningsSortedByDate[indexPath.row];
							break;
						case FFSearchStateUnfocused:
							screening = self.fullScheduleScreenings[indexPath.row];
							break;
					}
					
					[screeningScheduleCell updateWithScreening:screening];
					cell = screeningScheduleCell;
					break;
				}
			}
			break;
		case FFFilmsVCStateMySchedule:
			if (self.eventsManager.hasMyScreenings) {
				switch (indexPath.section) {
					case 0: {
						FFWeekCell * weekCell = [tableView dequeueReusableCellWithIdentifier:FFWeekCellIdentifier forIndexPath:indexPath];
						weekCell.tableWidth = CGRectGetWidth(self.view.frame);
						[weekCell initDatesForMySchedule:YES];
						weekCell.onDayChange = nil;
						if (self.myScheduleScreenings) {
							[weekCell selectDate:self.myScheduleSelectedDay];
						} else {
							[weekCell selectActualDay];
						}
						weekCell.onDayChange = ^(NSDate * date) {
							[weakself updateMyScheduleEventsWithDay:date];
						};
						cell = weekCell;
						cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, CGRectGetWidth(self.view.frame));
						break;
					}
					case 1: {
						FFTodayScreeningCell * screeningCell = [tableView dequeueReusableCellWithIdentifier:FFTodayScreeningCellIdentifier forIndexPath:indexPath];
						screeningCell.screening = self.myScheduleScreenings[indexPath.row];
						cell = screeningCell;
						break;
					}
				}
			} else {
				FFOneLineInfoCell * infoCell = [tableView dequeueReusableCellWithIdentifier:FFOneLineInfoCellIdentifier forIndexPath:indexPath];
				infoCell.textLabel.text = @"You have no screenings saved";
				cell = infoCell;
				cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, CGRectGetWidth(self.view.frame));
				break;
			}
			break;
		case FFFilmsVCStateFavorites:
			if (self.favoriteEvents.count) {
				FFEventImageTitleCell * eventCell = [tableView dequeueReusableCellWithIdentifier:FFEventImageTitleCellIdentifier forIndexPath:indexPath];
				eventCell.parallaxEnabled = YES;
				eventCell.event = self.favoriteEvents[indexPath.row];
				__weak FFEventImageTitleCell * weakEventCell = eventCell;
				eventCell.onFavoriteChange = ^(BOOL isFavorite) {
					[weakself removeCellFromFavorites:weakEventCell];
				};
				cell = eventCell;
			} else {
				FFOneLineInfoCell * infoCell = [tableView dequeueReusableCellWithIdentifier:FFOneLineInfoCellIdentifier forIndexPath:indexPath];
				infoCell.textLabel.text = @"No events added to favorites";
				cell = infoCell;
			}
			break;
	}
	
	if (!cell) {
		cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_EMPTY forIndexPath:indexPath];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}
- (void)updateMyScheduleEventsWithDay:(NSDate *)date {
	NSAssert(self.state == FFFilmsVCStateMySchedule, @"My schedule should be opened at this point");
	self.myScheduleSelectedDay = date;
	self.myScheduleScreenings = [self.eventsManager myScreeningsOnDay:date];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)updateFullScheduleEventsWithDay:(NSDate *)date {
	NSAssert(self.state == FFFilmsVCStateFullSchedule, @"Full schedule should be opened at this point");
	self.fullScheduleSelectedDay = date;
	self.fullScheduleScreenings = [self.eventsManager screeningsOnDay:date];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)removeCellFromFavorites:(FFEventImageTitleCell *)cell {
	NSAssert(self.state == FFFilmsVCStateFavorites, @"Favorites should be opened at this point");
	
	[self loadFavoriteEvents];
	if (self.favoriteEvents.count) {
		[cell.superview exchangeSubviewAtIndex:0 withSubviewAtIndex:[cell.superview.subviews indexOfObject:cell]];
		NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

//////////////////////////////////////////////////
#pragma mark - Table view delegate
//////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (self.state) {
		case FFFilmsVCStateFullSchedule: {
			if (indexPath.section == 1) {
				FFEventInfoTVC * vc = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFEventInfoTVCIdentifier];

				Screening * screening;
				switch (self.searchState) {
					case FFSearchStateFocused:
						screening = self.screeningsSortedByDate[indexPath.row];
						break;
					case FFSearchStateUnfocused:
						screening = self.fullScheduleScreenings[indexPath.row];
						break;
				}

				vc.screening = screening;
				
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		}
		case FFFilmsVCStateMySchedule:
			if (indexPath.section == 1) {
				FFEventInfoTVC * vc = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFEventInfoTVCIdentifier];
				vc.screening = self.myScheduleScreenings[indexPath.row];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		case FFFilmsVCStateFavorites: {
			FFEventInfoTVC * vc = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFEventInfoTVCIdentifier];
			vc.event = self.favoriteEvents[indexPath.row];
			[self.navigationController pushViewController:vc animated:YES];
			break;
		}
	}
}

//////////////////////////////////////////////////
#pragma mark - Scroll view delegate
//////////////////////////////////////////////////

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.state == FFFilmsVCStateFavorites && self.favoriteEvents.count) {
		NSArray * visibleCellsIndexes = self.tableView.indexPathsForVisibleRows;
		for (NSIndexPath * cellIndex in visibleCellsIndexes) {
			FFEventImageTitleCell * cell = (id)[self.tableView cellForRowAtIndexPath:cellIndex];
			if (![cell isKindOfClass:[FFEventImageTitleCell class]]) continue;
			CGRect cellRect = [cell convertRect:cell.bounds toView:self.view];
			CGFloat cellY = CGRectGetMidY(cellRect);
			float percent = cellY / CGRectGetHeight(self.view.frame);
			[cell updateWithScrollPercentage:percent];
		}
	}
}

/*
//////////////////////////////////////////////////
#pragma mark - Search bar delegate and gesture callback
//////////////////////////////////////////////////

- (void)tapOutside {
	[self.searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[self.view.window addGestureRecognizer:self.tapGestureRecognizer];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self.view.window removeGestureRecognizer:self.tapGestureRecognizer];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchText = searchText;
	[self loadScreeningsSortedByDate:YES];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"searchBarSearchButtonClicked");
	[searchBar resignFirstResponder];
}
*/

@end
