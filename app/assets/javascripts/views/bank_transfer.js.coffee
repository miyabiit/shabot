#= require ../widgets/autocomplete-combo

$ ->
  $('#target_date').datepicker({
      todayBtn: "linked",
      todayHighlight: true,
      format: "yyyy-mm-dd"
  })
