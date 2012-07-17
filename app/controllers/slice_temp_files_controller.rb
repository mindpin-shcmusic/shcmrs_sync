class SliceTempFilesController < ApplicationController
  before_filter :login_required

  def new_upload
    file_name = params[:file_name]
    file_size = params[:file_size]

    slice_temp_file = SliceTempFile.find_or_create(file_name,file_size,current_user)
    if slice_temp_file.valid?
      render :json=>{
        :saved_size => slice_temp_file.saved_size,
        :slice_temp_file_id => slice_temp_file.id
      }
    else
      render :status=>422,:json=>slice_temp_file.errors
    end
  end

  def upload_blob
    file_blob = params[:file_blob]
    slice_temp_file = SliceTempFile.find(params[:slice_temp_file_id])
    slice_temp_file.save_new_blob(file_blob)
    
    res = {:saved_size => slice_temp_file.saved_size}
    render :json=>res
  rescue Exception=>ex
    p ex.message
    puts ex.backtrace*"\n"
    render :status=>500,:text=>ex.message
  end

  def new_upload_page
  end
end