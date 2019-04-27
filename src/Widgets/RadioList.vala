  public class raddiu.Widgets.RadioList: Gtk.FlowBox {
    public RadioList (RadioData[] data = {}) {
      valign = Gtk.Align.START;
      row_spacing = 10;
      column_spacing = 10;
      child_activated.connect((item) => {
        var radio = (item.get_child() as Widgets.Radio).metadata;
        Raddiu.player.play(radio);
        Views.Recents.save_radio(radio);
      });
      add_radio_list(data);
    } 
    public void add_radio_list(RadioData[] data = {}) {
      foreach (var radio in data) {
        add_radio(radio); 
      }
    }
    public void add_radio(RadioData data) {
      var radio = new Widgets.Radio(data);
      add(radio);
      radio.show_all();
    }
  }
