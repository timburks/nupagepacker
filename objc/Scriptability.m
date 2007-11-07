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
#import "Scriptability.h"
#import "AppController.h"
#import "PreferenceController.h"
#import "MyDocument.h"
#import "CatalogController.h"
#import "PackModel.h"


@implementation NSObject (MNscriptability)

- (void) returnError:(int)n string:(NSString*)s {
	NSScriptCommand* c = [NSScriptCommand currentCommand];
	[c setScriptErrorNumber:n];
	if (s)
		[c setScriptErrorString:s];
}

@end

// =========

@implementation CatalogController (MNscriptability)

-(PDFView*) pdfView {
	return pdfView;
}

@end

// =========

@implementation AppController (MNscriptability)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key {
	//NSLog(@"handles %@",key);
	if ([key isEqualToString: @"pageSizePref"])
		return YES;
	return NO;
}

// page size pref

enum {
	LETTER_PAGE_SIZE_ENUMERATOR='psLt',
	A4_PAGE_SIZE_ENUMERATOR='psA4'
} pageSizeEnumeration;

static int sizeEnumeration[] = {
	LETTER_PAGE_SIZE_ENUMERATOR,
	A4_PAGE_SIZE_ENUMERATOR
};

- (int)pageSizePref
{
	//NSLog(@"get page size pref");
	int sz = [[PreferenceController sharedPreferenceController] paperSizeID];
	return sizeEnumeration[sz];
}

- (void)setPageSizePref:(int)sz
{
    //NSLog(@"set page size pref");
	int i, u = sizeof sizeEnumeration / sizeof sizeEnumeration[0];
	for (i = 0; i < u; i++)
		if (sizeEnumeration[i] == sz)
			[[PreferenceController sharedPreferenceController] setPaperSizeID: i];
}


@end

// =========

@implementation MyDocument (MNscriptability)

- (PackModel*) packModel {
	return packModel;
}

- (unsigned int)countOfPagesArray { 
    return 8; 
}

- (id)objectInPagesArrayAtIndex:(unsigned int)i {
	//NSLog(@"objectinPagesArrayAtIndex: %i",i);
	if (i > 7) {
		[self returnError: errOSACantAccess string: @"No such document page."];
		return nil;
	}
	MNDocPage* p = [[[MNDocPage alloc] init] autorelease];
	p->index = i;
	p->document = self;
    return p; 
}

- (void) insertInPagesArray: (id) obj {
	[self returnError: errOSACantAssign string: @"Can't create additional document pages."];
}

- (void) removeObjectFromPagesArrayAtIndex:(int)ix {
    //NSLog(@"removingObjectFromPagesArrayAtIndex:%d", ix);
	[self returnError: errOSACantAssign string: @"Can't delete document pages."];
}


@end

// =========

@implementation MNDocPage

- (void)handleClearScriptCommand:(id)sender
{
    //NSLog(@"handlClearScriptCommand:%@", sender);
    [[document packModel] removeImageRepAtPage:index];
}
- (NSScriptObjectSpecifier *)objectSpecifier {
	NSScriptObjectSpecifier* spec = [[NSIndexSpecifier alloc] initWithContainerClassDescription:(NSScriptClassDescription*)[self->document classDescription]
																			 containerSpecifier:[self->document objectSpecifier]
																							key:@"PagesArray"
																						  index: self->index];
	return [spec autorelease];
}

- (void) setCatalogSourcePage:(int)p {
    //NSLog(@"set catalog source page of page %i to %i", self->index, p);
	int pp = p - 1;
	PDFDocument *doc = [[[CatalogController sharedCatalogController] pdfView] document];
	if (pp >= [doc pageCount]) {
		[self returnError: errOSACantAccess string: @"No such catalog page."];
		return;
	}
	PDFPage *page = [doc pageAtIndex:pp];
	NSData* d = [page dataRepresentation];
	[[self->document packModel] putPDFData:d startingOnPage: self->index];
}

- (int) catalogSourcePage {
	[self returnError: errOSACantAccess string: @"This property is write-only."];
	return 0;
}

- (void) setFileSource:(NSURL*)url {
	NSArray* arr = [NSArray arrayWithObject: [url path]];
	[[self->document packModel] putFiles:arr startingOnPage: self->index];
}

- (id) fileSource {
	[self returnError: errOSACantAccess string: @"This property is write-only."];
	return nil;
}


@end
