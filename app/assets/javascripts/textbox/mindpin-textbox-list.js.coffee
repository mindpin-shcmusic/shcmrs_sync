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
        cond2 = (!@focused || @current != @get_last_bit())

        # console.log(target, cond1, cond2)

        @focus_last() if cond1 && cond2

      .appendTo @$element

    @$list = jQuery('<ul></ul>')
      .addClass('bits')
      .appendTo @$container

    @after_init()

  # enablePlugin

  after_init: =>
    bit = @create('Editable')
    @$list.append(bit.$elm)

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

        is_box      = @current.is('box')
        is_editable = @current.is('editable')
        at_editable_left  = is_editable && caret == 0
        at_editable_right = is_editable && caret == value.length

        # console.log(is_box, is_editable, at_editable_left, at_editable_right, caret)

        switch evt.keyCode
          when 8 # backspace
            if is_box
              evt.preventDefault()
              @current.remove()
              @focus_to @current.prev()

            if at_editable_left
              evt.preventDefault()
              @focus_to @current.prev()

          when 37 # ← left
            if is_box || at_editable_left
              evt.preventDefault()
              @focus_to @current.prev()

          when 46 # delete
            if is_box
              evt.preventDefault()
              @current.remove()
              @focus_to @current.next()

            if at_editable_right
              evt.preventDefault()
              @focus_to @current.next()

          when 39 # → right
            if is_box || at_editable_right
              evt.preventDefault()
              @focus_to @current.next()



  create: (klass, value)=>
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
    # if bit.is('box')
    #   prior = get_bit_obj_of(bit.$elm.prev())

    #   if (prior && prior.is('box')) || !prior
    #     b = @create('editable')
    #     b.$elm.hide()

    #     # .inject(prior || this.list, prior ? 'after' : 'top');

  on_remove: (bit)=>
    return this if !@focused
    prior = @get_bit_obj_of bit.$elm.prev()
    if prior && prior.is('editable') 
      prior.remove()
    @focus_to bit.next()

  focus_to: (bit)=>
    bit.focus() if bit

  focus_last: =>   
    last_bit = @get_last_bit()
    last_bit.focus() if last_bit

  get_last_bit: =>
    last_element = @$list.children().last()
    return @get_bit_obj_of(last_element) if last_element
    return null

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

  # autocomplete
  show_results: (html)=>
    # console.log(html)

    that = this

    if !@$result_list
      @$result_list = jQuery('<ul></ul>')
        .addClass('results')
        .delegate '.autocomplete-result', 'click', (evt)->
          evt.preventDefault()
          $result = jQuery(this)
          that.add_result($result)

        .appendTo @$container

    @$result_list.html(html)

  complete_search: =>
    value = @current.get_value()
    if @last_search_value != value
      @last_search_value = value
      if jQuery.string(value).blank()
        @show_results('')
        return

      @result_blur()
      jQuery.ajax
        url : '/user_complete_search'
        data : {
          q : value
        },
        success : (res)=>
          @show_results(res)

  focus_first: =>
    $first_result = @$result_list.find('.autocomplete-result').first()
    @focus_result $first_result

  focus_next_result: =>
    return if !@$current_result
    @focus_result @$current_result.next()

  focus_prev_result: =>
    return if !@$current_result
    @focus_result @$current_result.prev()

  focus_result: ($result)=>
    if $result.length > 0
      @$current_result.removeClass('focus') if @$current_result
      $result.addClass('focus')
      @$current_result = $result

  result_blur: =>
    @$current_result.removeClass('focus') if @$current_result
    @$current_result = null

  add_result: ($result)=>
    name  = $result.data('name')
    value = $result.data('value')
    bit = @get_last_bit()
    if bit
      bit.set_value(name)
      bit.to_box()
      bit.focus()

# ---------------------------

# 基类，不会直接被实例化
class TextboxListBit
  constructor: (value, textboxlist)->
    @textboxlist = textboxlist

    @$elm = jQuery('<li></li>')
      .addClass('bit')
      .addClass(@type)
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
      .addClass('focus')

  blur: =>
    return this if (!@focused)
    @focused = false
    @textboxlist.on_blur(this)
    @$elm
      .removeClass('focus')

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

  prev: =>
    $prev = @$elm.prev()
    return @textboxlist.get_bit_obj_of($prev) if $prev

  next: =>
    $next = @$elm.next()
    return @textboxlist.get_bit_obj_of($next) if $next

# ----------------------------------------------------

class TextboxListBit.Editable extends TextboxListBit
  type: 'editable'
  constructor: (value, @textboxlist, options)->
    super(value, textboxlist, options)

    @$element = jQuery('<input type="text" />')
      .addClass('input')
      .attr('data-autocomplete', 'off')
      .val(value)
    # 处理输入框自动延长

    @$element
      .bind 'focus', =>
        @focus(true)
      .bind 'blur', =>
        @blur(true)
      # .bind 'keydown', (evt)=>
      #   if evt.keyCode == 13
      #     evt.preventDefault()
      #     @to_box()

    @$elm.append(@$element)

    # autocomplete events
    @$element
      .bind 'keyup', =>
        @textboxlist.complete_search()
      .bind 'keydown', (evt)=>
        switch evt.keyCode
          when 38 # ↑ up
            if @textboxlist.$current_result
              if @textboxlist.$result_list.find('.autocomplete-result').first()[0] == @textboxlist.$current_result[0]
                @textboxlist.result_blur()
              else @textboxlist.focus_prev_result()
          when 40 # ↓ down
            evt.preventDefault()
            if @textboxlist.$current_result
            then @textboxlist.focus_next_result()
            else @textboxlist.focus_first()
          when 13 # enter
            evt.preventDefault()
            if @textboxlist.$current_result
              @textboxlist.add_result(@textboxlist.$current_result)

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
    return @$element[0].selectionStart # 这里不用支持 IE

  get_caret_end: =>
    return @$element[0].selectionEnd

  is_selected: =>
    return @focused && @get_caret() != @get_caret_end()

  set_value: (value)=>
    @$element.val(value)

  get_value: =>
     return @$element.val()

  to_box: =>
    box = @textboxlist.create('Box', @get_value())
    
    if box
      @$elm.before box.$elm
      @textboxlist.on_add(this)
      @set_value('')
      return box

    return null



# -----------------------------------------

class TextboxListBit.Box extends TextboxListBit
  type: 'box'
  constructor: (value, textboxlist, options)->
    super(value, textboxlist, options)
    @$elm.html(value)
    @$elm
      .bind 'click', @focus
    # 删除按钮




window.TextboxList = TextboxList
window.TextboxListBit = TextboxListBit
window.TextboxListBit.Editable = TextboxListBit.Editable
window.TextboxListBit.Box = TextboxListBit.Box