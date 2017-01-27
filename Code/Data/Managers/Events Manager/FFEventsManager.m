//
//  PDEventsManager.m
//  ParseDemo
//
//  Created by matata on 23.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFEventsManager.h"
#import "FFApiClient.h"
#import "Event.h"
#import "Screening.h"
#import "FFDateUtils.h"

#import "GTMNSString+HTML.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import <RegExCategories/RegExCategories.h>
#import <MTDates/NSDate+MTDates.h>
#import <DateTools/NSDate+DateTools.h>

NSString * const FFEventsManagerStateChanged = @"FFEventsManagerStateChanged";

static NSString * const kDefaultsKeyDeletedOldScreenings = @"deleted-old-screenings";

@interface FFEventsManager ()

@property (nonatomic, strong) FFApiClient * api;
@property (nonatomic, strong) CWStatusBarNotification * notification;

@end

@implementation FFEventsManager

+ (instancetype)instance {
	static FFEventsManager * _instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [FFEventsManager new];
	});
	return _instance;
}

//////////////////////////////////////////////////
#pragma mark - Init
//////////////////////////////////////////////////

- (id)init {
	self = [super init];
	if (self) {
		self.api = [FFApiClient instance];
		[self checkForStateLoading:NO];
	}
	return self;
}

//////////////////////////////////////////////////
#pragma mark - Public get data
//////////////////////////////////////////////////

- (NSArray *)events {
	return [Event MR_findAll];
}
- (NSArray *)screeningsSortedByDate {
	return [Screening MR_findAllSortedBy:@"screeningDate" ascending:YES];
}
- (NSArray *)upcomingScreeningsLimitedBy:(NSUInteger)numScreenings {
	NSDate * now = [NSDate date];
	
	//// For testing
//	now = [now dateByAddingYears:1];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"screeningDate >= %@", now];
	
	NSFetchRequest * request = [Screening MR_requestAllSortedBy:@"screeningDate" ascending:YES withPredicate:predicate];
	if (numScreenings != NSNotFound) {
		request.fetchLimit = numScreenings;
	}
	
	NSArray * result = [Screening MR_executeFetchRequest:request];
	return result;
}
- (NSArray *)screeningsSortedByDateWithTextInTitle:(NSString *)searchText {
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"event.eventTitle CONTAINS[cd] %@", searchText];
	return [Screening MR_findAllSortedBy:@"screeningDate" ascending:YES withPredicate:predicate];
}
- (NSArray *)favoriteEvents {
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
	// What field to sort by?
	return [Event MR_findAllSortedBy:@"eventSortTitle" ascending:YES withPredicate:predicate];
}
- (BOOL)hasFeaturedEvents {
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"featured == YES"];
	return [Event MR_numberOfEntitiesWithPredicate:predicate].unsignedIntegerValue > 0;
}
- (NSArray *)featuredEvents {
	//*/
	return [Event MR_findByAttribute:@"featured" withValue:@(YES) andOrderBy:@"eventSortTitle" ascending:YES];
	
	/*/
	 // Demo: return first 20 events
	NSArray * events = [Event MR_findAll];
	if (events.count > 20) {
		return [events objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 20)]];
	} else {
		return events;
	}
	 //*/
}
- (NSArray *)screeningsOnDay:(NSDate *)date {
	NSDate * dayStart = [date.copy mt_startOfCurrentDay];
	NSDate * dayEnd = [date.copy mt_endOfCurrentDay];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(screeningDate >= %@) && (screeningDate <= %@)", dayStart, dayEnd];
	return [Screening MR_findAllSortedBy:@"screeningDate" ascending:YES withPredicate:predicate];
}
- (NSArray *)myScreeningsOnDay:(NSDate *)date {
	NSDate * dayStart = [date.copy mt_startOfCurrentDay];
	NSDate * dayEnd = [date.copy mt_endOfCurrentDay];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(screeningDate >= %@) && (screeningDate <= %@) && isSaved == YES", dayStart, dayEnd];
	return [Screening MR_findAllSortedBy:@"screeningDate" ascending:YES withPredicate:predicate];
}
- (NSDate *)firstScreeningDate {
	return (NSDate *)[Screening MR_aggregateOperation:@"min:" onAttribute:@"screeningDate" withPredicate:nil];
}
- (NSDate *)lastScreeningDate {
	return (NSDate *)[Screening MR_aggregateOperation:@"max:" onAttribute:@"screeningDate" withPredicate:nil];
}
- (NSDate *)firstMyScreeningDate {
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isSaved == YES"];
	return (NSDate *)[Screening MR_aggregateOperation:@"min:" onAttribute:@"screeningDate" withPredicate:predicate];
}
- (NSDate *)lastMyScreeningDate {
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isSaved == YES"];
	return (NSDate *)[Screening MR_aggregateOperation:@"max:" onAttribute:@"screeningDate" withPredicate:predicate];
}
- (BOOL)hasMyScreenings {
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isSaved == YES"];
	return [Screening MR_numberOfEntitiesWithPredicate:predicate].unsignedIntegerValue > 0;
}

//////////////////////////////////////////////////
#pragma mark - State
//////////////////////////////////////////////////

- (void)checkForStateLoading:(BOOL)isLoading {
	FFEventsManagerState wasState = self.state;
	if ([Event MR_hasAtLeastOneEntity]) {
		_state = isLoading ? FFEventsManagerStateHasDataAndUpdating : FFEventsManagerStateHasData;
	} else {
		_state = isLoading ? FFEventsManagerStateNoDataAndLoading : FFEventsManagerStateNoData;
	}
	if (wasState != _state) {
		[self stateChanged];
	}
}
- (void)updateStateLoading:(BOOL)isLoading {
	FFEventsManagerState wasState = self.state;
	switch (self.state) {
		default:
		case FFEventsManagerStateNotInited:
			[self checkForStateLoading:isLoading];
			break;
		case FFEventsManagerStateNoData:
		case FFEventsManagerStateNoDataAndLoading:
			_state = isLoading ? FFEventsManagerStateNoDataAndLoading : FFEventsManagerStateNoData;
			break;
		case FFEventsManagerStateHasData:
		case FFEventsManagerStateHasDataAndUpdating:
			_state = isLoading ? FFEventsManagerStateHasDataAndUpdating : FFEventsManagerStateHasData;
			break;
	}
	if (wasState != _state) {
		[self stateChanged];
	}
}
- (void)stateChanged {
	[[NSNotificationCenter defaultCenter] postNotificationName:FFEventsManagerStateChanged object:self];
}

//////////////////////////////////////////////////
#pragma mark - Data works
//////////////////////////////////////////////////

- (void)load {
	NSAssert(self.api, @"Should have API at this moment");
	
	[self updateStateLoading:YES];
	
	__weak FFEventsManager * weakself = self;
	
	[self.api loadEventsDataWithSuccess:^(NSArray *rawEvents) {
		[weakself updateEventsWithRaw:rawEvents];
	} failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
//		[weakself showErrorNotificationWithText:[NSString stringWithFormat:@"Error loading data: %@", error.localizedDescription]];
		[weakself showErrorNotificationWithText:@"Error loading new films data, try again later"];
		[self updateStateLoading:NO];
	}];
}
- (void)updateEventsWithRaw:(NSArray *)rawEvents {
	NSManagedObjectContext * localContext = [NSManagedObjectContext MR_contextForCurrentThread];
	
	__weak FFEventsManager * weakself = self;
	
	//// Delete old screenings with no ID
	BOOL alreadyDeleted = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyDeletedOldScreenings];
	if (!alreadyDeleted) {
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"identifier == nil || identifier == ''"];
		NSArray * screeningsWithNoID = [Screening MR_findAllWithPredicate:predicate inContext:localContext];
		for (Screening * screening in screeningsWithNoID) {
			[screening MR_deleteInContext:localContext];
		}
		if (screeningsWithNoID.count) {
			NSLog(@"Deleted %u screenings", (uint)screeningsWithNoID.count);
		}
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyDeletedOldScreenings];
	}
	
	//// Process data
	[rawEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary * rawEventData = obj;
		[weakself updateEventWithRaw:rawEventData inContext:localContext];
	}];
	
	//// Not deleting any stored event
	//// TODO: Check for updated events and delete which not
	
	[localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
		if (success || !error) {
			[self checkForStateLoading:NO];
		} else {
			[weakself showErrorNotificationWithText:[NSString stringWithFormat:@"Error saving data: %@", error.localizedDescription]];
			[self checkForStateLoading:NO];
		}
	}];
}
- (void)updateEventWithRaw:(NSDictionary *)rawEvent inContext:(NSManagedObjectContext *)context {
//	NSLog(@"rawEvent: %@", rawEvent);
	
	NSString * eventNumber = rawEvent[@"EventNumber"];
	
	Event * event;
	if (eventNumber) {
		event = [Event MR_findFirstByAttribute:@"eventNumber" withValue:eventNumber inContext:context];
	}
	if (event) {
//		NSLog(@"Updating event with number: %@, title: %@", eventNumber, rawEvent[@"EventTitle"]);
	} else {
//		NSLog(@"Creating new event with number: %@, title: %@", eventNumber, rawEvent[@"EventTitle"]);
		event = [Event MR_createInContext:context];
		event.eventNumber = eventNumber;
	}
    event.castCredit           = [rawEvent[@"CastCredit"] gtm_stringByUnescapingFromHTML];
    event.eventType            = [rawEvent[@"EventType"] gtm_stringByUnescapingFromHTML];
    event.containerType        = rawEvent[@"ContainerType"];
    event.progCode             = rawEvent[@"ProgCode"];
    event.eventTitle           = rawEvent[@"EventTitle"];
    event.screeningOrder       = @([rawEvent[@"ScreeningOrder"] intValue]);
    event.eventSortTitle       = rawEvent[@"EventSortTitle"];
    event.foreignTitle         = rawEvent[@"ForeignTitle"];
    event.genres               = rawEvent[@"Genres"];
    event.directors            = [rawEvent[@"Directors"] gtm_stringByUnescapingFromHTML];
    event.year                 = @([rawEvent[@"Year"] intValue]);
    event.runTime              = @([rawEvent[@"RunTime"] intValue]);
    event.printFormat          = rawEvent[@"PrintFormat"];
    event.colour               = rawEvent[@"Colour"];
    event.language             = rawEvent[@"Language"];
    event.dubbed               = @([rawEvent[@"Dubbed"] intValue]);
    event.eventNote            = [rawEvent[@"EventNote"] gtm_stringByUnescapingFromHTML];
//    event.eventNote            = [[rawEvent[@"EventNote"] gtm_stringByUnescapingFromHTML] replace:RX(@"<[^>]+>") with:@""];
    event.premiere             = rawEvent[@"Premiere"];
    event.noteCredit           = rawEvent[@"NoteCredit"];
    event.shortNote            = [rawEvent[@"ShortNote"] gtm_stringByUnescapingFromHTML];
    event.specNote             = rawEvent[@"SpecNote"];
    event.synopsisNote         = [rawEvent[@"SynopsisNote"] gtm_stringByUnescapingFromHTML];
    event.sponsorName          = rawEvent[@"SponsorName"];
    event.filmClipURL          = rawEvent[@"FilmClipUrl"];
    event.filmWebsite          = rawEvent[@"FilmWebsite"];
    event.mySpaceURL           = rawEvent[@"MySpaceURL"];
    event.imdbFilm             = rawEvent[@"ImdbFilm"];
    event.salesAgent           = rawEvent[@"SalesAgent"];
    event.printSource          = rawEvent[@"PrintSource"];
    event.filmContact          = rawEvent[@"FilmContact"];
    event.pressContact         = rawEvent[@"PressContact"];
    event.filmRights           = rawEvent[@"FilmRights"];
    event.dirStatement         = rawEvent[@"DirStatement"];
    event.photoCaption         = rawEvent[@"PhotoCaption"];
    event.facebookURL          = rawEvent[@"FacebookURL"];
    event.twitterURL           = rawEvent[@"TwitterURL"];
    event.musicURL1            = rawEvent[@"MusicURL1"];
    event.musicURL2            = rawEvent[@"MusicURL2"];
    event.musicURL3            = rawEvent[@"MusicURL3"];
    event.peviewURL1           = rawEvent[@"PeviewURL1"];
    event.peviewURL2           = rawEvent[@"PeviewURL2"];
    event.peviewURL3           = rawEvent[@"PeviewURL3"];
    event.blogURL              = rawEvent[@"BlogURL"];
    event.filmRating           = rawEvent[@"FilmRating"];
    event.sectionName          = rawEvent[@"SectionName"];
    event.countries            = [((NSString *)rawEvent[@"Countries"]) replace:RX(@"\\s{2,}") with:@""];
    event.filmContactsTitle    = rawEvent[@"FilmContactsTitle"];
    event.printSourceRecordID  = @([rawEvent[@"PrintSourceRecordID"] intValue]);
    event.printSourcePSourceID = @([rawEvent[@"PrintSourcePSourceID"] intValue]);
    event.printSourceContact   = rawEvent[@"PrintSourceContact"];
    event.printSourceAddress1  = rawEvent[@"PrintSourceAddress1"];
    event.printSourceCity      = rawEvent[@"PrintSourceCity"];
    event.printSourceState     = rawEvent[@"PrintSourceState"];
    event.printSourceZip       = @([rawEvent[@"PrintSourceZip"] intValue]);
    event.printSourcePhone1    = rawEvent[@"PrintSourcePhone1"];
    event.printSourceEmail     = rawEvent[@"PrintSourceEmail"];
	event.filmImageURL		   = rawEvent[@"FilmImageUrl"];
	event.featured			   = @([((NSString *)rawEvent[@"Featured"]) isEqualToString:@"true"]);
	
	/*
	//// Testing when there're no featured events
	if ([event.eventTitle isEqualToString:@"A Beautiful Now"]) {
		event.featured = @(YES);
	}
	 */
	
	/*
	// FIXME: Remove next code if there is unique screening id
	for (Screening * screening in event.screenings) {
		[screening MR_deleteInContext:context];
	}
	event.screenings = nil;
	 */
	
	id screeningRaw = rawEvent[@"Screenings"][@"Screening"];
	if ([screeningRaw isKindOfClass:[NSArray class]]) {
		[self updateScreeningsWithRaw:screeningRaw event:event inContext:context];
	} else if ([screeningRaw isKindOfClass:[NSDictionary class]]) {
		[self updateScreeningsWithRaw:@[screeningRaw] event:event inContext:context];
	}
}
- (void)updateScreeningsWithRaw:(NSArray *)rawScreenings event:(Event *)event inContext:(NSManagedObjectContext *)context {
	
	[rawScreenings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary * rawScreening = obj;
		[self updateScreeningWithRaw:rawScreening event:event inContext:context];
	}];
}
- (void)updateScreeningWithRaw:(NSDictionary *)rawScreening event:(Event *)event inContext:(NSManagedObjectContext *)context {
	
//	NSLog(@"rawScreening: %@", rawScreening);
	
	// TODO: Check for deleted screenings and remove them from local cache
	
	NSString * screeningID = rawScreening[@"Id"];
	screeningID = [NSString stringWithFormat:@"%@-%@", event.eventNumber, screeningID];
	Screening * screening = [Screening MR_findFirstByAttribute:@"identifier" withValue:screeningID inContext:context];
	if (!screening) {
		screening = [Screening MR_createInContext:context];
		screening.identifier = screeningID;
	}
	
	screening.event = event;
	screening.screeningDate = [FFDateUtils screeningDateWithDateString:rawScreening[@"ScreeningDate"] andTimeString:rawScreening[@"ScreeningTime"]];
	
	// Force to make all dates in 2014
//	screening.screeningDate = [NSDate mt_dateFromYear:2014 month:screening.screeningDate.mt_monthOfYear day:screening.screeningDate.mt_dayOfMonth hour:screening.screeningDate.mt_hourOfDay minute:screening.screeningDate.mt_minuteOfHour];
	
	screening.sequence    = @([rawScreening[@"Sequence"] intValue]);
	screening.venueCode   = rawScreening[@"VenueCode"];
	screening.venueName   = rawScreening[@"VenueName"];
	screening.ticketType  = @([rawScreening[@"TicketType"] intValue]);
	screening.ticketDesc  = rawScreening[@"TicketDesc"];
	screening.ticketPrice = [NSDecimalNumber decimalNumberWithString:rawScreening[@"TicketPrice"]];
	screening.ticketPurchaseUrl = rawScreening[@"TicketPurchaseUrl"];
	screening.displayDate = rawScreening[@"DisplayDate"];
	if (!screening.displayDate) {
		screening.displayDate = [[FFDateUtils screeningScheduleDateFormatter] stringFromDate:screening.screeningDate];
	}
}

//////////////////////////////////////////////////
#pragma mark - Other data methods
//////////////////////////////////////////////////

- (void)deleteAllSynchronous:(BOOL)synchronous {
	BOOL hasAtLeastOneRecord = [Event MR_hasAtLeastOneEntity] || [Screening MR_hasAtLeastOneEntity];
	if (!hasAtLeastOneRecord) return;
	
	__weak FFEventsManager * weakself = self;
	
	void (^saveBlock)(NSManagedObjectContext *localContext) = ^(NSManagedObjectContext *localContext) {
		[Screening	MR_truncateAll];
		[Event		MR_truncateAll];
		
		NSLog(@"Events count: %u, screenings count: %u", (uint)[Event MR_countOfEntities], (uint)[Screening MR_countOfEntities]);
	};
	
	void (^completeBlock)(BOOL success, NSError *error) = ^(BOOL success, NSError *error) {
		if (success) {
			//			[weakself showInfoNotificationWithText:@"All records deleted"];
			[weakself checkForStateLoading:NO];
		} else {
			[weakself showErrorNotificationWithText:[NSString stringWithFormat:@"Error deleting records: %@", error.localizedDescription]];
			[weakself checkForStateLoading:NO];
		}
	};
	
	if (synchronous) {
		[MagicalRecord saveWithBlockAndWait:saveBlock];
		completeBlock(YES, nil);
	} else {
		[MagicalRecord saveUsingCurrentThreadContextWithBlock:saveBlock completion:completeBlock];
	}
}

//////////////////////////////////////////////////
#pragma mark - Notifications
//////////////////////////////////////////////////

- (void)showInfoNotificationWithText:(NSString *)text {
	BOOL hasOldNotification = self.notification && self.notification.notificationIsShowing;
	
	self.notification = [CWStatusBarNotification new];
	self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
	self.notification.notificationLabelBackgroundColor = [UIColor whiteColor];
	self.notification.notificationLabelTextColor = [UIColor grayColor];
	if (hasOldNotification) {
		self.notification.notificationAnimationType = CWNotificationAnimationTypeOverlay;
	}
	[self.notification displayNotificationWithMessage:text forDuration:1.5f];
}
- (void)showErrorNotificationWithText:(NSString *)text {
	BOOL hasOldNotification = self.notification && self.notification.notificationIsShowing;
	
	self.notification = [CWStatusBarNotification new];
	self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
	self.notification.notificationStyle = CWNotificationStyleNavigationBarNotification;
	self.notification.notificationLabelBackgroundColor = [UIColor redColor];
	self.notification.multiline = YES;
	if (hasOldNotification) {
		self.notification.notificationAnimationType = CWNotificationAnimationTypeOverlay;
	}
	[self.notification displayNotificationWithMessage:text forDuration:3.f];
}

@end
