#import "SVGKSource.h"
#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"


@implementation SVGKSource

@synthesize svgLanguageVersion;
@synthesize stream;

- (id)initWithInputSteam:(NSInputStream*)s {
	self = [super init];
	if (!self)
		return nil;
	
	self.stream = s;
	return self;
}

+ (SVGKSource*)sourceFromFilename:(NSString*)p
{
	return [SVGKSourceLocalFile sourceFromFilename:p];
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u
{
	return [SVGKSourceURL sourceFromURL:u];
}

+ (SVGKSource*)sourceFromData:(NSData*)data {
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	
	SVGKSource* s = [[[SVGKSource alloc] initWithInputSteam:stream] autorelease];
	return s;
}

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString {
	return [self sourceFromData:[rawString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)dealloc {
	self.svgLanguageVersion = nil;
	self.stream = nil;
	[super dealloc];
}

@end
