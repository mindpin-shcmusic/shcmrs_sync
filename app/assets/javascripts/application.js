//= require jquery
//= require jquery_ujs
//= require_tree .

// show
jQuery(document).ready(function(){
  jQuery('form a.form-submit-button').click(function(){
    console.log(111)
    jQuery(this).closest('form').submit();
  })
});

// new
jQuery(document).ready(function() {
  
  var refresh_input_names_and_select_options = function(){
    // 1 刷新names 按参数规约 vote[vote_items_attributes][:index][item_title]
    var input_idx = 0;
    jQuery('.page-new-vote form .item-list .item input[type=text]').each(function(){
      jQuery(this).attr('name', 'vote[vote_items_attributes][' + input_idx + '][item_title]');
      input_idx += 1;
    });
    
    // 2 如果选项还剩两项，则隐藏删除按钮，否则显示删除按钮
    if(input_idx <= 2){
      jQuery('.page-new-vote form .item-list').addClass('min');
    }else{
      jQuery('.page-new-vote form .item-list').removeClass('min');
    }
    
    // 刷新select 
    jQuery('.page-new-vote form select.limit option').remove();
    for(var i=1; i<=input_idx; i++){
      var text = (i == 1) ? '单选' : '最多选'+i+'项';
      var opt_elm = jQuery('<option value="'+i+'">'+text+'</option>')
        .appendTo(jQuery('.page-new-vote form select.limit'));
    }
  }
  
  jQuery('.page-new-vote form .item-list .item input[type=text]').attr('id', null);
  refresh_input_names_and_select_options();
  
  // 删除选项，如果只剩两项则不允许再删
  jQuery('.page-new-vote form .item-list .item a.delete').live('click', function(){
    jQuery(this).closest('.item').remove();
    refresh_input_names_and_select_options();
  });
  
  // 增加选项
  jQuery('.page-new-vote form .add-new-item').click(function(){
    var item_elm = jQuery('<div class="item"></div>')
      .append(jQuery('<input type="text" size="30" />'))
      .append(jQuery('<a class="delete" href="javascript:;">删除</a>'))
      .appendTo(jQuery(this).closest('.field').find('.item-list'));
    
    refresh_input_names_and_select_options();
  });
});
