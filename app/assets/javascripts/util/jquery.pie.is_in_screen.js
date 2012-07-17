/*
 * @author ben7th
 * @useage 用于判断某元素是否在屏幕显示区域之内
 */

jQuery.fn.is_in_screen = function(){
  var bottom = jQuery(window).height() + jQuery(window).scrollTop();
  var elm_top = this.offset().top;
  return elm_top < bottom;
}