//
//  FFAppDelegate.m
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFAppDelegate.h"
#import "FFConstants.h"
#import "FFEventsManager.h"
#import "FFCoverImageVC.h"
#import "FFDateUtils.h"
#import "UIStoryboard+Main.h"
#import "FFAppVersion.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <M13ProgressSuite/UINavigationController+M13ProgressViewBar.h>
#import <MTDates/NSDate+MTDates.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

static NSString * const DEFAULTS_KEY_VERSION = @"lastLaunchedVersion";

@interface FFAppDelegate ()

@property (nonatomic, strong) FFEventsManager * eventsManager;
@property (nonatomic, strong) MBProgressHUD * hud;
@property (nonatomic, strong) UITabBarController * tabBarController;

@end

@implementation FFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	//// DEV: Get app directory on mac
//	NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
	
	//// CoreData initialization
	[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"db.sqlite"];
	
//	[NSDate mt_setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
//	[NSDate mt_setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[NSDate mt_setTimeZone:[FFDateUtils timezone]];
	
	//// UI init
	[self setGlobalTintColor];
	
	////// DATA
	self.eventsManager = [FFEventsManager instance];
	[self versionCheck];
	
	//// Refreshing data at start
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsManagerStateChanged) name:FFEventsManagerStateChanged object:self.eventsManager];
	[self.eventsManager load];
	
	//// Google Analytics setup
	[[GAI sharedInstance] trackerWithTrackingId:FFConstantGoogleAnalyticsTrackingNumber];
	
	//// Creting main Tab Bar Controller
	self.tabBarController = (UITabBarController *)[UIStoryboard mainStoryboard].instantiateInitialViewController;
	self.tabBarController.delegate = self;
	
	//// Will switch to it in 3 seconds
	[self performSelector:@selector(switchToTabBar) withObject:self afterDelay:3.f];
	
	//// Showing cover image first
	FFCoverImageVC * coverImageVC = [FFCoverImageVC new];
	
	//// Manually creating main window
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	//// Show image first
	self.window.rootViewController = coverImageVC;
	//// Show tab bar immediately
//	self.window.rootViewController = self.tabBarController;
	
	[self.window makeKeyAndVisible];

    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {

	UIViewController * topController = window.rootViewController;
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}

	if ([topController isKindOfClass:[XCDYouTubeVideoPlayerViewController class]]) {
		return UIInterfaceOrientationMaskLandscapeLeft;
	}
	
	return UIInterfaceOrientationMaskPortrait;
}
- (void)switchToTabBar {
	FFCoverImageVC * coverImageVC = (FFCoverImageVC *)self.window.rootViewController;
	self.window.rootViewController = self.tabBarController;
	[self.tabBarController.view addSubview:coverImageVC.view];
	[UIView animateWithDuration:1.f animations:^{
		coverImageVC.view.alpha = 0.f;
	} completion:^(BOOL finished) {
		[coverImageVC.view removeFromSuperview];
	}];
}
/**
 *  Save current version and check if something need to do depending on previous version
 */
- (void)versionCheck {
	FFAppVersion * appVersion = [FFAppVersion instance];
	NSUInteger lastRunBuildNum = appVersion.lastRunBuildNumber;
	NSString * version = appVersion.version;
	BOOL needToClearData;

#ifdef LAFF
	needToClearData = [version isEqualToString:@"1.1"] && lastRunBuildNum < 7;
#elif NBFF
	needToClearData = [version isEqualToString:@"1.0"] && lastRunBuildNum < 2;
#endif
	
	if (needToClearData) {
		NSLog(@"YES, need to clear data");
		[self.eventsManager deleteAllSynchronous:YES];
	}
	
	/*
	NSString * lastLaunchedVersionNum = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_KEY_VERSION];
	
	BOOL updatedTo06orLater =
		!lastLaunchedVersionNum || !lastLaunchedVersionNum.length ||
		[lastLaunchedVersionNum compare:@"0.6" options:NSNumericSearch] == NSOrderedAscending;
	NSLog(@"updatedTo06orLater: %u", updatedTo06orLater);
	if (updatedTo06orLater) {
		[self.eventsManager deleteAllSynchronous:YES];
	}
	
	NSString * currentVersionNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	[[NSUserDefaults standardUserDefaults] setObject:currentVersionNum forKey:DEFAULTS_KEY_VERSION];
	 */
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	switch (tabBarController.selectedIndex) {
		case 0:
		case 2:
			[self eventsManagerStateChanged];
			break;
		case 3: {
			UINavigationController * nc = (UINavigationController *)viewController;
			if (!nc.viewControllers.count) {
				if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
					// >= iOS8
#ifdef LAFF
					[nc performSegueWithIdentifier:@"laff-root" sender:nc];
#elif NBFF
					[nc performSegueWithIdentifier:@"nbff-root" sender:nc];
#endif
					
				} else {
					// <= iOS7
#ifdef LAFF
					UIViewController * vc = [nc.storyboard instantiateViewControllerWithIdentifier:@"about-laff"];
					[nc pushViewController:vc animated:NO];
#elif NBFF
					UIViewController * vc = [nc.storyboard instantiateViewControllerWithIdentifier:@"about-nbff"];
					[nc pushViewController:vc animated:NO];
#endif
				}
			}
			break;
		}
		default:
			break;
	}
}
- (void)eventsManagerStateChanged {
	NSLog(@"=== eventsManagerStateChanged to %u", (uint)self.eventsManager.state);
	UITabBarController * tbc = (UITabBarController *)self.window.rootViewController;
	if (![tbc isKindOfClass:[UITabBarController class]]) {
		return;
	}
	UINavigationController * nc = (UINavigationController *)tbc.selectedViewController;
	if (!nc) {
		[self performSelector:@selector(eventsManagerStateChanged) withObject:self afterDelay:1.f];
		return;
	}
	
	BOOL shouldShowHUD;
	BOOL shouldAnimateNavigationBarLoading;
	
	switch (self.eventsManager.state) {
		default:
		case FFEventsManagerStateNotInited: {
			// 0
			shouldShowHUD = YES;
			shouldAnimateNavigationBarLoading = NO;
			break;
		}
		case FFEventsManagerStateNoData:
			// 1
			shouldShowHUD = NO;
			shouldAnimateNavigationBarLoading = NO;
			// show alert message with retry button
			break;
		case FFEventsManagerStateNoDataAndLoading:
			// 2
			shouldShowHUD = YES;
			shouldAnimateNavigationBarLoading = NO;
			break;
		case FFEventsManagerStateHasData:
			// 3
			shouldShowHUD = NO;
			shouldAnimateNavigationBarLoading = NO;
			break;
		case FFEventsManagerStateHasDataAndUpdating:
			// 4
			shouldShowHUD = NO;
			shouldAnimateNavigationBarLoading = YES;
			break;
	}
	
	if (shouldShowHUD) {
		self.hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
		self.hud.labelText = @"Please wait";
		self.hud.detailsLabelText = @"Loading initial data";
	} else if (self.hud) {
		[self.hud hide:YES];
		self.hud = nil;
	}
	
	if (shouldAnimateNavigationBarLoading) {
		[nc setIndeterminate:YES];
		[nc showProgress];
	} else {
		[nc finishProgress];
	}
}
- (void)setGlobalTintColor {
	UIColor * tintColor = FFConstants.tintColor;
//	[UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:tintColor};
	[UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
	[UINavigationBar appearance].tintColor = tintColor;
	[UITabBar		 appearance].tintColor = tintColor;
	[UIBarButtonItem appearance].tintColor = tintColor;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[MagicalRecord cleanUp];
}

@end
