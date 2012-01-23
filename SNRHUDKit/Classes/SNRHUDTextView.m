//
//  SNRHUDTextView.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-23.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDTextView.h"
#import "NSBezierPath+MCAdditions.h"

#define SNRTextViewTextColor                   [NSColor whiteColor]
#define SNRTextViewFont                        [NSFont systemFontOfSize:11.f]
#define SNRTextViewSelectedTextBackgroundColor [NSColor darkGrayColor]

#define SNRTextViewBackgroundColor             [NSColor colorWithDeviceWhite:0.000 alpha:0.150]
#define SNRTextViewInnerGlowColor              [NSColor colorWithDeviceWhite:0.000 alpha:0.300]
#define SNRTextViewInnerGlowOffset             NSMakeSize(0.f, 0.f)
#define SNRTextViewInnerGlowBlurRadius         3.f

#define SNRTextViewInnerShadowColor            [NSColor colorWithDeviceWhite:0.000 alpha:0.400]
#define SNRTextViewInnerShadowOffset           NSMakeSize(0.f, -1.f)
#define SNRTextViewInnerShadowBlurRadius       3.f

#define SNRTextViewDropShadowColor             [NSColor colorWithDeviceWhite:1.000 alpha:0.100]
#define SNRTextViewTextContainerInset          NSMakeSize(0.f, 2.f)

@implementation SNRHUDTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSScrollView *scrollView = [self enclosingScrollView];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setDrawsBackground:NO];
    [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    [scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    [scrollView setScrollerKnobStyle:NSScrollerKnobStyleLight];
    NSColor *textColor = SNRTextViewTextColor;
    [self setInsertionPointColor:textColor];
    [self setTextColor:textColor];
    [self setDrawsBackground:NO];
    [self setFont:SNRTextViewFont];
    [self setTextContainerInset:SNRTextViewTextContainerInset];
    NSMutableDictionary *dict = [[self selectedTextAttributes] mutableCopy];	
    [dict setObject:SNRTextViewSelectedTextBackgroundColor forKey:NSBackgroundColorAttributeName];
    [self setSelectedTextAttributes:dict];
}

- (void)drawViewBackgroundInRect:(NSRect)rect
{
    NSRect backgroundRect = [self visibleRect];
    backgroundRect.size.height -= 1.f;
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:backgroundRect];
    [SNRTextViewBackgroundColor set];
    [backgroundPath fill];
    NSShadow *innerGlow = [NSShadow new];
    [innerGlow setShadowColor:SNRTextViewInnerGlowColor];
    [innerGlow setShadowOffset:SNRTextViewInnerGlowOffset];
    [innerGlow setShadowBlurRadius:SNRTextViewInnerGlowBlurRadius];
    [backgroundPath fillWithInnerShadow:innerGlow];
    NSRect innerShadowRect = NSInsetRect(backgroundRect, -2.f, 0.f);
    innerShadowRect.size.height *= 2.f;
    NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRect:innerShadowRect];
    NSShadow *innerShadow = [NSShadow new];
    [innerShadow setShadowColor:SNRTextViewInnerShadowColor];
    [innerShadow setShadowOffset:SNRTextViewInnerShadowOffset];
    [innerShadow setShadowBlurRadius:SNRTextViewInnerShadowBlurRadius];
    [shadowPath fillWithInnerShadow:innerShadow];
    NSRect dropShadowRect = backgroundRect;
    dropShadowRect.origin.y = NSMaxY([self visibleRect]) - 1.f;
    [SNRTextViewDropShadowColor set];
    [NSBezierPath fillRect:dropShadowRect];
    [super drawViewBackgroundInRect:rect];
}

@end
