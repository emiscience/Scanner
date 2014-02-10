#import "SAppDelegate.h"

@implementation SAppDelegate

//MARK: - Synthesize Properties
@synthesize window = _window;

//MARK: - Application Delegate Methods
//TODO: Set users defaults if not set
- (void)applicationDidFinishLaunching:(NSNotification *)notification {}

- (void)applicationWillTerminate:(NSNotification *)notification {
    //Save the user defaults before terminating
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end