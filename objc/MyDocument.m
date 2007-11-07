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
#import "MyDocument.h"
#import "PackModel.h"
#import "PackerView.h"
#import "CatalogController.h"

@implementation MyDocument

- (id)init
{
    [super init];
    packModel = [[PackModel alloc] init];
    [packModel setUndoManager:[self undoManager]];
    
    return self;
}

- (void)dealloc
{
    [packModel release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}
- (void)updateUI
{
    [packerView setPackModel:packModel];
    [[packerView window] setNextResponder:[CatalogController sharedCatalogController]];
}
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    [self updateUI];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:packModel];
    return d;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    [packModel release];
    packModel = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
    [packModel setUndoManager:[self undoManager]];
    if (packerView) {
        [self updateUI];
    }
    return YES;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    NSPrintInfo *pi = [self printInfo];
    NSPrintOperation *po = [NSPrintOperation printOperationWithView:packerView
                                                          printInfo:pi];
    return po;
    
}

@end
