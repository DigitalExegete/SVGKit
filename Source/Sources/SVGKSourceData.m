//
//  SVGKSourceData.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/24/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "SVGKSourceData.h"

@implementation SVGKSourceData

+ (SVGKSource*)sourceFromData:(NSData*)data {
	if ([data isKindOfClass:[NSMutableData class]]) {
		data = [[NSData alloc] initWithData:data];
	} 
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	
	SVGKSourceData* s = [[SVGKSourceData alloc] initWithInputSteam:stream];
	s.data = data;
	return s;
}

@end
