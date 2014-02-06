#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface SScannerController : NSObject <NSApplicationDelegate, ICDeviceBrowserDelegate, ICScannerDeviceDelegate> {
    //MARK: - Instance Variables
    ICDeviceBrowser *deviceBrowser;
    NSDictionary *sizes;
    
    //MARK: Instance Variable Outlets
    IBOutlet NSArrayController *scannersController;
    IBOutlet PDFView *pdfView;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSButton *scanButton;
    IBOutlet NSPathControl *pathControl;
    IBOutlet NSPopUpButton *resolutionPopUpButton;
    IBOutlet NSPopUpButton *sizePopUpButton;
    IBOutlet NSSegmentedControl *kindSegmentedControl;
    IBOutlet NSSegmentedControl *orientationSegmentedControl;
}

//MARK: - Properties
@property (nonatomic, retain) NSMutableArray *scanners;

//MARK: - Class Methods
- (NSRect)scanArea;

//MARK: Class Method Actions
- (IBAction)scan:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)reset:(id)sender;

@end