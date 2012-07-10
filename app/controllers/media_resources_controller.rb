class MediaResourcesController < ApplicationController
  def index
    @media_resources = MediaResource.where(:dir_id => 0)

    @file_entity = FileEntity.new

    @current_dir = "/"
  end

=begin
  def file
    resource_path = URI.decode(request.fullpath).sub('/file', '')

    @media_resource = MediaResource.get_by_path resource_path
    render :status => 404,
           :file   => "#{Rails.root}/public/404.html",
           :layout => false if @media_resource.nil?
  end
=end


  def create_folder
    MediaResource.create_folder(params[:resource_path])

    @media_resources = MediaResource.all

    render :layout => false
  end

end
