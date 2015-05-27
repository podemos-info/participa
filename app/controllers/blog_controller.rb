class BlogController < ApplicationController
  def index
    @posts = Post.all
  end

  def post
    @post = Post.find(params[:id])
    
  end

  def category
    @category = Category.find(params[:id])
    @posts = @category.posts
  end  
end
