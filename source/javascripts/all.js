// This is where it all goes :)

$(function() {
  $('time').each(function() {
    var time = $(this).attr('datetime');
    var theMoment = moment(time);
    $(this).attr('title', $(this).html());
    $(this).data('placement', 'top');
    $(this).tooltip();
    $(this).html(theMoment.fromNow());
  });

  $('abbr').tooltip();
  $('a[title]').tooltip();

  $.bigfoot();
});
