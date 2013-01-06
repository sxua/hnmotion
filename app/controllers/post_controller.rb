class PostController < UIViewController
  attr_accessor :post
  attr_accessor :webView, :bottomBar, :bottomBarButtons
  attr_accessor :activityIndicator, :forwardButton, :backButton, :stopButton, :reloadButton, :actionButton

  def viewDidLoad
    super
    self.title = @post.title
    @webView = UIWebView.alloc.initWithFrame(CGRectMake(0, 0, 320, 372))
    @webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    @webView.scalesPageToFit = true
    @webView.delegate = self
    self.view.addSubview(@webView)

    popButton = UIBarButtonItem.alloc.initWithTitle('Back', style:UIBarButtonItemStyleDone, target:self, action:'popButtonPressed')
    self.navigationItem.leftBarButtonItem = popButton
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(@activityIndicator)

    self.view.addSubview(@bottomBar)

    @webView.loadRequest(NSURLRequest.requestWithURL(@post.url))
    self.updateBottomBar
  end

  def viewDidUnload
    self.navigationItem.setRightBarButtonItem(nil)
    super
  end

  def initWithObject(object)
    @post = object

    @activityIndicator = UIActivityIndicatorView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20))
    @backButton = UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed('left.png'), style:UIBarButtonItemStylePlain, target:self, action:'backButtonPressed')
    @forwardButton = UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed('right.png'), style:UIBarButtonItemStylePlain, target:self, action:'forwardButtonPressed')
    @stopButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:'stopReloadButtonPressed')
    @reloadButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:self, action:'stopReloadButtonPressed')
    @actionButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButtonPressed')

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
    @bottomBarButtons = [ @backButton, flexibleSpace, @forwardButton, flexibleSpace, @reloadButton, flexibleSpace, @actionButton ]

    @bottomBar = UIToolbar.alloc.initWithFrame(CGRectMake(0, 372, 0, 0))
    @bottomBar.barStyle = UIBarStyleBlackTranslucent
    @bottomBar.sizeToFit
    @bottomBar.setItems(@bottomBarButtons, animated:false)

    self.initWithNibName(nil, bundle:nil)
  end

  def updateBottomBar
    @forwardButton.enabled = @webView.canGoForward
    @backButton.enabled = @webView.canGoBack
    @bottomBarButtons[4] = @activityIndicator.isAnimating ? @stopButton : @reloadButton
    @bottomBar.setItems(@bottomBarButtons, animated:false)
  end

  def backButtonPressed
    @webView.goBack if @webView.canGoBack
  end

  def forwardButtonPressed
    @webView.goForward if @webView.canGoForward
  end

  def stopReloadButtonPressed
    if @activityIndicator.isAnimating
      @webView.stopLoading
      @activityIndicator.stopAnimating
    else
      @webView.loadRequest(NSURLRequest.requestWithURL(@post.url))
    end
    self.updateBottomBar
  end

  def actionButtonPressed
    UIApplication.sharedApplication.openURL(@post.url)
  end

  def popButtonPressed
    self.navigationController.popViewControllerAnimated(animated:true)
  end

  def webViewDidStartLoad(webView)
    @activityIndicator.startAnimating
    self.updateBottomBar
  end

  def webViewDidFinishLoad(webView)
    @activityIndicator.stopAnimating if @activityIndicator
    self.updateBottomBar
  end

  def webView(webView, didFailLoadWithError:error)
    self.updateBottomBar
  end
end