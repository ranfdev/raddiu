public class raddiu.Views.Recents: Gtk.ScrolledWindow {
  private Gtk.Box content;
  private Json.Parser parser;
  private static GenericArray<RadioData> recents; 
  private static string recents_file;
  private static Widgets.RadioList radio_list;

  static construct {
    recents_file = Path.build_filename(Raddiu.cache, "recents");
  }

  public void load() {
    try {
      parser.load_from_file(recents_file);
      parser.get_root().get_array().foreach_element((array, index, radio_node) => {
        recents.add(Json.gobject_deserialize(typeof (RadioData),radio_node) as RadioData);
      }); 
    } catch (Error e) {
      print("%s", e.message);
    }

  }

  public static void save_radio(RadioData data) {
    // Add to local list
    uint older_index;
    var found = recents.find(data, out older_index);

    if (found) {
      print("\n removing -------- %u -------- \n", older_index);
      radio_list.get_child_at_index((int)older_index).destroy();
      recents.remove_index(older_index);
    }

    recents.insert(0, data);
    var radio = new Widgets.Radio(data);
    radio_list.insert(radio, 0);
    radio_list.show_all();

    // Save to json file
    var builder = new Json.Builder();    
    
    builder.begin_array();
    recents.foreach ((radio_data) => {
      var node = Json.gobject_serialize(radio_data);
      builder.add_value(node);
    });
    builder.end_array();

    var generator = new Json.Generator();
    generator.set_root(builder.get_root());
    generator.to_file(recents_file);

  }

  public Recents() {
    recents = new GenericArray<RadioData>();
    parser = new Json.Parser();
    load();

    content = new Gtk.Box(Gtk.Orientation.VERTICAL, 20); 
    content.margin = 10;
    add(content);

    radio_list = new Widgets.RadioList();
    content.add(radio_list);

    recents.foreach((radio) => {
      radio_list.add_radio(radio);
    });
  }
}
