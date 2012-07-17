/*
 * @author ben7th
 * @useage 在dom容器中加载图片的几种方法
 */

// 在某个容器中加载其上的由data-src声明的图片，
// 并且图片通过调整以最佳自适应容器大小，填满容器同时避免宽高比变化
pie.load_box_img = function(box_elm, time){
  var src = box_elm.data('src');

  var time = time || 500;

  if(!src){
    pie.log('必须声明 data-src');
    return;
  }

  var img_elm = jQuery('<img style="display:none;" src="'+src+'" />');

  img_elm
    .bind('load', function(){
      img_elm.fadeIn(time);
      pie.resize_box_img(box_elm, img_elm);
    })
    .appendTo(box_elm.empty().show());
}

// 计算某容器内图片缩放宽度，高度，负margin
// 图片通过调整以最佳自适应容器大小，填满容器同时避免宽高比变化
// 分两步走：
// 1 如果宽度不等，调齐宽度，计算高度
// 2 如果此时高度不足，补齐高度
// 最后计算margin
pie.resize_box_img = function(box_elm){
  var img_elm = box_elm.find('img');

  var box_width  = box_elm.width();
  var box_height = box_elm.height();

  var img_width  = img_elm.width();
  var img_height = img_elm.height();

  var w1, h1, rw, rh, ml, mt;

  //step 1 如果宽度不等，调齐宽度，计算高度
  if(img_width != box_width){w1 = box_width; h1 = img_height * box_width / img_width;}
  else{w1 = img_width; h1 = img_height;}

  //step 2 如果此时高度不足，补齐高度
  if(h1 < box_height){rh = box_height; rw = w1 * box_height / h1;}
  else{rh = h1; rw = w1;}

  //margin
  ml = (box_width - rw) / 2; mt = (box_height - rh) / 2;

  img_elm
    .css('width',rw).css('height',rh)
    .css('margin-left',ml).css('margin-top',mt);
}