//
//  SNRHUDSegmentedCell.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-22.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDSegmentedCell.h"
#import "NSBezierPath+MCAdditions.h"

#define SNRSegControlGradientBottomColor         [NSColor colorWithDeviceWhite:0.150 alpha:1.000]
#define SNRSegControlGradientTopColor            [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define SNRSegControlSelectedGradientBottomColor [NSColor colorWithDeviceWhite:0.130 alpha:1.000]
#define SNRSegControlSelectedGradientTopColor    [NSColor colorWithDeviceWhite:0.120 alpha:1.000]

#define SNRSegControlDividerGradientBottomColor  [NSColor colorWithDeviceWhite:0.120 alpha:1.000]
#define SNRSegControlDividerGradientTopColor     [NSColor colorWithDeviceWhite:0.160 alpha:1.000]

#define SNRSegControlHighlightColor              [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define SNRSegControlHighlightOverlayColor       [NSColor colorWithDeviceWhite:0.000 alpha:0.300]
#define SNRSegControlBorderColor                 [NSColor blackColor]
#define SNRSegControlCornerRadius                3.f

#define SNRSegControlInnerShadowColor            [NSColor colorWithDeviceWhite:0.000 alpha:1.000]
#define SNRSegControlInnerShadowBlurRadius       3.f
#define SNRSegControlInnerShadowOffset           NSMakeSize(0.f, -1.f)

#define SNRSegControlDropShadowColor             [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define SNRSegControlDropShadowBlurRadius        1.f
#define SNRSegControlDropShadowOffset            NSMakeSize(0.f, -1.f)

#define SNRSegControlTextFont                    [NSFont systemFontOfSize:11.f]
#define SNRSegControlTextColor                   [NSColor colorWithDeviceWhite:0.700 alpha:1.000]
#define SNRSegControlSelectedTextColor           [NSColor whiteColor]
#define SNRSegControlSelectedTextShadowOffset    NSMakeSize(0.f, -1.f)
#define SNRSegControlTextShadowOffset            NSMakeSize(0.f, 1.f)
#define SNRSegControlTextShadowBlurRadius        1.f
#define SNRSegControlTextShadowColor             [NSColor blackColor]

#define SNRSegControlDisabledAlpha               0.5f

#define SNRSegControlXEdgeMargin                 10.f
#define SNRSegControlYEdgeMargin                 5.f
#define SNRSegControlImageLabelMargin            5.f

// This is a value that is set internally by AppKit, used for layout purposes in this code
// Don't change this
#define SNRSegControlDivderWidth 3.f

@interface SNRHUDSegmentedCell ()
// Returns the bezier path that the border was drawn in
- (NSBezierPath*)snr_drawBackgroundWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
- (NSRect)snr_widthForSegment:(NSInteger)segment;
- (void)snr_drawInteriorOfSegment:(NSInteger)segment inFrame:(NSRect)frame inView:(NSView*)controlView;
@end

@implementation SNRHUDSegmentedCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    if (![self isEnabled]) {
        CGContextSetAlpha(ctx, SNRSegControlDisabledAlpha);
    }
    // The frame needs to be inset 0.5px to make the border line crisp
    // because NSBezierPath draws the stroke centered on the bounds of the rect
    // This means that 0.5px of the 1px stroke line will be outside the rect and the other half will be inside
    NSInteger segmentCount = [self segmentCount];
    cellFrame = NSInsetRect(cellFrame, 0.5f, 0.5f);
    cellFrame.size.height -= SNRSegControlDropShadowBlurRadius; // Make room for the drop shadow
    // OS X seems to add 3px of extra space in the frame per segment for the dividers
    // but we get rid of this 
    NSBezierPath *path = [self snr_drawBackgroundWithFrame:cellFrame inView:controlView];
    NSRect bounds = [path bounds];
    if (!segmentCount) { return; } // Stop drawing if there are no segments
    [path addClip];
    // Need to improvise a bit here because there is no public API to get the
    // drawing rect of a specific segment
    CGFloat currentOrigin = 0.0;
    for (NSInteger i = 0; i < segmentCount; i++) {
        CGFloat width = [self widthForSegment:i];
        
        // widthForSegment: returns 0 for autosized segments
        // so we need to divide the width of the cell evenly between all the segments
        // It will still break if one segment is much wider than the others
        if (width == 0) {
            width = (cellFrame.size.width - (SNRSegControlDivderWidth * (segmentCount - 1))) / segmentCount;
        }
        
        if (i != (segmentCount - 1)) {
            width += SNRSegControlDivderWidth;
        }
        NSRect frame = NSMakeRect(bounds.origin.x + currentOrigin, bounds.origin.y, width, bounds.size.height);
        [NSGraphicsContext saveGraphicsState];
        if ([self isEnabled] && ![self isEnabledForSegment:i]) {
            CGContextSetAlpha(ctx, SNRSegControlDisabledAlpha);
        }
        [self drawSegment:i inFrame:frame withView:controlView];
        [NSGraphicsContext restoreGraphicsState];
        currentOrigin += width;
    }
}

- (NSBezierPath*)snr_drawBackgroundWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:SNRSegControlCornerRadius yRadius:SNRSegControlCornerRadius];
    NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:SNRSegControlGradientBottomColor endingColor:SNRSegControlGradientTopColor];
    // Draw the gradient fill
    [gradientFill drawInBezierPath:borderPath angle:270.f];
    // Draw the border and drop shadow
    [NSGraphicsContext saveGraphicsState];
    [SNRSegControlBorderColor set];
    NSShadow *dropShadow = [NSShadow new];
    [dropShadow setShadowColor:SNRSegControlDropShadowColor];
    [dropShadow setShadowBlurRadius:SNRSegControlDropShadowBlurRadius];
    [dropShadow setShadowOffset:SNRSegControlDropShadowOffset];
    [dropShadow set];
    [borderPath stroke];
    [NSGraphicsContext restoreGraphicsState];
    // Draw the highlight line around the top edge of the pill
    // Outset the width of the rectangle by 0.5px so that the highlight "bleeds" around the rounded corners
    // Outset the height by 1px so that the line is drawn right below the border
    NSRect highlightRect = NSInsetRect(cellFrame, -0.5f, 1.f);
    // Make the height of the highlight rect something bigger than the bounds so that it won't show up on the bottom
    highlightRect.size.height *= 2.f;
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:SNRSegControlCornerRadius yRadius:SNRSegControlCornerRadius];
    [borderPath addClip];
    [SNRSegControlHighlightColor set];
    [highlightPath stroke];
    [NSGraphicsContext restoreGraphicsState];
    return borderPath;
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView
{
    BOOL selected = [self isSelectedForSegment:segment];
    // Only draw the divider if it's not selected and it isn't the last segment
    BOOL drawDivider = !selected && (segment < ([self segmentCount] - 1)) && ([self selectedSegment] != (segment + 1));
    if (selected) {
        NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:SNRSegControlSelectedGradientBottomColor endingColor:SNRSegControlSelectedGradientTopColor];
        [gradientFill drawInRect:frame angle:270.f];
        NSShadow *innerShadow = [NSShadow new];
        [innerShadow setShadowColor:SNRSegControlInnerShadowColor];
        [innerShadow setShadowBlurRadius:SNRSegControlInnerShadowBlurRadius];
        [innerShadow setShadowOffset:SNRSegControlInnerShadowOffset];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:frame];
        [path fillWithInnerShadow:innerShadow];
    }
    [self snr_drawInteriorOfSegment:segment inFrame:frame inView:controlView];
    NSEvent *currentEvent = [NSApp currentEvent]; // This is probably a dirty way of figuring out whether to highlight
    if (currentEvent.type == NSLeftMouseDown && [self isEnabledForSegment:segment]) {
        NSPoint location = [controlView convertPoint:[currentEvent locationInWindow] fromView:nil];
        if (NSPointInRect(location, frame)) {
            [SNRSegControlHighlightOverlayColor set];
            [NSBezierPath fillRect:frame];
        }
    }
    if (drawDivider) {
        NSRect highlightRect = NSMakeRect(round(NSMaxX(frame) - 1.f), frame.origin.y, 1.f, frame.size.height);
        [SNRSegControlHighlightColor set];
        [NSBezierPath fillRect:highlightRect];
        NSRect dividerRect = highlightRect;
        dividerRect.origin.x -= 1.f;
        NSGradient *dividerFill = [[NSGradient alloc] initWithStartingColor:SNRSegControlDividerGradientBottomColor endingColor:SNRSegControlDividerGradientTopColor];
        [dividerFill drawInRect:NSIntegralRect(dividerRect) angle:270.f];
    }
}

- (void)snr_drawInteriorOfSegment:(NSInteger)segment inFrame:(NSRect)frame inView:(NSView*)controlView
{
    BOOL selected = [self isSelectedForSegment:segment];
    NSString *label = [self labelForSegment:segment];
    NSImage *image = [self imageForSegment:segment];
    NSRect imageRect = NSZeroRect;
    if (image) {
        NSSize imageSize = [image size];
        CGFloat maxImageHeight = frame.size.height - (SNRSegControlYEdgeMargin * 2.f);
        CGFloat imageHeight = MIN(maxImageHeight, imageSize.height);
        imageRect = NSMakeRect(round(NSMidX(frame) - (imageSize.width / 2.f)), round(NSMidY(frame) - (imageHeight / 2.f)), imageSize.width, imageHeight);
    }
    if (label) {
        NSShadow *textShadow = [NSShadow new];
        [textShadow setShadowOffset:selected ? SNRSegControlSelectedTextShadowOffset : SNRSegControlTextShadowOffset];
        [textShadow setShadowColor:SNRSegControlTextShadowColor];
        [textShadow setShadowBlurRadius:SNRSegControlTextShadowBlurRadius];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:SNRSegControlTextFont, NSFontAttributeName, selected ? SNRSegControlSelectedTextColor : SNRSegControlTextColor, NSForegroundColorAttributeName, textShadow, NSShadowAttributeName, nil];
        NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
        NSSize labelSize = attrLabel.size;
        if (image) {
            CGFloat totalContentWidth = labelSize.width + imageRect.size.width + SNRSegControlImageLabelMargin;
            imageRect.origin.x = round(NSMidX(frame) - (totalContentWidth / 2.f));
        }
        NSRect labelRect = NSMakeRect((image == nil) ? (NSMidX(frame) - (labelSize.width / 2.f)) : (NSMaxX(imageRect) + SNRSegControlImageLabelMargin), NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
        [attrLabel drawInRect:NSIntegralRect(labelRect)];
    }
    NSImageCell *imageCell = [[NSImageCell alloc] init];
    [imageCell setImage:image];
    [imageCell setImageScaling:[self imageScalingForSegment:segment]];
    [imageCell setHighlighted:[self isHighlighted]];
    [imageCell drawWithFrame:imageRect inView:controlView];
}

- (NSRect)snr_widthForSegment:(NSInteger)segment
{
    return NSZeroRect;
}
@end