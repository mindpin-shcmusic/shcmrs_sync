//= require jquery
//= require jquery_ujs
//= require_tree .

// show
jQuery(document).ready(function(){
  jQuery('form a.form-submit-button').click(function(){
    jQuery(this).closest('form').submit();
  })
});
