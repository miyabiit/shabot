#= require ../widgets/autocomplete-combo

$ ->
  $('#target_date').datepicker({
      todayBtn: "linked",
      todayHighlight: true,
      format: "yyyy-mm-dd"
  })
  $("#bank_transfer_form_src_account_id").autocomplete_combo()
  $("#bank_transfer_form_dst_account_id").autocomplete_combo()
