function optimizeYouTubeEmbeds() {
  // Get all iframes
  var frames = document.getElementsByTagName('iframe');
  // Loop through each iframe in the page.
  for (var i = 0; i < frames.length; i++) {

    // Find out youtube embed iframes.
    if (frames[i].src && frames[i].src.length > 0 && frames[i].src.match(/http(s)?:\/\/www\.youtube\.com/)) {

      // For Youtube iframe, extract src and id.
      var src = frames[i].src;
      var p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/;
      var id = (src.match(p) ? RegExp.$1 : false);
      if (id == false) {
        continue;
      }

      // Get width and height.
      var w = frames[i].width;
      var h = frames[i].height;
      if (src == '' || w == '' || h == '') {
        continue;
      }
      var div = getYouTubeDiv(id, w, h);
      frames[i].parentNode.replaceChild(div, frames[i]);
      i--;
    }
  }
  var divs = document.getElementsByClassName('youtube');
  for (i = 0; i < divs.length; i++) {
    var youtubeid = divs[i].getAttribute('youtubeid');
    var youtubeDiv = getYouTubeDiv(youtubeid, divs[i].getAttribute('width'), divs[i].getAttribute('height'), divs[i].getAttribute('thumbnail'));
    divs[i].parentNode.replaceChild(youtubeDiv, divs[i]);
    i--;
  }
}

function getYouTubeDiv(id, w, h, thumbnail) {
  // The image+button overlay code.
  var imgUrl = 'http://i.ytimg.com/vi/' + id + '/hqdefault.jpg';
  if (thumbnail != null) {
    imgUrl = thumbnail;
  }

  // Replace the iframe with image+button code
  var div = document.createElement('div');
  div.style.width = w + 'px';
  div.style.height = h + 'px';
  div.style.margin = '0 auto';

  var innerDiv = document.createElement('div');
  innerDiv.id = 'youtubevid-' + id;

  var img = document.createElement('img');
  img.src = imgUrl;
  img.style.width = w + 'px';
  img.style.height = h + 'px';

  var playDiv = document.createElement('div');
  playDiv.className = 'youtube-play';
  // These are to position the play button centrally.
  var pw = Math.ceil(w / 2 - 38.5);
  var ph = Math.ceil(h / 2 + 38.5);
  playDiv.style.marginLeft = pw + 'px';
  playDiv.style.marginTop = -ph + 'px';

  innerDiv.appendChild(img);
  innerDiv.appendChild(playDiv);
  innerDiv.onclick = function() {
    LoadYoutubeVidOnPreviewClick(id, w, h);
  };
  div.appendChild(innerDiv);
  return div;
}

// Replace preview image of a video with it's iframe.
function LoadYoutubeVidOnPreviewClick(id, w, h) {
  var code = '<iframe src="https://www.youtube.com/embed/' + id + '/?autoplay=1&autohide=1&border=0&wmode=opaque&enablejsapi=1" width="' + w + '" height="' + h + '" frameborder=0 allowfullscreen="allowfullscreen" style="border:1px solid #ccc;" ></iframe>';
  var iframe = document.createElement('div');
  iframe.innerHTML = code;
  iframe = iframe.firstChild;
  var div = document.getElementById("youtubevid-" + id);
  div.parentNode.replaceChild(iframe, div)
}

// Replace divs after DOMContentLoaded. Doesn't work in IE < 9
if(document.readyState === 'complete' || document.readyState === 'interactive') {
  optimizeYouTubeEmbeds();
} else {
  document.addEventListener('DOMContentLoaded', optimizeYouTubeEmbeds);
}
