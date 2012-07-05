class MediaResourcesController < ApplicationController
  def index
    @media_resources = MediaResource.where(:dir_id => 0)
  end

  def file
    resource_path = URI.decode(request.fullpath).sub('/file', '')

    @media_resource = MediaResource.get_by_path resource_path
  end
end
