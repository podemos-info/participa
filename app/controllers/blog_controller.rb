class BlogController < ApplicationController
  before_action :get_categories

  def index
    @posts = Post.index.page(params[:page])
  end

  def post
    @post = Post.find(params[:id])
  end

  def category
    @category = Category.find(params[:id])
    @posts = @category.posts.page(params[:page])
  end

  def get_categories
    @categories = Category.active
  end
end
