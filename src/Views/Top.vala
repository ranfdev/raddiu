using Gtk;
using Granite;
public class raddiu.Views.Top: Gtk.ScrolledWindow {
  private Gtk.Box content;
  private Network.RadioListFetcher fetcher; 
  private int loaded = 0;
  public void load_next() {
    fetcher.parameters.set_data("offset", loaded.to_string());
    loaded+=40;
    fetcher.parameters.set_data("limit", loaded.to_string());
    print("fetching");
    fetcher.load.begin("");
  }
  public Top() {
    content = new Gtk.Box(Orientation.VERTICAL, 20);

    var title = new Gtk.Label ("Top");
    title.get_style_context().add_class(STYLE_CLASS_H2_LABEL);
    title.margin = 15;
    title.halign = Align.START;
    content.add(title);


    var radio_list = new Widgets.RadioList();
    content.add(radio_list);

    fetcher = new Network.RadioListFetcher();
    fetcher.item_loaded.connect((top, radio_data) => {
      radio_list.add_radio(radio_data);
    });
    fetcher.parameters.set_data("order", "clickcount");
    fetcher.parameters.set_data("reverse", "true");

    add(content);

    edge_reached.connect((top, position) => {
      if (position == PositionType.BOTTOM) {
        print("BOTTOM");
        load_next();
      }
    });

    load_next();
  }
}
