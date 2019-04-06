  public class raddiu.Widgets.RadioList: Gtk.FlowBox {
    public RadioList (RadioData[] data = {}) {
      margin = 10;
      valign = Gtk.Align.START;
      child_activated.connect((item) => {
        Raddiu.player.play((item.get_child() as Widgets.Radio).metadata);
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
