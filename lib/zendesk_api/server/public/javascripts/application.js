function credentials_modal() {
  $("#credentials").modal({ backdrop: 'static', keyboard: false });

  $("#credentials-save").click(function() {
    $.ajax({
      type: 'POST',
      url: '/client',
      data: $("#credentials-form").serialize(),
      beforeSend: function() {
        $("#credentials-error").val();
        $("#credentials-spinner").show();
        $("#credentials-save").attr('disabled', 'disabled');
      },
      complete: function() {
        $("#credentials-save").removeAttr('disabled');
        $("#credentials-spinner").hide();
      },
      success: function() {
        //$("#credentials").modal('hide');
        window.location.reload();
      },
      error: function(xhr) {
        $("#credentials-error").text(xhr.responseText);
      }
    });
  });
};
