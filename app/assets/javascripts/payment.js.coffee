#= require jquery.maskMoney

$.fn.formatMoney = ->
  this.maskMoney({
    thousands:',',
    allowZero: true,
    allowNegative: true,
    precision: '0'
  })

$ ->
  $(".money").formatMoney()
  $(".money").each(->
    $(this).val($(this).val().replace(/(\d)(?=(\d{3})+$)/g , '$1,'))
  )
  $("form").on('submit', ->
    $(".money").each(->
      $(this).val($(this).val().replace(/,/g, ''))
    )
  )
