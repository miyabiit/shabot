$ ->
  $('a[data-form-id]').each ->
    $a = $(this)
    $a.on 'click', (event) =>
      event.preventDefault()
      $form = $("##{$a.attr('data-form-id')}")
      location.href = "#{$a.attr('href')}?#{$form.serialize()}"
