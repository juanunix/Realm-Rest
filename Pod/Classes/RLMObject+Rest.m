//
// Created by Tobias Sundstrand on 15-02-02.
//

#import <Realm-Rest/RestNotifier.h>
#import <Realm-Rest/RestOrchestrator.h>
#import <Realm/RLMRealm.h>
#import <Realm+JSON/RLMObject+JSON.h>
#import <Realm-Rest/RestPathFinder.h>
#import "RLMObject+Rest.h"


@implementation RLMObject (Rest)

+ (NSString *)restSuccessNotification {
    return [NSString stringWithFormat:@"%@Success%@", NSStringFromClass(self), RestNotification];
}

+ (NSString *)restFailureNotification {
    return [NSString stringWithFormat:@"%@Failure%@", NSStringFromClass(self), RestNotification];
}

+ (NSString *)restWithRequestType:(RestRequestType)requestType
                       parameters:(NSDictionary *)parameters
                          headers:(NSDictionary *)headers
                            realm:(RLMRealm *)realm
                  realmIdentifier:(NSString *)realmIdentifier
                          success:(RestSuccessBlock)success
                          failure:(RestFailureBlock)failure {

    NSString *requestId = [[NSUUID UUID] UUIDString];

    [self addObserverWithSuccessBlock:success identifier:requestId notification:[self restSuccessNotification]];
    [self addObserverWithFailureBlock:failure identifier:requestId notification:[self restFailureNotification]];

    [RestOrchestrator restForModelClass:self
                            requestType:requestType
                              requestId:requestId
                             parameters:parameters
                                headers:headers
                                  realm:realm
                        realmIdentifier:realmIdentifier];

    return requestId;
}

- (NSString *)restWithRequestType:(RestRequestType)requestType
                       parameters:(NSDictionary *)parameters
                          headers:(NSDictionary *)headers
                            realm:(RLMRealm *)realm
                  realmIdentifier:(NSString *)realmIdentifier
                          success:(RestSuccessBlock)success
                          failure:(RestFailureBlock)failure {

    NSMutableDictionary *newParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    newParameters[RestRequestParameterStyleJSON] = [self JSONDictionary];

    NSString *requestId = [[NSUUID UUID] UUIDString];

    [self.class addObserverWithSuccessBlock:success identifier:requestId notification:[self.class restSuccessNotification]];
    [self.class addObserverWithFailureBlock:failure identifier:requestId notification:[self.class restFailureNotification]];

    [RestOrchestrator restForObject:(RLMObject <RestModelObjectProtocol> *) self
                        requestType:requestType
                          requestId:requestId
                         parameters:newParameters
                            headers:headers
                              realm:realm
                    realmIdentifier:realmIdentifier];

    return requestId;
}


+ (NSString *)restWithRequestType:(RestRequestType)requestType
                       parameters:(NSDictionary *)parameters
                          headers:(NSDictionary *)headers
                            realm:(RLMRealm *)realm
                  realmIdentifier:(NSString *)realmIdentifier {

    return [self restWithRequestType:requestType
                          parameters:parameters
                             headers:headers
                               realm:realm
                     realmIdentifier:realmIdentifier
                             success:nil
                             failure:nil];
}

+ (NSString *)restInDefaultRealmWithRequestType:(RestRequestType)requestType
                                     parameters:(NSDictionary *)parameters
                                        headers:(NSDictionary *)headers {
    return [self restWithRequestType:requestType
                          parameters:parameters
                             headers:headers
                               realm:[RLMRealm defaultRealm]
                     realmIdentifier:nil];
}

- (NSString *)restWithRequestType:(RestRequestType)requestType
                       parameters:(NSDictionary *)parameters
                          headers:(NSDictionary *)headers
                            realm:(RLMRealm *)realm
                  realmIdentifier:(NSString *)realmIdentifier {

    return [self restWithRequestType:requestType
                          parameters:parameters
                             headers:headers
                               realm:realm
                     realmIdentifier:realmIdentifier
                             success:nil
                             failure:nil];
}

- (NSString *)restInDefaultRealmWithRequestType:(RestRequestType)requestType parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers {
    return [self restWithRequestType:requestType
                          parameters:parameters
                             headers:headers
                               realm:[RLMRealm defaultRealm]
                     realmIdentifier:nil];
}



+ (NSString *)restInDefaultRealmWithRequestType:(RestRequestType)requestType
                                     parameters:(NSDictionary *)parameters
                                        headers:(NSDictionary *)headers
                                        success:(RestSuccessBlock)success
                                        failure:(RestFailureBlock)failure {
    return [self restWithRequestType:requestType
                          parameters:parameters
                             headers:headers
                               realm:[RLMRealm defaultRealm]
                     realmIdentifier:nil
                             success:success
                             failure:failure];
}

- (NSString *)restInDefaultRealmWithRequestType:(RestRequestType)requestType
                                     parameters:(NSDictionary *)parameters
                                        headers:(NSDictionary *)headers
                                        success:(RestSuccessBlock)success
                                        failure:(RestFailureBlock)failure {
    return [self restWithRequestType:requestType
                          parameters:parameters
                             headers:headers
                               realm:[RLMRealm defaultRealm]
                     realmIdentifier:nil
                             success:success
                             failure:failure];
}


+ (void)addObserverWithFailureBlock:(RestFailureBlock)failure
                         identifier:(NSString *)identifier
                       notification:(NSString *)notification {
    if(failure) {
        __block id <NSObject> failureNot = [[NSNotificationCenter defaultCenter] addObserverForName:notification
                                                                                             object:nil
                                                                                              queue:[NSOperationQueue mainQueue]
                                                                                         usingBlock:^(NSNotification *note) {
                                                                                             if([note.userInfo[RequestIdKey] isEqualToString:identifier]) {
                                                                                                 failure(note.userInfo[NSUnderlyingErrorKey], note.userInfo);
                                                                                                 [[NSNotificationCenter defaultCenter] removeObserver:failureNot];
                                                                                             }
                                                                                         }];
    }
}

+ (void)addObserverWithSuccessBlock:(RestSuccessBlock)success
                         identifier:(NSString *)identifier
                       notification:(NSString *)notification {
    if(success) {
        __block id <NSObject> successNot = [[NSNotificationCenter defaultCenter] addObserverForName:notification
                                                                                             object:nil
                                                                                              queue:[NSOperationQueue mainQueue]
                                                                                         usingBlock:^(NSNotification *note) {
                                                                                             if([note.userInfo[RequestIdKey] isEqualToString:identifier]) {
                                                                                                 success(note.userInfo[PrimaryKeyValueKey]);
                                                                                                 [[NSNotificationCenter defaultCenter] removeObserver:successNot];
                                                                                             }
                                                                                         }];
    }
}

@end