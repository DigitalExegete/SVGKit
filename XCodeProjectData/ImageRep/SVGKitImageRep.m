//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

//This will cause problems...
#define Comment AIFFComment
#include <CoreServices/CoreServices.h>
#undef Comment

#import "SVGKit.h"

#import "SVGKitImageRep.h"
#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"
#import "SVGKSourceString.h"

@interface SVGKitImageRep ()
- (id)initWithSVGSource:(SVGKSource*)theSource;

@property (nonatomic, strong, readonly) SVGKImage *image;
@end

@implementation SVGKitImageRep

@synthesize image = _image;

+ (NSArray *)imageUnfilteredFileTypes
{
	static NSArray *types = nil;
	if (types == nil) {
		types = @[@"svg"];
	}
	return types;
}

+ (NSArray *)imageUnfilteredTypes
{
	static NSArray *UTItypes = nil;
	if (UTItypes == nil) {
		UTItypes = @[@"public.svg-image"];
	}
	return UTItypes;
}

+ (NSArray *)imageUnfilteredPasteboardTypes
{
	/* TODO */
	return nil;
}

+ (BOOL)canInitWithData:(NSData *)d
{
	SVGKParseResult *parseResult = nil;
	@autoreleasepool {
		parseResult = [SVGKParser parseSourceUsingDefaultSVGKParser:[SVGKSource sourceFromData:d]];
	}
	if (parseResult == nil) {
		return NO;
	}
	if (parseResult.libXMLFailed || [parseResult.errorsFatal count]) {
		return NO;
	}
	return YES;
}

+ (NSImageRep *)imageRepWithData:(NSData *)d
{
	return [[self alloc] initWithData:d];
}

+ (void)load
{
	[NSImageRep registerImageRepClass:[SVGKitImageRep class]];
}

- (id)initWithData:(NSData *)theData
{
	return [self initWithSVGSource:[SVGKSource sourceFromData:theData]];
}

- (id)initWithURL:(NSURL *)theURL
{
	return [self initWithSVGSource:[SVGKSourceURL sourceFromURL:theURL]];
}

- (id)initWithPath:(NSString *)thePath
{
	return [self initWithSVGSource:[SVGKSourceLocalFile sourceFromFilename:thePath]];
}

- (id)initWithSVGString:(NSString *)theString
{
	return [self initWithSVGSource:[SVGKSourceString sourceFromContentsOfString:theString]];
}

- (id)initWithSVGSource:(SVGKSource*)theSource
{
	if (self = [super init]) {
		_image = [[SVGKImage alloc] initWithSource:theSource];
		if (_image == nil || _image.parseErrorsAndWarnings.libXMLFailed || [_image.parseErrorsAndWarnings.errorsFatal count]) {
			return nil;
		}
		if (![_image hasSize]) {
			_image.size = CGSizeMake(32, 32);
		}
		
		[self setColorSpaceName:NSCalibratedRGBColorSpace];
		[self setAlpha:YES];
		[self setBitsPerSample:0];
		[self setOpaque:NO];
		{
			NSSize renderSize = _image.size;
			[self setSize:renderSize];
			[self setPixelsHigh:ceil(renderSize.height)];
			[self setPixelsWide:ceil(renderSize.width)];
		}
	}
	return self;
}


- (BOOL)draw
{
	//Just in case someone resized the image rep.
	NSSize scaledSize = self.size;
	if (!CGSizeEqualToSize(_image.size, scaledSize)) {
		[_image scaleToFitInside:scaledSize];
	}
	
	NSImage *tmpImage = _image.NSImage;
	if (!tmpImage) {
		return NO;
	}
	
	NSRect imageRect;
	imageRect.size = self.size;
	imageRect.origin = NSZeroPoint;
	
	[tmpImage drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeCopy fraction:1];
	
	return YES;
}

@end
