//
//  ViewController.h
//  SideProject
//
//  Created by E420_25 on 2024/12/20.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// 4x4 遊戲棋盤的格子
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *gridButtons;

// 分數顯示 Label
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

// 最高分數顯示 Label
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;

// 滑動手勢處理方法
- (IBAction)handleSwipeUp:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleSwipeDown:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender;

@end
