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

#import "PreferenceController.h"

NSString *PaperSizeChangedNotification = @"PaperSizeChangedNotification";
NSString *PaperSizeKey = @"PaperSize";
NSString *FontFamilyKey = @"FontFamily";
NSString *FontSizeKey = @"FontSize";


static PreferenceController *sharedPreferenceController;

@implementation PreferenceController

- (id)init
{
    [super initWithWindowNibName:@"PreferenceController"];
    sharedPreferenceController = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fontFamily = [defaults stringForKey:FontFamilyKey];
    float fontSize = [defaults floatForKey:FontSizeKey];
    textFont = [[NSFont fontWithName:fontFamily
                                size:fontSize] retain];
    return self;
}

+ (void)initialize
{
    NSMutableDictionary *factoryDefaults = [[NSMutableDictionary alloc] init];
    [factoryDefaults setObject:[NSNumber numberWithInt:0]
                        forKey:PaperSizeKey];
    [factoryDefaults setObject:@"Helvetica"
                        forKey:FontFamilyKey];
    [factoryDefaults setObject:[NSNumber numberWithFloat:8.0]
                        forKey:FontSizeKey];
        
    [[NSUserDefaults standardUserDefaults] registerDefaults:factoryDefaults];
}

+ (PreferenceController *)sharedPreferenceController
{
    if (!sharedPreferenceController) {
        [[PreferenceController alloc] init];
    }
    return sharedPreferenceController;
}

- (int)paperSizeID
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:PaperSizeKey];
}
- (void)setPaperSizeID:(int)i
{
    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:PaperSizeKey];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSValue valueWithSize:[self paperSize]]
                 forKey:@"PaperSize"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PaperSizeChangedNotification
                                                        object:self
                                                      userInfo:userInfo];
}
- (NSSize)paperSize
{
    int i = [self paperSizeID];
    
    // Is it letter?
    if (i == 0) {
        return NSMakeSize(612, 792);
    } else {
        // must be A4
        return NSMakeSize(595, 842); 
    }
}

- (void)windowDidLoad
{
    int i = [self paperSizeID];
    [paperPopUp selectItemWithTag:i];
    [textFontField setStringValue:[self fontDescription]];
}

- (IBAction)paperChosen:(id)sender
{
    int i = [paperPopUp selectedTag];
    [self setPaperSizeID:i];
}

- (NSFont *)textFont
{
    return textFont;
}

- (void)setTextFont:(NSFont *)f
{
    [textFont release];
    textFont = [f retain];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[f familyName]
           forKey:FontFamilyKey];
    [ud setFloat:[f pointSize]
          forKey:FontSizeKey];
    [textFontField setStringValue:[self fontDescription]];

}

- (NSString *)fontDescription
{
    NSFont *f = [self textFont];
    return [NSString stringWithFormat:@"%@ - %.1f", [f displayName], [f pointSize]];
}

- (void)changeFont:(id)sender
{
    NSFont *newFont = [sender convertFont:textFont];
    [self setTextFont:newFont];
}

- (IBAction)chooseFont:(id)sender
{
    NSFontManager *fm = [NSFontManager sharedFontManager];
    [fm setSelectedFont:textFont isMultiple:NO];
    NSFontPanel *fp = [NSFontPanel sharedFontPanel];        
    [fp makeKeyAndOrderFront:nil];
}

@end
