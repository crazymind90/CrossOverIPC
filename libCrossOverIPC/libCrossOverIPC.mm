 //  Created by CrazyMind90 ~ 2024.


#import "../CrossOverIPC.h"
#import "../libCrossOverIPC.h"
#import <Foundation/Foundation.h>
#include <dlfcn.h>
 

#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wprotocol"
#pragma GCC diagnostic ignored "-Wmacro-redefined"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wunknown-warning-option"
#pragma GCC diagnostic ignored "-Wincompatible-pointer-types"
#pragma GCC diagnostic ignored "-Wunused-value"
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic ignored "-Wignored-attributes"
#pragma GCC diagnostic ignored "-Wunused-result"



#define CLog(format, ...) NSLog(@"CM90~[libCrossOverIPC] : " format, ##__VA_ARGS__)
 
 
@interface CrossOverIPC (CFImp)
 
@property (nonatomic, strong) NSMutableDictionary <id, NSArray *> *registeredTargets;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSString *origServiceName;
@property (nonatomic, strong) NSString *senderServiceName;
@property (nonatomic, strong) NSString *clientServiceName;

+ (instancetype) shared;

@end 

@implementation CrossOverIPC
 
 

#pragma  --------------------------------------------- Main event ----------------------------------------------------

static void distributedCenterEvent(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
         
    CrossOverIPC.shared.origServiceName = [CrossOverIPC.shared purifySenderName:[CrossOverIPC.shared purifyClientName:(__bridge NSString *)name]];
    CrossOverIPC.shared.senderServiceName = SWF(@"%@-CROSS_OVER_SENDER",[CrossOverIPC.shared purifyClientName:(__bridge NSString *)name]);
    CrossOverIPC.shared.clientServiceName = (__bridge NSString *)name;
    CrossOverIPC.shared.serviceName = CrossOverIPC.shared.clientServiceName;
        
    if ([CrossOverIPC.shared isSender]) {
        #pragma mark - Sender 
        [CrossOverIPC.shared senderHandler:(__bridge NSDictionary *)userInfo];
    } else {
        #pragma mark - Client 
        [CrossOverIPC.shared clientHandler:(__bridge NSDictionary *)userInfo];       
    }
}
 

#pragma  --------------------------------------------- Allocates ----------------------------------------------------

+(instancetype) shared {
	static dispatch_once_t once = 0;
	__strong static CrossOverIPC *shared = nil;
	dispatch_once(&once, ^{
		shared = [[self alloc] init];
        shared.registeredTargets = NSMutableDictionary.alloc.init;
	});
	return shared;
}

 
-(instancetype) initWithServiceNamed:(NSString *)serviceName type:(CrossOverIPCServiceType)type {
   
        self.origServiceName = serviceName;
        self.senderServiceName = SWF(@"%@-CROSS_OVER_SENDER",serviceName);
        self.clientServiceName = SWF(@"%@-CROSS_OVER_CLIENT",serviceName);

        switch(type){
        case SERVICE_TYPE_SENDER:
                serviceName = self.senderServiceName;
                break;
        case SERVICE_TYPE_LISTENER:
                serviceName = self.clientServiceName;
                break;
        }
 
        self.serviceName = serviceName;
 
        CFNotificationCenterAddObserver(
        CFNotificationCenterGetDistributedCenter(),
        (__bridge const void *)self,
        distributedCenterEvent,
        (CFStringRef)serviceName,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);

    return self;
}

 
+ (instancetype) centerNamed:(NSString *)serviceName type:(CrossOverIPCServiceType)type {
    return [CrossOverIPC.shared initWithServiceNamed:serviceName type:type];
}

 
#pragma  --------------------------------------------- Senders ----------------------------------------------------


-(void) sendMessageName:(NSString *)msgName userInfo:(NSDictionary *)userInfo {
    
    if (!userInfo)
    userInfo = @{};

    NSString *serviceName = [self isSender] ? self.clientServiceName : self.senderServiceName;

    CFMutableDictionaryRef dictionary = convertNSDictToCFDict(@{msgName:userInfo,
                                                                @"msgName":msgName,
                                                                @"isWithReply":@"NO",
                                                                @"clientServiceName":self.clientServiceName,
                                                                });
    CFNotificationCenterPostNotificationWithOptions(
             CFNotificationCenterGetDistributedCenter(),
             (CFStringRef)self.clientServiceName,
             NULL,
             dictionary,
             kCFNotificationPostToAllSessions | kCFNotificationDeliverImmediately);

    CFRelease(dictionary);
 
}


-(NSDictionary *) sendMessageAndReceiveReplyName:(NSString *)msgName userInfo:(NSDictionary *)userInfo {
    
    if (!userInfo)
    userInfo = @{};
    

    NSString *serviceName = [self isSender] ? self.clientServiceName : self.senderServiceName;

    CFMutableDictionaryRef dictionary = convertNSDictToCFDict(@{msgName:userInfo,
                                                                @"isWithReply":@"YES",
                                                                @"msgName":msgName,
                                                                @"clientServiceName":self.clientServiceName,
                                                                });
    CFNotificationCenterPostNotificationWithOptions(
             CFNotificationCenterGetDistributedCenter(),
             (CFStringRef)self.clientServiceName,
             NULL,
             dictionary,
             kCFNotificationPostToAllSessions | kCFNotificationDeliverImmediately);

    CFRelease(dictionary);
  
    NSString *dictKey = SWF(@"%@~%@",self.origServiceName,msgName);
    NSDate *startTime = NSDate.date;

    do {
        if ([PlistManager.shared objectForKey:dictKey]) {
            break;
        }
        if ([NSDate.date timeIntervalSinceDate:startTime] >= 0.5) {
            break;
        }
    } while (![PlistManager.shared objectForKey:dictKey]);

    NSDictionary *ret = [PlistManager.shared objectForKey:dictKey];
    [PlistManager.shared removeObjectForKey:dictKey];

    return ret;
}


#pragma  --------------------------------------------- Handlers ----------------------------------------------------

  

- (void) senderHandler:(NSDictionary *)userInfo {

        if (userInfo) {

        } else { 
        // CLog(@"~[Sender]~ No userInfo received.");
        }
}

- (void) clientHandler:(NSDictionary *)userInfo {
    
        if (userInfo) {

        NSDictionary *infoDict = (__bridge NSDictionary *)userInfo;

        NSString *msgName = infoDict[@"msgName"];
        NSString *fullKey = SWF(@"%@~%@",self.clientServiceName,msgName);
        
        if ([self isValidTargetForServiceName:fullKey]) {

            BOOL isWithReply = [infoDict[@"isWithReply"] isEqual:@"YES"];
            if (isWithReply) { 
            NSDictionary *dict = [self callServiceNameTarget:fullKey userInfo:infoDict[msgName]];
            if (!dict)
            dict = @{};

            [PlistManager.shared setObject:dict forKey:SWF(@"%@~%@",self.origServiceName,msgName)];

            } else {
            [self callServiceNameTarget:fullKey userInfo:infoDict[msgName]];
            }
        } else {
        }

        } else { 
        // CLog(@"~[Client]~ No userInfo received.");
        }
}

 

#pragma  --------------------------------------------- Extras ----------------------------------------------------


-(void) registerForMessageName:(NSString *)msgName target:(id)target selector:(SEL)sel {
    [self.registeredTargets setObject:@[target,NSStringFromSelector(sel)] forKey:SWF(@"%@~%@",self.serviceName,msgName)];
}

-(NSDictionary *) callServiceNameTarget:(NSString *)serviceKey userInfo:(NSDictionary *)dict {
    id target = self.registeredTargets[serviceKey][0];
    SEL selector = NSSelectorFromString(self.registeredTargets[serviceKey][1]);
	return [target performSelector:selector withObject:[self purifyClientName:serviceKey] withObject:dict];
}

-(BOOL) isValidTargetForServiceName:(NSString *)serviceKey {
    if ([self.registeredTargets objectForKey:serviceKey]) return YES;
    return NO;
}

- (BOOL) isSender {
    return [self.serviceName containsString:@"-CROSS_OVER_SENDER"];
}

- (NSString *) purifySenderName:(NSString *)senderName {
    return [senderName stringByReplacingOccurrencesOfString:@"-CROSS_OVER_SENDER" withString:@""];
}

- (NSString *) purifyClientName:(NSString *)clientName {
    return [clientName stringByReplacingOccurrencesOfString:@"-CROSS_OVER_CLIENT" withString:@""];
}

  

#pragma  --------------------------------------------- Properties ----------------------------------------------------


- (NSString *)senderServiceName {
    return objc_getAssociatedObject(self, @selector(senderServiceName));
}

- (void)setSenderServiceName:(NSString *)senderServiceName {
    objc_setAssociatedObject(self, @selector(senderServiceName), senderServiceName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)clientServiceName {
    return objc_getAssociatedObject(self, @selector(clientServiceName));
}

- (void)setClientServiceName:(NSString *)clientServiceName {
    objc_setAssociatedObject(self, @selector(clientServiceName), clientServiceName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)origServiceName {
    return objc_getAssociatedObject(self, @selector(origServiceName));
}

- (void)setOrigServiceName:(NSString *)origServiceName {
    objc_setAssociatedObject(self, @selector(origServiceName), origServiceName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)serviceName {
    return objc_getAssociatedObject(self, @selector(serviceName));
}

- (void)setServiceName:(NSString *)serviceName {
    objc_setAssociatedObject(self, @selector(serviceName), serviceName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<id, NSArray *> *)registeredTargets {
    return objc_getAssociatedObject(self, @selector(registeredTargets));
}

- (void)setRegisteredTargets:(NSMutableDictionary<id, NSArray *> *)registeredTargets {
    objc_setAssociatedObject(self, @selector(registeredTargets), registeredTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
  
 




