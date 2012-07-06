$ ->
  $upload_field = $ '.file-upload'
  $submit       = $ '.file-submit'
  base_path     = $upload_field.data 'path'
  url           = '/api/file_put'

  $submit.click ->
    upload_files files()

  files         = -> $upload_field[0].files

  upload_files  = (files)->
    $.each files, ->
      upload_file this

  upload_file   = (file)->
    if_path = if base_path == '/' then '' else '/'

    data = new FormData;
    data.append 'file',
                file

    xhr_provider = ->
      $.ajaxSettings.xhr()

    $request = $.ajax
      type: 'PUT',
      contentType: false,
      processData: false,
      url: url + base_path + if_path + file.fileName,
      data: data,
      xhr: xhr_provider

    $request.done (res)=>
      console.log 'ohy'

    $request.error =>
      console.log 'ohn'