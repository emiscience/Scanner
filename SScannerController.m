#import "SScannerController.h"

@implementation SScannerController

//MARK: - Synthesize Properties
@synthesize scanners = _scanners;

//MARK: - Init Methods
- (id)init {
    //If self is not nil after superclass init
    if (self = [super init]) {
        //Init sizes dictionary
        _sizesDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSValue valueWithSize:NSMakeSize(21.0, 29.7)], @"A4",
            [NSValue valueWithSize:NSMakeSize(14.8, 21.0)], @"A5",
            [NSValue valueWithSize:NSMakeSize(10.5, 14.8)], @"A6",
            [NSValue valueWithSize:NSMakeSize(21.59, 27.94)], @"Letter", nil];
        
        //Init scanners array & setup scanners array controller
        _scanners = [[NSMutableArray alloc] initWithCapacity:0];
        [_scannersController setSelectsInsertedObjects:NO];
        
        //Init, setup and start device browser
        _deviceBrowser = [[ICDeviceBrowser alloc] init];
        [_deviceBrowser setDelegate:self];
        [_deviceBrowser setBrowsedDeviceTypeMask:
            ICDeviceTypeMaskScanner|
            ICDeviceLocationTypeMaskLocal|
            ICDeviceLocationTypeMaskRemote];
        [_deviceBrowser start];
    }
    return self;
}

//MARK: - Device Browser Delegate Methods
- (void)deviceBrowser:(ICDeviceBrowser *)browser didAddDevice:(ICDevice *)device moreComing:(BOOL)moreComing {
    //If device is a scanner
    if (([device type] & ICDeviceTypeMaskScanner) == ICDeviceTypeScanner) {
        //Setup scanner, select functional unit, open session & add to scanners array
        ICScannerDevice *scanner = (ICScannerDevice *)device;
        [scanner setDelegate:self];
        [scanner setTransferMode:ICScannerTransferModeMemoryBased];
        [scanner setDocumentUTI:@"kUTTypePNG"];
        [scanner requestSelectFunctionalUnit:[[[scanner availableFunctionalUnitTypes] objectAtIndex:0] intValue]];
        [scanner requestOpenSession];
        [_scannersController addObject:scanner];
    }
}

- (void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing {
    //Remove device from scanners array & close session
    [_scannersController removeObject:device];
    [device requestCloseSession];
}

- (void)didRemoveDevice:(ICDevice *)device {
    //Remove device from scanners array & close session
    [_scannersController removeObject:device];
    [device requestCloseSession];
}

//MARK: - Scanner Device Delegate Methods
- (void)device:(ICDevice *)device didOpenSessionWithError:(NSError *)error {}

- (void)scannerDevice:(ICScannerDevice *)scanner didSelectFunctionalUnit:(ICScannerFunctionalUnit *)functionalUnit error:(NSError *)error {}

- (void)device:(ICDevice *)device didReceiveStatusInformation:(NSDictionary *)status {
	//If the scanner starts warming up, else if the scanner finished warming up
	if ([[status objectForKey:ICStatusNotificationKey] isEqualToString:ICScannerStatusWarmingUp]) {
		//Show indeterminate progress indicator
        [_progressIndicator setIndeterminate:YES];
        [_progressIndicator startAnimation:nil];
    } else if ([[status objectForKey:ICStatusNotificationKey] isEqualToString:ICScannerStatusWarmUpDone]) {
		//Hide indeterminate progress indicator
        [_progressIndicator stopAnimation:nil];
        [_progressIndicator setIndeterminate:NO];
    }
}

//???: Better way to redraw pdf view
- (void)scannerDevice:(ICScannerDevice *)scanner didScanToURL:(NSURL *)url data:(NSData *)data {
	//Hide progress indicator
	[_progressIndicator setIndeterminate:YES];
    [_progressIndicator startAnimation:nil];
    
    //Disable scan button & set title to scan
	[_scanButton setEnabled:NO];
	[_scanButton setTitle:@"Scan"];
	
    //Create pdf page from the data
    NSImage *image = [[NSImage alloc] initWithData:data];
    PDFPage *page = [[PDFPage alloc] initWithImage:image];
    [image release];
    
    //If pdf view already has document, else if it doesn't
    if ([_pdfView document]) {
        //Set page number and add page to document
        [page setValue:[NSString stringWithFormat:@"%d", [[_pdfView document] pageCount] + 1] forKey:@"label"];
        [[_pdfView document] insertPage:page atIndex:[[_pdfView document] pageCount]];
    } else {
        //Create new document and add page
        PDFDocument *document = [[PDFDocument alloc] init];
        [page setValue:@"1" forKey:@"label"];
        [document insertPage:page atIndex:0];
        [_pdfView setDocument:document];
        [document release];
    }
    [page release];
    
    [[(SAppDelegate *)[[NSApplication sharedApplication] delegate] window] setDocumentEdited:YES];
    
    //Force pdf view to redraw
    [_pdfView zoomIn:self];
    [_pdfView setAutoScales:YES];
}

- (void)scannerDevice:(ICScannerDevice *)scanner didCompleteScanWithError:(NSError *)error {
    //Enable scan button when scan is completed
	[_scanButton setEnabled:YES];
    [_progressIndicator stopAnimation:nil];
    [_progressIndicator setIndeterminate:NO];
}

- (void)device:(ICDevice *)device didCloseSessionWithError:(NSError *)error {}

- (void)device:(ICDevice *)device didEncounterError:(NSError *)error {}

//MARK: Class Method Actions
- (IBAction)scan:(id)sender {
    //Get selected scanner and its functional unit
    ICScannerDevice *scanner = [[_scannersController selectedObjects] lastObject];
    ICScannerFunctionalUnit *unit = [scanner selectedFunctionalUnit];
        
    //If no scan or overview scan in progress
    if (![unit overviewScanInProgress] && ![unit scanInProgress]) {
        //Setup functional unit & start scan
		[unit setMeasurementUnit:ICScannerMeasurementUnitCentimeters];
		[unit setUsesThresholdForBlackAndWhiteScanning:[[NSUserDefaults standardUserDefaults] boolForKey:@"usesMonochromeThreshold"]];
		[unit setThresholdForBlackAndWhiteScanning:[[NSUserDefaults standardUserDefaults] doubleForKey:@"monochromeThreshold"]];
        [unit setResolution:[[unit supportedResolutions] indexGreaterThanOrEqualToIndex:[[_resolutionPopUpButton selectedItem] tag]]];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"orientation"] == 0) {
            [unit setScanArea:NSMakeRect(0.0, 0.0, [[_sizesDictionary valueForKey:[[_sizePopUpButton selectedItem] title]] sizeValue].width, [[_sizesDictionary valueForKey:[[_sizePopUpButton selectedItem] title]] sizeValue].height)];
        } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"orientation"] == 1) {
            [unit setScanArea:NSMakeRect(0.0, 0.0, [[_sizesDictionary valueForKey:[[_sizePopUpButton selectedItem] title]] sizeValue].height, [[_sizesDictionary valueForKey:[[_sizePopUpButton selectedItem] title]] sizeValue].width)];
        }
        [unit setPixelDataType:[[NSUserDefaults standardUserDefaults] integerForKey:@"kind"]];
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kind"] == 0) [unit setBitDepth:ICScannerBitDepth1Bit]; else [unit setBitDepth:ICScannerBitDepth8Bits];
		[scanner requestScan];
		[_scanButton setTitle:@"Cancel"];
    } else {
        //Cancel ongoing scan
        [scanner cancelScan];
        [_scanButton setEnabled:NO];
        [_scanButton setTitle:@"Scan"];
    }
}

- (IBAction)save:(id)sender {
	//Format current date and time
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"ddMMyyyyHHmmss"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
	//Setup number & name
	NSInteger number = 0;
	NSString *name = [NSString stringWithFormat:@"scan_%@", dateString];
	
	//While filename exists, increment number
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[[_pathControl URL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", name]] path]]) {
		number++;
		name = [NSString stringWithFormat:@"scan_%@_%d", dateString, number];
	}
	
	//Save file to directory
	[[_pdfView document] writeToURL:[[_pathControl URL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", name]]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[[_pathControl URL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", name]] path]]) {
        [[(SAppDelegate *)[[NSApplication sharedApplication] delegate] window] setDocumentEdited:NO];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"resetOnSave"]) [_pdfView setDocument:nil];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Saving failed" defaultButton:@"Retry" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"The document was not saved."];
        [alert runModal];
    }
}

- (IBAction)reset:(id)sender {
	//Remove document from pdf view
	[_pdfView setDocument:nil];
    [[(SAppDelegate *)[[NSApplication sharedApplication] delegate] window] setDocumentEdited:NO];
}

- (IBAction)deletePage:(id)sender {
    [[NSApplication sharedApplication] sendAction:@selector(delete:) to:nil from:nil];
    [[(SAppDelegate *)[[NSApplication sharedApplication] delegate] window] setDocumentEdited:YES];
    for (int i = 0; i < [[_pdfView document] pageCount]; i++) {
        [[[_pdfView document] pageAtIndex:i] setValue:[NSString stringWithFormat:@"%d", i + 1] forKey:@"label"];
    }
}

@end