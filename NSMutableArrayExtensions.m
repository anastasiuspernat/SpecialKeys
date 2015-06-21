//
//  NSMutableArrayExtensions.m
//  SpecialKeys
//
//  Created by Anastasius on 28/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArrayExtensions.h"


@implementation NSMutableArray (MoveArray)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [obj retain];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
        [obj release];
    }
}
@end