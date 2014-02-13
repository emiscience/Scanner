#import "SAppDelegate.h"

@implementation SAppDelegate

//MARK: - Synthesize Properties
@synthesize window = _window;

//MARK: - Application Delegate Methods
//TODO: Set users defaults if not set
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    //Set defaults if not yet set
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"directory"])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil]] forKey:@"directory"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"kind"])
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"kind"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"resolution"])
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"resolution"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"size"])
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"size"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"orientation"])
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"orientation"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"usesMonochromeThreshold"])
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usesMonochromeThreshold"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"monochromeThreshold"])
        [[NSUserDefaults standardUserDefaults] setDouble:127.5 forKey:@"monochromeThreshold"];
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