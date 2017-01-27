//
//  FFSponsorsNBFFVC.m
//  laff
//
//  Created by matata on 08.04.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFSponsorsNBFFVC.h"

#import <SVWebViewController/SVWebViewController.h>

@interface FFSponsorsNBFFVC ()

@property (weak, nonatomic) IBOutlet UIButton *sbutBMW;
@property (weak, nonatomic) IBOutlet UIButton *sbutLATimes;
@property (weak, nonatomic) IBOutlet UIButton *sbutFashionIsland;
@property (weak, nonatomic) IBOutlet UIButton *sbutTitosVodka;
@property (weak, nonatomic) IBOutlet UIButton *sbutKona;

@end

@implementation FFSponsorsNBFFVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)onSponsorButtonPress:(id)sender {
	NSString * link;
	NSString * title;
	
	if (sender == self.sbutBMW) {
		link = @"http://www.socalbmw.com/";
		title = @"BMW";
	} else if (sender == self.sbutLATimes) {
		link = @"http://www.latimes.com/";
		title = @"LA Times";
	} else if (sender == self.sbutFashionIsland) {
		link = @"http://www.shopfashionisland.com/";
		title = @"Fashion Island";
	} else if (sender == self.sbutTitosVodka) {
		link = @"http://www.titosvodka.com/";
		title = @"Tito's Vodka";
	} else if (sender == self.sbutKona) {
		link = @"http://konacompany.com";
		title = @"Kona";
	}
	
	SVWebViewController * webViewController = [[SVWebViewController alloc] initWithAddress:link];
	webViewController.hidesBottomBarWhenPushed = YES;
	webViewController.navigationItem.title = title;
	[self.navigationController pushViewController:webViewController animated:YES];

}

@end
