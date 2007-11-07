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
#import "PackModel.h"
#import "PageInfo.h"
#import "PDFUtility.h"
#import "PreferenceController.h"

NSString *PackModelChangedNotification = @"PackModelChangedNotification";

@implementation PackModel

- (id)init
{
    [super init];
    pageInfos = [[NSMutableArray alloc] init];
    int i;
    for (i = 0; i < BLOCK_COUNT; i++) {
        [pageInfos addObject:[NSNull null]];
    }
    return self;
}
- (void)dealloc
{
    [pageInfos release];
    [undoManager release];
    [super dealloc];
}

- (NSImageRep *)preparedImageRepForPage:(int)pageNum
{
    id obj = [pageInfos objectAtIndex:pageNum];
    if (obj == [NSNull null]) {
        return nil;
    }
    return [obj preparedImageRep];
}

- (void)_replacePageInfoAt:(int)i
              withPageInfo:(PageInfo *)pi
{
    PageInfo *oldInfo = [pageInfos objectAtIndex:i];
    if (pi == oldInfo) {
        return;
    }
    [[undoManager prepareWithInvocationTarget:self]
            _replacePageInfoAt:i
                  withPageInfo:oldInfo];
    [pageInfos replaceObjectAtIndex:i
                         withObject:pi];
    [[NSNotificationCenter defaultCenter] postNotificationName:PackModelChangedNotification
                                                        object:self
                                                      userInfo:nil];    
}

- (void)setImageRep:(NSImageRep *)r
          pageOfRep:(int)repPage
            forPage:(int)viewPage
{
    PageInfo *pi = [[PageInfo alloc] init];
    [pi setImageRep:r];
    [pi setPageOfRep:repPage];
    [self _replacePageInfoAt:viewPage
                withPageInfo:pi];
    [pi release];
    
 }

- (id)initWithCoder:(NSCoder *)c
{
    [super init];
    pageInfos = [[c decodeObjectForKey:@"pageInfos"] retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeObject:pageInfos forKey:@"pageInfos"];
}


- (void)setUndoManager:(NSUndoManager *)undo
{
    [undo retain];
    [undoManager release];
    undoManager = undo;
}

- (NSUndoManager *)undoManager
{
    return undoManager;
}
- (void)removeAllImageReps
{
    int i;
    for (i = 0; i < BLOCK_COUNT; i++) {
        [self _replacePageInfoAt:i
                    withPageInfo:(PageInfo *)[NSNull null]];
    }
}

- (void)removeImageRepAtPage:(int)i
{
    [self _replacePageInfoAt:i
                withPageInfo:(PageInfo *)[NSNull null]];
}

- (void)swapImageRepAt:(int)i
             withRepAt:(int)j
{
    PageInfo *pii = [pageInfos objectAtIndex:i];
    [pii retain];
    
    PageInfo *pij = [pageInfos objectAtIndex:j];
    [pij retain];
    
    [self _replacePageInfoAt:i
                withPageInfo:pij];
    [self _replacePageInfoAt:j
                withPageInfo:pii];
    
    [pii release];
    [pij release];
}

- (void)copyImageRepAt:(int)i
               toRepAt:(int)j
{
    PageInfo *pii = [pageInfos objectAtIndex:i];
    PageInfo *pij = [[PageInfo alloc] init];
    [pij setImageRep:[pii imageRep]];
    [pij setPageOfRep:[pii pageOfRep]];
    [self _replacePageInfoAt:j
                withPageInfo:pij];
    [pij release];
}

- (BOOL)pageIsFilled:(int)i
{
    return ([pageInfos objectAtIndex:i] != [NSNull null]);
}

- (NSDictionary *)textAttributes
{
    NSFont *f = [[PreferenceController sharedPreferenceController] textFont];
    NSDictionary *d = [NSDictionary dictionaryWithObject:f
                                                  forKey:NSFontAttributeName];
    return d;
}

- (int)putAttributedString:(NSAttributedString *)attStr 
            startingOnPage:(int)i
{
    NSData *pdf = pdfFromAttributedStringOfSize(attStr,NSMakeSize(200, 300));
    return [self putPDFData:pdf startingOnPage:i];
}

- (int)putPDF:(NSPDFImageRep *)pdf startingOnPage:(int)i
{
    int pageCount = [pdf pageCount];
    int j;
    for (j = 0; (j < pageCount) && (j+i < BLOCK_COUNT); j++) {
        [self setImageRep:pdf
                pageOfRep:j
                  forPage:j+i];
    }
    return i + j;
}

- (int)putFile:(NSString *)currentPath startingOnPage:(int)i
{
    NSImageRep *imageRep = [NSImageRep imageRepWithContentsOfFile:currentPath];
    
    if (imageRep == nil) {
        NSString *str = [NSString stringWithContentsOfFile:currentPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
        if (!str) {
            return i;
        }
        
        NSDictionary *atts = [self textAttributes];
        
        NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:str
                                                                     attributes:atts];
        return [self putAttributedString:attStr
                          startingOnPage:i];
    }
    
    if ([imageRep isKindOfClass:[NSPDFImageRep class]]) {
        return [self putPDF:(NSPDFImageRep *)imageRep startingOnPage:i];
    } else {
        [self setImageRep:imageRep
                pageOfRep:-1
                  forPage:i];
        return i+1;
    }
    
}

- (int)putFiles:(NSArray *)filenames startingOnPage:(int)i
{
    int fileCount, currentFileIndex;
    int currentStart = i;
    fileCount = [filenames count];
    for (currentFileIndex = 0; currentFileIndex < fileCount; currentFileIndex++) {
        NSString *currentPath = [filenames objectAtIndex:currentFileIndex];
        currentStart = [self putFile:currentPath startingOnPage:currentStart];
    }
    return currentStart;
}


- (int)putPDFData:(NSData *)d startingOnPage:(int)i
{
    NSPDFImageRep *ir = [[NSPDFImageRep alloc] initWithData:d];
    int pageCount = [ir pageCount];
    int j;
    for (j = 0; (j < pageCount) && (j+i < BLOCK_COUNT); j++) {
        [self setImageRep:ir
                pageOfRep:j
                  forPage:j+i];
    }
    [ir release];
    return i + j;
}

@end
