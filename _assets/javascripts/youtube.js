// Call this function at the end of the closing </body> tag.

function optimizeYouTubeEmbeds() {
    // Get all iframes
    var frames = document.getElementsByTagName( 'iframe' );
    // Loop through each iframe in the page.
    for ( var i = 0; i < frames.length; i++ ) {

        // Find out youtube embed iframes.
        if ( frames[ i ].src && frames[ i ].src.length > 0 && frames[ i ].src.match(/http(s)?:\/\/www\.youtube\.com/)) {

            // For Youtube iframe, extract src and id.
            var src=frames[i].src;
            var p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/;
            var id=(src.match(p) ? RegExp.$1 : false);
            if(id == false) { continue;}

            // Get width and height.
            var w=frames[i].width;
            var h=frames[i].height;
            if(src == '' || w=='' || h=='') {continue;}
            var div = getYouTubeDiv(id, w, h);
            frames[i].parentNode.replaceChild(div, frames[i]);
            i--;
        }
    }
    var divs = document.getElementsByClassName('youtube');
    for (i=0; i<divs.length;i++) {
        var youtubeid = divs[i].getAttribute('youtubeid');
        var youtubediv=getYouTubeDiv(youtubeid, divs[i].getAttribute('width'), divs[i].getAttribute('height'), divs[i].getAttribute('thumbnail'));
        divs[i].parentNode.replaceChild(youtubediv, divs[i]);
        i--;
    }
}

function getYouTubeDiv(id,w,h,thumbnail) {
    // Thease are to position the play button centrally.
    var pw=Math.ceil(w/2-38.5);
    var ph=Math.ceil(h/2+38.5);

    // The image+button overlay code.
    var img = 'http://i.ytimg.com/vi/'+id+'/hqdefault.jpg';
    if(thumbnail != null) {
        img = thumbnail;
    }
    var code='<div style="width:'+w+'px; height:'+h+'px; margin:0 auto"><a href="#" onclick="LoadYoutubeVidOnPreviewClick(\''+id+'\','+w+','+h+');return false;" id="youtubevid-'+id+'"><img src="'+img+'" style="width:'+w+'px; height:'+h+'px;" /><div class="youtube-play" style="margin-left:'+pw+'px; margin-top:-'+ph+'px;"></div></a></div>';

    // Replace the iframe with a the image+button code
    var div = document.createElement('div');

    div.innerHTML=code;
    div=div.firstChild;
    return div;
}

// Replace preview image of a video with it's iframe.
function LoadYoutubeVidOnPreviewClick(id,w ,h) {
    var code='<iframe src="https://www.youtube.com/embed/'+id+'/?autoplay=1&autohide=1&border=0&wmode=opaque&enablejsapi=1" width="'+w+'" height="'+h+'" frameborder=0 allowfullscreen="allowfullscreen" style="border:1px solid #ccc;" ></iframe>';
    var iframe = document.createElement('div');
    iframe.innerHTML=code;
    iframe=iframe.firstChild;
    var div=document.getElementById("youtubevid-"+id);
    div.parentNode.replaceChild( iframe, div)
}
optimizeYouTubeEmbeds();
