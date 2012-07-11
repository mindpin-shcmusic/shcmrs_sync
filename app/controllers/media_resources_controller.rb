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
    
    if @current_resource.is_file?
      return send_file current_resource.attach.path
    end
  end

  def upload_file
    resource_path = URI.decode(request.fullpath).sub('/file_put', '')
    MediaResource.put(current_user, resource_path, params[:file])
    redirect_to :back
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

end
