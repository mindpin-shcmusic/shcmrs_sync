//= require jquery
//= require jquery_ujs
//= require ./util/pie
//= require ./util/jquery.pie.is_in_screen
//= require ./util/jquery.pie.domdata
//= require ./util/jquery.pie.path_join
//= require ./util/pie.image_in_box
//= require ./util/form
//= require notifier
//= require_tree .

// show
jQuery(function(){
  jQuery('form a.form-submit-button').click(function(){
    jQuery(this).closest('form').submit();
  })
});
