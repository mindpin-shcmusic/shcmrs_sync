class MediaResourcesController < ApplicationController
  def index
    @media_resources = MediaResource.where(:dir_id.exists => false)
  end

  def file
    resource_path = URI.decode(request.fullpath).sub('/file', '')

    @media_resource = MediaResource.get_by_path resource_path
    render :status => 404,
           :file   => "#{Rails.root}/public/404.html",
           :layout => false if @media_resource.nil?
  end
end
