namespace KDEConnectIndicator {
    public class DeviceIndicator {
        private const string ICON_NAME = "phone-symbolic";
        public string path;
        private Device device;
        private Gtk.Menu menu;
        private AppIndicator.Indicator indicator;
        private Gtk.MenuItem battery_item;
        private Gtk.MenuItem status_item;
        private Gtk.MenuItem browse_item;
        private Gtk.MenuItem send_item;
        private Gtk.SeparatorMenuItem separator;
        private Gtk.MenuItem pair_item;
        private Gtk.MenuItem unpair_item;
        public DeviceIndicator (string path) {
            this.path = path;
            device = new Device (path);
            menu = new Gtk.Menu ();

            indicator = new AppIndicator.Indicator (
                    path,
                    ICON_NAME,
                    AppIndicator.IndicatorCategory.APPLICATION_STATUS);
            indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);

            menu.append(new Gtk.MenuItem.with_label (device.name));
            battery_item = new Gtk.MenuItem();
            menu.append(battery_item);
            status_item = new Gtk.MenuItem ();
            menu.append(status_item);
            menu.append (new Gtk.SeparatorMenuItem ());
            browse_item = new Gtk.MenuItem.with_label ("Browse device");
            menu.append(browse_item);
            send_item = new Gtk.MenuItem.with_label ("Send file");
            menu.append(send_item);
            separator = new Gtk.SeparatorMenuItem ();
            menu.append (separator);
            pair_item = new Gtk.MenuItem.with_label ("Request pairing");
            menu.append(pair_item);
            unpair_item = new Gtk.MenuItem.with_label ("Unpair");
            menu.append(unpair_item);

            menu.show_all ();

            update_battery_item ();
            update_status_item ();
            update_pair_item ();

            indicator.set_menu (menu);

            browse_item.activate.connect (() => {
                device.browse ();
            });
            send_item.activate.connect (() => {
                Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
                "Select file", null, Gtk.FileChooserAction.OPEN,
                "Cancel", Gtk.ResponseType.CANCEL,
                "Select", Gtk.ResponseType.OK
                );
                // TODO:don't know whether kdeconnect support multiple file
                chooser.select_multiple = false;
                if (chooser.run () == Gtk.ResponseType.OK) {
                var url = chooser.get_uri ();
                device.send_file (url);
                }
                chooser.close ();
            });
            pair_item.activate.connect (() => {
                device.request_pair ();
            });
            unpair_item.activate.connect (() => {
                device.unpair ();
            });

            device.charge_changed.connect ((charge) => {
                update_battery_item ();
            });
            device.state_changed.connect ((charge) => {
                update_status_item ();
            });
            device.pairing_failed.connect (()=>{
                update_pair_item ();
            });
            device.pairing_successful.connect (()=>{
                update_pair_item ();
            });
            device.reachable_status_changed.connect (()=>{
                update_pair_item ();
            });
            device.unpaired.connect (()=>{
                update_pair_item ();
            });
        }
        private void update_battery_item () {
            if (device.is_charging ())
                this.battery_item.label = "Battery : %d %% (charging)".printf(device.battery);
            else
                this.battery_item.label = "Battery : %d %%".printf(device.battery);
        }
        private void update_status_item () {

            if (device.is_reachable ())
                this.status_item.label="Status: Reachable";
            else
                this.status_item.label="Status: Not Reachable";

            if (device.is_paired ())
                this.status_item.label += " and Paired";
            else
                this.status_item.label += " but Not Paired";
        }
        private void update_pair_item () {
            var paired = device.is_paired ();
            pair_item.visible = !paired;
            unpair_item.visible = paired;

            separator.visible = paired;
            browse_item.visible = paired;
            send_item.visible = paired;
        }
    }
}