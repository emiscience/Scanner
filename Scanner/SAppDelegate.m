#import "SAppDelegate.h"

@implementation SAppDelegate

//MARK: - Synthesize Properties
@synthesize window = _window;
@synthesize _scanners = scanners;

//MARK: - Application Delegate Methods	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //Initializing and setting up the scanners array and arraycontroller
    scanners = [[NSMutableArray alloc] initWithCapacity:0];
    [scannersController setSelectsInsertedObjects:NO];
    
    //Initializing and setting up the device browser
    deviceBrowser = [[ICDeviceBrowser alloc] init];
    [deviceBrowser setDelegate:self];
    [deviceBrowser setBrowsedDeviceTypeMask:ICDeviceTypeMaskScanner|
                                            ICDeviceLocationTypeMaskLocal|
                                            ICDeviceLocationTypeMaskRemote];
    [deviceBrowser start];
}

//MARK: - Device Browser Delegate Methods
- (void)deviceBrowser:(ICDeviceBrowser *)browser didAddDevice:(ICDevice *)device moreComing:(BOOL)moreComing {
    //If the device is a scanner
    if (([device type] & ICDeviceTypeMaskScanner) == ICDeviceTypeScanner) {
		//Adding the device to the scanners array
        [self willChangeValueForKey:@"_scanners"];
        [scanners addObject:device];
        [self didChangeValueForKey:@"_scanners"];
        
        //Setting up the device
        [device setDelegate:self];
        [device requestOpenSession];
        [(ICScannerDevice *)device requestSelectFunctionalUnit:[[[(ICScannerDevice *)device availableFunctionalUnitTypes] objectAtIndex:0] intValue]];
        [(ICScannerDevice *)device setTransferMode:ICScannerTransferModeMemoryBased];
        [(ICScannerDevice *)device setDocumentUTI:@"kUTTypePDF"];
    }
}

- (void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing {
    //Remove the device from the scanners array
    [self willChangeValueForKey:@"_scanners"];
    [scanners removeObject:device];
    [self didChangeValueForKey:@"_scanners"];
    [device requestCloseSession];
}

- (void)didRemoveDevice:(ICDevice *)device {
    //Remove the device from the scanners array
    [self willChangeValueForKey:@"_scanners"];
    [scanners removeObject:device];
    [self didChangeValueForKey:@"_scanners"];
    [device requestCloseSession];
}

//MARK: - Scanner Device Delegate Methods
- (void)device:(ICDevice *)device didOpenSessionWithError:(NSError *)error {
    if ([error isNotEqualTo:nil]) {
        NSLog(@"%@", error);
    }
}

- (void)scannerDevice:(ICScannerDevice *)scanner didSelectFunctionalUnit:(ICScannerFunctionalUnit *)functionalUnit error:(NSError *)error {
    if ([error isNotEqualTo:nil]) {
        NSLog(@"%@", error);
    }
}

- (void)device:(ICDevice *)device didReceiveStatusInformation:(NSDictionary *)status {
	//If the scanner starts warming up or else if the scanner finished warming up
	if ([[status objectForKey:ICStatusNotificationKey] isEqualToString:ICScannerStatusWarmingUp]) {
		//Show an indeterminate progress bar
        [progressIndicator setDisplayedWhenStopped:YES];
        [progressIndicator setIndeterminate:YES];
        [progressIndicator startAnimation:nil];
    } else if ([[status objectForKey:ICStatusNotificationKey] isEqualToString:ICScannerStatusWarmUpDone]) {
		//Hide the indeterminate progress bar
        [progressIndicator stopAnimation:nil];
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setDisplayedWhenStopped:NO];
    }
}

//???: Better way to redraw pdf view
- (void)scannerDevice:(ICScannerDevice *)scanner didScanToURL:(NSURL *)url data:(NSData *)data {
	//Hide the progress bar
	[progressIndicator stopAnimation:nil];
	
    //Create a pdf page from the data
    NSImage *image = [[NSImage alloc] initWithData:data];
    PDFPage *page = [[PDFPage alloc] initWithImage:image];
    
    //If the pdf view has a document
    if ([pdfView document]) {
        //Set the page number and add it to the document
        [page setValue:[NSString stringWithFormat:@"%d", [[pdfView document] pageCount] + 1] forKey:@"label"];
        [[pdfView document] insertPage:page atIndex:[[pdfView document] pageCount]];
    } else {
        //Create a new document and add the page
        [page setValue:@"1" forKey:@"label"];
        PDFDocument *document = [[PDFDocument alloc] init];
        [document insertPage:page atIndex:0];
        [pdfView setDocument:document];
    }
    
    //Force a redraw for the pdf view so the pages are shown properly
    [pdfView zoomIn:self];
    [pdfView setAutoScales:YES];
}

- (void)device:(ICDevice *)device didCloseSessionWithError:(NSError *)error {
    if ([error isNotEqualTo:nil]) {
        NSLog(@"%@", error);
    }
}

//MARK: - Interface Builder Actions
//FIXME: Black and white not working
- (IBAction)scan:(id)sender {
    //Get the selected scanner and it's functional unit
    ICScannerDevice *scanner = [self selectedScanner];
    ICScannerFunctionalUnit *unit = [scanner selectedFunctionalUnit];
    
    //If there is no scan or overviewscan in progress
    if (![unit overviewScanInProgress] && ![unit scanInProgress]) {
        //Setup the functional unit and start the scan
        [unit setScanArea:[self scanArea]];
        [unit setResolution:[[unit supportedResolutions] indexGreaterThanOrEqualToIndex:[[resolutionPopUpButton selectedItem] tag]]];
        [unit setBitDepth:ICScannerBitDepth8Bits];
        [unit setPixelDataType:[kindSegmentedControl selectedSegment]];
        [scanner requestScan];
    } else {
        //Cancel the ongoing scan
        [scanner cancelScan];
    }
}

- (IBAction)save:(id)sender {
	//
}

- (IBAction)reset:(id)sender {
	//Remove the document from the view
	[pdfView setDocument:nil];
}

//MARK: - Class Variables
- (ICScannerDevice *)selectedScanner {
    //Return the scanner that is currently selected in the popup
    return [[scannersController selectedObjects] objectAtIndex:0];
}

//???: Better way
- (NSRect)scanArea {
    //Get the variables from interface elements
    NSInteger orientation = [orientationSegmentedControl selectedSegment]; //0=Portrait 1=Landscape
    NSString *size = [[sizePopUpButton selectedItem] title];
    CGFloat resolution = [[resolutionPopUpButton selectedItem] tag];
    
    //If the orientation is portrait or else if it is landscape
    if (orientation == 0) {
        //If the size is A4, A5, A6 or else if it is Letter
        if ([size isEqualToString:@"A4"]) {
            return NSMakeRect(0.0, 0.0, 8.27 * resolution, 11.69 * resolution);
        } else if ([size isEqualToString:@"A5"]) {
            return NSMakeRect(0.0, 0.0, 5.83 * resolution, 8.27 * resolution);
        } else if ([size isEqualToString:@"A6"]) {
            return NSMakeRect(0.0, 0.0, 4.13 * resolution, 5.83 * resolution);
        } else {
            return NSMakeRect(0.0, 0.0, 8.5 * resolution, 11.0 * resolution);
        }
    } else {
        //If the size is A4, A5, A6 or else if it is Letter
        if ([size isEqualToString:@"A4"]) {
            return NSMakeRect(0.0, 0.0, 11.69 * resolution, 8.27 * resolution);
        } else if ([size isEqualToString:@"A5"]) {
            return NSMakeRect(0.0, 0.0, 8.27 * resolution, 5.83 * resolution);
        } else if ([size isEqualToString:@"A6"]) {
            return NSMakeRect(0.0, 0.0, 5.83 * resolution, 4.13 * resolution);
        } else {
            return NSMakeRect(0.0, 0.0, 11.0 * resolution, 8.5 * resolution);
        }
    }
}

@end