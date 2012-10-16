# SorryApp Example for iOS

SorryApp is simple announcement service for iOS App.

Like this. 

![](http://tobioka.net/wp-content/uploads/2012/10/sorryapp.png)

## How to use

### Get API key

1. Access to <http://sorryapp.net/>.
2. Sign in with GitHub.
3. Go to "Register App" page by upper right menu. 
4. Input "App Store URI" (for publised ppp) or "App Name" (for developing app).
5. API Key is in the lowest part of "App page".

### Add Library
 
* Copy `SAMessageView` to your projects.
* Add `QuartzCore.framework` in Build Phases.
* Import `SAMessageView.h`.
* Write code.

    SAMessageView *messageView = [[SAMessageView alloc] initWithParentView:self.navigationController.view];
    messageView.apiKey = @"923111a2216e0d71216a26f5a116e316206959c9";
    messageView.alertWhenError = YES;
    [messageView show];
	
### Powerd by SorryApp

* [Naming Memo](https://itunes.apple.com/us/app/naming-memo/id568420416?mt=8)