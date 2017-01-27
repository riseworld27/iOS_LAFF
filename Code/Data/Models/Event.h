//
//  Event.h
//  laff
//
//  Created by matata on 14.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Screening;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * blogURL;
@property (nonatomic, retain) NSString * castCredit;
@property (nonatomic, retain) NSString * colour;
@property (nonatomic, retain) NSString * containerType;
@property (nonatomic, retain) NSString * countries;
@property (nonatomic, retain) NSString * directors;
@property (nonatomic, retain) NSString * dirStatement;
@property (nonatomic, retain) NSNumber * dubbed;
@property (nonatomic, retain) NSString * eventNote;
@property (nonatomic, retain) NSString * eventNumber;
@property (nonatomic, retain) NSString * eventSortTitle;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSString * facebookURL;
@property (nonatomic, retain) NSString * filmClipURL;
@property (nonatomic, retain) NSString * filmContact;
@property (nonatomic, retain) NSString * filmContactsTitle;
@property (nonatomic, retain) NSString * filmRating;
@property (nonatomic, retain) NSString * filmRights;
@property (nonatomic, retain) NSString * filmWebsite;
@property (nonatomic, retain) NSString * foreignTitle;
@property (nonatomic, retain) NSString * genres;
@property (nonatomic, retain) NSString * imdbFilm;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * musicURL1;
@property (nonatomic, retain) NSString * musicURL2;
@property (nonatomic, retain) NSString * musicURL3;
@property (nonatomic, retain) NSString * mySpaceURL;
@property (nonatomic, retain) NSString * noteCredit;
@property (nonatomic, retain) NSString * peviewURL1;
@property (nonatomic, retain) NSString * peviewURL2;
@property (nonatomic, retain) NSString * peviewURL3;
@property (nonatomic, retain) NSString * photoCaption;
@property (nonatomic, retain) NSString * premiere;
@property (nonatomic, retain) NSString * pressContact;
@property (nonatomic, retain) NSString * printFormat;
@property (nonatomic, retain) NSString * printSource;
@property (nonatomic, retain) NSString * printSourceAddress1;
@property (nonatomic, retain) NSString * printSourceCity;
@property (nonatomic, retain) NSString * printSourceContact;
@property (nonatomic, retain) NSString * printSourceEmail;
@property (nonatomic, retain) NSString * printSourcePhone1;
@property (nonatomic, retain) NSNumber * printSourcePSourceID;
@property (nonatomic, retain) NSNumber * printSourceRecordID;
@property (nonatomic, retain) NSString * printSourceState;
@property (nonatomic, retain) NSNumber * printSourceZip;
@property (nonatomic, retain) NSString * progCode;
@property (nonatomic, retain) NSNumber * runTime;
@property (nonatomic, retain) NSString * salesAgent;
@property (nonatomic, retain) NSNumber * screeningOrder;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSString * shortNote;
@property (nonatomic, retain) NSString * specNote;
@property (nonatomic, retain) NSString * sponsorName;
@property (nonatomic, retain) NSString * synopsisNote;
@property (nonatomic, retain) NSString * twitterURL;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * filmImageURL;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSSet *screenings;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addScreeningsObject:(Screening *)value;
- (void)removeScreeningsObject:(Screening *)value;
- (void)addScreenings:(NSSet *)values;
- (void)removeScreenings:(NSSet *)values;

@end
