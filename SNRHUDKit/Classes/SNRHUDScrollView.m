//
//  SNRHUDScrollView.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-23.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDScrollView.h"

@implementation SNRHUDScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setScrollerKnobStyle:NSScrollerKnobStyleLight];
    }
    return self;
}

@end
