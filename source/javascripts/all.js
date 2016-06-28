// This is where it all goes :)

$(function() {
  
  // Turn any <time> tags from absolute times into relative ones, with the
  // absolute time as a tooltip instead.
  $('time').each(function() {
    var time = $(this).attr('datetime');
    var theMoment = moment(time);
    $(this).attr('title', $(this).html());
    $(this).data('placement', 'top');
    $(this).tooltip();
    $(this).html(theMoment.fromNow());
  });

  // Turn abbreviations into Bootstrap tooltips intead of the slow browser
  // built-in ones.
  $('abbr').tooltip();

  // Smooth scrolling for anything linking to an anchor tag within the page.
  $('a[href^="#"]').on('click', function(event) {
    event.preventDefault();
    
    var fragment = this.hash;
    var target = $(fragment);
    
    $('html, body').stop().animate({
      // Scroll to the top of #main (ish), which is just below the navbar. The
      // default scroll offset means the target winds up underneath the navbar
      // itself.
      'scrollTop': target.offset().top - ($('#main').offset().top + 20)
    }, 1200, 'swing', function() {
      window.location.hash = fragment;
    });
  });

  // Enable pretty looking footnotes.
  $.bigfoot();
});
