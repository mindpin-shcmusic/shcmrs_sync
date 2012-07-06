$ ->
  $create_folder = $ '.create-folder'
  $submit        = $ '.folder-submit'
  base_path      = $create_folder.data 'path'
  url            = '/api/fileops/create_folder'

  $submit.click ->
    create_folder folder_name()

  folder_name    = -> $create_folder.val()

  create_folder  = (name)->
    if_slash = if base_path == '/' then '' else '/'
    path = base_path + if_slash + name

    $request = $.ajax
      type: 'POST',
      url: url,
      data:
        'path': path

    $request.done (res)=>
      console.log 'ohy'

    $request.error =>
      console.log 'ohn'