# encoding: utf-8

class MediaResourcesController < ApplicationController
  before_filter :login_required

  def index
    @dir = nil
    @media_resources = current_user.media_resources.root_res.web_order
    render :action => 'index'
  end

  def file
    resource_path = URI.decode(request.fullpath).sub('/file', '')
    current_resource = MediaResource.get(current_user, resource_path)

    if current_resource.is_dir?
      @current_dir = current_resource
      @media_resources = @current_dir.media_resources.web_order
      return render :action => 'index'
    end
    
    if current_resource.is_file?
      return send_file current_resource.attach.path
    end
  end

  def upload_file
    file_name = params[:file_name]
    file_size = params[:file_size]
    slice_temp_file = SliceTempFile.get(file_name,file_size,current_user)
    file = slice_temp_file.get_merged_file

    resource_path = URI.decode(request.fullpath).sub('/file_put', '')
    MediaResource.put(current_user, resource_path, file)

    slice_temp_file.remove_files
    slice_temp_file.destroy
    render :text=>200
  end

  def create_folder
    if params[:folder].match(/^([A-Za-z0-9一-龥\-\_\.]+)$/)
      resource_path = File.join(params[:current_path], params[:folder])
      MediaResource.create_folder(current_user, resource_path)
    else
      flash[:error] = '输入的目录名不合法'
    end

    redirect_to :back
  end

  def destroy
    resource_path = URI.decode(request.fullpath).sub('/file', '')
    MediaResource.get(current_user, resource_path).remove

    redirect_to :back
  end

  # 搜索当前登录用户资源
  def search
    @keyword = params[:keyword]
    @media_resources = MediaResource.search(@keyword, 
      :conditions => {:creator_id => current_user.id, :is_removed => 0}, 
      :page => params[:page], :per_page => 20)

  end

end
