class BlogController < ApplicationController
  before_action :get_categories

  def index
    if current_user && current_user.is_admin?
      @posts = Post.index.page(params[:page]).per(5)
    else
      @posts = Post.published.index.page(params[:page]).per(5)
    end
  end

  def post
    if current_user && current_user.is_admin?
      @post = Post.find(params[:id])
    else
      @post = Post.published.find(params[:id])
    end
  end

  def category
    @category = Category.find(params[:id])
    if current_user && current_user.is_admin?
      @posts = @category.posts.index.page(params[:page]).per(5)
    else
      @posts = @category.posts.published.index.page(params[:page]).per(5)
    end
  end

  def get_categories
    @categories = Category.active
  end
end
