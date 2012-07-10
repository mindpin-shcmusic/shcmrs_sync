# encoding: utf-8
class MediaResourcesApiController < ApplicationController

  def get_file
    resource_path = URI.decode(request.fullpath).sub('/api/file', '')

    # 例如 /foo/bar/hello/test.txt
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
    
    if MediaResource.put(current_user, resource_path, params[:file])
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

    return render :json => @resource.metadata(:list => true)
  end

  def get_delta
    cursor = params[:cursor] || 0
    count  = params[:count] || 100

    render :json => MediaResource.delta(cursor, count)
  end

  def create_folder
    resource_path = params[:path]

    if MediaResource.get resource_path
      return render :status => 403, :text => '指定的资源路径已经存在，不能重复创建'
    end

    render :json => MediaResource.create_folder_by_path(resource_path).metadata
  end

  def delete
    @resource = MediaResource.get params[:path]

    if @resource.blank?
      return render :status => 404, :text => '指定的路径上没有找到资源'
    end

    @resource.remove

    render :json => @resource.metadata(:list => false)
  end

end
