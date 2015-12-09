class CommentsController < ApplicationController
  before_action :set_comment, only: [:vote]
  before_action :require_user

  def create
    @post = Post.find_by slug: params[:post_id]
    @comment = @post.comments.build(params.require(:comment).permit(:body))
    @comment.creator = current_user

    if @comment.save
      flash[:notice] = 'Your comment was added.'
      redirect_to post_path(@post)
    else
      render 'posts/show'
    end
  end

  def vote
    vote = Vote.create(voteable: @comment, creator: current_user, vote: params[:vote])

    respond_to do |format|
      format.html do
        if vote.valid?
          flash[:notice] = 'Your vote was counted'
        else
          flash[:error] = 'You can only vote on a comment once.'
        end
        redirect_to :back
      end

      format.js do
        if vote.valid?
          flash.now[:notice] = 'Your vote was counted'
        else
          flash.now[:error] = 'You can\'t vote on that more than once'
        end
      end
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
