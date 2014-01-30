#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface SAppDelegate : NSObject <NSApplicationDelegate, ICDeviceBrowserDelegate, ICScannerDeviceDelegate, NSOutlineViewDelegate> {
    ICDeviceBrowser *deviceBrowser;
    NSMutableArray *scanners;
    IBOutlet NSArrayController *scannersController;
    IBOutlet PDFView *pdfView;
    IBOutlet NSPopUpButton *resolutionPopUpButton;
    IBOutlet NSSegmentedControl *kindSegmentedControl;
    IBOutlet NSPopUpButton *sizePopUpButton;
    IBOutlet NSSegmentedControl *orientationSegmentedControl;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) NSMutableArray *_scanners;

- (IBAction)scan:(id)sender;

- (ICScannerDevice *)selectedScanner;
- (BOOL)scannerAvailable;
- (NSRect)scanArea;

@end