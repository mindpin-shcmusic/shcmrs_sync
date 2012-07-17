$ ->
  class MediaShareNotifier extends Notifier
    update_text: ->
      @$content.text "#{this.get_count()}个新文件分享"

  if window.Juggernaut
    jug = new Juggernaut
    media_share_notifier = new MediaShareNotifier('.media-share-notifier')
    console.log "user-share-tip-message-count-user-#{USER_ID}"
    media_share_notifier.subscribe jug, "user-share-tip-message-count-user-#{USER_ID}"