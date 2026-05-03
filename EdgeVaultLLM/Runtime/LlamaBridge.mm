#import "LlamaBridge.hpp"

static NSString * const EdgeVaultLlamaErrorDomain = @"EdgeVaultLlamaErrorDomain";

@implementation LlamaGenerationResult
@end

@interface LlamaBridge ()
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL stopRequested;
@property (nonatomic, assign) BOOL mmapEnabled;
@end

@implementation LlamaBridge

- (instancetype)init {
    self = [super init];
    if (self) {
        _loaded = NO;
        _stopRequested = NO;
        _mmapEnabled = YES;
    }
    return self;
}

- (BOOL)loadModelAtPath:(NSString *)path mmapEnabled:(BOOL)mmapEnabled error:(NSError **)error {
    if (path.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:EdgeVaultLlamaErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"Empty model path."}];
        }
        return NO;
    }

    // TODO: Replace stub with llama.cpp load and params.use_mmap = mmapEnabled.
    self.loaded = YES;
    self.mmapEnabled = mmapEnabled;
    return YES;
}

- (void)unloadModel {
    self.loaded = NO;
}

- (nullable LlamaGenerationResult *)generate:(NSString *)prompt
                              contextLength:(int32_t)contextLength
                                  maxTokens:(int32_t)maxTokens
                                temperature:(float)temperature
                                       topP:(float)topP
                                    onToken:(void (^ _Nullable)(NSString *token))onToken
                                      error:(NSError **)error {
    if (!self.loaded) {
        if (error) {
            *error = [NSError errorWithDomain:EdgeVaultLlamaErrorDomain code:2 userInfo:@{NSLocalizedDescriptionKey: @"Model not loaded."}];
        }
        return nil;
    }

    self.stopRequested = NO;
    NSDate *start = [NSDate date];
    double firstTokenMs = 0.0;

    NSString *output = [NSString stringWithFormat:@"[Stub response] Local inference placeholder for: %@", prompt];
    NSArray<NSString *> *tokens = [output componentsSeparatedByString:@" "];
    NSMutableString *assembled = [NSMutableString string];

    for (NSUInteger i = 0; i < tokens.count && (int32_t)i < maxTokens; i++) {
        if (self.stopRequested) { break; }
        NSString *token = [tokens objectAtIndex:i];
        if (i == 0) { firstTokenMs = [[NSDate date] timeIntervalSinceDate:start] * 1000.0; }
        [assembled appendString:token];
        if (i + 1 < tokens.count) { [assembled appendString:@" "]; }
        if (onToken) { onToken(token); }
    }

    double durationMs = [[NSDate date] timeIntervalSinceDate:start] * 1000.0;
    LlamaGenerationResult *result = [LlamaGenerationResult new];
    result.text = assembled;
    result.tokens = (NSInteger)MIN((int32_t)tokens.count, maxTokens);
    result.durationMs = durationMs;
    result.firstTokenMs = firstTokenMs;

    (void)contextLength;
    (void)temperature;
    (void)topP;

    return result;
}

- (void)stopGeneration {
    self.stopRequested = YES;
}

- (NSString *)runtimeBackend {
    return @"cpu";
}

@end
