//
// Created by Tobias Sundstrand on 15-01-30.
//

#import <Foundation/Foundation.h>
#import <Realm-Rest/RestRequestBuilder.h>
#import <Realm-Rest/RestPathFinder.h>
#import <Realm-Rest/RestRequestQueue.h>
#import <Realm-Rest/RestConstants.h>

@protocol RestModelObjectProtocol;
@class RLMObject;
@class RestRequestQueue;
@class RLMRealm;

@interface RestOrchestrator : NSObject

@property (nonatomic, readonly) RestRequestQueuePeristance peristance;

- (instancetype)initWithPersistance:(RestRequestQueuePeristance)persistance;

- (void)restForModelClass:(Class)modelClass
              requestType:(RestRequestType)requestType
                requestId:(NSString *)requestId
               parameters:(NSDictionary *)parameters
                  headers:(NSDictionary *)headers
                    realm:(RLMRealm *)realm
          realmIdentifier:(NSString *)realmIdentifier
                 userInfo:(NSDictionary *)userInfo;

- (void)restForObject:(RLMObject <RestModelObjectProtocol> *)object
          requestType:(RestRequestType)requestType
            requestId:(NSString *)requestId
           parameters:(NSDictionary *)parameters
              headers:(NSDictionary *)headers
                realm:(RLMRealm *)realm
      realmIdentifier:(NSString *)realmIdentifier
             userInfo:(NSDictionary *)userInfo;

@end