class TextboxList
  constructor: (element, options)->
    @$element = jQuery(element)

    @options = {
      class_name: 'mindpin-textbox-list'
    }

    @$container = jQuery('<div></div>')
      .addClass(@options.class_name)
      .bind 'click', (evt)=>
        evt.stopPropagation()

        target = evt.target

        # 点击的是外层容器吗？
        cond1 = (target == @$list[0] || target == @$container[0])
        # list 的最后一个子节点没有被聚焦吗？
        cond2 = (!@focused || @current != @$list.children().last())

        @focus_last() if cond1 and cond2

    @$list = jQuery('<ul></ul>')
      .addClass('bits')

    @$container.append @$list
    @$element.append @$container

    @after_init()

  # enablePlugin

  after_init: =>
    bit = @create('Editable')
    @$list.append(bit.$elm)
    @on_add(bit)

    jQuery(document)
      .bind 'click', ()=>
        return if !@focused
        @blur()

      .bind 'keydown', (evt)=>
        return if !@focused
        return if !@current

        caret = 
          if @current.is('editable')
          then @current.get_caret() 
          else null

        value = @current.get_value();

        is_box = @current.is('box')
        at_editable_left  = @current.is('editable') && (caret == 0 || value.length == 0)
        at_editable_right = @current.is('editable') && caret == value.length

        switch evt.keyCode
          when 8 # backspace
            if is_box
              evt.preventDefault()
              @current.remove()
              @focus_relative('prev')

            if at_editable_left
              evt.preventDefault()
              @focus_relative('prev')

          when 37 # ← left
            if is_box || at_editable_left
              evt.preventDefault()
              @focus_relative('prev')

          when 46 # delete
            if is_box
              evt.preventDefault()
              @current.remove()
              @focus_relative('next')

            if at_editable_right
              evt.preventDefault()
              @focus_relative('next')

          when 39 # → right
            if is_box || at_editable_right
              evt.preventDefault()
              @focus_relative('next')



  create: (klass, value, options)=>
    bit = new TextboxListBit[klass](value, this)
    return bit

  # uniqueValue

  on_focus: (bit)=>
    @current.blur() if @current
    @current = bit
    @$container.addClass('focus')

    if (!@focused)
      @focused = true
  
  on_blur: =>
    @current = null
    @$container.removeClass('focus')

  on_add: (bit)=>
    if bit.is('box')
      prior = get_bit_obj_of(bit.$elm.prev())

      if (prior && prior.is('box')) || !prior
        b = @create('editable')
        b.$elm.hide()

        # .inject(prior || this.list, prior ? 'after' : 'top');

  on_remove: (bit)=>
    return this if !@focused
    prior = @get_bit_obj_of bit.$elm.prev()
    if prior && prior.is('editable') 
      prior.remove()
    this.focus_relative('next', bit)

  focus_relative: (dir, to)=>
    # dir = prev | next

    $elm = (to || @current).$elm[dir]()

    bit = @get_bit_obj_of($elm);
    bit.focus() if bit
    return this

  focus_last: =>   
    last_element = @$list.children().last()
    @get_bit_obj_of(last_element).focus() if last_element
    return this

  blur: =>
    return this if !@focused
    @current.blur() if @current
    @focused = false
    # return this.fireEvent('blur');

  # add: =>

  get_bit_obj_of: ($elm)=>
    $elm.data('bit-obj') # 取出对象

  # getValues
  # setValues
  # update

# ---------------------------

class TextboxListBit
  constructor: (value, textboxlist)->
    @textboxlist = textboxlist

    @$elm = jQuery('<li></li>')
      .addClass('bit')
      .bind 'mouseenter', =>
        @$elm.addClass('hover')
      .bind 'mouseleave', =>
        @$elm.removeClass('hover')
      .data('bit-obj', this) # 保存对象

  focus: =>
    return this if (@focused) 
    @$elm.show()
    @focused = true
    @textboxlist.on_focus(this)
    @$elm
      .addClass("#{@prefix}-focus")
      .addClass("#{@prefix}-#{@type}-focus")

  blur: =>
    return this if (!@focused)
    @focused = false
    @textboxlist.on_blur(this)
    @$elm
      .removeClass("#{@prefix}-focus")
      .removeClass("#{@prefix}-#{@type}-focus")

  remove: =>
    @blur()
    @textboxlist.on_remove(this)
    @$elm.remove()

  is: (type)=>
    return @type == type

  set_value: (value)=>
    @value = value

  get_value: =>
    return @value

class TextboxListBit.Editable extends TextboxListBit
  type: 'editable'
  constructor: (value, @textboxlist, options)->
    super(value, textboxlist, options)

    @$element = jQuery('<input type="text" />')
      .addClass("#{@textboxlist.options.prefix}-bit-editable-input")
      .attr('data-autocomplete', 'off')
      .val(value)
    # 处理输入框自动延长

    @$element
      .bind 'focus', =>
        @focus(true)
      .bind 'blur', =>
        @blur(true)
      .bind 'keydown', (evt)=>
        if evt.keyCode == 13
          evt.preventDefault()
          @to_box()

    @$elm.append(@$element)

  # hide

  focus: =>
    super()
    @$element[0].focus()
    return this

  blur: =>
    super()
    @$element[0].blur()
    return this

  get_caret: =>
    return @$element.selectionStart # 这里不用支持 IE

  get_caret_end: =>
    return @$element.selectionEnd

  is_selected: =>
    return @focused && @get_caret() != @get_caret_end()

  set_value: (value)=>
    @$element.val(value)

  get_value: =>
     return @$element.val()

  to_box: =>
    box = @textboxlist.create('Box', @get_value())
    
    if $box
      @$elm.before box.$elm
      @textboxlist.on_add(this)
      @set_value('')
      return $box

    return null

class TextboxListBit.Box extends TextboxListBit
  type: 'box'
  constructor: (value, textboxlist, options)->
    super(value, textboxlist, options)
    @$elm.addClass("#{@textboxlist.options.prefix}-bit-box")

    @$elm.html(value)
    @$elm
      .bind 'click', @focus
    # 删除按钮




window.TextboxList = TextboxList
window.TextboxListBit = TextboxListBit
window.TextboxListBit.Editable = TextboxListBit.Editable