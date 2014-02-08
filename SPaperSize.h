#import <Foundation/Foundation.h>

//MARK: - Type Definitions
//MARK: Enumerators
typedef enum {
    SPaperSizeOrientationPortrait = 0,
    SPaperSizeOrientationLandscape = 1
} SPaperSizeOrientation;

@interface SPaperSize : NSObject <NSCoding>

//MARK: - Properties
@property (copy) NSString *name;
@property (assign) CGFloat width;
@property (assign) CGFloat height;

//MARK: - Init Methods
- (id)initWithName:(NSString *)inputName width:(CGFloat)inputWidth height:(CGFloat)inputHeight;
+ (SPaperSize *)paperSizeWithName:(NSString *)inputName width:(CGFloat)inputWidth height:(CGFloat)inputHeight;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

//MARK: - Class Methods
- (CGFloat)widthForOrientation:(SPaperSizeOrientation)orientation;
- (CGFloat)heightForOrientation:(SPaperSizeOrientation)orientation;
- (NSInteger)pixelWidthForOrientation:(SPaperSizeOrientation)orientation resolution:(NSInteger)resolution;
- (NSInteger)pixelHeightForOrientation:(SPaperSizeOrientation)orientation resolution:(NSInteger)resolution;

@end