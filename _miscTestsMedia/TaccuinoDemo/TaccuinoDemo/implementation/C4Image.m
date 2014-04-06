//
//  C4Image.m
//  C4iOS
//
//  Created by Travis Kirton on 13-02-27.
//

#import "C4Image.h"

@interface C4Image ()
@property (readwrite, strong, nonatomic) C4ImageView *imageView;
@property (readwrite, strong, nonatomic) UIImage *originalImage;
@property (readwrite, strong, nonatomic) CIImage *output;
@property (readwrite, strong, nonatomic) CIContext *filterContext;
@property (readonly, nonatomic) dispatch_queue_t filterQueue;
@property (readonly, nonatomic) NSUInteger bytesPerPixel, bytesPerRow;
@property (readonly, nonatomic) unsigned char *rawData;
@property (readonly, nonatomic) C4ActivityIndicator *filterIndicator;
@end

@implementation C4Image
@synthesize filterQueue = _filterQueue, rawData = _rawData, rotation = _rotation;

#pragma mark Initialization
+(C4Image *)imageNamed:(NSString *)name {
    return [[C4Image alloc] initWithImageName:name];
}

+(C4Image *)imageWithImage:(C4Image *)image {
    return [[C4Image alloc] initWithImage:image];
}

+(C4Image *)imageWithUIImage:(UIImage *)image {
    return [[C4Image alloc] initWithUIImage:image];
}

+(C4Image *)imageWithURL:(NSString *)imageURL {
    return [[C4Image alloc] initWithURL:[NSURL URLWithString:imageURL]];
}

-(id)initWithRawData:(unsigned char*)data width:(NSInteger)width height:(NSInteger)height {
    @autoreleasepool {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, 4*width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGImageRef image = CGBitmapContextCreateImage(context);
        UIImage *uiimg = [UIImage imageWithCGImage:image];
        CFRelease(colorSpace);
        CFRelease(context);
        CFRelease(image);
        return [self initWithUIImage:uiimg];
    }
}

-(id)initWithCGImage:(CGImageRef)image {
    return [self initWithUIImage:[UIImage imageWithCGImage:image]];
}

-(id)initWithImageName:(NSString *)name {
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    UIImage *newImage = [UIImage imageNamed:name];
    return [self initWithUIImage:newImage];
}

-(id)initWithImage:(C4Image *)image {
    return [self initWithUIImage:image.UIImage];
}

-(id)initWithUIImage:(UIImage *)image {
    if(image == nil || image == (UIImage *)[NSNull null]) return nil;
    self = [super init];
    if(self != nil) {
        _originalImage = image;
        _constrainsProportions = YES;
        _multipleFilterEnabled = NO;
        
        [self setProperties];
        _filterQueue = nil;
        _output = nil;
        _imageView = [[C4ImageView alloc] initWithImage:_originalImage];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
        self.autoresizesSubviews = YES;
        self.showsActivityIndicator = YES;
        _filterIndicator = [C4ActivityIndicator indicatorWithStyle:WHITE];
        _filterIndicator.center = CGPointMake(self.width/2,self.height/2);
        [_filterIndicator stopAnimating];
        [self addUIElement:_filterIndicator];
    }
    return self;
}

+(C4Image *)imageWithData:(NSData *)imageData {
    return [[C4Image alloc] initWithData:imageData];
}

-(id)initWithData:(NSData *)imageData {
    return [self initWithUIImage:[UIImage imageWithData:imageData]];
}

-(id)initWithURL:(NSURL *)imageURL {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMappedIfSafe error:&error];
    if(data) {
        self = [self initWithData:data];
        return self;
    }
    C4Log(@"There was an error downloading the content from the url you provided.\n%@",[error description]);
    return nil;
}

-(void)setProperties {
    _originalSize = _originalImage.size;
    _originalRatio = _originalSize.width / _originalSize.height;
    
    CGRect scaledFrame = CGRectZero;
    scaledFrame.origin = self.frame.origin;
    scaledFrame.size = _originalSize;
    self.frame = scaledFrame;
}

#pragma mark Properties
-(void)setHeight:(CGFloat)height {
    CGRect newFrame = self.frame;
    newFrame.size.height = height;
    if(_constrainsProportions) newFrame.size.width = height * self.originalRatio;
    self.frame = newFrame;
}

-(void)setWidth:(CGFloat)width {
    CGRect newFrame = self.frame;
    newFrame.size.width = width;
    if(_constrainsProportions) newFrame.size.height = width/self.originalRatio;
    self.frame = newFrame;
}

-(void)setSize:(CGSize)size {
    CGRect newFrame = CGRectZero;
    newFrame.origin = self.origin;
    newFrame.size = size;
    self.frame = newFrame;
}

#pragma mark C4Control Overrides
/*
 The C4Image object is slightly different than other C4Controls in that it has an embedded C4ImageView.
 There are some issues with rotating the view inside the view, and as such we have to do the followign overrides.
 
 */
-(void)setRotation:(CGFloat)rotation {
    [self _setRotation:@(rotation)];
}

-(void)_setRotation:(NSNumber *)rotation {
    [(id <C4LayerAnimation>)self.layer animateRotation:[rotation floatValue]-_rotation];
}

-(void)rotationDidFinish:(CGFloat)rotation {
    _rotation += rotation;
    CGAffineTransform transform = CGAffineTransformMakeRotation(_rotation);
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:0.0001f];
    [super setTransform:transform];
    [UIView commitAnimations];
}

//We override this as well because if we don't it "looks" like the background doesn't rotate.
-(void)setBackgroundColor:(UIColor *)backgroundColor {
    self.imageView.backgroundColor = backgroundColor;
}

#pragma mark Contents
-(UIImage *)UIImage {
    CGImageRef cg = self.contents;
    UIImage *image = [UIImage imageWithCGImage:cg scale:CGImageGetWidth(cg)/self.width orientation:self.originalImage.imageOrientation ];
    return image;
}

-(CIImage *)CIImage {
    return [CIImage imageWithCGImage:self.contents];
}

-(CGImageRef)CGImage {
    return self.contents;
}

-(CGImageRef)contents {
    return (__bridge CGImageRef)(self.imageLayer.contents);
}

-(void)setContents:(CGImageRef)image {
    if(self.animationDuration == 0.0f) self.imageLayer.contents = (__bridge id)image;
    else [self.imageLayer animateContents:image];
}

-(void)setImage:(C4Image *)image {
    _originalImage = image.UIImage;
    [self setProperties];
    [self setContents:_originalImage.CGImage];
}

#pragma mark Filter Basics
-(void)startFiltering {
    _multipleFilterEnabled = YES;
}

-(CIFilter *)prepareFilterWithName:(NSString *)filterName {
    @autoreleasepool {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setDefaults];
        CIImage *inputImage = _output == nil ? self.CIImage : _output;
        [filter setValue:inputImage forKey:@"inputImage"];
        return filter;
    }
}

-(void)renderFilteredImage {
    if(_multipleFilterEnabled == YES && _output != nil) {
        [self renderImageWithFilterName:@"MultipleFilter"];
    }
}

-(void)renderImageWithFilterName:(NSString *)filterName {
    if(self.showsActivityIndicator) [_filterIndicator startAnimating];
    dispatch_async(self.filterQueue, ^{
        //applies create the image based on its original size, contents will automatically scale
        CGImageRef filteredImage = [self.filterContext createCGImage:_output fromRect:(CGRect){CGPointZero,self.originalSize}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setContents:filteredImage];
            NSString *notificationName = [filterName stringByAppendingString:@"Complete"];
            [self postNotification:notificationName];
            _multipleFilterEnabled = NO;
            _output = nil;
            if(self.showsActivityIndicator) [_filterIndicator stopAnimating];
        });
    });
}

-(CIContext *)filterContext {
    if(_filterContext == nil) _filterContext = [CIContext contextWithOptions:nil];
    return _filterContext;
}

-(dispatch_queue_t)filterQueue {
    if(_filterQueue == nil) {
        const char *label = [[@"FILTER_QUEUE_" stringByAppendingString:[self description]]UTF8String];
        _filterQueue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
    }
    return _filterQueue;
}

#pragma mark Old Filters
-(void)additionComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAdditionCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorBurn:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorBurnBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorControlSaturation:(CGFloat)saturation brightness:(CGFloat)brightness contrast:(CGFloat)contrast {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorControls"];
        [filter setValue:@(saturation) forKey:@"inputSaturation"];
        [filter setValue:@(brightness) forKey:@"inputBrightness"];
        [filter setValue:@(contrast) forKey:@"inputContrast"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorDodge:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorDodgeBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorInvert {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorInvert"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorMatrix:(UIColor *)color bias:(CGFloat)bias {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorMatrix"];
        
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        [filter setValue:[CIVector vectorWithX:red Y:0 Z:0 W:0] forKey:@"inputRVector"];
        [filter setValue:[CIVector vectorWithX:0 Y:green Z:0 W:0] forKey:@"inputGVector"];
        [filter setValue:[CIVector vectorWithX:0 Y:0 Z:blue W:0] forKey:@"inputBVector"];
        [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:alpha] forKey:@"inputAVector"];
        [filter setValue:[CIVector vectorWithX:bias Y:bias Z:bias W:bias] forKey:@"inputBiasVector"];
        
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorMonochrome:(UIColor *)color inputIntensity:(CGFloat)intensity {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorMonochrome"];
        CGFloat rgba[4];
        [color getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
        [filter setValue:[CIColor colorWithRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]] forKey:@"inputColor"];
        [filter setValue:@(intensity) forKey:@"inputIntensity"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)darkenBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDarkenBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)differenceBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDifferenceBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)exclusionBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIExclusionBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)exposureAdjust:(CGFloat)adjustment {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIExposureAdjust"];
        [filter setValue:@(adjustment) forKey:@"inputEV"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)falseColor:(UIColor *)color1 color2:(UIColor *)color2 {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIFalseColor"];
        [filter setValue:color1.CIColor forKey:@"inputColor0"];
        [filter setValue:color2.CIColor forKey:@"inputColor1"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)gammaAdjustment:(CGFloat)adjustment {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIGammaAdjust"];
        [filter setValue:@(adjustment) forKey:@"inputPower"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)hardLightBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHardLightBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)highlightShadowAdjust:(CGFloat)highlightAmount shadowAmount:(CGFloat)shadowAmount {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHighlightShadowAdjust"];
        [filter setValue:@(highlightAmount) forKey:@"inputHighlightAmount"];
        [filter setValue:@(shadowAmount) forKey:@"inputShadowAmount"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)hueAdjust:(CGFloat)angle {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHueAdjust"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)hueBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHueBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)lightenBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CILightenBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)luminosityBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CILuminosityBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)maximumComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMaximumCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)minimumComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMinimumCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)multiplyBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMultiplyBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)multiplyComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMultiplyCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)overlayBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIOverlayBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)saturationBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISaturationBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)screenBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIScreenBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sepiaTone:(CGFloat)intensity {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISepiaTone"];
        [filter setValue:@(intensity) forKey:@"inputIntensity"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)softLightBlend:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISoftLightBlendMode"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sourceAtopComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISourceAtopCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sourceInComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISourceInCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sourceOutComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISourceOutCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sourceOverComposite:(C4Image *)backgroundImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISourceOverCompositing"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)straighten:(CGFloat)angle {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIStraightenFilter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)tempartureAndTint:(CGSize)neutral target:(CGSize)targetNeutral {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CITemperatureAndTint"];
        [filter setValue:[CIVector vectorWithX:neutral.width Y:neutral.height] forKey:@"inputNeutral"];
        [filter setValue:[CIVector vectorWithX:targetNeutral.width Y:targetNeutral.height] forKey:@"inputTargetNeutral"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)toneCurve:(CGPoint *)pointArray {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIToneCurve"];
        [filter setValue:[CIVector vectorWithCGPoint:pointArray[0]] forKey:@"inputPoint0"];
        [filter setValue:[CIVector vectorWithCGPoint:pointArray[1]] forKey:@"inputPoint1"];
        [filter setValue:[CIVector vectorWithCGPoint:pointArray[2]] forKey:@"inputPoint2"];
        [filter setValue:[CIVector vectorWithCGPoint:pointArray[3]] forKey:@"inputPoint3"];
        [filter setValue:[CIVector vectorWithCGPoint:pointArray[4]] forKey:@"inputPoint4"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)vibranceAdjust:(CGFloat)amount {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIVibrance"];
        [filter setValue:@(amount) forKey:@"inputAmount"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)whitePointAdjust:(UIColor *)color {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIWhitePointAdjust"];
        [filter setValue:color.CIColor forKey:@"inputColor"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

#pragma mark New Filters
-(void)affineClamp:(CGAffineTransform)transform {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAffineClamp"];
        [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)]
                  forKey:@"inputTransform"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)affineTile:(CGAffineTransform)transform {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAffineTile"];
        [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)]
                  forKey:@"inputTransform"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
};

-(void)affineTransform:(CGAffineTransform)transform {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAffineTransform"];
        [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)]
                  forKey:@"inputTransform"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(C4Image *)areaAverage:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAreaAverage"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;

        CIImage *image = filter.outputImage;
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef filteredImage = [context createCGImage:image fromRect:CGRectMake(0, 0, 10, 10)];
        C4Image *averageImage = [[C4Image alloc] initWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return averageImage;
    }
}

-(void)areaHistogram:(CGRect)area count:(NSInteger)width scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAreaHistogram"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        [filter setValue:@(width) forKey:@"inputCount"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)areaMaximum:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAreaMaximum"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)areaMaximumAlpha:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAreaMaximumAlpha"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)areaMinimum:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAreaMinimum"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)areaMinimumAlpha:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIAreaMinimumAlpha"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)blendWithMask:(C4Image *)backgroundImage mask:(C4Image *)maskImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIBlendWithMask"];
        [filter setValue:backgroundImage.CIImage forKey:@"inputBackgroundImage"];
        [filter setValue:maskImage.CIImage forKey:@"inputMaskImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)bloom:(CGFloat)radius intensity:(CGFloat)intensity {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIBloom"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(intensity) forKey:@"inputIntensity"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)boxBlur:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIBoxBlur"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)bumpDistortion:(CGPoint)center radius:(CGFloat)radius scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIBumpDistortion"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)bumpDistortionLinear:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIBumpDistortionLinear"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)circleSplashDistortion:(CGPoint)center radius:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CICircleSplashDistortion"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)circularScreen:(CGPoint)center width:(CGFloat)width sharpness:(CGFloat)sharpness {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CICircularScreen"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)circularWrap:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CICircularWrap"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}
-(void)halftoneCMYK:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle sharpness:(CGFloat)sharpness gcr:(CGFloat)gcr ucr:(CGFloat)ucr {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CICMYKHalftone"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        [filter setValue:@(gcr) forKey:@"inputGCR"];
        [filter setValue:@(ucr) forKey:@"inputUCR"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorCube:(CGFloat)dimension cubeData:(NSData *)data {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorCube"];
        [filter setValue:@(dimension) forKey:@"inputCubeDimension"];
        [filter setValue:data forKey:@"inputCubeData"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorMap:(C4Image *)gradientImage {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorMap"];
        [filter setValue:gradientImage.CIImage forKey:@"inputGradientImage"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)colorPosterize:(CGFloat)levels {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColorPosterize"];
        [filter setValue:@(levels) forKey:@"inputLevels"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)columnAverage:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIColumnAverage"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)comicEffect {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIComicEffect"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)crop:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CICrop"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputRectangle"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)crystallize:(CGFloat)radius center:(CGPoint)center {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CICrystallize"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)depthOfField:(CGPoint)point1 point2:(CGPoint)point2 saturation:(CGFloat)saturation maskRadius:(CGFloat)maskRadius maskIntensity:(CGFloat)maskIntensity blurRadius:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDepthOfField"];
        point1.y = self.height - point1.y;
        [filter setValue:[CIVector vectorWithCGPoint:point1] forKey:@"inputPoint1"];
        point2.y = self.height - point2.y;
        [filter setValue:[CIVector vectorWithCGPoint:point2] forKey:@"inputPoint2"];
        [filter setValue:@(saturation) forKey:@"inputSaturation"];
        [filter setValue:@(maskRadius) forKey:@"inputUnsharpMaskRadius"];
        [filter setValue:@(maskIntensity) forKey:@"inputUnsharpMaskIntensity"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)discBlur:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDiscBlur"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)displacementDistortion:(C4Image *)displacementImage scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDisplacementDistortion"];
        [filter setValue:displacementImage.CIImage forKey:@"inputDisplacementImage"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)dotScreen:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDotScreen"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)droste:(CGPoint)inset1 inset2:(CGPoint)inset2 strandRadius:(CGFloat)radius periodicity:(CGFloat)periodicity rotation:(CGFloat)rotation zoom:(CGFloat)zoom {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIDroste"];
        inset1.y = self.height - inset1.y;
        [filter setValue:[CIVector vectorWithCGPoint:inset1] forKey:@"inputInsetPoint0"];
        inset2.y = self.height - inset2.y;
        [filter setValue:[CIVector vectorWithCGPoint:inset2] forKey:@"inputInsetPoint1"];
        [filter setValue:@(radius) forKey:@"inputStrands"];
        [filter setValue:@(periodicity) forKey:@"inputPeriodicity"];
        [filter setValue:@(rotation) forKey:@"inputRotation"];
        [filter setValue:@(zoom) forKey:@"inputZoom"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}
-(void)edges:(CGFloat)intensity {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIEdges"];
        [filter setValue:@(intensity) forKey:@"inputIntensity"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)edgeWork:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIEdgeWork"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)eightFoldReflectedTile:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIEightFoldReflectedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)fourFoldReflectedTile:(CGPoint)center angle:(CGFloat)angle acuteAngle:(CGFloat)acuteAngle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIFourFoldReflectedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(acuteAngle) forKey:@"inputAcuteAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)fourFoldRotatedTile:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIFourFoldRotatedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)fourFoldTranslatedTile:(CGPoint)center angle:(CGFloat)angle acuteAngle:(CGFloat)acuteAngle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIFourFoldTranslatedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(acuteAngle) forKey:@"inputAcuteAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)gaussianBlur:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIGaussianBlur"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)glassDistortion:(C4Image *)texture center:(CGPoint)center scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIGlassDistortion"];
        [filter setValue:texture.CIImage forKey:@"inputTexture"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)glassLozenge:(CGPoint)point1 point2:(CGPoint)point2 radius:(CGFloat)radius refraction:(CGFloat)refraction {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIGlassLozenge"];
        point1.y = self.height - point1.y;
        [filter setValue:[CIVector vectorWithCGPoint:point1] forKey:@"inputPoint0"];
        point2.y = self.height - point2.y;
        [filter setValue:[CIVector vectorWithCGPoint:point2] forKey:@"inputPoint1"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(refraction) forKey:@"inputRefraction"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)glideReflectedTile:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIGlideReflectedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)gloom:(CGFloat)radius intensity:(CGFloat)intensity {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIGloom"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(intensity) forKey:@"inputIntensity"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)hatchedScreen:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHatchedScreen"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)heightShieldFromMask:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHeightSheildFromMask"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)hexagonalPixellate:(CGPoint)center scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHexagonalPixellate"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)holeDistortion:(CGPoint)center radius:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIHoleDistortion"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)kaleidescope:(CGFloat)count center:(CGPoint)center angle:(CGFloat)angle {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIKaleidescope"];
        [filter setValue:@(count) forKey:@"inputCount"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)lanczosScaleTransform:(CGFloat)scale aspectRatio:(CGFloat)ratio {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CILanczosScaleTransform"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        [filter setValue:@(ratio) forKey:@"inputAspectRatio"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)lightTunnel:(CGPoint)center rotation:(CGFloat)rotation radius:(CGFloat)radius {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CILightTunnel"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(rotation) forKey:@"inputRotation"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)lineOverlay:(CGFloat)noiseLevel sharpness:(CGFloat)sharpness edgeIntensity:(CGFloat)edgeIntensity threshold:(CGFloat)threshold contrast:(CGFloat)contrast {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CILightTunnel"];
        [filter setValue:@(noiseLevel) forKey:@"inputRotation"];
        [filter setValue:@(sharpness) forKey:@"inputRadius"];
        [filter setValue:@(edgeIntensity) forKey:@"inputRotation"];
        [filter setValue:@(threshold) forKey:@"inputRadius"];
        [filter setValue:@(contrast) forKey:@"inputRotation"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)lineScreen:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness{
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CILineScreen"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)maskToAlpha {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMaskToAlpha"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)maximumComponent {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMaximumComponent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)medianFilter {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMedianFilter"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)minimumComponent {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMinimumComponent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)motionBlur:(CGFloat)radius angle:(CGFloat)angle {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIMotionBlur"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)noiseRedution:(CGFloat)level sharpness:(CGFloat)sharpness {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CINoiseReduction"];
        [filter setValue:@(level) forKey:@"inputLevel"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)opTile:(CGPoint)center scale:(CGFloat)scale angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIOpTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)parallelogramTile:(CGPoint)center angle:(CGFloat)angle acuteAngle:(CGFloat)acuteAngle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIParallelogramTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(acuteAngle) forKey:@"inputAcuteAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)perspectiveTile:(CGPoint *)points {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIParallelogramTile"];
        for(int i = 0 ; i < 4; i++) points[i].y = self.height - points[i].y;
        [filter setValue:[CIVector vectorWithCGPoint:points[0]] forKey:@"inputTopLeft"];
        [filter setValue:[CIVector vectorWithCGPoint:points[1]] forKey:@"inputTopRight"];
        [filter setValue:[CIVector vectorWithCGPoint:points[2]] forKey:@"inputBottomRight"];
        [filter setValue:[CIVector vectorWithCGPoint:points[3]] forKey:@"inputBottomLeft"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)perspectiveTransform:(CGPoint *)points {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIPerspectiveTransform"];
        for(int i = 0; i < 4; i++) points[i].y = self.height - points[i].y;
        [filter setValue:[CIVector vectorWithCGPoint:points[0]] forKey:@"inputTopLeft"];
        [filter setValue:[CIVector vectorWithCGPoint:points[1]] forKey:@"inputTopRight"];
        [filter setValue:[CIVector vectorWithCGPoint:points[2]] forKey:@"inputBottomRight"];
        [filter setValue:[CIVector vectorWithCGPoint:points[3]] forKey:@"inputBottomLeft"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)pinchDistortion:(CGPoint)center radius:(CGFloat)radius scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIPinchDistortion"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)pixellate:(CGPoint)center scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIPixellate"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)pointillize:(CGFloat)radius center:(CGPoint)center {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIPointillize"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)rowAverage:(CGRect)area {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIRowAverage"];
        [filter setValue:[NSValue valueWithCGRect:area] forKey:@"inputExtent"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)shadedMaterial:(C4Image *)shadingImage scale:(CGFloat)scale {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CIShadedMaterial"];
        [filter setValue:shadingImage.CIImage forKey:@"inputShadingImage"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sharpenLuminance:(CGFloat)sharpness {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISharpenLuminance"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sixFoldReflectedTile:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISixFoldReflectedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)sixFoldRotatedTile:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISixFoldRotatedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)spotColor:(NSArray *)colorsets closenessAndContrast:(CGFloat *)values {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CISpotColor"];
        [filter setValue:((UIColor *)colorsets[0]).CIColor forKey:@"inputCenterColor1"];
        [filter setValue:((UIColor *)colorsets[1]).CIColor forKey:@"inputReplacementColor1"];
        [filter setValue:@(values[0]) forKey:@"inputCloseness1"];
        [filter setValue:@(values[1]) forKey:@"inputContrast1"];
        [filter setValue:((UIColor *)colorsets[2]).CIColor forKey:@"inputCenterColor2"];
        [filter setValue:((UIColor *)colorsets[3]).CIColor forKey:@"inputReplacementColor2"];
        [filter setValue:@(values[2]) forKey:@"inputCloseness2"];
        [filter setValue:@(values[3]) forKey:@"inputContrast2"];
        [filter setValue:((UIColor *)colorsets[4]).CIColor forKey:@"inputCenterColor3"];
        [filter setValue:((UIColor *)colorsets[5]).CIColor forKey:@"inputReplacementColor3"];
        [filter setValue:@(values[4]) forKey:@"inputCloseness3"];
        [filter setValue:@(values[5]) forKey:@"inputContrast3"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}
-(void)spotLight:(C4Vector *)position lightPointsAt:(C4Vector *)spot brightness:(CGFloat)brightness concentration:(CGFloat)concentration color:(UIColor *)color {
    CIFilter *filter = [self prepareFilterWithName:@"CISpotLight"];
    [filter setValue:[CIVector vectorWithX:position.x Y:position.y Z:position.z] forKey:@"inputLightPosition"];
    [filter setValue:[CIVector vectorWithX:spot.x Y:spot.y Z:spot.z] forKey:@"inputLightPointsAt"];
    [filter setValue:@(brightness) forKey:@"inputBrightness"];
    [filter setValue:@(concentration) forKey:@"inputConcentration"];
    [filter setValue:color.CIColor forKey:@"inputColor"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)stretchCrop:(CGSize)size cropAmount:(CGFloat)cropAmount stretchAmount:(CGFloat)stretchAmount {
    CIFilter *filter = [self prepareFilterWithName:@"CIStretchCrop"];
    [filter setValue:[NSValue valueWithCGSize:size] forKey:@"inputSize"];
    [filter setValue:@(cropAmount) forKey:@"inputCropAmount"];
    [filter setValue:@(stretchAmount) forKey:@"inputCenterStretchAmount"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)torusLensDistortion:(CGPoint)center radius:(CGFloat)radius width:(CGFloat)width refraction:(CGFloat)refraction {
    CIFilter *filter = [self prepareFilterWithName:@"CITorusLensDistortion"];
    [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
    [filter setValue:@(radius) forKey:@"inputRadius"];
    [filter setValue:@(width) forKey:@"inputWidth"];
    [filter setValue:@(refraction) forKey:@"inputRefraction"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)triangleKaleidescope:(CGPoint)point size:(CGFloat)size rotation:(CGFloat)rotation decay:(CGFloat)decay {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CITriangleKaleidoscope"];
        point.y = self.height - point.y;
        [filter setValue:[CIVector vectorWithCGPoint:point] forKey:@"inputPoint"];
        [filter setValue:@(size) forKey:@"inputSize"];
        [filter setValue:@(rotation) forKey:@"inputRotation"];
        [filter setValue:@(decay) forKey:@"inputDecay"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)triangleTile:(CGPoint)center scale:(CGFloat)scale angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CITriangleTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(scale) forKey:@"inputScale"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)twelveFoldReflectedTile:(CGPoint)center angle:(CGFloat)angle width:(CGFloat)width {
    @autoreleasepool {
        CIFilter *filter = [self prepareFilterWithName:@"CITwelveFoldReflectedTile"];
        center.y = self.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(angle) forKey:@"inputAngle"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        _output = filter.outputImage;
        if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
        filter = nil;
    }
}

-(void)twirlDistortion:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle {
    CIFilter *filter = [self prepareFilterWithName:@"CITwirlDistortion"];
    center.y = self.height - center.y;
    [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
    [filter setValue:@(radius) forKey:@"inputRadius"];
    [filter setValue:@(angle) forKey:@"inputAngle"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)unsharpMask:(CGFloat)radius intensity:(CGFloat)intensity {
    CIFilter *filter = [self prepareFilterWithName:@"CIUnsharpMask"];
    [filter setValue:@(radius) forKey:@"inputRadius"];
    [filter setValue:@(intensity) forKey:@"inputIntensity"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)vignette:(CGFloat)radius intensity:(CGFloat)intensity {
    CIFilter *filter = [self prepareFilterWithName:@"CIVignette"];
    [filter setValue:@(radius) forKey:@"inputRadius"];
    [filter setValue:@(intensity) forKey:@"inputIntensity"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)vortexDistortion:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle {
    CIFilter *filter = [self prepareFilterWithName:@"CIVortexDistortion"];
    center.y = self.height - center.y;
    [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
    [filter setValue:@(radius) forKey:@"inputRadius"];
    [filter setValue:@(angle) forKey:@"inputAngle"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

-(void)zoomBlur:(CGPoint)center amount:(CGFloat)amount {
    CIFilter *filter = [self prepareFilterWithName:@"CIZoomBlur"];
    center.y = self.height - center.y;
    [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
    [filter setValue:@(amount) forKey:@"inputAmount"];
    _output = filter.outputImage;
    if(_multipleFilterEnabled == NO) [self renderImageWithFilterName:filter.name];
    filter = nil;
}

#pragma mark Generators
+(C4Image *)checkerboard:(CGSize)size center:(CGPoint)center color1:(UIColor *)color1 color2:(UIColor *)color2 squareWidth:(CGFloat)width sharpness:(CGFloat)sharpness {
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CICheckerboardGenerator"];
        [filter setDefaults];
        center.y = size.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:color1.CIColor forKey:@"inputColor0"];
        [filter setValue:color2.CIColor forKey:@"inputColor1"];
        [filter setValue:@(width) forKey:@"inputWidth"];
        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
        CIImage *image = filter.outputImage;
        CGImageRef filteredImage = [context createCGImage:image fromRect:(CGRect){CGPointZero,size}];
        filter = nil;
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
}

+(C4Image *)constantColor:(CGSize)size color:(UIColor *)color{
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CIConstantColorGenerator"];
        [filter setDefaults];
        [filter setValue:color.CIColor forKey:@"inputColor"];
        CGImageRef filteredImage = [context createCGImage:filter.outputImage
                                                 fromRect:(CGRect){CGPointZero,size}];
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
};

+(C4Image *)lenticularHalo:(CGSize)size center:(CGPoint)center color:(UIColor *)color haloRadius:(CGFloat)radius haloWidth:(CGFloat)haloWidth haloOverlap:(CGFloat)overlap striationStrength:(CGFloat)strength striationContrast:(CGFloat)contrast time:(CGFloat)time{
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CILenticularHaloGenerator"];
        [filter setDefaults];
        center.y = size.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:color.CIColor forKey:@"inputColor"];
        [filter setValue:@(radius) forKey:@"inputHaloRadius"];
        [filter setValue:@(haloWidth) forKey:@"inputHaloWidth"];
        [filter setValue:@(overlap) forKey:@"inputHaloOverlap"];
        [filter setValue:@(strength) forKey:@"inputStriationStrength"];
        [filter setValue:@(contrast) forKey:@"inputStriationContrast"];
        [filter setValue:@(time) forKey:@"inputTime"];
        CIImage *image = filter.outputImage;
        CGImageRef filteredImage = [context createCGImage:image fromRect:(CGRect){CGPointZero,size}];
        filter = nil;
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
};

+(C4Image *)random:(CGSize)size{
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CIRandomGenerator"];
        [filter setDefaults];
        CGImageRef filteredImage = [context createCGImage:filter.outputImage
                                                 fromRect:(CGRect){CGPointZero,size}];
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
}

+(C4Image *)gaussianGradient:(CGSize)size center:(CGPoint)center innerColor:(UIColor *)innerColor outerColor:(UIColor *)outerColor radius:(CGFloat)radius {
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianGradient"];
        [filter setDefaults];
        center.y = size.height - center.y;
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:innerColor.CIColor forKey:@"inputColor0"];
        [filter setValue:outerColor.CIColor forKey:@"inputColor1"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        CIImage *image = filter.outputImage;
        CGImageRef filteredImage = [context createCGImage:image fromRect:(CGRect){CGPointZero,size}];
        filter = nil;
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
    return nil;
}

+(C4Image *)linearGradient:(CGSize)size startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint startColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CILinearGradient"];
        [filter setDefaults];
        startPoint.y = size.height - startPoint.y; //inverting for Core Image Coordinates
        [filter setValue:[CIVector vectorWithCGPoint:startPoint] forKey:@"inputPoint0"];
        endPoint.y = size.height - endPoint.y; //inverting for Core Image Coordinates
        [filter setValue:[CIVector vectorWithCGPoint:endPoint] forKey:@"inputPoint1"];
        [filter setValue:startColor.CIColor forKey:@"inputColor0"];
        [filter setValue:endColor.CIColor forKey:@"inputColor1"];
        CIImage *image = filter.outputImage;
        CGImageRef filteredImage = [context createCGImage:image fromRect:(CGRect){CGPointZero,size}];
        filter = nil;
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
    return nil;
}

+(C4Image *)radialGradient:(CGSize)size center:(CGPoint)center innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius innerColor:(UIColor *)innerColor outerColor:(UIColor *)outerColor {
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIFilter *filter = [CIFilter filterWithName:@"CIRadialGradient"];
        [filter setDefaults];
        center.y = size.height - center.y; //inverting for Core Image Coordinates
        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
        [filter setValue:@(innerRadius) forKey:@"inputRadius0"];
        [filter setValue:@(outerRadius) forKey:@"inputRadius1"];
        [filter setValue:innerColor.CIColor forKey:@"inputColor0"];
        [filter setValue:outerColor.CIColor forKey:@"inputColor1"];
        CIImage *image = filter.outputImage;
        CGImageRef filteredImage = [context createCGImage:image fromRect:(CGRect){CGPointZero,size}];
        filter = nil;
        UIImage *uiimg = [UIImage imageWithCGImage:filteredImage];
        CFRelease(filteredImage);
        return [[C4Image alloc] initWithUIImage:uiimg];
    }
}

+(NSArray *)availableFilters {
    NSArray *filterCategories = @[
    kCICategoryDistortionEffect,
    kCICategoryGeometryAdjustment,
    kCICategoryCompositeOperation,
    kCICategoryHalftoneEffect,
    kCICategoryColorAdjustment,
    kCICategoryColorEffect,
    kCICategoryTransition,
    kCICategoryTileEffect,
    kCICategoryGenerator,
    kCICategoryReduction,
    kCICategoryGradient,
    kCICategoryStylize,
    kCICategorySharpen,
    kCICategoryBlur,
    kCICategoryVideo,
    kCICategoryStillImage,
    kCICategoryInterlaced,
    kCICategoryNonSquarePixels,
    kCICategoryHighDynamicRange ,
    kCICategoryBuiltIn
    ];
    
    NSMutableSet *allFilters = [[NSMutableSet alloc] initWithCapacity:0];
    
    for(NSString *s in filterCategories) [allFilters addObjectsFromArray:[CIFilter filterNamesInCategory:s]];
    NSArray *sortedFilterList = [[allFilters allObjects] sortedArrayUsingFunction:basicSort context:NULL];
    return sortedFilterList;
}

//+(C4Image *)starShineGenerator:(CGSize)size center:(CGPoint)center color:(UIColor *)color radius:(CGFloat)radius crossScale:(CGFloat)scale crossAngle:(CGFloat)angle crossOpacity:(CGFloat)opacity crossWidth:(CGFloat)width epsilon:(CGFloat)epsilon{return nil;};
//
//+(C4Image *)stripes:(CGSize)size center:(CGPoint)center color1:(UIColor *)color1 color2:(UIColor *)color2 stripeWidth:(CGFloat)width sharpness:(CGFloat)sharpness{
//    @autoreleasepool {
//        CIContext *context = [CIContext contextWithOptions:nil];
//        CIFilter *filter = [CIFilter filterWithName:@"CIStripesGenerator"];
//        [filter setDefaults];
//        [filter setValue:[CIVector vectorWithCGPoint:center] forKey:@"inputCenter"];
//        [filter setValue:color1.CIColor forKey:@"inputColor0"];
//        [filter setValue:color2.CIColor forKey:@"inputColor1"];
//        [filter setValue:@(width) forKey:@"inputWidth"];
//        [filter setValue:@(sharpness) forKey:@"inputSharpness"];
//        CIImage *image = filter.outputImage;
//        CGImageRef filteredImage = [context createCGImage:image fromRect:(CGRect){CGPointZero,size}];
//        filter = nil;
//        return [[C4Image alloc] initWithCGImage:filteredImage];
//    }
//};
//+(C4Image *)sunbeams:(CGSize)size center:(CGPoint)center color:(UIColor *)color sunRadius:(CGFloat)sunRadius maxStriationRadius:(CGFloat)striationRadius striationStrength:(CGFloat)striationStrength striationContrast:(CGFloat)striationContrast time:(CGFloat)time{return nil;};

#pragma mark Animated Image 
+(C4Image *)animatedImageWithNames:(NSArray *)imageNames {
    C4Image *animImg = [[C4Image alloc] initAnimatedImageWithNames:imageNames];
    return animImg;
}

-(id)initAnimatedImageWithNames:(NSArray *)imageNames {
    self = [C4Image imageNamed:imageNames[0]];
    if(nil != self) {
        NSMutableArray *animatedImages = [[NSMutableArray alloc] initWithCapacity:0];
        for(int i = 0; i < [imageNames count]; i++) {
            NSString *name = imageNames[i];
            name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            UIImage *img = [UIImage imageNamed:name];
            [animatedImages addObject:img];
            img = nil; name = nil;
        }
        
        self.animationImages = animatedImages;
        animatedImages = nil;
        [self setProperties];
        _constrainsProportions = YES;
    }
    return  self;
}

-(void)setAnimationRepeatCount:(NSInteger)animationRepeatCount {
    self.imageView.animationRepeatCount = animationRepeatCount;
}

-(NSInteger)animationRepeatCount {
    return self.imageView.animationRepeatCount;
}

-(void)play {
    [self.imageView startAnimating];
}

-(void)pause {
    [self.imageView stopAnimating];
}

-(void)setAnimatedImageDuration:(CGFloat)animatedImageDuration {
    self.imageView.animationDuration = (NSTimeInterval)animatedImageDuration;
}

-(CGFloat)animatedImageDuration {
    return (CGFloat)self.imageView.animationDuration;
}

-(void)setAnimationImages:(NSArray *)animationImages {
    self.imageView.animationImages = animationImages;
}

-(NSArray *)animationImages {
    return self.imageView.animationImages;
}

-(BOOL)isAnimating {
    return self.imageView.isAnimating;
}

-(void)setShowsActivityIndicator:(BOOL)showsActivityIndicator {
    _showsActivityIndicator = showsActivityIndicator;
    if(showsActivityIndicator == NO) {
        [_filterIndicator stopAnimating];
        _filterIndicator.hidden = YES;
    }
}

#pragma mark Pixels
-(void)loadPixelData {
    const char *queueName = [@"pixelDataQueue" UTF8String];
    __block dispatch_queue_t pixelDataQueue = dispatch_queue_create(queueName,  DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(pixelDataQueue, ^{
        NSUInteger width = CGImageGetWidth(self.CGImage);
        NSUInteger height = CGImageGetHeight(self.CGImage);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        _bytesPerPixel = 4;
        _bytesPerRow = _bytesPerPixel * width;
        free(_rawData);
        _rawData = malloc(height * _bytesPerRow);
        
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(_rawData, width, height, bitsPerComponent, _bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
        CGContextRelease(context);
        _pixelDataLoaded = YES;
        [self postNotification:@"pixelDataWasLoaded"];
        pixelDataQueue = nil;
    });
}

-(UIColor *)colorAt:(CGPoint)point {
    if(_pixelDataLoaded == NO) {
        C4Log(@"You must first load pixel data");
    } else  if ([self pointInside:point withEvent:nil]) {
        if(_rawData == nil) {
            [self loadPixelData];
        }
        NSUInteger byteIndex = (NSUInteger)(_bytesPerPixel * point.x + _bytesPerRow * point.y);
        NSInteger r, g, b, a;
        r = _rawData[byteIndex];
        g = _rawData[byteIndex + 1];
        b = _rawData[byteIndex + 2];
        a = _rawData[byteIndex + 3];
        
        return [UIColor colorWithRed:RGBToFloat(r) green:RGBToFloat(g) blue:RGBToFloat(b) alpha:RGBToFloat(a)];
    }
    return [UIColor clearColor];
}

-(C4Vector *)rgbVectorAt:(CGPoint)point {
    if(_pixelDataLoaded == NO) {
        C4Log(@"You must first load pixel data");
    } else if([self pointInside:point withEvent:nil]) {
        if(self.pixelDataLoaded == NO) {
            [self loadPixelData];
        }
        NSUInteger byteIndex = (NSUInteger)(_bytesPerPixel * point.x + _bytesPerRow * point.y);
        CGFloat r, g, b;
        r = _rawData[byteIndex];
        g = _rawData[byteIndex + 1];
        b = _rawData[byteIndex + 2];
        return [C4Vector vectorWithX:r Y:g Z:b];
    }
    return [C4Vector vectorWithX:-1 Y:-1 Z:-1];
}

#pragma mark Copying
-(C4Image *)copyWithZone:(NSZone *)zone {
    return [[C4Image allocWithZone:zone] initWithImage:self];
}

#pragma mark Default Style
+(C4Image *)defaultStyle {
    return (C4Image *)[C4Image appearance];
}

#pragma mark Layer Access Overrides
-(C4Layer *)imageLayer {
    return self.imageView.imageLayer;
}

-(C4Layer *)layer {
    return self.imageLayer;
}

@end