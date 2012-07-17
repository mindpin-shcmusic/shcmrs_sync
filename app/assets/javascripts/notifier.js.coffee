$ ->
  class Counter
    collection = []
    id_maker  = 0

    constructor: (selector, dependent)->
      id_maker++
      @$el = $ selector
      @id  = id_maker
      collection.push this
      @$el.data 'id', @id
      if dependent
        @dependent = dependent
        @dependent.counter = this

    get_count: ->
      @$el.data 'count'

    set_count: (count)->
      @$el.data 'count', count

    fade_in: ->
      @$el.fadeIn()

    fade_out: ->
      @$el.fadeOut()

    update_text: ->
      @$el.text "#{this.get_count()}"

    @find: (id)->
      collection.filter((element)->
        element.id == id)[0]

    @all: ->
      collection

    display: ->
      count = @dependent.get_count()
      @set_count count

      if count > 0
        @update_text()
        @fade_in()
      else
        @fade_out()

  class Notifier extends Counter
    constructor: (selector)->
      super selector
      @$content = @$el.find '.content'

    update_text: ->
      @$content.text "#{this.get_count()}条消息"

    subscribe: (juggernaut, channel)->
      new Subscriber(juggernaut, channel, this)

    @any_count: ->
      @all().some (element)->
        element.get_count() > 0

    hide_container: ->
      @$el.parent().fadeOut() unless @constructor.any_count()

  class CommentMessageNotifier extends Notifier
    update_text: ->
      @$content.text "#{this.get_count()}条未读评论"

  class NotificationNotifier extends Notifier
    update_text: ->
      @$content.text "#{this.get_count()}条未读通知"

  class ShortMessageNotifier extends Notifier
    update_text: ->
      @$content.text "#{this.get_count()}条未读站内信"

  class Subscriber
    constructor: (@juggernaut, @channel, @notifier)->
      subscribe @juggernaut, @channel, @notifier

    subscribe = (juggernaut, channel, notifier)->
      juggernaut.subscribe channel, (data)->
        notifier.set_count data.count

        if notifier.counter
          notifier.counter.display()

        if notifier.get_count() > 0
          notifier.$el.parent().fadeIn()
          notifier.update_text()
          notifier.fade_in()
        else
          notifier.fade_out()
          console.log '>>>>', notifier.get_count()
          notifier.hide_container() #需要确保在所有notifier以及counter的count都set后再运行...

  USER_ID = $('meta[current-user-id]').attr 'current-user-id'

  names =
    Counter               : Counter
    Notifier              : Notifier
    NotificationNotifier  : NotificationNotifier
    CommentMessageNotifier: CommentMessageNotifier
    ShortMessageNotifier  : ShortMessageNotifier
    Subscriber            : Subscriber
    USER_ID               : USER_ID

  jQuery.extend window, names
