#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LlamaGenerationResult : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger tokens;
@property (nonatomic, assign) double durationMs;
@property (nonatomic, assign) double firstTokenMs;
@end

@interface LlamaBridge : NSObject
- (BOOL)loadModelAtPath:(NSString *)path mmapEnabled:(BOOL)mmapEnabled error:(NSError **)error;
- (void)unloadModel;
- (nullable LlamaGenerationResult *)generate:(NSString *)prompt
                              contextLength:(int32_t)contextLength
                                  maxTokens:(int32_t)maxTokens
                                temperature:(float)temperature
                                       topP:(float)topP
                                    onToken:(void (^ _Nullable)(NSString *token))onToken
                                      error:(NSError **)error;
- (void)stopGeneration;
- (NSString *)runtimeBackend;
@end

NS_ASSUME_NONNULL_END
