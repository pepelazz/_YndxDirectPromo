$ (-> # window.onLoad
  $('.excl-instruction-click').on 'click', ()->
    $('.excl-instruction').toggleClass('show')
    $('.excl-instruction-click .icon-plus').toggleClass('hide')
    $('.excl-instruction-click .icon-minus').toggleClass('hide')
)