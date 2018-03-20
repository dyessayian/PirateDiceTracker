//
//  DRYMainViewController.m
//  PiratesDiceTracker
//
//  Created by Daniel Yessayian on 10/24/15.
//  Copyright © 2015 Daniel Yessayian. All rights reserved.
//

#import "DRYMainViewController.h"
#import "DRYPirateDrawerTableViewCell.h"

@interface DRYMainViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSInteger currentCount;
@property (nonatomic, strong) NSMutableArray *probabilityDataSource;
@property (weak, nonatomic) IBOutlet UITableView *probabilityTableView;
@property (weak, nonatomic) IBOutlet UILabel *chanceCorrectLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawerLeadingConstraint;
@property (nonatomic) BOOL drawerIsOpen;
@property (nonatomic) BOOL drawerIsAnimating;

//IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIView *drawerView;
@property (weak, nonatomic) IBOutlet UIButton *diceButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIImageView *helpOverlayImageView;

@end

@implementation DRYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Analytics
    self.screenName = @"Main Screen";
    
    [self performInitialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
- (IBAction)diceButtonTapped:(UIButton *)sender {
    [self decrementCurrentCount];
}

- (IBAction)mapButtonTapped:(UIButton *)sender {
    //NSLog(@"Drawer is open?: %d", self.drawerIsOpen);
    if (self.helpOverlayImageView.hidden == YES){
        [self setProbabilityDrawerOpen:!self.drawerIsOpen];
    } else {
        NSLog(@"Close the help view first.");
    }
}

- (IBAction)helpButtonTapped:(UIButton *)sender {
    //NSLog(@"Help button tapped");
    if (self.drawerIsAnimating == FALSE && !self.drawerIsOpen){
        [self.helpOverlayImageView setHidden:!self.helpOverlayImageView.hidden];
    }
    else {
        NSLog(@"Wait until animation finishes.");
    }
}

#pragma mark - Helper Methods
-(void)performInitialSetup {
    //Initialize array
    self.probabilityDataSource = [NSMutableArray new];
    
    //Default dice count to 20
    self.currentCount = 20;
    
    //Register Xib
    [self.probabilityTableView registerNib:[UINib nibWithNibName:@"DRYPirateDrawerTableViewCell" bundle:nil] forCellReuseIdentifier:@"PirateCell"];
    
    //Setup Gestures for drawer and button counter.
    [self swipeGestureSetup];
    
    [self.helpButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.helpButton.imageView setImage:[UIImage imageNamed:@"PiratesDice_hookhelp.png"]];
    
    //Setup Gestures for tap on help overlay
    [self tapGestureSetup];
}

-(void)decrementCurrentCount {
    if (self.currentCount > 1){
        self.currentCount -= 1;
    }
}

-(void)incrementCurrentCount {
    if (self.currentCount < 99){
        self.currentCount += 1;
    }
}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.diceButton)){
        return NO;
    }
    return YES;
}

#pragma mark - Helper Methods
-(void) tapGestureSetup {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(helpOverlayTapped:)];
    [self.helpOverlayImageView addGestureRecognizer:tapGesture];
}

-(void) helpOverlayTapped:(UIGestureRecognizer*)gestureRecognizer {
    [self.helpOverlayImageView setHidden:!self.helpOverlayImageView.hidden];
}

-(void) swipeGestureSetup {
    
    //Screen Swipe Left: open the drawer
    UISwipeGestureRecognizer * swipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenSwipe:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    //Screen Swipe Right: close the drawer
    UISwipeGestureRecognizer * swiperight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenSwipe:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    //Swipe up on button dice counter
    UISwipeGestureRecognizer * swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.diceButton addGestureRecognizer:swipeUp];
    
    //Swipe down on button dice counter
    UISwipeGestureRecognizer * swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.diceButton addGestureRecognizer:swipeDown];
    
    //Long Press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.diceButton addGestureRecognizer:longPress];
}

-(void) buttonSwipe:(UISwipeGestureRecognizer*)gestureRecognizer {
    //NSLog(@"Button swiped");
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp){
        //NSLog(@"Increment");
        [self incrementCurrentCount];
    }
    else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown){
        //NSLog(@"Decrement!");
        [self decrementCurrentCount];
    }
}

-(void) screenSwipe:(UISwipeGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        [self setProbabilityDrawerOpen:YES];
    }
    else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
        [self setProbabilityDrawerOpen:NO];
    }
}

-(void) longPress:(UISwipeGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        //NSLog(@"Long press!");
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Set Dice Number"
                                      message:@"Choose what number of dice you'd like to start at (1-99)"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* setDiceAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                                //NSLog(@"The alert textfields: %@", alert.textFields);
                                                                NSString *diceCountEntered = [[alert.textFields firstObject] text];
                                                                
                                                                 if ([diceCountEntered integerValue] >= 1 && [diceCountEntered integerValue] <= 99){
                                                                     [self.diceButton setTitle:diceCountEntered forState:UIControlStateNormal];
                                                                     self.currentCount = [diceCountEntered integerValue];
                                                                     [self populateProbabilityArray];
                                                                 }
                                                                 else {
                                                                     //NSLog(@"Not valid");
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }
                                                             }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:cancelAction];
        [alert addAction:setDiceAction];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Dice Count";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void)setCurrentCount:(NSInteger)currentCount {
    //When the current count is updated, the label updates automatically.
    _currentCount = currentCount;
    [self.diceButton setTitle:[NSString stringWithFormat:@"%ld", (long)_currentCount] forState:UIControlStateNormal];
    [self populateProbabilityArray];
}


- (void) setProbabilityDrawerOpen: (BOOL)open {
    //NSLog(@"Sent: %d", open);
    if (!self.drawerIsAnimating){
        if (open){
            [UIView animateWithDuration:1.0 animations:^{
                //NSLog(@"Animating opening");
                self.drawerIsAnimating = YES;
                self.drawerLeadingConstraint.constant = -self.drawerView.frame.size.width; //548
                [self.view layoutIfNeeded];
                [self.mapButton layoutIfNeeded];
                
            } completion:^(BOOL finished) {
                //NSLog(@"Done opening");
                self.drawerIsAnimating = NO;
                self.drawerIsOpen = YES;
            }];
        }
        else {
            [UIView animateWithDuration:1.0 animations:^{
                //NSLog(@"Animating closed");
                self.drawerIsAnimating = YES;
                self.drawerLeadingConstraint.constant = 0; //1024
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                //NSLog(@"Done closing.");
                self.drawerIsAnimating = NO;
                self.drawerIsOpen = NO;
            }];
        }
    }
    else {
        //NSLog(@"Wait until animation is complete.");
    }
}


#pragma mark -
#pragma mark - Calculations
-(long double)factorial:(float)number1 {
    //First factorial attempt.  Overflows at n=35+, so switching to use alternate.
    return tgammaf(++number1);
}

- (long double) alternateFactorial: (float)factorialNumber {
    //Calculate and return factorial for: n!
    long double theVal = 0.0;
    for (int i = 0; i < 5; i++){
        long double product = 1;
        for (int j = factorialNumber; j > 0; j--){
            product *= j;
        }
        theVal = product;
    }
    return theVal;
}

- (long double) calculateChancesForAtLeast:(int)value withDiceRemaining:(NSInteger)diceCount AndPopulateArray:(BOOL)populate{
    
    //     n!
    // ---------- *  (1/3)^x * (2/3)^(n-x)
    // (n-x)!(x)!
    //  firstComp *     secondComponent
    
    //Initialize values
    long double totalChance = 0.0;
    long double firstComponent = 0.0;
    long double secondComponent = 0.0;
    long double totalToAdd = 0.0;
    
    if (populate){
        //Clear the array
        self.probabilityDataSource = [NSMutableArray new];
    }
    
    for (int i = value; i < diceCount+1; i++){
        
        firstComponent = [self alternateFactorial:diceCount] / ([self alternateFactorial:(diceCount - i)]*[self alternateFactorial:i]);
        
        secondComponent = (long double)powf(1.0/3.0, i) * (long double)powf(2.0/3.0, (diceCount-i));
        
        totalToAdd = firstComponent * secondComponent;
        
        totalChance += totalToAdd;
        
        if (populate){
            //Add the probability to the array.
            [self.probabilityDataSource addObject:[NSString stringWithFormat:@"%.3Lf", totalToAdd*100]];
            //NSLog(@"The total chance of getting %d out of %ld is: %Lf", i, (long)diceCount, totalToAdd);
        }
    }
    //NSLog(@"Returning %Lf", totalChance);
    return totalChance;
}

- (void) populateProbabilityArray {
    
    NSInteger totalDiceCount = self.currentCount;
    int specificDiceCount = 1;
    [self calculateChancesForAtLeast:specificDiceCount withDiceRemaining:totalDiceCount AndPopulateArray:YES];
    //NSLog(@" After, the array is : %@", self.probabilityDataSource);
    [self.probabilityTableView reloadData];
}

#pragma mark -
#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DRYPirateDrawerTableViewCell *cell = (DRYPirateDrawerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PirateCell"];
    if (cell == nil) {
        cell = [[DRYPirateDrawerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PirateCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.cellDiceLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    cell.cellProbabilityLabel.text = [NSString stringWithFormat:@"%@", [self.probabilityDataSource objectAtIndex:indexPath.row]];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.probabilityDataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Selected value: %@", [self.probabilityDataSource objectAtIndex:indexPath.row]);
    //NSLog(@"The # of dice bet: %ld", indexPath.row+1);
    int diceBet = (int)(indexPath.row + 1);
    long double chance = [self calculateChancesForAtLeast:diceBet withDiceRemaining:self.currentCount AndPopulateArray:NO];
    //NSLog(@"The chance you are right: %Lf", chance*100);
    
    [self.chanceCorrectLabel setHidden:NO];
    [self.chanceCorrectLabel setAlpha:1.0];
    [self.chanceCorrectLabel setText:[NSString stringWithFormat:@"AHOY! THERE'S A %.3Lf%% CHANCE OF WINNING, MATEY!", chance*100]];
    
    [UIView animateWithDuration:3.0 animations:^{
        self.chanceCorrectLabel.alpha = 0;
    }];
}



@end











