#import "AssetHelper.h"

@implementation AssetHelper

+ (void)saveAsset:(AVURLAsset *)asset rate:(CGFloat)rate {
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    NSError *videoInsertError = nil;
    BOOL videoInsertResult = [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:&videoInsertError];
    if (!videoInsertResult || nil != videoInsertError) {
      return;
    }

    NSError *audioInsertError = nil;
    BOOL audioInsertResult = [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:&audioInsertError];
    if (!audioInsertResult || nil != audioInsertError) {
      return;
    }

    CMTime videoDuration = asset.duration;
    double factor = ((double)videoDuration.value / rate);

    [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration) toDuration:CMTimeMake(factor, videoDuration.timescale)];
    [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration) toDuration:CMTimeMake(factor, videoDuration.timescale)];
    [compositionVideoTrack setPreferredTransform:track.preferredTransform];

    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:@"mov"];

    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    assetExport.outputURL = fileURL;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        id completionHandler = [[AssetHelper alloc] init];
        UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path, completionHandler, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
    }
}
@end