//
//  SVGKitImageRep.m
//  SVGKit
//
//  Created by C.W. Betts on 12/5/12.
//
//

#import "SVGKitImageRep.h"
#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"

@interface SVGKitImageRep ()
- (id)initWithSVGSource:(SVGKSource*)theSource;

@end

@implementation SVGKitImageRep

@synthesize image = _image;

+ (NSArray *)imageUnfilteredFileTypes
{
	static NSArray *types = nil;
	if (types == nil) {
		types = [[NSArray alloc] initWithObjects:@"svg", nil];
	}
	return types;
}

+ (NSArray *)imageUnfilteredTypes
{
	static NSArray *UTItypes = nil;
	if (UTItypes == nil) {
		UTItypes = [[NSArray alloc] initWithObjects:@"public.svg-image", nil];
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
		NSInputStream* stream = [NSInputStream inputStreamWithData:d];
		[stream open];
		
		SVGKSource *sour = [[SVGKSource alloc] initWithInputSteam:stream];
		parseResult = [[SVGKParser parseSourceUsingDefaultSVGKParser:sour] retain];
		[sour release];
	}
	if (parseResult == nil) {
		return NO;
	}
	if (parseResult.libXMLFailed || [parseResult.errorsFatal count]) {
		[parseResult release];
		return NO;
	}
	[parseResult release];
	return YES;
}

+ (NSImageRep *)imageRepWithData:(NSData *)d
{
	return [[[self alloc] initWithData:d] autorelease];
}

+ (void)load
{
	[NSImageRep registerImageRepClass:[SVGKitImageRep class]];
}

- (id)initWithData:(NSData *)theData
{
	@autoreleasepool {
		NSInputStream* stream = [NSInputStream inputStreamWithData:theData];
		[stream open];
		SVGKSource *sour = [[[SVGKSource alloc] initWithInputSteam:stream] autorelease];
		return [self initWithSVGSource:sour];
	}
}

- (id)initWithURL:(NSURL *)theURL
{
	@autoreleasepool {
		return [self initWithSVGSource:[SVGKSourceURL sourceFromURL:theURL]];
	}
}

- (id)initWithPath:(NSString *)thePath
{
	@autoreleasepool {
		return [self initWithSVGSource:[SVGKSourceLocalFile sourceFromFilename:thePath]];
	}
}

- (id)initWithSVGSource:(SVGKSource*)theSource
{
	if (self = [super init]) {
		_image = [[SVGKImage alloc] initWithSource:theSource];
		if (_image == nil || _image.parseErrorsAndWarnings.libXMLFailed || [_image.parseErrorsAndWarnings.errorsFatal count]) {
			[self autorelease];
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

- (void)dealloc
{
	[_image release];
	
	[super dealloc];
}

- (BOOL)draw
{
	@autoreleasepool {
#if 0
		CGContextRef CGCtx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
		
		CGAffineTransform scaleTrans = CGContextGetCTM(CGCtx);
		
		//Just in case the image is in a differently-sized NSImage
		//should also work for retina displays
		_image.scale = MIN(scaleTrans.a, scaleTrans.d);
#endif
		[_image scaleToFitInside:self.size];

		NSImage *tmpImage = _image.NSImage;
		
		NSRect imageRect;
		imageRect.size = self.size;
		imageRect.origin = NSZeroPoint;
		
		[tmpImage drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeCopy fraction:1];
		
		return YES;
	}
}

@end
