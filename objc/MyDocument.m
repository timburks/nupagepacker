#import <Cocoa/Cocoa.h>

@interface MyDocument : NSDocument
{
    id packModel;
    id packerView;
}

@end

@implementation MyDocument
- (id) printOperationWithSettings:(id)printSettings error:(NSError **)outError
{
    [NSPrintOperation printOperationWithView:packerView printInfo:[self printInfo]];
}

@end
