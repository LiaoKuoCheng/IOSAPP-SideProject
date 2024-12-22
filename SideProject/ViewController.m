//
//  ViewController.m
//  SideProject
//
//  Created by E420_25 on 2024/12/20.
//

#import "ViewController.h"

@interface ViewController ()

// 私有邏輯方法宣告
- (void)moveTilesInDirection:(NSString *)direction;
- (NSMutableArray *)mergeLine:(NSMutableArray *)line;
- (void)checkGameOver;
// 遊戲棋盤 4x4 的數字陣列
@property (nonatomic, strong) NSMutableArray *board;
// 分數
@property (nonatomic, assign) NSInteger score;

// 最高分數
@property (nonatomic, assign) NSInteger highScore; // 最高分數

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

     // 判斷是否存在最高分數，若不存在則設定為 0
     if (![[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"]) {
         [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highScore"];
         [[NSUserDefaults standardUserDefaults] synchronize];
     }

     // 載入保存的最高分數
     self.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];

     self.highScoreLabel.adjustsFontSizeToFitWidth = YES;
     self.highScoreLabel.minimumScaleFactor = 0.5;
     self.highScoreLabel.lineBreakMode = NSLineBreakByClipping;

     // 初始化遊戲棋盤
     [self initializeGame];
}

#pragma mark - 初始化遊戲邏輯

- (void)initializeGame {
    self.score = 0;
    self.board = [NSMutableArray array];
    
    // 初始化 4x4 棋盤為 0
    for (int i = 0; i < 4; i++) {
        NSMutableArray *row = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, nil];
        [self.board addObject:row];
    }
    
    // 添加兩個隨機數字
    [self addRandomTile];
    [self addRandomTile];
    
    [self updateUI];
}

// 隨機在棋盤上新增一個 2 或 4
- (void)addRandomTile {
    NSMutableArray *emptyTiles = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if ([self.board[i][j] integerValue] == 0) {
                [emptyTiles addObject:@[@(i), @(j)]];
            }
        }
    }
    
    if (emptyTiles.count > 0) {
        NSInteger randomIndex = arc4random_uniform((uint32_t)emptyTiles.count);
        NSArray *tilePosition = emptyTiles[randomIndex];
        NSInteger row = [tilePosition[0] integerValue];
        NSInteger col = [tilePosition[1] integerValue];
        self.board[row][col] = @(arc4random_uniform(10) < 9 ? 2 : 4);
    }
}

#pragma mark - 更新 UI

- (void)updateUI {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            UIButton *button = self.gridButtons[i * 4 + j];
            NSInteger value = [self.board[i][j] integerValue];
            NSString *title = value > 0 ? [NSString stringWithFormat:@"%ld", (long)value] : @"";
            [button setTitle:title forState:UIControlStateNormal];
            button.backgroundColor = [self colorForValue:value];
        }
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.score];
    
    // 更新最高分數顯示
    if (self.score > self.highScore) {
        self.highScore = self.score; // 更新最高分數
        [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:@"highScore"]; // 儲存最高分數
        [[NSUserDefaults standardUserDefaults] synchronize]; // 強制同步
    }
    self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld", (long)self.highScore];
}

- (UIColor *)colorForValue:(NSInteger)value {
    switch (value) {
        case 0: return [UIColor lightGrayColor];
        case 2: return [UIColor colorWithRed:0.93 green:0.89 blue:0.85 alpha:1.0];
        case 4: return [UIColor colorWithRed:0.93 green:0.87 blue:0.78 alpha:1.0];
        case 8: return [UIColor colorWithRed:0.95 green:0.69 blue:0.47 alpha:1.0];
        case 16: return [UIColor colorWithRed:0.96 green:0.58 blue:0.39 alpha:1.0];
        case 32: return [UIColor colorWithRed:0.96 green:0.48 blue:0.37 alpha:1.0];
        case 64: return [UIColor colorWithRed:0.96 green:0.36 blue:0.21 alpha:1.0];
        case 128: return [UIColor colorWithRed:0.93 green:0.81 blue:0.45 alpha:1.0];
        case 256: return [UIColor colorWithRed:0.93 green:0.75 blue:0.29 alpha:1.0];
        case 512: return [UIColor colorWithRed:0.93 green:0.68 blue:0.21 alpha:1.0];
        default: return [UIColor colorWithRed:0.70 green:0.50 blue:0.40 alpha:1.0];
    }
}

#pragma mark - 手勢邏輯

// 處理滑動方向
- (IBAction)handleSwipeUp:(UISwipeGestureRecognizer *)sender {
    [self moveTilesInDirection:@"up"];
}

- (IBAction)handleSwipeDown:(UISwipeGestureRecognizer *)sender {
    [self moveTilesInDirection:@"down"];
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender {
    [self moveTilesInDirection:@"left"];
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender {
    [self moveTilesInDirection:@"right"];
}

// 處理邏輯合併
- (void)moveTilesInDirection:(NSString *)direction {
    BOOL moved = NO;

    for (int i = 0; i < 4; i++) {
        NSMutableArray *line = [NSMutableArray array];
        // 提取行或列數據
        for (int j = 0; j < 4; j++) {
            NSInteger value = ([direction isEqualToString:@"up"] || [direction isEqualToString:@"down"])
                ? [self.board[j][i] integerValue]
                : [self.board[i][j] integerValue];
            if (value != 0) [line addObject:@(value)];
        }
        
        // 合併數據
        NSMutableArray *mergedLine = [self mergeLine:line];

        // 比較新舊數據，確定是否有移動
        for (int j = 0; j < 4; j++) {
            NSInteger oldValue = ([direction isEqualToString:@"up"] || [direction isEqualToString:@"down"])
                ? [self.board[j][i] integerValue]
                : [self.board[i][j] integerValue];

            NSInteger newValue = (j < mergedLine.count) ? [mergedLine[j] integerValue] : 0;

            if (oldValue != newValue) moved = YES;

            // 回寫數據到棋盤
            if ([direction isEqualToString:@"up"]) self.board[j][i] = @(newValue);
            else if ([direction isEqualToString:@"down"]) self.board[3 - j][i] = @(newValue);
            else if ([direction isEqualToString:@"left"]) self.board[i][j] = @(newValue);
            else if ([direction isEqualToString:@"right"]) self.board[i][3 - j] = @(newValue);
        }
    }

    // 若有移動，則新增隨機數字並更新 UI
    if (moved) {
        [self addRandomTile];
        [self updateUI];
        [self checkGameOver];
    }
}

- (NSMutableArray *)mergeLine:(NSMutableArray *)line {
    NSMutableArray *newLine = [NSMutableArray array];
    NSInteger skipIndex = -1; // 紀錄上一個已合併的索引

    for (int i = 0; i < line.count; i++) {
        if (skipIndex == i) continue; // 跳過已合併的數字

        NSInteger currentValue = [line[i] integerValue];
        if (i + 1 < line.count && currentValue == [line[i + 1] integerValue]) {
            NSInteger mergedValue = currentValue * 2;
            [newLine addObject:@(mergedValue)]; // 合併後的數值
            self.score += mergedValue;         // 更新分數
            skipIndex = i + 1;                 // 標記下一個數字跳過
        } else {
            [newLine addObject:@(currentValue)];
        }
    }

    // 補齊 0，確保長度為 4
    while (newLine.count < 4) {
        [newLine addObject:@0];
    }
    return newLine;
}

#pragma mark - 遊戲結束邏輯

- (void)checkGameOver {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if ([self.board[i][j] integerValue] == 0) return; // 還有空格
            if (j < 3 && [self.board[i][j] integerValue] == [self.board[i][j + 1] integerValue]) return; // 水平可合併
            if (i < 3 && [self.board[i][j] integerValue] == [self.board[i + 1][j] integerValue]) return; // 垂直可合併
        }
    }
    NSLog(@"Game Over!");
    
    NSString *message = [NSString stringWithFormat:@"遊戲結束！\n得分: %ld", (long)self.score];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *restart = [UIAlertAction actionWithTitle:@"重新開始" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self initializeGame];
    }];
    [alert addAction:restart];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
