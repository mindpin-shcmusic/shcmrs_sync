class IndexController < ApplicationController
  def index
    # return render :template=>'index/index' if logged_in?
    return redirect_to '/file' if logged_in?

    # 如果还没有登录，渲染登录页
    return render :template=>'index/login'
  end

  def user_complete_search
    user_ids = User.complete_search(params[:q]).map { |doc|
      doc['id']
    }[0...10]

    @users = user_ids.map{ |user_id|
      User.find_by_id(user_id)
    }.compact.uniq

    render :partial => 'complete_search/user'
  end
end
