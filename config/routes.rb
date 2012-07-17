Voteapp::Application.routes.draw do  
  # -- 用户登录认证相关 --
  root :to => 'index#index'
  
  get  '/login'  => 'sessions#new'
  post '/login'  => 'sessions#create'
  get  '/logout' => 'sessions#destroy'

  get  '/signup'        => 'signup#form'
  post '/signup_submit' => 'signup#form_submit'
  
  # -- 以下可以自由添加其他 routes 配置项

  # web
  get    '/file'       => 'media_resources#index'
  get    '/file/*path' => 'media_resources#file', :format => false

  put    '/file_put/*path' => 'media_resources#upload_file'
  post   '/file/create_folder' => 'media_resources#create_folder'
  delete '/file/*path' => 'media_resources#destroy'

  get    '/file_share/*path'       => 'media_resources#share'

  post '/new_upload'               => 'slice_temp_files#new_upload'
  post '/upload_blob'              => 'slice_temp_files#upload_blob'
  get  '/select_upload_file' => 'slice_temp_files#select_upload_file'
  
  resources :media_shares do
    collection do
      get :mine
      get :search
    end
  end
  get    '/media_shares/user/:id/file/*path' => 'media_shares#share'
  get    '/media_shares/shared_by/:user_id'  => 'media_shares#shared_by'

  # 全文索引
  get    '/file_search' => 'media_resources#search'
  # 结束全文索引

  # api
  get    '/api/file/*path'            => 'media_resources_api#get_file'
  put    '/api/file_put/*path'        => 'media_resources_api#put_file'
  get    '/api/metadata/*path'        => 'media_resources_api#get_metadata'
  get    '/api/delta'                 => 'media_resources_api#get_delta'
  post   '/api/fileops/create_folder' => 'media_resources_api#create_folder'
  delete '/api/fileops/delete'        => 'media_resources_api#delete'


  # 公共资源
  resources :public_resources do
    collection do
      post :share
      put :upload
      get :search
    end
  end

  get    '/public_resources/user/:id/file/*path' => 'public_resources#dir'
  get    '/public_resources/user/:id/index_file/:file_entity_id' => 'public_resources#index_file'
  put    '/public_resources/upload/*path' => 'public_resources#upload'
  # 结束公共资源

end
