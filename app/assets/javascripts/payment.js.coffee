#= require jquery.maskMoney

$ ->
  $(".money").maskMoney({
    thousands:',',
    allowZero: true,
    precision: '0'
  })
  $(".money").each(->
    $(this).val($(this).val().replace(/(\d)(?=(\d{3})+$)/g , '$1,'))
  )
  $("form").on('submit', ->
    $(".money").each(->
      $(this).val($(this).val().replace(/,/g, ''))
    )
  )
