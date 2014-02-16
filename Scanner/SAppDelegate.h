#import <LeviKit/LeviKit.h>

@interface SAppDelegate : NSObject <NSApplicationDelegate>

//MARK: - Properties
//MARK: Property Outlets
@property (assign) IBOutlet NSWindow *window;

//MARK: - Class Methods
//MARK: Class Method Actions
- (IBAction)reportBug:(id)sender;

@end