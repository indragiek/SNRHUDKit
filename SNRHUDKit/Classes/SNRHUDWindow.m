//
//  SNRHUDWindow.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-22.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDWindow.h"

#define SNRWindowTitlebarHeight         22.f
#define SNRWindowBorderColor            [NSColor blackColor]
#define SNRWindowTopColor               [NSColor colorWithDeviceWhite:0.240 alpha:0.960]
#define SNRWindowBottomColor            [NSColor colorWithDeviceWhite:0.150 alpha:0.960]
#define SNRWindowHighlightColor         [NSColor colorWithDeviceWhite:1.000 alpha:0.200]
#define SNRWindowCornerRadius           5.f

#define SNRWindowTitleFont              [NSFont systemFontOfSize:11.f]
#define SNRWindowTitleColor             [NSColor colorWithDeviceWhite:0.700 alpha:1.000]
#define SNRWindowTitleShadowOffset      NSMakeSize(0.f, 1.f)
#define SNRWindowTitleShadowBlurRadius  1.f
#define SNRWindowTitleShadowColor       [NSColor blackColor]

@interface SNRHUDWindowFrameView : NSView
- (void)snr_drawTitleInRect:(NSRect)rect;
@end

@implementation SNRHUDWindow {
    NSView *__customContentView;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    if (([super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation])) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:YES];
    }
    return self;
}

- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
{
    windowFrame.origin = NSZeroPoint;
    windowFrame.size.height -= SNRWindowTitlebarHeight;
    return windowFrame;
}

+ (NSRect)frameRectForContentRect:(NSRect)windowContentRect
                        styleMask:(NSUInteger)windowStyle
{
    windowContentRect.size.height += SNRWindowTitlebarHeight;
    return windowContentRect;
}

- (void)setContentView:(NSView *)aView
{
    if ([__customContentView isEqualTo:aView]) {
        return;
    }
    NSRect bounds = [self frame];
    bounds.origin = NSZeroPoint;
    SNRHUDWindowFrameView *frameView = [super contentView];
    if (!frameView) {
        frameView = [[SNRHUDWindowFrameView alloc] initWithFrame:bounds];
        [super setContentView:frameView];
    }
    if (__customContentView) {
        [__customContentView removeFromSuperview];
    }
    __customContentView = aView;
    [__customContentView setFrame:[self contentRectForFrameRect:bounds]];
    [__customContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [frameView addSubview:__customContentView];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}
@end

@implementation SNRHUDWindowFrameView

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect drawingRect = NSInsetRect(self.bounds, 0.5f, 0.5f);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:SNRWindowCornerRadius yRadius:SNRWindowCornerRadius];
    [NSGraphicsContext saveGraphicsState];
    [path addClip];
    // Fill in the title bar with a gradient background
    NSRect titleBarRect = NSMakeRect(0.f, NSMaxY(self.bounds) - SNRWindowTitlebarHeight, self.bounds.size.width, SNRWindowTitlebarHeight);
    NSGradient *titlebarGradient = [[NSGradient alloc] initWithStartingColor:SNRWindowBottomColor endingColor:SNRWindowTopColor];
    [titlebarGradient drawInRect:titleBarRect angle:90.f];
    // Draw the window title
    [self snr_drawTitleInRect:titleBarRect];
    // Rest of the window has a solid fill
    NSRect bottomRect = NSMakeRect(0.f, 0.f, self.bounds.size.width, self.bounds.size.height - SNRWindowTitlebarHeight);
    [SNRWindowBottomColor set];
    [NSBezierPath fillRect:bottomRect];
    // Draw the highlight line around the top edge of the window
    // Outset the width of the rectangle by 0.5px so that the highlight "bleeds" around the rounded corners
    // Outset the height by 1px so that the line is drawn right below the border
    NSRect highlightRect = NSInsetRect(drawingRect, 0.f, 0.5f);
    // Make the height of the highlight rect something bigger than the bounds so that it won't show up on the bottom
    highlightRect.size.height += 50.f;
    highlightRect.origin.y -= 50.f;
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:SNRWindowCornerRadius yRadius:SNRWindowCornerRadius];
    [SNRWindowHighlightColor set];
    [highlightPath stroke];
    [NSGraphicsContext restoreGraphicsState];
    [SNRWindowBorderColor set];
    [path stroke];
}

- (void)snr_drawTitleInRect:(NSRect)titleBarRect
{
    NSString *title = [[self window] title];
    if (!title) { return; }
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:SNRWindowTitleShadowColor];
    [shadow setShadowOffset:SNRWindowTitleShadowOffset];
    [shadow setShadowBlurRadius:SNRWindowTitleShadowBlurRadius];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:SNRWindowTitleColor, NSForegroundColorAttributeName, SNRWindowTitleFont, NSFontAttributeName, shadow, NSShadowAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    NSSize titleSize = attrTitle.size;
    NSRect titleRect = NSMakeRect(0.f, NSMidY(titleBarRect) - (titleSize.height / 2.f), titleBarRect.size.width, titleSize.height);
    [attrTitle drawInRect:NSIntegralRect(titleRect)];
}
@end
