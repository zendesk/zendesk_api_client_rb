function search(query) {
  query = query.split("#");

  $.post("/search", { query: query[0] }, function(data) {
    $("#search-results").html(data);

    if(query[1]) {
      $("#search-results #" + query[1]).click();
      document.getElementById(query[1]).scrollIntoView(true);
    }
  });
}

  $(document).ready(function() {
    $('#search input').keyup(function() {
      search($this).val());
    });

    $("#search-results h3").live("click", function() {
      $(this).nextUntil("h3").toggle();
      $(this).children("i").toggle();

      query = $('#search input').val();
      query = query.split("#");
      $('#search input').val(query[0] + "#" + this.id);
    });

    $("#search-results a").live("click", function(event) {
      event.preventDefault();

      query = $(this).attr("href");
      query = query.replace(/\.html/, "");

      $('#search input').val(query);

      search(query);
    });
  });


  $('.tab_link').click(function() {
    var elem = $(this);

    $('.tab').hide();
    $('ul.nav-pills li').removeClass('active');

    $('#' + this.id + '_tab').show();
    elem.parent('li').addClass('active');
  });

  $('#json').keydown(function() {
    $('#input p.error').html('');
  });

  $('#json').keyup(function() {
    var value = $('#json').val();

    if(value == '')
      return;

    try {
      JSON.parse(value);
    } catch(e) {
      $('#input p.error').html("There was an error with your JSON syntax: " + e.message);
    }
  });

  function toggle_json() {
    var method = $("#method_select option:selected").val();
    $("#json").toggle(method == "POST" || method == "PUT");
  }

  $("#method_select").change(toggle_json);

  var param_html = #{haml(:param, :locals => { :param => {} }).to_json}

  $("#add-param").click(function(event) {
    event.preventDefault();
    $("#params").append(param_html);
  });

  $(".remove-param").live("click", function(event) {
    event.preventDefault();
    $(this).parent("div").remove();
  });

  $(document).ready(function() {
    toggle_json();
  });
