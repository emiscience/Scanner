#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface SAppDelegate : NSObject <NSApplicationDelegate, ICDeviceBrowserDelegate, ICScannerDeviceDelegate> {
    ICDeviceBrowser *deviceBrowser;
    NSMutableArray *files;
    NSDictionary *sizes;
    IBOutlet NSArrayController *scannersController;
    IBOutlet PDFView *pdfView;
    IBOutlet NSPopUpButton *resolutionPopUpButton;
    IBOutlet NSSegmentedControl *kindSegmentedControl;
    IBOutlet NSPopUpButton *sizePopUpButton;
    IBOutlet NSSegmentedControl *orientationSegmentedControl;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSPathControl *pathControl;
    IBOutlet NSMenu *sizesMenu;
    IBOutlet NSMenu *resolutionsMenu;
}

@property (atomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSMutableArray *scanners;

- (IBAction)scan:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)reset:(id)sender;

- (ICScannerDevice *)selectedScanner;
- (NSRect)scanArea;

@end