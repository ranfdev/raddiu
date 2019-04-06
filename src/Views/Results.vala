public class raddiu.Views.Results: Gtk.ScrolledWindow {
  private Gtk.Box content;
  private Network.RadioListFetcher fetcher;
  public string query;
  private Widgets.RadioList radio_list;
  public void load_next() {
    if (query == null)
      return;
    fetcher.parameters.set_data("name", query);
    fetcher.load.begin("/search");
  }
  public Results() {
    fetcher = new Network.RadioListFetcher();
    fetcher.parameters.set_data("order", "clickcount");
    fetcher.parameters.set_data("reverse", "true");
    fetcher.parameters.set_data("limit", "40");

    radio_list = new Widgets.RadioList(); 
    add(radio_list);

    fetcher.started.connect(() => {
      radio_list.foreach((widget) => {
        print("removing");
        widget.destroy(); 
      });
    });

    fetcher.item_loaded.connect((fetcher, radio) => {
      radio_list.add_radio(radio); 
    });

    load_next();
  } 
}
