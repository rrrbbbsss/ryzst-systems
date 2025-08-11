import sys, gi, subprocess, os.path, json

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, Gdk


buttonsConfig = os.path.expanduser("~/.config/media-powermenu/buttons.json")
with open(buttonsConfig) as f:
    buttonsCommands = json.load(f)
buttons = [
    ("Sleep", buttonsCommands["Sleep"]),
    ("Reboot", buttonsCommands["Reboot"]),
    ("Shut Down", buttonsCommands["Shut Down"]),
]


# https://github.com/Taiko2k/GTK4PythonTutorial
class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.box = Gtk.Box()
        self.box.set_orientation(Gtk.Orientation.VERTICAL)
        self.box.set_valign(Gtk.Align.CENTER)
        self.box.set_halign(Gtk.Align.CENTER)
        self.box.set_css_classes(["power"])
        self.set_child(self.box)

        for label, command in buttons:
            self.createButton(label, command)

    def createButton(self, label, command):
        button = Gtk.Button(label=label)
        button.set_css_classes(["powerbutton"])
        button.set_cursor(Gdk.Cursor.new_from_name("pointer"))
        button.connect("clicked", lambda x: self.execute(command))
        self.box.append(button)

    def execute(self, command):
        subprocess.run(command.split(" "))


class MyApp(Gtk.Application):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.setCss()
        self.connect("activate", self.on_activate)

    def on_activate(self, app):
        self.win = MainWindow(application=app)
        self.win.present()

    def setCss(self):
        configPath = os.path.expanduser("~/.config/media-powermenu/style.css")
        if not os.path.exists(configPath):
            return
        css_provider = Gtk.CssProvider()
        css_provider.load_from_path(configPath)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )


def main():
    app = MyApp(application_id="net.ryzst.media-powermenu")
    app.run(sys.argv)


if __name__ == "__main__":
    main()
