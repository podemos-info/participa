class ActiveRecord::Base
  def add_comment text, author = nil
    author = current_user if author.nil? and defined? current_user
    if defined? ActiveAdmin
      ActiveAdmin::Comment.create author: author, resource: self, namespace:'admin', body:text
    end
  end
end