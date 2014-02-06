#import "SScannerController.h"

@implementation SScannerController

//MARK: - Synthesize Properties
@synthesize scanners;

//MARK: - Init Methods
- (id)init {
    //If self is not nil after superclass init
    if (self = [super init]) {
        //Init sizes array
        sizes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            [NSValue valueWithSize:NSMakeSize(21.0, 27.9)], @"A4",
            [NSValue valueWithSize:NSMakeSize(14.8, 21.0)], @"A5",
            [NSValue valueWithSize:NSMakeSize(10.5, 14.8)], @"A6",
            [NSValue valueWithSize:NSMakeSize(21.59, 27.94)], @"Letter", nil];
        
        //Init scanners array & setup scanners array controller
        scanners = [[NSMutableArray alloc] initWithCapacity:0];
        [scannersController setSelectsInsertedObjects:NO];
        
        //Init, setup and start device browser
        deviceBrowser = [[ICDeviceBrowser alloc] init];
        [deviceBrowser setDelegate:self];
        [deviceBrowser setBrowsedDeviceTypeMask:
            ICDeviceTypeMaskScanner|
            ICDeviceLocationTypeMaskLocal|
            ICDeviceLocationTypeMaskRemote];
        [deviceBrowser start];
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
        [scannersController addObject:scanner];
    }
}

- (void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing {
    //Remove device from scanners array & close session
    [scannersController removeObject:device];
    [device requestCloseSession];
}

- (void)didRemoveDevice:(ICDevice *)device {
    //Remove device from scanners array & close session
    [scannersController removeObject:device];
    [device requestCloseSession];
}

//MARK: - Scanner Device Delegate Methods
- (void)device:(ICDevice *)device didOpenSessionWithError:(NSError *)error {}

- (void)scannerDevice:(ICScannerDevice *)scanner didSelectFunctionalUnit:(ICScannerFunctionalUnit *)functionalUnit error:(NSError *)error {}

- (void)device:(ICDevice *)device didReceiveStatusInformation:(NSDictionary *)status {
	//If the scanner starts warming up, else if the scanner finished warming up
	if ([[status objectForKey:ICStatusNotificationKey] isEqualToString:ICScannerStatusWarmingUp]) {
		//Show indeterminate progress indicator
        [progressIndicator setIndeterminate:YES];
        [progressIndicator startAnimation:nil];
    } else if ([[status objectForKey:ICStatusNotificationKey] isEqualToString:ICScannerStatusWarmUpDone]) {
		//Hide indeterminate progress indicator
        [progressIndicator stopAnimation:nil];
        [progressIndicator setIndeterminate:NO];
    }
}

//???: Better way to redraw pdf view
- (void)scannerDevice:(ICScannerDevice *)scanner didScanToURL:(NSURL *)url data:(NSData *)data {
	//Hide progress indicator
	[progressIndicator stopAnimation:nil];
    
    //Disable scan button & set title to scan
	[scanButton setEnabled:NO];
	[scanButton setTitle:@"Scan"];
	
    //Create pdf page from the data
    NSImage *image = [[NSImage alloc] initWithData:data];
    PDFPage *page = [[PDFPage alloc] initWithImage:image];
    
    //If pdf view already has document, else if it doesn't
    if ([pdfView document]) {
        //Set page number and add page to document
        [page setValue:[NSString stringWithFormat:@"%d", [[pdfView document] pageCount] + 1] forKey:@"label"];
        [[pdfView document] insertPage:page atIndex:[[pdfView document] pageCount]];
    } else {
        //Create new document and add page
        PDFDocument *document = [[PDFDocument alloc] init];
        [page setValue:@"1" forKey:@"label"];
        [document insertPage:page atIndex:0];
        [pdfView setDocument:document];
    }
    
    //Force pdf view to redraw
    [pdfView zoomIn:self];
    [pdfView setAutoScales:YES];
}

- (void)scannerDevice:(ICScannerDevice *)scanner didCompleteScanWithError:(NSError *)error {
    //Enable scan button when scan is completed
	[scanButton setEnabled:YES];
}

- (void)device:(ICDevice *)device didCloseSessionWithError:(NSError *)error {}

- (void)device:(ICDevice *)device didEncounterError:(NSError *)error {}

//MARK: - Class Methods
- (NSRect)scanArea {
	//Convert metric size to pixel size
    NSSize metricSize = [[sizes objectForKey:[[sizePopUpButton selectedItem] title]] sizeValue];
	NSSize imperialSize = NSMakeSize(metricSize.width * 0.393700787, metricSize.height * 0.393700787);
	NSSize pixelSize = NSMakeSize(imperialSize.width * [[resolutionPopUpButton selectedItem] tag], imperialSize.height * [[resolutionPopUpButton selectedItem] tag]);
	
	//If orientation is portrait, else if orientation is landscape, else if none
	if ([orientationSegmentedControl selectedSegment] == 0) {
        //Return size
		return NSMakeRect(0.0, 0.0, pixelSize.width, pixelSize.height);
	} else if ([orientationSegmentedControl selectedSegment] == 1) {
        //Return inverted size
		return NSMakeRect(0.0, 0.0, pixelSize.height, pixelSize.width);
	} else {
        //Return no size
		return NSMakeRect(0.0, 0.0, 0.0, 0.0);
	}
}

//MARK: Class Method Actions
- (IBAction)scan:(id)sender {
    //Get selected scanner and its functional unit
    ICScannerDevice *scanner = [[scannersController selectedObjects] objectAtIndex:0];
    ICScannerFunctionalUnit *unit = [scanner selectedFunctionalUnit];
    
    //If no scan or overview scan in progress
    if (![unit overviewScanInProgress] && ![unit scanInProgress]) {
        //Setup functional unit & start scan
		[unit setMeasurementUnit:ICScannerMeasurementUnitCentimeters];
		[unit setUsesThresholdForBlackAndWhiteScanning:[[NSUserDefaults standardUserDefaults] boolForKey:@"usesMonochromeThreshold"]];
		[unit setThresholdForBlackAndWhiteScanning:[[NSUserDefaults standardUserDefaults] doubleForKey:@"monochromeThreshold"]];
        [unit setScanArea:[self scanArea]];
        [unit setResolution:[[unit supportedResolutions] indexGreaterThanOrEqualToIndex:[[resolutionPopUpButton selectedItem] tag]]];
        [unit setPixelDataType:[[NSUserDefaults standardUserDefaults] integerForKey:@"kind"]];
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kind"] == 0) [unit setBitDepth:ICScannerBitDepth1Bit]; else [unit setBitDepth:ICScannerBitDepth8Bits];
		[scanner requestScan];
		[scanButton setTitle:@"Cancel"];
    } else {
        //Cancel ongoing scan
        [scanner cancelScan];
        [scanButton setEnabled:NO];
        [scanButton setTitle:@"Scan"];
    }
}

- (IBAction)save:(id)sender {
	//Format current date and time
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"ddMMyyyyHHmmss"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
	//Setup number & name
	NSInteger number = 0;
	NSString *name = [NSString stringWithFormat:@"scan_%@", dateString];
	
	//While filename exists, increment number
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[[pathControl URL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", name]] path]]) {
		number++;
		name = [NSString stringWithFormat:@"scan_%@_%d", dateString, number];
	}
	
	//Save file to directory
	[[pdfView document] writeToURL:[[pathControl URL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", name]]];
}

- (IBAction)reset:(id)sender {
	//Remove document from pdf view
	[pdfView setDocument:nil];
}

@end