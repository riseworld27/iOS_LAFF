//
//  FFEventActionsCell.m
//  laff
//
//  Created by matata on 20.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFEventActionsCell.h"
#import "Screening.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>

NSString * const FFEventActionsCellIdentifier = @"actions";
CGFloat const FFEventActionsCellHeight = 70.f;

@interface FFEventActionsCell ()

@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;

@property (nonatomic, assign) BOOL isFavorite;

@end

@implementation FFEventActionsCell

- (void)awakeFromNib {
	
}
- (void)setEvent:(Event *)event {
	_isFavorite = event.isFavorite.boolValue;
	self.heartButton.selected = _isFavorite;
	_event = event;
	
	[self updatePlusButtonState];
}
- (void)updatePlusButtonState {
	NSSet * screenings = self.event.screenings;
	BOOL allScreeningsAreSaved = YES;
	for (Screening * screening in screenings) {
		allScreeningsAreSaved = allScreeningsAreSaved && screening.isSaved.boolValue;
	}
	
	self.plusButton.selected = allScreeningsAreSaved;
}
- (void)setIsFavorite:(BOOL)isFavorite {
	self.heartButton.selected = isFavorite;
	__weak FFEventActionsCell * weakself = self;
	
	[MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
		weakself.event.isFavorite = @(isFavorite);
	} completion:^(BOOL success, NSError *error) {
		if (weakself.onFavoriteChange) {
			weakself.onFavoriteChange(isFavorite);
		}
	}];
	
	_isFavorite = isFavorite;
}

- (IBAction)plusButtonPressed:(id)sender {
	NSSet * screenings = self.event.screenings;
	if (screenings.count > 1) {
		UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a screening to add or remove from saved list" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] destructiveButtonItem:nil otherButtonItems:nil];
		for (Screening * screening in screenings) {
			if (screening.isSaved.boolValue) {
				NSString * buttonTitle = [NSString stringWithFormat:@"- %@", screening.displayDate];
				[sheet addButtonItem:[RIButtonItem itemWithLabel:buttonTitle action:^{
					[self deleteScreening:screening];
				}]];
			} else {
				NSString * buttonTitle = [NSString stringWithFormat:@"+ %@", screening.displayDate];
				[sheet addButtonItem:[RIButtonItem itemWithLabel:buttonTitle action:^{
					[self saveScreening:screening];
				}]];
			}
		}
		[sheet showFromRect:self.plusButton.frame inView:self animated:YES];
	} else {
		Screening * screening = screenings.allObjects[0];
		if (screening.isSaved.boolValue) {
			[self deleteScreening:screening];
		} else {
			[self saveScreening:screening];
		}
	}
}
- (void)saveScreening:(Screening *)screening {
	__weak FFEventActionsCell * weakself = self;
	[MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
		screening.isSaved = @(YES);
	} completion:^(BOOL success, NSError *error) {
		[weakself updatePlusButtonState];
	}];
}
- (void)deleteScreening:(Screening *)screening {
	__weak FFEventActionsCell * weakself = self;
	[MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
		screening.isSaved = @(NO);
	} completion:^(BOOL success, NSError *error) {
		[weakself updatePlusButtonState];
	}];
}
- (IBAction)heartButtonPress:(id)sender {
	self.isFavorite = !self.isFavorite;
}
- (IBAction)cartButtonPress:(id)sender {
	if (self.onAddToCart) {
		self.onAddToCart();
	}
}

@end
