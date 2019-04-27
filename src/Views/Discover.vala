using Gtk;
using Granite;
public class raddiu.Views.Discover: Gtk.ScrolledWindow {
  private Gtk.Box content;
  private static string[] genres = {
    "jazz",
    "blues",
    "punk",
    "metal",
    "rock",
    "country",
    "reggae",
    "soul",
    "funk",
    "k-pop",
    "gaming",
    "R&B",
    "classical",
    "electro",
    "dance",
    "indie",
    "hip-hop",
    "latin",
    "chill",
    "pop",
    "rap",
    "trap"
  };
  public Discover() {
    content = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
    content.margin = 10;
    add(content);

    var top_title = new Granite.HeaderLabel("Top");
    content.add(top_title);

    var top_radio_list = new Widgets.RadioList();
    content.add(top_radio_list);

    var top_fetcher = new Network.RadioListFetcher();
    top_fetcher.parameters.set_data("order", "clickcount");
    top_fetcher.parameters.set_data("reverse", "true");
    top_fetcher.parameters.set_data("limit", "6");

    top_fetcher.item_loaded.connect((_, radio) => {
      top_radio_list.add_radio(radio);
    });

    top_fetcher.load.begin("");

    var genre_title = new Granite.HeaderLabel("By Genres");
    content.add(genre_title);

    var genres_container = new Gtk.FlowBox();
    genres_container.row_spacing = 10;
    genres_container.column_spacing = 10;
    foreach (var genre in genres) {
      var flowbox_child = new Gtk.FlowBoxChild();
      flowbox_child.get_style_context().add_class(Granite.STYLE_CLASS_CARD);

      var label = new Gtk.Label(genre);
      label.margin = 15;

      flowbox_child.add(label);
      genres_container.add(flowbox_child);
    }
    content.add(genres_container);
  }
}
