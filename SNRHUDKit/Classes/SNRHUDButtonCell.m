//
//  SNRHUDButtonCell.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-23.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDButtonCell.h"

#define SNRButtonBlackGradientBottomColor         [NSColor colorWithDeviceWhite:0.150 alpha:1.000]
#define SNRButtonBlackGradientTopColor            [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define SNRButtonBlackHighlightColor              [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define SNRButtonBlueGradientBottomColor          [NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]
#define SNRButtonBlueGradientTopColor             [NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000]
#define SNRButtonBlueHighlightColor               [NSColor colorWithDeviceWhite:1.000 alpha:0.250]

#define SNRButtonTextFont                         [NSFont systemFontOfSize:11.f]
#define SNRButtonTextColor                        [NSColor whiteColor]
#define SNRButtonBlackTextShadowOffset            NSMakeSize(0.f, 1.f)
#define SNRButtonBlackTextShadowBlurRadius        1.f
#define SNRButtonBlackTextShadowColor             [NSColor blackColor]
#define SNRButtonBlueTextShadowOffset             NSMakeSize(0.f, -1.f)
#define SNRButtonBlueTextShadowBlurRadius         2.f
#define SNRButtonBlueTextShadowColor              [NSColor colorWithDeviceWhite:0.000 alpha:0.600]

#define SNRButtonDisabledAlpha                    0.7f
#define SNRButtonCornerRadius                     3.f
#define SNRButtonDropShadowColor                  [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define SNRButtonDropShadowBlurRadius             1.f
#define SNRButtonDropShadowOffset                 NSMakeSize(0.f, -1.f)
#define SNRButtonBorderColor                      [NSColor blackColor]
#define SNRButtonHighlightOverlayColor            [NSColor colorWithDeviceWhite:0.000 alpha:0.300]

static NSString* const SNRButtonReturnKeyEquivalent = @"\r";

@interface SNRHUDButtonCell ()
- (BOOL)snr_shouldDrawBlueButton;
@end

@implementation SNRHUDButtonCell {
    NSBezierPath *__bezelPath;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (![self isEnabled]) {
        CGContextSetAlpha([[NSGraphicsContext currentContext] graphicsPort], SNRButtonDisabledAlpha);
    }
    [super drawWithFrame:cellFrame inView:controlView];
    if (__bezelPath && [self isHighlighted]) {
        [SNRButtonHighlightOverlayColor set];
        [__bezelPath fill];
    }
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    frame = NSInsetRect(frame, 0.5f, 0.5f);
    frame.size.height -= SNRButtonDropShadowBlurRadius;
    BOOL blue = [self snr_shouldDrawBlueButton];
    __bezelPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:SNRButtonCornerRadius yRadius:SNRButtonCornerRadius];
    NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:blue ? SNRButtonBlueGradientBottomColor : SNRButtonBlackGradientBottomColor endingColor:blue ? SNRButtonBlueGradientTopColor : SNRButtonBlackGradientTopColor];
    // Draw the gradient fill
    [gradientFill drawInBezierPath:__bezelPath angle:270.f];
    // Draw the border and drop shadow
    [NSGraphicsContext saveGraphicsState];
    [SNRButtonBorderColor set];
    NSShadow *dropShadow = [NSShadow new];
    [dropShadow setShadowColor:SNRButtonDropShadowColor];
    [dropShadow setShadowBlurRadius:SNRButtonDropShadowBlurRadius];
    [dropShadow setShadowOffset:SNRButtonDropShadowOffset];
    [dropShadow set];
    [__bezelPath stroke];
    [NSGraphicsContext restoreGraphicsState];
    // Draw the highlight line around the top edge of the pill
    // Outset the width of the rectangle by 0.5px so that the highlight "bleeds" around the rounded corners
    // Outset the height by 1px so that the line is drawn right below the border
    NSRect highlightRect = NSInsetRect(frame, -0.5f, 1.f);
    // Make the height of the highlight rect something bigger than the bounds so that it won't show up on the bottom
    highlightRect.size.height *= 2.f;
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:SNRButtonCornerRadius yRadius:SNRButtonCornerRadius];
    [__bezelPath addClip];
    [blue ? SNRButtonBlueHighlightColor : SNRButtonBlackHighlightColor set];
    [highlightPath stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    BOOL blue = [self snr_shouldDrawBlueButton];
    NSString *label = [title string];
    NSShadow *textShadow = [NSShadow new];
    [textShadow setShadowOffset:blue ? SNRButtonBlueTextShadowOffset : SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:blue ? SNRButtonBlueTextShadowColor : SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:blue ? SNRButtonBlueTextShadowBlurRadius : SNRButtonBlackTextShadowBlurRadius];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:SNRButtonTextFont, NSFontAttributeName, SNRButtonTextColor, NSForegroundColorAttributeName, textShadow, NSShadowAttributeName, nil];
    NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
    NSSize labelSize = attrLabel.size;
    NSRect labelRect = NSMakeRect(NSMidX(frame) - (labelSize.width / 2.f), NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
    [attrLabel drawInRect:NSIntegralRect(labelRect)];
    return labelRect;
}

#pragma mark - Private

- (BOOL)snr_shouldDrawBlueButton
{
    return [[self keyEquivalent] isEqualToString:SNRButtonReturnKeyEquivalent];
}
@end
