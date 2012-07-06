# encoding: utf-8
class MediaResourcesApiController < ApplicationController

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

  def get_meta_data
    resource_path = URI.decode(request.fullpath).sub('/api/meta_data', '')

    @resource = MediaResource.get_by_path resource_path

    if @resource.blank?
      return render :status => 404, :text => '请求的文件资源不存在'
    end

    return render :text => @resource.meta_data(:list => true).to_json
  end

  def get_delta
    cursor = params[:cursor] ? params[:cursor] : 0

    count = params[:count] ? params[:count] : 100

    render :text => MediaResource.delta(cursor, count).to_json
  end

  def create_folder
    if MediaResource.get_by_path params[:path]
      return render :status => 403, :text => '指定的资源路径已经存在，不能重复创建'
    end

    render :text => MediaResource.create_folder_from_path(params[:path]).meta_data.to_json
  end

  def delete
    @resource = MediaResource.get_by_path params[:path]

    if @resource.blank?
      return render :status => 404, :text => '指定的路径上没有找到资源'
    end

    @resource.destroy

    render :text => @resource.meta_data(:list => false).to_json
  end

  def delete_all
    MediaResource.destroy_all
    redirect_to '/file'
  end
end
