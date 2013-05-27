//
//  HomeViewController.h
//  TestMediaPickerController
//
//  Created by Mike Chen on 13-5-27.
//  Copyright (c) 2013年 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate>

@end
