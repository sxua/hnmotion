class PostsController < UITableViewController
  attr_accessor :posts, :page

  def viewDidLoad
    super
    self.title = 'Hacker News'
    @posts, @page = [], 1

    Post.loadAllInto(:@posts, withPage:@page, delegate:self)

    @refreshHeaderView ||= begin
      viewSize = self.tableView.bounds.size
      header = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - viewSize.height, viewSize.width, viewSize.height))
      header.delegate = self
      header.refreshLastUpdatedDate
      header
    end

    self.tableView.addSubview(@refreshHeaderView)

    aboutButton = UIBarButtonItem.alloc.initWithTitle('About', style:UIBarButtonItemStyleBordered, target:self, action:'about')
    self.navigationItem.rightBarButtonItem = aboutButton
  end

  def about
    self.navigationController.pushViewController(AboutController.new, animated:true)
  end

  # TableView

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    post = @posts[indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier("Cell") || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:"Cell")
    cell.textLabel.text = "#{indexPath.row + 1}. #{post.title}"
    cell.detailTextLabel.text = post.description
    cell
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @posts.count
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    post = @posts[indexPath.row]
    self.navigationController.pushViewController(PostController.alloc.initWithObject(post), animated:true)
  end

  # ReloadTableView

  def reloadTableViewDataSource
    Post.loadAllInto(:@posts, withPage:@page, delegate:self)
    @reloading = true
  end

  def doneReloadingTableViewData
    @reloading = false
    @refreshHeaderView.refreshScrollViewDataSourceDidFinishLoading(self.tableView)
  end

  # ScrollView

  def scrollViewDidScroll(scrollView)
    @refreshHeaderView.refreshScrollViewDidScroll(scrollView)
  end

  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end

  # RefreshTableHeader

  def refreshTableHeaderDidTriggerRefresh(view)
    self.reloadTableViewDataSource
    self.performSelector('doneReloadingTableViewData', withObject:nil, afterDelay:2)
  end

  def refreshTableHeaderDataSourceIsLoading(view)
    @reloading
  end

  def refreshTableHeaderDataSourceLastUpdated(view)
    NSDate.date
  end
end