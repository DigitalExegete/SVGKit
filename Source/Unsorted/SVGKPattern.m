#import "SVGKPattern.h"

//Code taken from TBColor from https://github.com/zrxq/TBColor
static void ImagePatternCallback (void *imagePtr, CGContextRef ctx) {
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(imagePtr), CGImageGetHeight(imagePtr)), imagePtr);
}

static void ImageReleaseCallback(void *imagePtr) {
    CGImageRelease(imagePtr);
}

static CGColorRef CGColorMakeFromImage(CGImageRef CF_CONSUMED image) {
    static const CGPatternCallbacks callback = {0, ImagePatternCallback, ImageReleaseCallback};
    CGPatternRef pattern = CGPatternCreate(image, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), CGAffineTransformIdentity, CGImageGetWidth(image), CGImageGetHeight(image), kCGPatternTilingConstantSpacing, true, &callback);
    CGColorSpaceRef coloredPatternColorSpace = CGColorSpaceCreatePattern(NULL);
    CGFloat dummy = 1.0f;
    CGColorRef color = CGColorCreateWithPattern(coloredPatternColorSpace, pattern, &dummy);
    CGColorSpaceRelease(coloredPatternColorSpace);
    CGPatternRelease(pattern);
    return color;
}
//end taken code

@implementation SVGKPattern

@synthesize color;

+ (SVGKPattern*)patternWithCGImage:(CGImageRef)cgImage
{
	SVGKPattern *p = nil;
	
	CGImageRetain(cgImage);
	CGColorRef tmpColor = CGColorMakeFromImage(cgImage);
	p = [SVGKPattern patternWithCGColor:tmpColor];
	CGColorRelease(tmpColor);
	
	return p;
}

+ (SVGKPattern*)patternWithCGColor:(CGColorRef)cgColor
{
	SVGKPattern *p = [[SVGKPattern alloc] init];
	
	p.color = cgColor;
	
	return [p autorelease];
}

#if TARGET_OS_IPHONE

+ (SVGKPattern *)patternWithUIColor:(UIColor *)color
{
	return [self patternWithCGColor:[color CGColor]];
}

+ (SVGKPattern*)patternWithImage:(UIImage*)image
{
    UIColor* patternImage = [UIColor colorWithPatternImage:image];
    return [self patternWithUIColor:patternImage];
}

#else

+ (SVGKPattern*)patternWithImage:(NSImage*)image
{
	CGImageRef quartzImage = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
	SVGKPattern *p = [self patternWithCGImage:quartzImage];
	CGImageRelease(quartzImage);
	return p;
}


+ (SVGKPattern*)patternWithNSColor:(NSColor*)color
{
	if ([color respondsToSelector:@selector(CGColor)]) {
		return [self patternWithCGColor:color.CGColor];
	} else {
		if ([[color colorSpace] colorSpaceModel] == NSPatternColorSpaceModel) {
			return [self patternWithImage:[color patternImage]];
		} else {
			CGColorSpaceRef spaceRef = [[color colorSpace] CGColorSpace];
			CGFloat * components = malloc(sizeof(CGFloat) * [color numberOfComponents]);
			[color getComponents:components];
			CGColorRef tmpColor = CGColorCreate(spaceRef, components);
			free(components);
			SVGKPattern *p = [SVGKPattern patternWithCGColor:tmpColor];
			CGColorRelease(tmpColor);
			return p;
		}
	}
}

#endif

- (CGColorRef)CGColor
{
    return self.color;
}

- (void)dealloc
{
	self.color = NULL;
	
	[super dealloc];
}

- (void)finalize
{
	self.color = NULL;
	
	[super finalize];
}

@end
