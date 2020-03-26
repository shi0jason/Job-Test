//
//  ViewController.m
//  FlickrPhoto
//
//  Created by cch on 2020/3/13.
//  Copyright © 2020 cch. All rights reserved.
//

#import "MainViewController.h"
#import "FlickrKit.h"
#import "PhotoDisplayController.h"
#import "JSDataManager.h"

@interface MainViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *contentTextInput;
@property (weak, nonatomic) IBOutlet UITextField *contentDisplayCountInput;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;
@property (nonatomic, retain) FKDUNetworkOperation *checkAuthOp;

@property (nonatomic, retain) NSString *userID;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentTextInput.delegate = self;
    _contentDisplayCountInput.delegate = self;
    
    [_contentTextInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_contentDisplayCountInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];
    
    self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self userLoggedIn:userName userID:userId];
            } else {
                [self userLoggedOut];
            }
        });
    }];
}
- (IBAction)searchClick:(id)sender {
    FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
    search.text = self.contentTextInput.text;
    search.per_page = self.contentDisplayCountInput.text;
    [JSDataManager shareInstance].searchItemName = self.contentTextInput.text;
    
    [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response) {
                NSMutableArray *photoURLs = [NSMutableArray array];
                NSMutableArray *photoTitles = [NSMutableArray array];
                for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
                    NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoDictionary];
                    [photoURLs addObject:url];
                    [photoTitles addObject:[photoDictionary objectForKey:@"title"]];
                }
                if ([JSDataManager shareInstance].photoURLs.count > 0) {
                    [[JSDataManager shareInstance].photoURLs removeAllObjects];
                }
                [JSDataManager shareInstance].photoURLs = [NSMutableArray arrayWithArray:photoURLs];
                if ([JSDataManager shareInstance].photoURLs.count > 6) {
                    [[JSDataManager shareInstance].photoURLs addObject:photoURLs.firstObject];
                    [[JSDataManager shareInstance].photoURLs insertObject:photoURLs.lastObject atIndex:0];
                }
                
                if ([JSDataManager shareInstance].photoTitles.count > 0) {
                    [[JSDataManager shareInstance].photoTitles removeAllObjects];
                }
                [JSDataManager shareInstance].photoTitles = [NSMutableArray arrayWithArray:photoTitles];
                if ([JSDataManager shareInstance].photoTitles.count > 6) {
                    [[JSDataManager shareInstance].photoTitles addObject:photoTitles.firstObject];
                    [[JSDataManager shareInstance].photoTitles insertObject:photoTitles.lastObject atIndex:0];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DataProccessed" object:nil];
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:error.localizedDescription
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"cancel"
                                                                 style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        });
    }];
}
#pragma mark - Auth
- (void) userAuthenticateCallback:(NSNotification *)notification {
    NSURL *callbackURL = notification.object;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self userLoggedIn:userName userID:userId];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
}

- (void) userLoggedIn:(NSString *)username userID:(NSString *)userID {
    self.userID = userID;
}

- (void) userLoggedOut {
}
#pragma mark - TextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField {
    if (_contentTextInput == textField) {
        _contentTextInput.text = textField.text;
    }
    if (_contentDisplayCountInput == textField) {
        _contentDisplayCountInput.text = textField.text;
    }
    if (_contentTextInput.text.length > 0 && _contentDisplayCountInput.text.length > 0) {
        [_searchButton setBackgroundColor:UIColor.blueColor];
        [_searchButton setEnabled:true];
    } else {
        [_searchButton setBackgroundColor:UIColor.redColor];
        [_searchButton setEnabled:false];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _contentDisplayCountInput) {
        return [self validateNumber:string];
    }
    return true;
}
- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
@end
