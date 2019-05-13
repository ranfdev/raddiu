public class raddiu.Views.Search: Gtk.ScrolledWindow {
  public string query;
  public int loaded = 0;
  public int limit = 40;

  private Gtk.Box content;
  private Network.RadioListFetcher fetcher;
  private Widgets.RadioList radio_list;
  private Gtk.Spinner spinner;
  private Granite.Widgets.AlertView alert_view;

  public Gtk.SearchEntry search_entry;
  public Gtk.ComboBoxText reverse_combo_box;
  public Gtk.ComboBoxText language_combo_box;
  public Gtk.ComboBoxText country_combo_box;
  public Gtk.ComboBoxText order_combo_box;
  public Gtk.SearchEntry tags_entry;

  public void reset_filters() {
      search_entry.text = "";
      order_combo_box.active_id = "votes";
      reverse_combo_box.active_id = "descending";
      language_combo_box.active_id = "";
      country_combo_box.active_id = "";
      tags_entry.text = "";
  }

  public void load() {
    spinner.start();
    alert_view.hide();

    // Stop fetching the old query
    if (fetcher != null) {
      fetcher.cancel();
      print("CANCELLED REQUESTS");
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
    content.margin = 10;
    add(content);


    // search bar

    search_entry = new Gtk.SearchEntry();
    search_entry.margin = 10;
    search_entry.placeholder_text = _("Search by radio name...");
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

    var country_label = new Gtk.Label(_("Country:"));
    option_row_country.add(country_label);

    country_combo_box = new Gtk.ComboBoxText.with_entry();
    country_combo_box.append("","");
    option_row_country.pack_end(country_combo_box);

    country_combo_box.changed.connect(reload);


    // Order by option

    var option_row_order = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_order);

    var order_label = new Gtk.Label(_("Order by:"));
    option_row_order.add(order_label);

    string possible_orders[] = {
      "votes",
      "clickcount",
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
    order_combo_box.append("","");

    foreach (var order in possible_orders) {
      order_combo_box.append(order,order);
    }
    order_combo_box.active = 1;
    option_row_order.pack_end(order_combo_box);

    order_combo_box.changed.connect(reload);


    // Filter by language

    var option_row_language = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_language);

    var language_label = new Gtk.Label(_("Language:"));
    option_row_language.add(language_label);

    language_combo_box = new Gtk.ComboBoxText.with_entry();
    language_combo_box.append("","");

    option_row_language.pack_end(language_combo_box);

    language_combo_box.changed.connect(reload);


    // Tags entry

    var option_row_tags = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_tags);

    var tags_label = new Gtk.Label(_("Tags:"));
    option_row_tags.add(tags_label);

    tags_entry = new Gtk.SearchEntry();
    tags_entry.placeholder_text = _("blues, jazz, rock, punk...");
    tags_entry.search_changed.connect(reload);
    option_row_tags.pack_end(tags_entry);


    // Reverse order

    var option_row_reverse = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    option_container.add(option_row_reverse);

    var reverse_label = new Gtk.Label(_("Reverse:"));
    option_row_reverse.add(reverse_label);

    reverse_combo_box = new Gtk.ComboBoxText();
    reverse_combo_box.append("descending","descending");
    reverse_combo_box.append("ascending","ascending");
    reverse_combo_box.active = 0;
    option_row_reverse.pack_end(reverse_combo_box);

    reverse_combo_box.changed.connect(reload);


    // Load item suggestions
    var countries_fetcher = new Network.FilterListFetcher();
    var language_fetcher = new Network.FilterListFetcher();

    countries_fetcher.item_loaded.connect((obj) => {
      country_combo_box.append(obj.name,obj.name);
    });

    language_fetcher.item_loaded.connect((obj) => {
      language_combo_box.append(obj.name,obj.name);
    });

    countries_fetcher.load.begin("countries");
    language_fetcher.load.begin("languages");




    // Alert view

    alert_view = new Granite.Widgets.AlertView(_("No results"), _("Try to change your search query"), "system-search-symbolic");
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

    // Reset filters
    reset_filters();
  } 
}
