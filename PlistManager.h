

#import <Foundation/Foundation.h>




@interface PlistManager : NSObject

@property (nonatomic, strong) NSString *plistPath;

+ (instancetype)shared;

- (NSMutableDictionary *)loadPlist;

- (void)removeAllObjects;
- (void)removeObjectForKey:(NSString *)key;

- (void)setObject:(id)obj forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

- (void)setInt:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)intForKey:(NSString *)key;

@end
