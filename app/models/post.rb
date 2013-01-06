class Post
  API = 'http://hndroidapi.appspot.com'
  PROPERTIES = %w(comments description item_id score time title url user)
  PROPERTIES.each do |property|
    attr_accessor property.to_sym
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      value = NSURL.URLWithString(value) if key == 'url'
      self.send("#{key}=", value) if PROPERTIES.member?(key)
    end
  end

  def self.loadAllInto(ivar, withPage:page, delegate:delegate)
    BW::HTTP.get("#{API}/news/format/json/page/#{page}") do |response|
      if response.ok?
        posts = BW::JSON.parse(response.body.to_str)['items'].map { |post| Post.new(post) }
        delegate.instance_variable_set(ivar, posts)
        delegate.tableView.reloadData
      elsif response.status_code.to_s =~ /40\d/
        App.alert("Server responded with error")
      else
        App.alert(response.status_description)
      end
    end
  end
end