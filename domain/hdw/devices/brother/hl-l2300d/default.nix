{ pkgs, ... }:
{
  services.printing = {
    drivers = [ pkgs.brlaser ];
  };
  hardware.printers.ensurePrinters = [
    {
      name = "brother";
      model = "drv:///brlaser.drv/brl2300d.ppd";
      location = "place";
      deviceUri = "usb://Brother/HL-L2300D%20series";
      ppdOptions = { printer-is-shared = "true"; };
    }
  ];
}
