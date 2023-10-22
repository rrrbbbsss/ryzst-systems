import sys, gi, subprocess
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gdk

buttons = [
    ("Sleep", "systemctl suspend"),
    ("Reboot", "systemctl reboot"),
    ("Shut Down", "systemctl poweroff")
]

#https://github.com/Taiko2k/GTK4PythonTutorial
class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.box = Gtk.Box()
        self.box.set_orientation(Gtk.Orientation.VERTICAL)
        self.box.set_valign(Gtk.Align.CENTER)
        self.box.set_halign(Gtk.Align.CENTER)
        self.box.set_css_classes(['power'])
        self.set_child(self.box)

        for (label, command) in buttons:
            self.createButton(label, command)

    def createButton(self, label, command):
        button = Gtk.Button(label=label)
        button.set_css_classes(['powerbutton'])
        button.set_cursor(Gdk.Cursor.new_from_name("pointer"))
        button.connect('clicked', lambda x: self.execute(command))
        self.box.append(button)

    def execute(self, command):
        subprocess.run(command.split(" "))

class MyApp(Gtk.Application):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.setCss()
        self.connect('activate', self.on_activate)

    def on_activate(self, app):
        self.win = MainWindow(application=app)
        self.win.present()

    def setCss(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_path('style.css')
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(),
                                                  css_provider,
                                                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)


def main():
    app = MyApp(application_id="net.ryzst.media-powermenu")
    app.run(sys.argv)

if __name__ == "__main__":
    main()
