


#include <notify.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFNotificationCenter.h>
#import "PlistManager.h"


#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic ignored "-Wobjc-property-no-attribute"


#define CLogLib(format, ...) NSLog(@"CM90~[CrossOverIPC] : " format, ##__VA_ARGS__)


extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);


static NSString *SWF(id Value, ...) {
    va_list args;
    va_start(args, Value);
    NSString *Formated = [[NSString alloc] initWithFormat:Value arguments:args];
    va_end(args);
    return Formated;
}


static CFMutableDictionaryRef convertNSDictToCFDict(NSDictionary *nsDictionary) {

    CFMutableDictionaryRef cfDictionary = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        [nsDictionary count],
        &kCFTypeDictionaryKeyCallBacks,
        &kCFTypeDictionaryValueCallBacks
    );
    
    for (id key in nsDictionary) {
        CFDictionarySetValue(cfDictionary, (__bridge const void *)(key), (__bridge const void *)(nsDictionary[key]));
    }
    
    return cfDictionary;
}