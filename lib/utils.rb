def randstr(length=8)
  base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  size = base.size
  re = '' << base[rand(size-10)]
  (length - 1).times {
    re << base[rand(size)]
  }
  re
end

# 获取一个随机的文件名
def get_randstr_filename(uploaded_filename)
  ext_name = File.extname(uploaded_filename)

  return "#{randstr}#{ext_name.blank? ? "" : ext_name }".strip
end
