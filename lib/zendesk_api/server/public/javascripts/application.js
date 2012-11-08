function search(query) {
  query = query.split("#");

  $("#spinner").show();

  $.post("/search", { query: query[0] }, function(data) {
    $("#search-results").html(data);

    $("#search-results h2, h3").nextUntil("h3").addClass("hide");
    $("#search-results h2, h3").children("i.icon-minus").addClass("hide");
    $("#search-results h2, h3").children("i.icon-plus").removeClass("hide");

    if(query[1]) {
      var header = $("#search-results #" + query[1]);

      if(header.children("i.icon-minus").hasClass("hide"))
        header.click();

      // document.getElementById(query[1]).scrollIntoView(true);
    }
  }).complete(function() {
    $("#spinner").hide();
  }).error(function() {
    // TODO
  });
}

function toggle_json_editor() {
  var method = $("#method_select option:selected").val();
  $("#json").toggle(method == "POST" || method == "PUT");
}

$(document).ready(function() {
  var dirty = false;

  $('#search input').keyup(function() {
    var value = $(this).val();
    dirty = value != "";

    setTimeout(function() {
      if(dirty)
        search($('#search input').val());
    }, 750);
  });

  $('#clear-search').click(function() {
    $('#search input').val("");
    search("help");
  });

  $("#search-results h2, h3").nextUntil("h3").addClass("hide");

  $("#search-results h2, h3").live("click", function() {
    $(this).nextUntil("h3").toggleClass("hide");
    $(this).children().toggleClass("hide");

    query = $('#search input').val();
    query = query.split("#");
    $('#search input').val(query[0] + "#" + this.id);
  });

  $("#search-results a").live("click", function(event) {
    event.preventDefault();

    query = $(this).attr("href");
    query = query.replace(/\.(html|md)/, "");

    $('#search input').val(query);

    search(query);
  });

  $('#response .tab_link').click(function() {
    var elem = $(this);

    $('#response .tab').hide();
    $('#response ul.nav-pills li').removeClass('active');

    $('#' + this.id.replace(/-link/, '')).show();
    elem.parent('li').addClass('active');
  });

  if(window.location.hash == "#documentation") {
    $('.frame.tab').hide();
    $('#navigation ul.nav-pills li').removeClass('active');

    $('#help-tab').show();
    $('#help-tab-link').parent("li").addClass('active');
  }

  $('#navigation .tab_link').click(function() {
    var elem = $(this);

    $('.frame.tab').hide();
    $('#navigation ul.nav-pills li').removeClass('active');

    $('#' + this.id.replace(/-link/, '')).show();
    elem.parent('li').addClass('active');
  });

  $('#json').keydown(function() {
    $('#input p.error').html('');
  });

  $('#json').keyup(function() {
    var value = $('#json').val();

    $('#json').removeClass('invalid');

    if(value == '') {
      $('#json').removeClass('invalid', 'valid');
      return;
    }

    try {
      JSON.parse(value);
      $('#json').addClass('valid');
    } catch(e) {
      $('#json').addClass('invalid');
    }
  });

  $("#method_select").change(toggle_json_editor);
  toggle_json_editor();

  $(".remove-param").live("click", function(event) {
    event.preventDefault();
    $(this).parent("div").remove();
  });
});
