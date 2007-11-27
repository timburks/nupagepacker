#import <Cocoa/Cocoa.h>

@interface PackerView : NSView
{
}

@end

@implementation PackerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (BOOL)knowsPageRange:(NSRange *)rptr
{
    // As a sort of odd side-effect,  I'm also informing the view
    // of how much of the page the printer can actually draw.
    // I waited until now so that I could use the printer that the
    // user actually selected.
    id op = [NSPrintOperation currentOperation];
    id pi = [op printInfo];
    if (pi)
        [self setImageablePageRect:[pi imageablePageBounds]];

    // It is a one-page document
    rptr->location = 1;
    rptr->length = 1;
    return YES;
}

- (NSBezierPath *) cutlineFromPoint:(NSPoint) p1 toPoint:(NSPoint) p2
{
    float dashes[2] = {7.0, 3.0};
    NSBezierPath *cutLine = [NSBezierPath bezierPath];
    [cutLine setLineDash:dashes
        count:2
        phase:0];
    [cutLine moveToPoint:p1];
    [cutLine lineToPoint:p2];
    [cutLine setLineWidth:1.0];
    return cutLine;
}

@end
