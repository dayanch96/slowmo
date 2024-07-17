#import "AssetHelper.h"

// keep track of the rate
float rate = 1.00;

@interface ISAVPlayer : AVPlayer
@end

@interface ISWrappedAVPlayer
- (void)setRate:(float)arg1;
@end

@interface PXVideoSession
@property(nonatomic, readwrite, strong) AVPlayerItem *playerItem;
@end

@interface PUVideoTileViewController : NSObject
@property(nonatomic, readwrite, strong) PXVideoSession *videoSession;
@end

@interface PUOneUpViewController : UIViewController
- (id)_currentContentTileController;
@end

@interface PUNavigationController : UINavigationController
@property (nonatomic, weak, readwrite, setter=_setCurrentToolbarViewController:) PUOneUpViewController *_currentToolbarViewController;
@end

@interface PUExtendedToolbar : UIToolbar
@property(nonatomic, strong) UIBarButtonItem *item;
- (void)_setToolbarItems:(NSArray *)arg1;
- (void)rateChanged;
- (void)save:(AVURLAsset *)asset;
- (PUNavigationController *)_viewControllerForAncestor;
@end

@interface PUOneUpBarsController
@property(nonatomic) BOOL isShowingPlayPauseButton; // ivar: _isShowingPlayPauseButton``
@property(nonatomic, strong) UIBarButtonItem *item;
- (id)viewController;
- (void)rateChanged;
- (void)save:(id)arg1;
- (PUNavigationController *)_viewControllerForAncestor;
@end

%group iPad
%hook PUOneUpBarsController
%property(nonatomic, strong) UIBarButtonItem *item;
- (void)updateBars {
    %orig;

    if (self.isShowingPlayPauseButton) {
        PUOneUpViewController *controller = [self viewController];

        NSMutableArray *actions = [[NSMutableArray alloc] init];

        NSArray *speedTitles = @[@"0.25×", @"0.5×", @"0.75×", @"1×", @"1.25×", @"1.5×", @"1.75×", @"2×"];
        for (NSString *title in speedTitles) {
            float playbackRate = [title floatValue];

            UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                rate = playbackRate;
                self.item.title = title;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SlowMoChangeRateNotification" object:self];
            }];

            [actions addObject:action];
        }

        [actions addObject:[UIAction actionWithTitle:@"Save" image:[UIImage systemImageNamed:@"square.and.arrow.down.fill"] identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
            if (rate != 1.0) {
                PUVideoTileViewController *controller = [self._viewControllerForAncestor._currentToolbarViewController _currentContentTileController];
                [AssetHelper saveAsset:(AVURLAsset *)controller.videoSession.playerItem.asset rate:rate];
            } else {
                UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to save the video with 1x rate?" preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(
                    UIAlertAction *_Nonnull action){
                }];

                UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                    PUVideoTileViewController *controller = [self._viewControllerForAncestor._currentToolbarViewController _currentContentTileController];
                    [AssetHelper saveAsset:(AVURLAsset *)controller.videoSession.playerItem.asset rate:rate];
                }];

                [_alertController addAction:dismiss];
                [_alertController addAction:accept];
                [self._viewControllerForAncestor._currentToolbarViewController presentViewController:_alertController animated:YES completion:nil];
            }
        }]];

        UIMenu *menu = [UIMenu menuWithTitle:[NSString stringWithFormat:@"Playback Speed"] children:actions];

        NSString *rateTitle;
        if (rate == (NSInteger)rate) {
            rateTitle = [NSString stringWithFormat:@"%ld×", (NSInteger)rate];
        } else {
            rateTitle = [NSString stringWithFormat:@"%.2f×", rate];
        }

        self.item = [[UIBarButtonItem alloc] initWithTitle:rateTitle menu:menu];

        controller.navigationItem.rightBarButtonItems = [controller.navigationItem.rightBarButtonItems arrayByAddingObjectsFromArray:@[ self.item]];
    }
}
%end
%end

%group iPhone
%hook PUExtendedToolbar

%property(nonatomic, strong) UIBarButtonItem *item;

- (void)_setToolbarItems:(NSArray *)items {

    // Works only after interaction with Play/Pause
    // if ([self._viewControllerForAncestor isKindOfClass:%c(PUNavigationController)]) {
    //     PUNavigationController *nav = self._viewControllerForAncestor;
    //     if ([nav._currentToolbarViewController isKindOfClass:%c(PUOneUpViewController)]) {
    //         PUVideoTileViewController *tileVC = [nav._currentToolbarViewController _currentContentTileController];

    //         if (![tileVC isKindOfClass:%c(PUVideoTileViewController)]) {
    //             return %orig;
    //         }
    //     }
    // }

    BOOL isVideo = [items.description containsString:@"systemItem=Pause"] || [items.description containsString:@"systemItem=Play"] || [items.description containsString:@"system: pause.fill"] || [items.description containsString:@"system: play.fill"];

    if (!isVideo) {
        return %orig;
    }

    NSMutableArray *actions = [NSMutableArray array];

    [actions addObject:[UIAction actionWithTitle:@"Save" image:[UIImage systemImageNamed:@"square.and.arrow.down.fill"] identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
        if (rate != 1.0) {
            PUVideoTileViewController *controller = [self._viewControllerForAncestor._currentToolbarViewController _currentContentTileController];
            [AssetHelper saveAsset:(AVURLAsset *)controller.videoSession.playerItem.asset rate:rate];
        } else {
            UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to save the video with 1x rate?" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(
                UIAlertAction *_Nonnull action){
            }];

            UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                PUVideoTileViewController *controller = [self._viewControllerForAncestor._currentToolbarViewController _currentContentTileController];
                [AssetHelper saveAsset:(AVURLAsset *)controller.videoSession.playerItem.asset rate:rate];
            }];

            [_alertController addAction:dismiss];
            [_alertController addAction:accept];
            [self._viewControllerForAncestor._currentToolbarViewController presentViewController:_alertController animated:YES completion:nil];
        }
    }]];

    NSArray *speedTitles = @[@"0.25×", @"0.5×", @"0.75×", @"1×", @"1.25×", @"1.5×", @"1.75×", @"2×"];
    for (NSString *title in speedTitles) {
        float playbackRate = [title floatValue];

        UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            rate = playbackRate;
            self.item.title = title;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SlowMoChangeRateNotification" object:self];
        }];

        [actions addObject:action];
    }

    UIMenu *menu = [UIMenu menuWithTitle:[NSString stringWithFormat:@"Playback Speed"] children:actions];

    NSString *rateTitle;
    if (rate == (NSInteger)rate) {
        rateTitle = [NSString stringWithFormat:@"%ld×", (NSInteger)rate];
    } else {
        rateTitle = [NSString stringWithFormat:@"%.2f×", rate];
    }

    self.item = [[UIBarButtonItem alloc] initWithTitle:rateTitle menu:menu];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    %orig([items arrayByAddingObjectsFromArray:@[flexibleItem, self.item]]);
}
%end
%end

%hook ISAVPlayer
- (id)currentItem {
    AVPlayerItem *item = %orig;
    item.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed; // to allow flexibility for the rate
    return item;
}
%end

%hook ISWrappedAVPlayer
- (void)setRate:(float)arg1 {
    return %orig((arg1 == 0.0) ? arg1 : rate);
}

- (void)setLoopingEnabled:(BOOL)arg1 {
    %orig(YES);
}

- (id)_initWithAVPlayer:(id)arg1 {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRateNotification:) name:@"SlowMoChangeRateNotification" object:nil];
    return %orig;
}

%new
- (void)receiveRateNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"SlowMoChangeRateNotification"]) {
        [self setRate:rate];
    }
}
%end

%ctor {
    %init();
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        %init(iPhone);
    }
    
    else if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        %init(iPad);
    }
}
