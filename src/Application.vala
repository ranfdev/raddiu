/*
 * Copyright (c) 2019-2019 ranfdev
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: ranfdev and contributors
 */
using Granite;
using Granite.Widgets;
using Gtk;


namespace raddiu {
  public class Player: Object {
    public bool playing  {get;set;default = false;}
    public Subprocess mpv;
    public RadioData current_radio {get;set;}
    public void toggle() {
      if (playing)
        pause();
      else 
        resume();
    }
    public void pause() {
      if (mpv is Subprocess) {
        mpv.force_exit();
        playing = false;
      }
    }
    public void resume() {
      play(current_radio);
    }
    public void play(RadioData data) {
      current_radio = data;

      if (playing)
        pause();

      try {
        string[] spawn_args = {"mpv", data.url};
        mpv = new Subprocess.newv(spawn_args, SubprocessFlags.NONE);
        playing = true;
      } catch (Error e) {
        print("Impossible to spawn mpv process: %s\n", e.message);
      }



    }
  }


  [DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
  interface GnomeMediaKeys: Object {
    public abstract void GrabMediaPlayerKeys(string application, uint32 time) throws Error;
    public abstract signal void MediaPlayerKeyPressed(string application, string key);
  }

  public class Raddiu : Granite.Application {
    public static Player player;
    public static Soup.Session soup;
    public static GLib.Settings settings;
    public static string cache;
    public static string _app_id = "com.github.ranfdev.raddiu";

    private CssProvider css_provider = new CssProvider();

    private GnomeMediaKeys media_keys;

    private Widgets.PlayingPanel playing_view;

    private Views.Discover discover;
    public static Views.Search search;
    private Views.Recents recents;

    public static Stack stack;

    public ApplicationWindow window;

    public static MainLoop loop;
    public static string? state = null;
    public static string? country = null;
    public static string? order = null;
    public static bool reverse = false;
    public static int limit = 40;
    public static string[]? subcommand = null;
    public static string? tag = null;

    public const GLib.OptionEntry[] search_options = {
      {"state", 0,0, OptionArg.STRING, ref state, "Display only radios from this STATE", "STATE"},
      {"tag", 0,0, OptionArg.STRING, ref tag, "Filter radios by TAG", "TAG"},
      {"country", 0,0, OptionArg.STRING, ref country, "Display only radios from this COUNTRY", "COUNTRY"},
      {"order", 0,0, OptionArg.STRING, ref order, "Choose how to ORDER the results", "ORDER"},
      {"reverse", 0,0, OptionArg.NONE, ref reverse, "Reverse the order of results", "BOOLEAN"},
      {"limit", 0,0, OptionArg.INT, ref limit, "QUANTITY of radios to show", "INT"},
      {"", 0,0, OptionArg.STRING_ARRAY, ref subcommand, "Subcommand (search, listen...)", "STRING"},
      {null}
    };

    static construct {
      player = new Player();
      soup = new Soup.Session(); 
      soup.timeout = 10;
      settings = new GLib.Settings(_app_id);
      cache = Path.build_path(Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir(), _app_id);
    }

    public Raddiu () {
      Object(
        application_id: "com.github.ranfdev.raddiu", 
        flags: ApplicationFlags.FLAGS_NONE
        );
    }
    protected override void activate () {

      // Init player
      player = new Player();

      // create cache folder if it doesn't exist
      File cache_folder = File.new_for_path(cache);

      if (!cache_folder.query_exists()) {
        cache_folder.make_directory_async.begin();
      }

      // Init dbus
      try {
        media_keys = Bus.get_proxy_sync(BusType.SESSION,
                                        "org.gnome.SettingsDaemon",
                                        "/org/gnome/SettingsDaemon/MediaKeys",
                                        DBusProxyFlags.NONE, 
                                        null);
        media_keys.MediaPlayerKeyPressed.connect((caller,app,key) => {
          if (key == "Play" || key == "Pause") {
                        Raddiu.player.toggle();
                                  
          }
                  
        });

        try {
          media_keys.GrabMediaPlayerKeys(application_id, (uint32)0);
        } catch (Error e) {
          warning ("MEDIA KEY ERROR: %s", e.message);
        }

      } catch (Error e) {
        print("Impossible to get a dbus proxy: %s", e.message);
      }



      // Init styles
      css_provider.load_from_resource ("/com/github/ranfdev/raddiu/Application.css");
      Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(),css_provider,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);


      // Init window
      window = new Gtk.ApplicationWindow (this);
      window.get_style_context().add_class("rounded");


      window.title = "raddiu";
      window.set_default_size (900, 640);

      stack = new Gtk.Stack();
      stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

      discover = new Views.Discover();
      stack.add_titled(discover, "discover","Discover");

      search = new Views.Search();
      stack.add_titled(search, "search", "Search");

      recents = new Views.Recents();
      stack.add_titled(recents, "recents", "Recents");

      var stack_switcher = new Gtk.StackSwitcher();

      var panes = new Gtk.Box(Orientation.HORIZONTAL, 0);
      window.add(panes);


      // Notify user if mpv is not found
      var dialog = new Granite.MessageDialog.with_image_from_icon_name(
        "The program mpv is not installed", 
        "Raddiu to function needs to use the program mpv. Install it with your package manager (eg: 'sudo apt install mpv')",
        "dialog-error"
        );
      dialog.response.connect(() => {
        quit();
      });

      var mpv_path = GLib.Environment.find_program_in_path("mpv");

      print("MPV PATH: %s\n", mpv_path);
      if (mpv_path == null) {
        dialog.show();
        dialog.run();
      }

      // mpv section end

      panes.pack_start (stack,true,true,0);

      playing_view = new Widgets.PlayingPanel();
      playing_view.hexpand = false;
      playing_view.halign = Align.END;
      panes.pack_end (playing_view, false, false, 0);



      var header = new Gtk.HeaderBar();
      header.show_close_button = true;
      header.set_custom_title(stack_switcher);

      

      window.set_titlebar(header);
      window.show_all ();

      window.destroy.connect(() => {
        Raddiu.player.pause();
      });
      stack.visible_child = discover;
      stack_switcher.stack = stack;
    }

    public static int main (string[] args) {

      // If args > 1 it means the user is trying to run the program
      // as a cli program

      if (args.length > 1) {

        try {

          var option_context = new OptionContext("Raddiu");
          option_context.set_help_enabled(true);
          option_context.add_main_entries(search_options, null);
          option_context.parse(ref args);

        } catch (OptionError e) {
          print("Error: %s\n", e.message);
        }

        switch (subcommand[0]) {

          // If the subcommand is search

          case "search":
            if (subcommand[1] == null) {
              break;
            }

            loop = new MainLoop();

            var fetcher = new Network.RadioListFetcher();
            if (state != null) {
              fetcher.parameters.set_data("state", state);
            }
            if (country != null) {
              fetcher.parameters.set_data("country", country);
            }
            if (reverse) {
              fetcher.parameters.set_data("reverse", "true");
            }
            if (tag != null) {
              fetcher.parameters.set_data("tag", tag);
            }
            if (order != null) {
              fetcher.parameters.set_data("order", order);
            }
            fetcher.parameters.set_data("limit", @"$limit");

            fetcher.item_loaded.connect((item) => {
              print("%s\n%s\n%s\n", item.name, item.url, item.favicon);
            });

            fetcher.finished.connect(() => {
              loop.quit();
            });

            fetcher.load.begin("/" + subcommand[1]);

            loop.run();

            break;
        }


      } else {
        var app = new Raddiu ();
        return app.run (args);
      }
      return 0;
    }
  }
}
