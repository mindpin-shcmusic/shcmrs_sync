Voteapp::Application.routes.draw do  
  # -- 用户登录认证相关 --
  root :to=>"index#index"
  
  get  '/login'  => 'sessions#new'
  post '/login'  => 'sessions#create'
  get  '/logout' => 'sessions#destroy'
  
  get  '/signup'        => 'signup#form'
  post '/signup_submit' => 'signup#form_submit'
  
  # -- 以下可以自由添加其他 routes 配置项
  
  get '/api/file/*path'     => 'media_resources#resource'
  put '/api/file_put/*path' => 'media_resources#put_resource'
end
