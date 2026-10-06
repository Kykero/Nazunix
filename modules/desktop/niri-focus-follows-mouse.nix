# Hovering a window focuses it, no click needed. niri may scroll the view to
# bring a partially visible window into view when it gains focus this way.
{ ... }:
{
  den.aspects.desktop-niri-focus-follows-mouse.provides.to-users.homeManager = {
    programs.niri.settings.input.focus-follows-mouse.enable = true;
  };
}
