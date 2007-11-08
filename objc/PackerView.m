/*
 Copyright (c) 2007, Big Nerd Ranch, Inc.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, 
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this 
 list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this 
 list of conditions and the following disclaimer in the documentation and/or 
 other materials provided with the distribution.
 
 Neither the name of the Big Nerd Ranch, Inc. nor the names of its contributors may 
 be used to endorse or promote products derived from this software without 
 specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. 
 
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
                                                           PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
                                                           PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
                                                            NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
 */
#import "PackerView.h"
#import "PackModel.h"
#import "PreferenceController.h"
#import "RoundCloseButtonCell.h"
#define BLOCK_COUNT 8
#define BUTTON_MARGIN 4.0

float HalfX(NSRect r) {
    return r.origin.x + r.size.width * 0.5;
}

float QuarterY(NSRect r) {
    return r.origin.y + r.size.height * 0.25;
}

float HalfY(NSRect r) {
    return r.origin.y + r.size.height * 0.5;
}

float ThreeQuarterY(NSRect r) {
    return r.origin.y + r.size.height * 0.75;
}

BOOL isLeftSide(int pageNum) {
    return (pageNum == 0) || (pageNum > 4);
}

@interface PackerView (PrivatePackerViewAPI) 
- (void)prepareBezierPaths;
- (void)setDropPage:(int)i;
@end

@implementation PackerView

#pragma mark Initialization and dealloc

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
        imageablePageRect = NSInsetRect([self bounds], 15.0, 15.0);
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPDFPboardType,NSFilenamesPboardType, nil]];
        dropPage = -1;
        dragStart = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paperSizeChanged:)
                                                     name:PaperSizeChangedNotification
                                                   object:nil];
        [self prepareBezierPaths];
        NSRect bFrame;
        bFrame.origin = NSZeroPoint;
        bFrame.size = NSMakeSize(20, 20);
        NSButton *b = [[NSButton alloc] initWithFrame:bFrame];
        NSButtonCell *bc = [[RoundCloseButtonCell alloc] init];
        [b setCell:bc];
        [bc release];
        [self addSubview:b];
        [b release];
        
    }
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [packModel release];
    [foldLines release];
    [cutLine release];
    [super dealloc];
}

#pragma mark Drawing

- (void)drawImageRep:(NSImageRep *)rep
              inRect:(NSRect)rect
              isLeft:(BOOL)isLeft
{
    NSSize imageSize = [rep size];
    BOOL isPortrait = (imageSize.height > imageSize.width);

    // Figure out the rotation (as a multiple of 90 degrees)
    int rotation;
    if (isLeft) {
        rotation = 1;
    } else {
        rotation = -1;
    }
    if (!isPortrait) {
        rotation += 1;
    }
    
    // Figure out the scale
    float scaleVertical;
    float scaleHorizontal;
    // Is it rotated +/- 90 degrees?
    if (rotation % 2) {
        scaleVertical = rect.size.height / imageSize.width;
        scaleHorizontal = rect.size.width / imageSize.height;
    } else {
        scaleVertical = rect.size.height / imageSize.height;
        scaleHorizontal = rect.size.width / imageSize.width;
    }
    
    float scale;     // How much the image will be scaled
    float widthGap;  // How much it will need to be nudged to center horizontally
    float heightGap; // How much it will need to be nudged to center vertically
    if (scaleHorizontal > scaleVertical) {
        scale = scaleVertical;
        heightGap = 0;
        widthGap = 0.5 * rect.size.width * (scaleHorizontal - scaleVertical) / scaleHorizontal;
    } else {
        scale = scaleHorizontal;
        widthGap = 0;
        heightGap = 0.5 * rect.size.height * (scaleVertical - scaleHorizontal) / scaleVertical;
    }
    
    NSPoint origin;
    switch (rotation) {
        case -1: 
            origin.x = rect.origin.x + widthGap;
            origin.y = rect.origin.y + rect.size.height - heightGap;
            break;
        case 0:
            origin.x = rect.origin.x + widthGap;
            origin.y = rect.origin.y + heightGap;
            break;
        case 1:
            origin.x = rect.origin.x + rect.size.width - widthGap;
            origin.y = rect.origin.y + heightGap;
            break;
        case 2:
            origin.x = rect.origin.x + rect.size.width - widthGap;
            origin.y = rect.origin.y + rect.size.height - heightGap; 
            break;
        default:
            [NSException raise:@"Rotation" format:@"Rotation = %d?", rotation];
    }
    
    // Create the affine transform
    NSAffineTransform *transform = [[NSAffineTransform alloc] init];
    [transform translateXBy:origin.x yBy:origin.y];
    [transform rotateByDegrees:rotation * 90.0];
    [transform scaleBy:scale];
    [NSGraphicsContext saveGraphicsState];
    NSRectClip(rect);
    [transform concat];
    [rep draw];
    [NSGraphicsContext restoreGraphicsState];
}

- (NSRect)fullRectForPage:(int)pageNum
{
    NSRect result;
    NSRect bounds = [self bounds];
    result.size = NSMakeSize(bounds.size.width * 0.5, bounds.size.height * 0.25);
    if (isLeftSide(pageNum)) {
        result.origin.x = NSMinX(bounds);
    } else {
        result.origin.x = HalfX(bounds);
    }
    switch (pageNum) {
        case 0:
        case 1:
            result.origin.y = ThreeQuarterY(bounds);
            break;
        case 7:
        case 2:
            result.origin.y = HalfY(bounds);
            break;
        case 6:
        case 3:
            result.origin.y = QuarterY(bounds);
            break;
        default:
            result.origin.y = NSMinY(bounds);
    }
    return result;
}

- (NSRect)imageableRectForPage:(int)pageNum
{
    return NSIntersectionRect([self fullRectForPage:pageNum],imageablePageRect);
}
- (void)setImageablePageRect:(NSRect)r
{
    imageablePageRect = r;
    [self setNeedsDisplay:YES];
}

#pragma mark Dragging

- (void)setDragStart:(int)i
{
    if (dragStart == i) {
        return;
    }
    
    if (dragStart != -1) {
        NSRect oldRect = [self fullRectForPage:dragStart];
        [self setNeedsDisplayInRect:oldRect];
    }
    
    dragStart = i;
    
    if (dragStart != -1) {
        NSRect oldRect = [self fullRectForPage:dragStart];
        [self setNeedsDisplayInRect:oldRect];
    }
    
}

- (void)mouseDown:(NSEvent *)e
{
    int i = [self pageForPointInWindow:[e locationInWindow]];
    if ([packModel pageIsFilled:i]) {
        [self setDragStart:i];
    }
}

- (void)mouseDragged:(NSEvent *)e
{
    if (dragStart == -1) {
        return;
    }
    int i = [self pageForPointInWindow:[e locationInWindow]];
    if (i == dragStart) {
        return;
    }
      
    [self setDropPage:i];
}

- (void)mouseUp:(NSEvent *)e
{
    if ((dragStart != -1) &&
        (dropPage != -1) &&
        (dragStart != dropPage)) {
        int mask = [e modifierFlags];
        if (mask & NSAlternateKeyMask) {
            [packModel copyImageRepAt:dragStart toRepAt:dropPage];
        } else {
            [packModel swapImageRepAt:dragStart withRepAt:dropPage];
        }
    }
    [self setDragStart:-1];
    [self setDropPage:-1];
}
#pragma mark Drag and Drop Destination

- (void)setDropPage:(int)i
{
    if (i == dropPage) {
        return;
    }
    if (dropPage != -1) {
        NSRect toRedraw = [self fullRectForPage:dropPage];
        [self setNeedsDisplayInRect:toRedraw];
    }
    dropPage = i;
    if (dropPage != -1) {
        NSRect toRedraw = [self fullRectForPage:dropPage];
        [self setNeedsDisplayInRect:toRedraw];
    }
}

- (int)pageForPoint:(NSPoint)p
{
    NSRect bounds = [self bounds];
    if (!NSPointInRect(p, bounds)) {
        return -1;
    }
    int i;
    for (i = 0; i < BLOCK_COUNT; i++) {
        NSRect r = [self fullRectForPage:i];
        if (NSPointInRect(p,r)) {
            return i;
        }
    }
    return -1;
}

- (int)pageForPointInWindow:(NSPoint)p
{
    NSPoint x = [self convertPoint:p fromView:nil];
    return [self pageForPoint:x];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPoint p = [sender draggingLocation];
    [self setDropPage:[self pageForPointInWindow:p]];
    return NSDragOperationCopy;
}
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPoint p = [sender draggingLocation];
    [self setDropPage:[self pageForPointInWindow:p]];
    return NSDragOperationCopy;
}
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [self setDropPage:-1];
}
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}



- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *favoriteTypes = [NSArray arrayWithObjects:NSPDFPboardType, NSFilenamesPboardType,nil];
    NSString *matchingType = [pasteboard availableTypeFromArray:favoriteTypes];
    if (!matchingType) {
        return NO;
    }
    NSUndoManager *undo = [packModel undoManager];
    
    int groupingLevel = [undo groupingLevel];
    //NSLog(@"groupingLevel = %d", groupingLevel);
    
    // This is an odd little hack.  Seems undo groups are not properly closed after drag 
    // from the finder.
    if (groupingLevel > 0) {
        [undo endUndoGrouping];
        [undo beginUndoGrouping];
    }

    if ([matchingType isEqual:NSPDFPboardType]) {
        NSData *d = [pasteboard dataForType:NSPDFPboardType];
        [packModel putPDFData:d 
               startingOnPage:dropPage];
    }
    
    if ([matchingType isEqual:NSFilenamesPboardType]) {
        NSArray *filenames = [pasteboard propertyListForType:NSFilenamesPboardType];
        [packModel putFiles:filenames 
             startingOnPage:dropPage];
    }
         
    return YES;
}
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [self setDropPage:-1];

}
#pragma mark Pagination

- (BOOL)knowsPageRange:(NSRange *)rptr
{
    // As a sort of odd side-effect,  I'm also informing the view
    // of how much of the page the printer can actually draw.
    // I waited until now so that I could use the printer that the
    // user actually selected.
    NSPrintOperation *op = [NSPrintOperation currentOperation];
    NSPrintInfo *pi = [op printInfo];
    if (pi) {
        NSRect imgRect = [pi imageablePageBounds];
        [self setImageablePageRect:imgRect];
    }

    // It is a one-page document
    rptr->location = 1;
    rptr->length = 1;
    return YES;
}

- (NSRect)rectForPage:(int)i
{
    return [self bounds];
}

#pragma For Debugging Purposes

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PackerView: %@>", packModel];
}



@end
