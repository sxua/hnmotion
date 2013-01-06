class PostsController < UITableViewController
  attr_accessor :data

  def viewDidLoad
    super
    self.title = 'Hacker News'
    @data = []
    self.loadPosts

    @refreshHeaderView ||= begin
      view_size = self.tableView.bounds.size
      header = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - view_size.height, view_size.width, view_size.height))
      header.delegate = self
      header.refreshLastUpdatedDate
      header
    end

    self.tableView.addSubview(@refreshHeaderView)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    identifier = "Cell"
    cell = tableView.dequeueReusableCellWithIdentifier(identifier) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:identifier)
    cell.textLabel.text = "#{indexPath.row + 1}. #{@data[indexPath.row]['title']}"
    cell.detailTextLabel.text = @data[indexPath.row]['url']
    cell
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @data.count
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    App.alert(@data[indexPath.row]['url'])
  end

  def reloadTableViewDataSource
    self.loadPosts
    @reloading = true
  end

  def doneReloadingTableViewData
    @reloading = false
    @refreshHeaderView.refreshScrollViewDataSourceDidFinishLoading(self.tableView)
  end

  def scrollViewDidScroll(scrollView)
    @refreshHeaderView.refreshScrollViewDidScroll(scrollView)
  end

  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end

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

  def loadPosts
    BW::HTTP.get('http://hndroidapi.appspot.com/news/format/json/page/1') do |response|
      if response.ok?
        @data = BW::JSON.parse(response.body.to_str)['items']
        self.tableView.reloadData
      elsif response.status_code.to_s =~ /40\d/
        App.alert("Server responded with error")
      else
        App.alert(response.status_description)
      end
    end
  end
end