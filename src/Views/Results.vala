public class raddiu.Views.Results: Gtk.ScrolledWindow {
  public string query;

  private Gtk.Box content;
  private Network.RadioListFetcher fetcher;
  private Widgets.RadioList radio_list;
  private Gtk.Spinner spinner;
  private Granite.Widgets.AlertView alert_view;

  public void load_next() {
    if (query == "" || query == null) {
      return;
    }

    spinner.start();
    alert_view.hide();

    fetcher.cancel();
    radio_list.foreach((widget) => {
      print("removing");
      widget.destroy(); 
    });

    fetcher.parameters.set_data("name", query);
    fetcher.load.begin("/search");
  }
  public Results() {
    fetcher = new Network.RadioListFetcher();
    fetcher.parameters.set_data("order", "clickcount");
    fetcher.parameters.set_data("reverse", "true");
    fetcher.parameters.set_data("limit", "40");

    content = new Gtk.Box(Gtk.Orientation.VERTICAL,5);
    add(content);

    alert_view = new Granite.Widgets.AlertView("No results","Try to change your search query", "system-search-symbolic");
    content.add(alert_view);

    radio_list = new Widgets.RadioList(); 
    content.add(radio_list);

    spinner = new Gtk.Spinner();
    spinner.margin = 10;
    content.add(spinner);

    fetcher.finished.connect(() => {
      spinner.stop();
      if (radio_list.get_children().length() == 0) {
        alert_view.show();
      }
    });
    fetcher.item_loaded.connect((fetcher, radio) => {
      radio_list.add_radio(radio); 
    });

    load_next();
  } 
}
