jQuery ->
	$upload_form = jQuery('.page-media-resources-forms form.upload-file')

	if $upload_form.length > 0
		$upload_form.find('input[type=file]').change ->
			value = jQuery(this).val().replace(/// \\ ///g, '/')
			arr = value.split('/')
			filename = arr[arr.length - 1]

			current_path = $upload_form.find('input[name=current_path]').val()
			resource_path = 
				if current_path == '/' 
				then "/#{filename}" 
				else "#{current_path}/#{filename}"

			action = "/file_put#{resource_path}"

			$upload_form.attr('action', action)
			console.log(action)


jQuery ->
  jQuery('.page-media-resource-list .media-resource a.put-public').live 'click', ->
    elm = jQuery(this)
    id = elm.data('id')

    jQuery.ajax({
      type: 'POST',
      url : '/public_resources/share/',
      data: {resource_id: id},
      success : ->
        elm.remove()
    })