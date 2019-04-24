public class raddiu.Views.Search: Gtk.ScrolledWindow {
  public string query;
  public int loaded = 0;
  public int limit = 40;

  private Gtk.Box content;
  private Network.RadioListFetcher fetcher;
  private Widgets.RadioList radio_list;
  private Gtk.Spinner spinner;
  private Granite.Widgets.AlertView alert_view;

  public Gtk.ComboBoxText reverse_combo_box;
  public Gtk.ComboBoxText language_combo_box;
  public Gtk.ComboBoxText country_combo_box;
  public Gtk.ComboBoxText order_combo_box;
  public Gtk.SearchEntry tags_entry;

  public void load() {
    spinner.start();
    alert_view.hide();

    // Stop fetching the old query
    if (fetcher != null) {
      fetcher.cancel();
    }

    fetcher = new Network.RadioListFetcher();

    fetcher.parameters.set_data("name", query);
    fetcher.parameters.set_data("offset", @"$loaded");
    fetcher.parameters.set_data("limit", "40");
    fetcher.parameters.set_data("language", language_combo_box.get_active_text());
    fetcher.parameters.set_data("order", order_combo_box.get_active_text());
    fetcher.parameters.set_data("country", country_combo_box.get_active_text());

    // Reverse results order
    var reverse_string = reverse_combo_box.get_active_text() == "descending" ? "true" : "false";
    fetcher.parameters.set_data("reverse", reverse_string);

    // Filter by tag only if tag list is present
    print("\n\n Tags: %s \n\n", tags_entry.text);
    if (tags_entry.text.length > 0) {
      fetcher.parameters.set_data("tagList", tags_entry.text);
    }

    fetcher.finished.connect(() => {
      spinner.stop();
      if (radio_list.get_children().length() == 0) {
        alert_view.show();
      } else {
        alert_view.hide();
      }
    });

    fetcher.item_loaded.connect((fetcher, radio) => {
      radio_list.add_radio(radio); 
    });

    fetcher.load.begin("/search");
  }
  public void reload() {
    loaded = 0;

    // Remove every radio from the list
    radio_list.foreach((widget) => {
      widget.destroy(); 
    });

    load();
  }
  public void load_next() {
    loaded+=limit;
    load();
  }
  public Search() {

    content = new Gtk.Box(Gtk.Orientation.VERTICAL,5);
    add(content);


    // search bar

    var search_entry = new Gtk.SearchEntry();
    search_entry.margin = 10;
    search_entry.placeholder_text = "Search by radio name...";
    content.add(search_entry);

    search_entry.search_changed.connect(() => {
      print("\nUPDATE\n");
      query = search_entry.text;
      reload();
    });


    // Search options/filters

    // Container

    var option_container = new Gtk.FlowBox();
    option_container.margin = 10;
    option_container.row_spacing = 10;
    option_container.column_spacing = 10;
    option_container.selection_mode = Gtk.SelectionMode.NONE;
    content.add(option_container);

    
    // Filter by country

    var option_row_country = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_country);

    var country_label = new Gtk.Label("Country:");
    option_row_country.add(country_label);

    country_combo_box = new Gtk.ComboBoxText.with_entry();
    country_combo_box.append_text(Raddiu.settings.get_string("country"));
    option_row_country.pack_end(country_combo_box);

    country_combo_box.changed.connect(reload);


    // Order by option

    var option_row_order = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_order);

    var order_label = new Gtk.Label("Order by:");
    option_row_order.add(order_label);

    string possible_orders[] = {
      "clickcount",
      "votes",
      "name",
      "country",
      "state",
      "tags",
      "url",
      "homepage",
      "bitrate",
      "clicktrend",
      "favicon",
      "language",
      "negativevotes",
      "codec",
      "lastcheckok",
      "lastchecktime",
      "clicktimestamp"
    };

    order_combo_box = new Gtk.ComboBoxText.with_entry();

    foreach (var order in possible_orders) {
      order_combo_box.append_text(order);
    }
    order_combo_box.active = 0;
    option_row_order.pack_end(order_combo_box);

    order_combo_box.changed.connect(reload);


    // Filter by language

    var option_row_language = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_language);

    var language_label = new Gtk.Label("Language:");
    option_row_language.add(language_label);

    language_combo_box = new Gtk.ComboBoxText.with_entry();
    language_combo_box.append_text(Raddiu.settings.get_string("country"));
    option_row_language.pack_end(language_combo_box);

    language_combo_box.changed.connect(reload);


    // Tags entry

    var option_row_tags = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_tags);

    var tags_label = new Gtk.Label("Tags:");
    option_row_tags.add(tags_label);

    tags_entry = new Gtk.SearchEntry();
    tags_entry.placeholder_text = "blues, jazz, rock, punk...";
    tags_entry.search_changed.connect(reload);
    option_row_tags.pack_end(tags_entry);


    // Reverse order

    var option_row_reverse = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_reverse);

    var reverse_label = new Gtk.Label("Reverse:");
    option_row_reverse.add(reverse_label);

    reverse_combo_box = new Gtk.ComboBoxText();
    reverse_combo_box.append_text("descending");
    reverse_combo_box.append_text("ascending");
    reverse_combo_box.active = 0;
    option_row_reverse.pack_end(reverse_combo_box);

    reverse_combo_box.changed.connect(reload);


    // Load item suggestions
    var countries_fetcher = new Network.FilterListFetcher();
    var language_fetcher = new Network.FilterListFetcher();

    countries_fetcher.item_loaded.connect((obj) => {
      country_combo_box.append_text(obj.name);
    });

    language_fetcher.item_loaded.connect((obj) => {
      language_combo_box.append_text(obj.name);
    });

    countries_fetcher.load("countries");
    language_fetcher.load("languages");


    // Alert view

    alert_view = new Granite.Widgets.AlertView("No results","Try to change your search query", "system-search-symbolic");
    alert_view.hide();
    content.add(alert_view);

    radio_list = new Widgets.RadioList(); 
    content.add(radio_list);

    spinner = new Gtk.Spinner();
    spinner.margin = 10;
    content.add(spinner);

    

    edge_reached.connect((top, position) => {
      if (position == Gtk.PositionType.BOTTOM) {
        load_next();
      }
    });

    load();
  } 
}
