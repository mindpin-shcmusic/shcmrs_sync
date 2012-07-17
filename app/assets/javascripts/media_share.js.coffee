$ ->
  class MediaShareNotifier extends Notifier
    update_text: ->
      @$content.text "#{this.get_count()}个新文件分享"

<<<<<<< HEAD
  if window.Juggernaut
=======
  if Juggernaut?
>>>>>>> c48e8e91e9b6311e56635905fe233026e48faf11
    jug = new Juggernaut
    media_share_notifier = new MediaShareNotifier('.media-share-notifier')
    console.log "user-share-tip-message-count-user-#{USER_ID}"
    media_share_notifier.subscribe jug, "user-share-tip-message-count-user-#{USER_ID}"