class AboutController < UIViewController
  def viewDidLoad
    super
    self.title = "About"
    self.view.backgroundColor = UIColor.whiteColor

    homeButton = UIBarButtonItem.alloc.initWithTitle('Back', style:UIBarButtonItemStyleDone, target:self, action:'back')
    self.navigationItem.leftBarButtonItem = homeButton
  end

  def back
    self.navigationController.popViewControllerAnimated(animated:true)
  end
end