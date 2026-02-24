#import "ObjCExceptionCatcher.h"
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

BOOL GhosttyAddTabbedWindowSafely(
    id parent,
    id child,
    NSInteger ordered,
    NSError * _Nullable * _Nullable error
) {
#if TARGET_OS_OSX
    @try {
        [((NSWindow *)parent) addTabbedWindow:(NSWindow *)child ordered:(NSWindowOrderingMode)ordered];
        return YES;
    } @catch (NSException *exception) {
        if (error != NULL) {
            NSString *reason = exception.reason ?: @"Unknown Objective-C exception";
            *error = [NSError errorWithDomain:@"Ghostty.ObjCException"
                                         code:1
                                     userInfo:@{
                                         NSLocalizedDescriptionKey: reason,
                                         @"exception_name": exception.name,
                                     }];
        }

        return NO;
    }
#else
    if (error != NULL) {
        *error = [NSError errorWithDomain:@"Ghostty.ObjCException"
                                     code:2
                                 userInfo:@{
                                     NSLocalizedDescriptionKey: @"GhosttyAddTabbedWindowSafely is unavailable on this platform.",
                                 }];
    }
    return NO;
#endif
}
