//= require jquery
//= require jquery_ujs
//= require notifier
//= require_tree .

// show
jQuery(function(){
  jQuery('form a.form-submit-button').click(function(){
    jQuery(this).closest('form').submit();
  })
});
