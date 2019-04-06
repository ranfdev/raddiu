public class raddiu.Widgets.Radio : Gtk.Box {
  public RadioData metadata;
  public Radio (RadioData data) {
    orientation = Gtk.Orientation.HORIZONTAL;
    spacing = 5;
    margin = 12;
    metadata = data;


    var icon = new Widgets.WebImage.from_url (metadata.favicon, "playlist-symbolic");
    icon.pixel_width = 48;
    icon.pixel_height = 48;
    icon.pixel_size = 48;
    add(icon);

    var text = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    add(text);

    var label = new Granite.HeaderLabel(data.name);
    label.max_width_chars = 25;
    label.wrap = true;
    label.wrap_mode = Pango.WrapMode.WORD_CHAR;
    text.add(label);

    var url = new Gtk.Label(data.url);
    url.max_width_chars = 25;
    url.wrap = true;
    url.wrap_mode = Pango.WrapMode.WORD_CHAR;
    text.add(url);

  }    
}
