#import "SAppDelegate.h"

@implementation SAppDelegate

//MARK: - Synthesize Properties
@synthesize window = _window;

//MARK: - Application Delegate Methods
//TODO: Set users defaults if not set
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    //Set defaults if not yet set
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"directory"]) [userDefaults setObject:[NSArchiver archivedDataWithRootObject:[[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil]] forKey:@"directory"];
    if (![userDefaults integerForKey:@"kind"]) [userDefaults setInteger:1 forKey:@"kind"];
    if (![userDefaults integerForKey:@"resolution"]) [userDefaults setInteger:3 forKey:@"resolution"];
    if (![userDefaults integerForKey:@"size"]) [userDefaults setInteger:0 forKey:@"size"];
    if (![userDefaults integerForKey:@"orientation"]) [userDefaults setInteger:0 forKey:@"orientation"];
    if (![userDefaults boolForKey:@"usesMonochromeThreshold"]) [userDefaults setBool:NO forKey:@"usesMonochromeThreshold"];
    if (![userDefaults doubleForKey:@"monochromeThreshold"]) [userDefaults setDouble:127.5 forKey:@"monochromeThreshold"];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)application hasVisibleWindows:(BOOL)visibleWindows {
    //If there are visible windows or else if there are none
    if (visibleWindows) {
        [_window orderFront:self];
    } else {
        [_window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    //Save the user defaults before terminating
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end