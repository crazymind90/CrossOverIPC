

#import "PlistManager.h"




@implementation PlistManager

+ (instancetype)shared {
    static PlistManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.plistPath = @"/var/jb/var/mobile/Library/Preferences/libCrossOverIPC.plist";

         NSFileManager *fileManager = [NSFileManager defaultManager];

        if (![fileManager fileExistsAtPath:sharedInstance.plistPath])
             [@{} writeToFile:sharedInstance.plistPath atomically:YES];
       
    });
    return sharedInstance;
}

- (NSMutableDictionary *)loadPlist {
    if (self.plistPath == nil) {
        return nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.plistPath]) {
        return nil;
    }
    return [NSMutableDictionary dictionaryWithContentsOfFile:self.plistPath];
}

- (void)removeAllObjects {
    if (self.plistPath == nil) {
        return;
    }

    NSMutableDictionary *plist = [self loadPlist];
    if (plist == nil) return;
    
    [plist removeAllObjects];
    [self savePlist:plist];
}


- (void)savePlist:(NSDictionary *)plist {
    if (self.plistPath == nil) {
        return;
    }
    if (![plist writeToFile:self.plistPath atomically:YES]) {
    }
}

- (void)removeObjectForKey:(NSString *)key {
    if (self.plistPath == nil) {
        return;
    }
    if (key == nil) {
        return;
    }
    
    NSMutableDictionary *plist = [self loadPlist];
    if (plist == nil) return;
    [plist removeObjectForKey:key];
    [self savePlist:plist];
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    if (self.plistPath == nil) {
        return;
    }
    if (key == nil) {
        return;
    }
    if (obj == nil) {
        return;
    }
    
    NSMutableDictionary *plist = [self loadPlist];
    if (plist == nil) return;
    plist[key] = obj;
    [self savePlist:plist];
}
 

- (id)objectForKey:(NSString *)key {
    if (self.plistPath == nil) {
        return nil;
    }
    if (key == nil) {
        return nil;
    }
    
    NSMutableDictionary *plist = [self loadPlist];
    if (plist == nil) return nil;
    return plist[key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    [self setObject:@(value) forKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    return [obj boolValue];
}

- (void)setInt:(NSInteger)value forKey:(NSString *)key {
    [self setObject:@(value) forKey:key];
}

- (NSInteger)intForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    return [obj integerValue];
}

@end
