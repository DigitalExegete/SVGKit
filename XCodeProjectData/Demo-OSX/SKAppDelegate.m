//
//  SKAppDelegate.m
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKSVGObject.h"

@interface SKAppDelegate ()

@property (readwrite, retain) NSArray *svgArray;


@end

@implementation SKAppDelegate

- (void)dealloc
{
    self.svgArray = nil;
	self.svgImage = nil;
	
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[SVGKit enableLogging];
	
	NSMutableArray *tmpArray = [NSMutableArray array];
	NSString *pname;
		
	//NSDirectoryEnumerationOptions
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[[NSBundle mainBundle] resourcePath]];

	@autoreleasepool {
		while (pname = [dirEnum nextObject]) {
			//Only look for SVGs that are in the resources folder, no deeper.
			if ([[[dirEnum fileAttributes] objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
				[dirEnum skipDescendants];
				continue;
			}
			if (NSOrderedSame == [[pname pathExtension] caseInsensitiveCompare:@"svg"]) {
				[tmpArray addObject:[[[SKSVGBundleObject alloc] initWithName:pname] autorelease]];
			}
		}
		
		[tmpArray addObject:[[SKSVGURLObject alloc] initWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg"]]];
		
		[tmpArray sortUsingComparator:^NSComparisonResult(id rhs, id lhs) {
			NSString *rhsString = [rhs fileName];
			NSString *lhsString = [lhs fileName];
			NSComparisonResult result = [rhsString localizedStandardCompare:lhsString];
			return result;
		}];
		
		self.svgArray = [NSArray arrayWithArray:tmpArray];
	}
}

@end
