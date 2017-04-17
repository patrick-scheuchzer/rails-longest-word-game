document.addEventListener("turbolinks:load", function() {
  if ($('form').length === 0) return;

  var startTime = Date.now();

  $('form').on('submit', function(){
    var endTime = Date.now();
    var time = endTime - startTime;
    $('#time').val(time);
  });
});
