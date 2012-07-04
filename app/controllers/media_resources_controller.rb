# encoding: utf-8
class MediaResourcesController < ApplicationController

  def get_file
    resource_path = URI.decode(request.fullpath).sub('/api/file', '')

    # 例如 /hello/test.txt
    @resource = MediaResource.get_by_path resource_path

    if @resource.blank?
      return render :status => 404, :text => '请求的文件资源不存在'
    end

    if @resource.is_dir
      return render :status => 405, :text => '无法下载一个文件夹'
    end

    send_file @resource.file_entity.attach.path
  end

  def put_file
    resource_path = URI.decode(request.fullpath).sub('/api/file_put', '')
    
    if MediaResource.put_file_by_path resource_path, params[:file]
      return render :text => 'OK'
    end

    return render :status => 405, :text => '创建操作失败'
  end

  def get_metadata
    resource_path = URI.decode(request.fullpath).sub('/api/metadata', '')

    @resource = MediaResource.get_by_path resource_path

    if @resource.blank?
      return render :status => 404, :text => '请求的文件资源不存在'
    end

    return render :text => @resource.metadata(:list => false).to_json
  end
end
