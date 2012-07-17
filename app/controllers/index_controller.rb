class IndexController < ApplicationController
  def index
    # return render :template=>'index/index' if logged_in?
    return redirect_to '/file' if logged_in?

    # 如果还没有登录，渲染登录页
    return render :template=>'index/login'
  end

  def user_complete_search
    candidates = User.complete_search(params[:q]).map do |doc|
      doc['id']
    end

    @users = User.find candidates

    render :partial => 'complete_search/user'
  end
end
