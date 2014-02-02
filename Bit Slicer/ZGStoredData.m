/*
 * Created by Mayur Pawashe on 2/2/14.
 *
 * Copyright (c) 2014 zgcoder
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ZGStoredData.h"
#import "ZGVirtualMemory.h"
#import "ZGVirtualMemoryHelpers.h"
#import "ZGSearchData.h"
#import "ZGRegion.h"
#import "ZGSearchProgress.h"
#import "ZGUtilities.h"

@interface ZGStoredData ()

@property (nonatomic) ZGMemoryMap processTask;
@property (nonatomic) NSArray *regions;

@end

@implementation ZGStoredData

+ (instancetype)storedDataFromProcessTask:(ZGMemoryMap)processTask
{
	NSMutableArray *regions = [[NSMutableArray alloc] init];
	
	for (ZGRegion *region in ZGRegionsForProcessTask(processTask))
	{
		void *bytes = NULL;
		ZGMemorySize size = region.size;
		
		if (ZGReadBytes(processTask, region.address, &bytes, &size))
		{
			region.bytes = bytes;
			region.size = size;
			
			[regions addObject:region];
		}
	}
	
	return [[self alloc] initWithProcessTask:processTask regions:regions];
}

- (id)initWithProcessTask:(ZGMemoryMap)processTask regions:(NSArray *)regions
{
	self = [super init];
	if (self != nil)
	{
		self.processTask = processTask;
		self.regions = regions;
	}
	return self;
}

- (void)dealloc
{
	for (ZGRegion *region in self.regions)
	{
		ZGFreeBytes(self.processTask, region.bytes, region.size);
	}
}

@end
