#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface SScannerController : NSObject <NSApplicationDelegate, ICDeviceBrowserDelegate, ICScannerDeviceDelegate> {
    //MARK: - Instance Variables
    ICDeviceBrowser *_deviceBrowser;
    NSDictionary *_sizesDictionary;
    
    //MARK: Instance Variable Outlets
    IBOutlet NSArrayController *_scannersController;
    IBOutlet PDFView *_pdfView;
    IBOutlet PDFThumbnailView *_pdfThumbnailView;
    IBOutlet NSProgressIndicator *_progressIndicator;
    IBOutlet NSButton *_scanButton;
    IBOutlet NSPathControl *_pathControl;
    IBOutlet NSPopUpButton *_resolutionPopUpButton;
    IBOutlet NSPopUpButton *_sizePopUpButton;
    IBOutlet NSSegmentedControl *_kindSegmentedControl;
    IBOutlet NSSegmentedControl *_orientationSegmentedControl;
}

//MARK: - Properties
@property (nonatomic, retain) NSMutableArray *scanners;

//MARK: - Class Methods
//MARK: Class Method Actions
- (IBAction)scan:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)reset:(id)sender;

@end