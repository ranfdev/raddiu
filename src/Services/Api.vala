namespace raddiu {
  public class RadioData: Object {
    public string id {get;set;}
    public string name {get;set;}
    public string url {get; set;}
    public string favicon {get; set;}
  }
  public class Country: Object {
    public string name {get;set;}
    public string stationcount {get;set;}
  }
  namespace Network {
    public class CountriesFetcher {
      public Json.Parser parser;
      public signal void item_loaded(Country item);
      public signal void started();
      private string url = "http://www.radio-browser.info/webservice/json/countries";
      public CountriesFetcher() {
        parser = new Json.Parser();
        parser.array_start.connect(() => {started();});
        parser.array_element.connect((parser,array,index) => {
          item_loaded(Json.gobject_deserialize(typeof (Country), array.get_element(index)) as Country);
        });
      }

      public async void load() {
        var msg = new Soup.Message("GET", url);
        var stream = yield Raddiu.soup.send_async(msg);
        yield parser.load_from_stream_async(stream);
      }
    }

    public class RadioListFetcher {
      public Json.Parser parser;
      private Cancellable cancellable;
      public signal void item_loaded(RadioData item);
      private string url = "http://www.radio-browser.info/webservice/json/stations";
      public Datalist<string> parameters = Datalist<string>();

      public signal void started();
      public signal void finished();

      public RadioListFetcher() {
        parser = new Json.Parser();
        parser.array_start.connect(() => {started();});
        parser.array_element.connect((parser,array,index) => {
          item_loaded(Json.gobject_deserialize(typeof (RadioData), array.get_element(index)) as RadioData);
        });
        parser.array_end.connect(() => {finished();});
      }

      public void cancel() {
        cancellable.cancel();
      }
      public async void load(string input_url) {
        var msg = Soup.Form.request_new_from_datalist(
          "POST",
          url + input_url,
          parameters
          );
        var stream = yield Raddiu.soup.send_async(msg, cancellable);
        yield parser.load_from_stream_async(stream);
      }
    }
  }
}
