#import <Foundation/Foundation.h>

/// Minimal Objective-C exception bridge for AppKit tabbing APIs.
FOUNDATION_EXPORT BOOL GhosttyAddTabbedWindowSafely(
    id parent,
    id child,
    NSInteger ordered,
    NSError * _Nullable * _Nullable error
);
