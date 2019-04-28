public class raddiu.Widgets.PlayingPanel : Gtk.Box {
  public Gtk.Label label;
  private Gtk.Image toggler;
  public Widgets.WebImage image;
  public PlayingPanel () {
    orientation = Gtk.Orientation.VERTICAL;
    image = new Widgets.WebImage ("folder-music-symbolic");
    image.pixel_size = 32;
    image.margin = 20;
    image.get_style_context().add_class("raddiu-card");
    image.halign = Gtk.Align.CENTER;
    image.valign = Gtk.Align.CENTER;
    image.hexpand = false;
    image.vexpand = false;
    image.height_request = 200;
    image.width_request = 200;
    pack_start (image);

    label = new Gtk.Label("title");
    label.get_style_context().add_class(Granite.STYLE_CLASS_H2_LABEL);
    add (label);

    toggler = new Gtk.Image ();
    toggler.gicon = new ThemedIcon ("media-playback-start-symbolic");
    toggler.pixel_size = 32;

    var toggler_button = new Gtk.ToggleButton();
    toggler_button.image = toggler;
    toggler_button.toggled.connect(Raddiu.player.toggle);
    pack_end(toggler_button);

    Raddiu.player.notify["playing"].connect((s,t) => {
      if (Raddiu.player.playing)
        toggler.gicon = new ThemedIcon ("media-playback-pause-symbolic");
      else
        toggler.gicon = new ThemedIcon ("media-playback-start-symbolic");
    });

    Raddiu.player.notify["current-radio"].connect((s,t) => {set_radio(Raddiu.player.current_radio);});
  }
  public void set_radio(RadioData data) {
    image.url = data.favicon;
    image.pixel_width = 200;
    image.pixel_height = 200;
    label.label = data.name;
  }
}
