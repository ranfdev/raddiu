public class raddiu.Widgets.WebImage: Gtk.Image {
  private string _url;
  public string fallback;
  public int pixel_width = 32;
  public int pixel_height = 32;
  private Cancellable cancellable;
  public string url {get {return _url;}
    set {
      _url = value;
      load_from_url.begin(_url);
    }}
  public WebImage (string fallback_image = "unknown") {
    fallback = fallback_image; 
    gicon = new ThemedIcon(fallback);
    destroy.connect(() => {
      cancellable.cancel();
    });
  }
  public async void load_from_url(string url) {

    destroy.connect(() => {
      cancellable.cancel();
    });

    Soup.Request request;

    try {
      request = Raddiu.soup.request(url);
    } catch (Error e) {
      print("%s\n",e.message);
      return;
    }
    try {
      var stream = yield request.send_async(cancellable);
      try {
        pixbuf = yield new Gdk.Pixbuf.from_stream_at_scale_async(
          stream,
          pixel_width,
          pixel_height,
          true,
          null
          );
      } catch (Error e) {
        print("%s\n",e.message);
        gicon = new ThemedIcon(fallback);
      }
    } catch (Error e) {
      print("%s\n",e.message);
    }
  }
  public WebImage.from_url(string url,string fallback_image = "unknown") {
    fallback = fallback_image;
    load_from_url.begin(url);
  }  
}
