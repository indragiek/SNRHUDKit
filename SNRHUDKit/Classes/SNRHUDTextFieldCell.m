//
//  SNRHUDTextFieldCell.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-23.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDTextFieldCell.h"
#import "NSBezierPath+MCAdditions.h"

#define SNRTextFieldTextColor                   [NSColor whiteColor]
#define SNRTextFieldSelectedTextBackgroundColor [NSColor darkGrayColor]

#define SNRTextFieldBackgroundColor             [NSColor colorWithDeviceWhite:0.000 alpha:0.150]
#define SNRTextFieldInnerGlowColor              [NSColor colorWithDeviceWhite:0.000 alpha:0.300]
#define SNRTextFieldInnerGlowOffset             NSMakeSize(0.f, 0.f)
#define SNRTextFieldInnerGlowBlurRadius         3.f

#define SNRTextFieldInnerShadowColor            [NSColor colorWithDeviceWhite:0.000 alpha:0.400]
#define SNRTextFieldInnerShadowOffset           NSMakeSize(0.f, -1.f)
#define SNRTextFieldInnerShadowBlurRadius       3.f

#define SNRTextFieldDropShadowColor             [NSColor colorWithDeviceWhite:1.000 alpha:0.100]

#define SNRTextFieldTextShadowColor             [NSColor colorWithDeviceWhite:0.000 alpha:0.750]
#define SNRTextFieldTextShadowBlurRadius        3.f
#define SNRTextFieldTextShadowOffset            NSMakeSize(0.f, 0.f)

#define SNRTextFieldDisabledAlpha               0.5f
#define SNRTextFieldTextVerticalOffset          1.f

@implementation SNRHUDTextFieldCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setTextColor:SNRTextFieldTextColor];
        [self setDrawsBackground:NO];
        [self setFocusRingType:NSFocusRingTypeNone];
    }
    return self;
}

- (NSText*)setUpFieldEditorAttributes:(NSText *)textObj
{
    NSTextView *fieldEditor = (NSTextView*)[super setUpFieldEditorAttributes:textObj];
    NSColor *textColor = SNRTextFieldTextColor;
    [fieldEditor setInsertionPointColor:textColor];
    [fieldEditor setTextColor:textColor];
    [fieldEditor setDrawsBackground:NO];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[fieldEditor selectedTextAttributes]];
    [attributes setObject:SNRTextFieldSelectedTextBackgroundColor forKey:NSBackgroundColorAttributeName];
    [fieldEditor setSelectedTextAttributes:attributes];
    return fieldEditor;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (![self isEnabled]) {
        CGContextSetAlpha([[NSGraphicsContext currentContext] graphicsPort], SNRTextFieldDisabledAlpha);
    }
    NSRect backgroundRect = cellFrame;
    backgroundRect.size.height -= 1.f;
    
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:backgroundRect];
    
    if ([self drawsBackground]) {
        [SNRTextFieldBackgroundColor set];
        [backgroundPath fill];
    }
    
    if ([self isBezeled]) {
        NSShadow *innerGlow = [NSShadow new];
        [innerGlow setShadowColor:SNRTextFieldInnerGlowColor];
        [innerGlow setShadowOffset:SNRTextFieldInnerGlowOffset];
        [innerGlow setShadowBlurRadius:SNRTextFieldInnerGlowBlurRadius];
        [backgroundPath fillWithInnerShadow:innerGlow];
        NSRect innerShadowRect = NSInsetRect(backgroundRect, -2.f, 0.f);
        innerShadowRect.size.height *= 2.f;
        NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRect:innerShadowRect];
        NSShadow *innerShadow = [NSShadow new];
        [innerShadow setShadowColor:SNRTextFieldInnerShadowColor];
        [innerShadow setShadowOffset:SNRTextFieldInnerShadowOffset];
        [innerShadow setShadowBlurRadius:SNRTextFieldInnerShadowBlurRadius];
        [shadowPath fillWithInnerShadow:innerShadow];
        NSRect dropShadowRect = backgroundRect;
        dropShadowRect.origin.y = NSMaxY(cellFrame) - 1.f;
        [SNRTextFieldDropShadowColor set];
        [NSBezierPath fillRect:dropShadowRect];
    }
    
    // Draw the text vertically centered
    NSSize textSize = [self cellSizeForBounds:cellFrame];
    NSRect textRect = NSMakeRect(backgroundRect.origin.x, round(NSMidY(backgroundRect) - (textSize.height / 2.f)) - SNRTextFieldTextVerticalOffset, backgroundRect.size.width, textSize.height);
    [self drawInteriorWithFrame:textRect inView:controlView];
}
@end
