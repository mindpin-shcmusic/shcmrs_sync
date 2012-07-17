/*
 * @author fushang318
 * @useage 拼接路径，类似于ruby 中的 File.join
 */
jQuery.extend({
  path_join : function(){
    var path = "";
    for(var i = 0;i< arguments.length;i++){
      var str = arguments[i] + "";
      str = str.replace(/^\//, "");
      str = str.replace(/\/$/,"");
      if(str !== ""){
        path = path + "/" + str;
      }
    }
    return path;
  }
});