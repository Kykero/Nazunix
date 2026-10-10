# Hovering a window focuses it, no click needed. max-scroll-amount "0%" only
# lets the pointer focus windows that are already fully visible: without it, a
# new window opened next to a maximized column scrolls into view, the pointer
# still rests on the big window, and focus (and the view) snaps back to it.
{ ... }:
{
  den.aspects.desktop-niri-focus-follows-mouse.provides.to-users.homeManager = {
    programs.niri.settings.input.focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };
  };
}
