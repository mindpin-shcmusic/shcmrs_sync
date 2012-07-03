# encoding: utf-8
class MediaResourcesController < ApplicationController
  def resource
    path = URI.decode(request.fullpath).split('/')[3..-1]
    @resource = MediaResource.find_by_path path

    case @resource
    when MediaResource
      if @resource.is_dir
        return render :text => '无法下载一个文件夹', :status => 405
      end
      send_file @resource.file_entities.first.attach.path
    when nil
      render :text => '请求的文件资源不存在', :status => 404
    end
  end

  def put_resource
    path = URI.decode(request.fullpath).split('/')[3..-1]
    
    @resource = MediaResource.create_by_path path
    file = @resource.file_entities.new :attach => params[:file]
    file.save

    render :text => path
  end
end
