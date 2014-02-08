#import "SPaperSize.h"

@implementation SPaperSize

//MARK: Synthesize Properties
@synthesize name, width, height;

//MARK: - Init Methods
- (id)initWithName:(NSString *)inputName width:(CGFloat)inputWidth height:(CGFloat)inputHeight {
    if (self = [super init]) {
        name = inputName;
        width = inputWidth;
        height = inputHeight;
    }
    return self;
}

+ (SPaperSize *)paperSizeWithName:(NSString *)inputName width:(CGFloat)inputWidth height:(CGFloat)inputHeight {
    return [[self alloc] initWithName:inputName width:inputWidth height:inputHeight];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        name = [decoder decodeObjectForKey:@"name"];
        width = [decoder decodeDoubleForKey:@"width"];
        height = [decoder decodeDoubleForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeDouble:width forKey:@"width"];
    [encoder encodeDouble:height forKey:@"height"];
}

//MARK: - Class Methods
- (CGFloat)widthForOrientation:(SPaperSizeOrientation)orientation {
    switch (orientation) {
        case 0: return width; break;
        case 1: return height; break;
        default: return width; break;
    }
}

- (CGFloat)heightForOrientation:(SPaperSizeOrientation)orientation {
    switch (orientation) {
        case 0: return height; break;
        case 1: return width; break;
        default: return height; break;
    }
}

- (NSInteger)pixelWidthForOrientation:(SPaperSizeOrientation)orientation resolution:(NSInteger)resolution {
    switch (orientation) {
        case 0: return (NSInteger)(width * 0.393700787 * (CGFloat)resolution); break;
        case 1: return (NSInteger)(height * 0.393700787 * (CGFloat)resolution); break;
        default: return (NSInteger)(width * 0.393700787 * (CGFloat)resolution); break;
    }
}

- (NSInteger)pixelHeightForOrientation:(SPaperSizeOrientation)orientation resolution:(NSInteger)resolution {
    switch (orientation) {
        case 0: return (NSInteger)(height * 0.393700787 * (CGFloat)resolution); break;
        case 1: return (NSInteger)(width * 0.393700787 * (CGFloat)resolution); break;
        default: return (NSInteger)(height * 0.393700787 * (CGFloat)resolution); break;
    }
}

@end