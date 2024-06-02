# CrossOverIPC
*A lightweight cross-process communication tool for sending and receiving messages on iOS 15 & 16 for rootless jailbreaks*

## What does it do?

* **Send Messages :** *Send a message with a value to another process .*
* **Send Messages With Reply :** *Send a message with a value to other processes and get an instant reply from those processes .*

## How does it work?

*It depends on the ```CFNotificationCenterGetDistributedCenter()``` function from macOS.*
*Yes, it does also work on iOS. Its main functionality is to send cross-process notifications.*
*Since ```CPDistributedMessagingCenter``` is restricted, I made its methods using the CF function.*

## Header file : 

```objective-c
typedef enum CrossOverIPCServiceType : CFIndex {

    SERVICE_TYPE_SENDER,
    SERVICE_TYPE_LISTENER

} CrossOverIPCServiceType;


@interface CrossOverIPC : NSObject 

+ (instancetype) centerNamed:(NSString *)serviceName type:(CrossOverIPCServiceType)type;
- (void) registerForMessageName:(NSString *)msgName target:(id)target selector:(SEL)sel;
- (void) sendMessageName:(NSString *)msgName userInfo:(NSDictionary *)userInfo;
- (NSDictionary *) sendMessageAndReceiveReplyName:(NSString *)msgName userInfo:(NSDictionary *)userInfo;

@end 

```
## How to use it ?

#### For example ~ Getting UDID from SpringBoard to App ..
 
* Add `CrossOverIPC.h` to your project .
```objective-c
#import "CrossOverIPC.h"
```
 

## ~ SpringBoard :
```objective-c
  #define _serviceName @"com.cm90.crossOverIPC"

  CrossOverIPC *crossOver = [objc_getClass("CrossOverIPC") centerNamed:_serviceName type:SERVICE_TYPE_LISTENER];
  [crossOver registerForMessageName:@"UDID_Getter" target:self selector:@selector(handleMSG:userInfo:)];
```

#### Target method : 
```objective-c
-(NSDictionary *) handleMSG:(NSString *)msgId userInfo:(NSDictionary *)userInfo {

	if ([(NSString *)userInfo[@"action"] isEqual:@"getUDID"])
	  return @{@"UDID":[UIDevice.currentDevice sf_udidString] ?: @"No udid"};
	
	return @{};
}

```
  
## ~ App :
```objective-c
    #define _serviceName @"com.cm90.crossOverIPC"

    CrossOverIPC *crossOver = [objc_getClass("CrossOverIPC") centerNamed:_serviceName type:SERVICE_TYPE_SENDER];
    NSDictionary *dict = [crossOver sendMessageAndReceiveReplyName:@"UDID_Getter" userInfo:@{@"action":@"getUDID"}];
    CLog(@"[+] UDID : %@",dict[@"UDID"]);
```



## Important ..
* `ServiceName` must be the same in [Poster] and [Client] .




## Supports ..

* `Dopamine`
* `RootHide`
  
### Tested on iOS 15 & 16 :

* `arm64e`
* `arm64`



