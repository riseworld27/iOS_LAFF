#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(1);
captureLocalizedScreenshot("0-SplashScreen");
target.delay(5);
captureLocalizedScreenshot("1-LatestNewsScreen");
target.frontMostApp().tabBar().buttons()["Social"].tap();
captureLocalizedScreenshot("2-SocialScreen");
target.frontMostApp().tabBar().buttons()["Films"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.35}});
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.63, y:0.35}});
captureLocalizedScreenshot("3-FilmsScreen");
target.frontMostApp().tabBar().buttons()["About"].tap();
captureLocalizedScreenshot("4-AboutScreen");
// target.frontMostApp().tabBar().buttons()["More"].tap();
// target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.44, y:0.37}});
