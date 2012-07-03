class IndexController < ApplicationController
  def index
    return render :template=>'index/index' if logged_in?
    
    # 如果还没有登录，渲染登录页
    return render :template=>'index/login'
  end
end
