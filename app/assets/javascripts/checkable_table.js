$(function() {
  $('[data-link-id]').on('click', function(event) {
    event.preventDefault();
    var dataID = $(this).attr('data-link-id');
    $('input[type=checkbox][data-value-id=' + dataID + ']').each(function() {
      if (this.checked) {
        $(this).prop('checked', false);
      } else {
        $(this).prop('checked', true);
      }
    });
  });
  $('#check_all').on('change', function(event){
    var v = $('#check_all').prop('checked');
    $('input[type=checkbox][data-value-id]').each(function() {
      $(this).prop('checked', v);
    });
  });
});
