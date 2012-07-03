class MediaResourcesController < ApplicationController
  def resource
    path = params[:path].split('/')
    collection = MediaResource.bla path

    render :text => 'ok'
  end

  def put_resource
    path = params[:path].split('/')

    render :text => 'ok'
  end
end
