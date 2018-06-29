#import "AppDelegate.h"
#import "LDSharedManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    LDSharedManager *sharedManager = LDSharedManager.global;
    if ([shortcutItem.type isEqualToString:sharedManager.darkmodeToggle]) {
        [sharedManager setDarkmode:![sharedManager.userDefaults boolForKey:sharedManager.darkMode] pop:YES];
    }
    completionHandler(YES);
}

@end
