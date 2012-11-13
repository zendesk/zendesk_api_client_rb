function search(query) {
  query = query.split("#");

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
  }).error(function() {
    // TODO
  });
}

function toggle_json_editor() {
  var method = $("#method-select option:selected").val();
  $("#json").toggle(method == "POST" || method == "PUT");
}

$(document).ready(function() {
  var dirty = false;

  $('#search input').keyup(function() {
    var value = $(this).val();
    dirty = value != "";

    setTimeout(function() {
      if(dirty) {
        dirty = false;
        search($('#search input').val());
      }
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

  if(window.location.hash == "#response" || window.location.hash == "#request") {
    $('#response .tab').addClass('hide');
    $('#response ul.nav-pills li').removeClass('active');

    var tab = window.location.hash + "-tab";
    $(tab).removeClass("hide");
    $(tab + "-link").parent('li').addClass('active');
  } else if(window.location.hash == "#documentation") {
    $('.frame.tab').addClass('hide');
    $('#navigation ul.nav-pills li').removeClass('active');

    $('#help-tab').removeClass('hide');
    $('#help-tab-link').parent("li").addClass('active');
  }

  $('#response .tab-link').click(function() {
    var elem = $(this);

    $('#response .tab').addClass("hide");
    $('#response ul.nav-pills li').removeClass('active');

    $('#' + this.id.replace(/-link/, '')).removeClass("hide");
    elem.parent('li').addClass('active');

    event.preventDefault();
  });

  $('#possible-params').click(function(event) {
    $(this).children('i').toggleClass('hide');
    $('#possible-params-text').toggleClass('hide');

    event.preventDefault();
  });

  $('#navigation .tab-link').click(function() {
    var elem = $(this);

    $('.frame.tab').addClass("hide");
    $('#navigation ul.nav-pills li').removeClass('active');

    $('#' + this.id.replace(/-link/, '')).removeClass("hide");
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

  $('button.example').live("click", function() {
    var element = $(this).next();

    var url = element.data("url");
    url = url.split("?");

    $("#path").val(url[0]);

    if(url[1]) {
      var params = url[1].split("&");
      var param, inputs;

      for(var i = 0; i < params.length; i++) {
        param = params[i].split("=");
        $("#add-param").click();
        inputs = $("#params div:last input");

        if(inputs.length == 2) {
          $(inputs[0]).val(param[0]);
          $(inputs[1]).val(param[1]);
        }
      }
    }


    var method = element.data("method") || "GET";

    $("#method-select").val(method);
    $("#method-select").trigger("change");

    var json = element.data("json");

    if(json) {
      $("#json").val(JSON.stringify(json));
    } else {
      $("#json").val("");
    }

    window.location.hash = "";
    $("#throw-tab-link").click();
  });

  $("#method-select").change(toggle_json_editor);
  toggle_json_editor();

  $(".remove-param").live("click", function(event) {
    event.preventDefault();
    $(this).parent("div").remove();
  });
});
