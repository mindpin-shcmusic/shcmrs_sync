jQuery(document).ready(function(){
  jQuery('form a.form-submit-button').click(function(){
    var elm = jQuery(this);
    if(elm.hasClass('disabled')) return;
    
    jQuery(this).closest('form').submit();
  })
});

// -------------

// 给jQuery对象增加 input 的方法，绑定输入事件
jQuery.fn.input = function(fn) {
  var $this = this;
  return fn
  ?
  $this.bind({
    'input.input': function(event) {
      $this.unbind('keydown.input');
      fn.call(this, event);
    },
    'keydown.input': function(event) {
      fn.call(this, event);
    }
  })
  :
  $this.trigger('keydown.input');
};

// 定义 pie_j_tips 方法，用来给表单域声明提示信息
pie.load(function(){
  jQuery.fn.pie_j_tips = function() {
    try{
      jQuery(this).each(function(){
        var elm = jQuery(this)
          .change(function(){ _active(elm) })
          .input(function(){ _active(elm) })

        //初始化
        _active(elm);
      })
    }catch(e){pie.log(e)};
  };

  function _active(elm){
    var label_elm = elm.parent().find('label');
    var value = elm.val();

    jQuery.string(value).blank() ? label_elm.show() : label_elm.hide();
  }

  jQuery('.j-tip').each(function(){
    jQuery(this).pie_j_tips();
  })
})