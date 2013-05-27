//
//  HomeViewController.m
//  TestMediaPickerController
//
//  Created by Mike Chen on 13-5-27.
//  Copyright (c) 2013年 Mike Chen. All rights reserved.
//

#import "HomeViewController.h"


@interface HomeViewController ()

@property (nonatomic , retain) MPMusicPlayerController *myMusicPlayer;
@property (nonatomic , retain) UIButton *buttonPickAndPlay;
@property (nonatomic , retain) UIButton *buttonStopPlaying;

@end

@implementation HomeViewController
@synthesize buttonPickAndPlay = _buttonPickAndPlay;
@synthesize buttonStopPlaying = _buttonStopPlaying;

- (void)dealloc
{
    [_myMusicPlayer release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPlayingAudio];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"音频库";
	// Do any additional setup after loading the view.
    self.buttonPickAndPlay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_buttonPickAndPlay setFrame:CGRectMake(50, 100, 120, 40)];
    [_buttonPickAndPlay setTitle:@"选择&播放" forState:UIControlStateNormal];
    [self.buttonPickAndPlay addTarget:self action:@selector(displayMediaPickerAndPlayItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonPickAndPlay];
    
    self.buttonStopPlaying = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_buttonStopPlaying setFrame:CGRectMake(50, 150, 120, 40)];
    [_buttonStopPlaying setTitle:@"停止播放" forState:UIControlStateNormal];
    [_buttonStopPlaying addTarget:self action:@selector(stopPlayingAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonStopPlaying];
//    self.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - 似有方法 - 似有函数

- (void)stopPlayingAudio
{
    if (self.myMusicPlayer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.myMusicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.myMusicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:self.myMusicPlayer];
        [self.myMusicPlayer stop];
    }
}

- (void)nowPlayingItemsIsChanged:(NSNotification *)paramNotification
{
    NSLog(@"Playing Items is Changed!");
    NSString *persistentId = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerNowPlayingItemPersistentIDKey"];
    NSLog(@"得到一个很奇怪的东西:persistentId = %@",persistentId);
}

- (void)musicPlayerStateChanged:(NSNotification *)paramNotification
{
    NSLog(@"Player State Changed");
    NSNumber *stateAsObject = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    NSInteger state = [stateAsObject integerValue];
    switch (state) {
        case MPMusicPlaybackStateStopped:{
            NSLog(@"MPMusicPlaybackStateStopped");
        }
            break;
        case MPMusicPlaybackStatePlaying:{
            NSLog(@"正在播放...");
        }
            break;
        case MPMusicPlaybackStatePaused:{
            NSLog(@"暂停播放");
        }
            break;
        case MPMusicPlaybackStateInterrupted:{
            NSLog(@"中断播放");
        }
            break;
        case MPMusicPlaybackStateSeekingForward:{
            NSLog(@"正在快进");
        }
            break;
        case MPMusicPlaybackStateSeekingBackward:{
            NSLog(@"正在快退");
        }
            break;
        default:
            break;
    }
}

- (void)volumeIsChanged:(NSNotification *)paramNotification
{
    NSLog(@"音量改变");
    //正常情况下，paramNotification.userInfo为空
}

#pragma mark
#pragma mark - 私有方法 - 响应事件

- (void)displayMediaPickerAndPlayItem
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    if (mediaPicker) {
        NSLog(@"创建音频库成功!");
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        [self.navigationController presentViewController:mediaPicker animated:YES completion:^(void){}];
    } else{
        NSLog(@"创建音频库失败!");
    }
}

- (void)displayMediaPicker
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    if (mediaPicker) {
        NSLog(@"创建媒体库成功!");
        mediaPicker.delegate = (id<MPMediaPickerControllerDelegate>)self;
        mediaPicker.allowsPickingMultipleItems = NO;
        [self.navigationController presentViewController:mediaPicker animated:YES completion:^(void){}];
    } else{
        NSLog(@"不能创建媒体库!");
    }
}

#pragma mark
#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    self.myMusicPlayer = nil;
    self.myMusicPlayer = [[[MPMusicPlayerController alloc] init] autorelease];
    [self.myMusicPlayer beginGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.myMusicPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingItemsIsChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.myMusicPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeIsChanged:) name:MPMusicPlayerControllerVolumeDidChangeNotification object:self.myMusicPlayer];
    [self.myMusicPlayer setQueueWithItemCollection:mediaItemCollection];
    [self.myMusicPlayer play];
    [mediaPicker dismissViewControllerAnimated:YES completion:^(void){}];
/*
    for (MPMediaItem *thisItem in mediaItemCollection.items) {
        NSURL *itemUrl = [thisItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSString *itemTitle = [thisItem valueForProperty:MPMediaItemPropertyTitle];
        NSString *itemArtist = [thisItem valueForProperty:MPMediaItemPropertyArtist];
        MPMediaItemArtwork *itemArtwork = [thisItem valueForProperty:MPMediaItemPropertyArtwork];
        NSLog(@"文件路径:%@,标题:%@,艺术家:%@,鸟:%@",itemUrl,itemTitle,itemArtist,itemArtwork);
    }
    [mediaPicker dismissViewControllerAnimated:YES completion:^(void){}];
 */
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    NSLog(@"%s",__FUNCTION__);
    [mediaPicker dismissViewControllerAnimated:YES completion:^(void){}];
}

@end
