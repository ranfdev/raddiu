using Gtk;
using Granite;
public class raddiu.Views.Countries: Gtk.ScrolledWindow {
  private Gtk.Box content;

  private Network.RadioListFetcher fetcher;
  private Network.CountriesFetcher countries_fetcher;

  private string current_country = "USA";
  private int loaded;

  private Gtk.ComboBoxText combo_box;
  private Widgets.RadioList radio_list;
  private Gtk.Spinner spinner;


  public void load_countries() {
    countries_fetcher.item_loaded.connect((_,country) => {
      combo_box.append_text(country.name);
    });
    countries_fetcher.load.begin();
  }
  public void load_next() {
    spinner.start();
    fetcher.parameters.set_data("offset", loaded.to_string());
    loaded+=40;
    fetcher.parameters.set_data("limit", loaded.to_string());
    fetcher.load.begin("/bycountry/" + current_country);
  }
  public void change_country(string country) {
    current_country = country;
    Raddiu.settings.set_string("country",country);
    radio_list.foreach((widget) => {
      widget.destroy();
    });
    loaded = 0;
    load_next();
  }
  public Countries() {
    current_country = Raddiu.settings.get_string("country");

    fetcher = new Network.RadioListFetcher();
    fetcher.parameters.set_data("order", "clickcount");
    fetcher.parameters.set_data("reverse", "true");

    countries_fetcher = new Network.CountriesFetcher();

    content = new Gtk.Box(Orientation.VERTICAL, 20); 
    add(content);

    var horizontal_header = new Gtk.Box(Orientation.HORIZONTAL, 20);
    content.add(horizontal_header);

    var label = new Gtk.Label("Countries");
    label.get_style_context().add_class(STYLE_CLASS_H2_LABEL);
    label.halign = Align.START;
    label.margin = 15;
    horizontal_header.add(label);


    combo_box = new Gtk.ComboBoxText();
    combo_box.append_text(current_country);
    combo_box.active = 0;
    combo_box.valign = Align.CENTER;
    combo_box.changed.connect(() => {
      change_country(combo_box.get_active_text());
    });
    horizontal_header.add(combo_box);

    radio_list = new Widgets.RadioList();
    content.add(radio_list);

    spinner = new Gtk.Spinner();
    spinner.start();
    content.add(spinner);

    fetcher.item_loaded.connect((near, radio_data) => {
      if (spinner.active)
        spinner.stop();
      radio_list.add_radio(radio_data);
    });

    edge_reached.connect((top, position) => {
      if (position == PositionType.BOTTOM) {
        load_next();
      }
    });
    load_next();
    load_countries();
  }
}
