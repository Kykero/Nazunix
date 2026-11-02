# onedriver answers every statfs with a Graph request for the drive quota
# (fs/fs.go, StatFs -> graph.GetDrive), about half a second each. Nautilus
# statfs's ~/OneDrive several times on its main thread whenever a window
# opens or closes (sidebar bookmark, home listing), so it froze for seconds.
# The quota is cached for a minute here. Once a quota is known, statfs
# never waits on Graph again: a stale one is answered at once and
# refreshed in the background, one request at a time, so going offline
# (each request then hangs for the HTTP timeout, a minute) cannot freeze
# Nautilus either. Built locally, not substituted.
{ ... }:
{
  den.aspects.desktop-onedrive.nixos.nixpkgs.overlays = [
    (final: prev: {
      onedriver = prev.onedriver.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace fs/fs.go \
            --replace-fail 'graph.GetDrive(f.auth)' 'cachedDrive(f.auth)'
          cat > fs/statfs_cache.go <<'EOF'
          package fs

          import (
          	"sync"
          	"time"

          	"github.com/jstaf/onedriver/fs/graph"
          )

          var (
          	driveCacheM       sync.Mutex
          	driveCache        graph.Drive
          	driveCacheAt      time.Time
          	driveCacheRefresh bool
          )

          func cachedDrive(auth *graph.Auth) (graph.Drive, error) {
          	driveCacheM.Lock()
          	defer driveCacheM.Unlock()
          	if driveCacheAt.IsZero() {
          		drive, err := graph.GetDrive(auth)
          		if err == nil {
          			driveCache, driveCacheAt = drive, time.Now()
          		}
          		return drive, err
          	}
          	if time.Since(driveCacheAt) >= time.Minute && !driveCacheRefresh {
          		driveCacheRefresh = true
          		go refreshDrive(auth)
          	}
          	return driveCache, nil
          }

          func refreshDrive(auth *graph.Auth) {
          	drive, err := graph.GetDrive(auth)
          	driveCacheM.Lock()
          	defer driveCacheM.Unlock()
          	driveCacheRefresh = false
          	if err == nil {
          		driveCache, driveCacheAt = drive, time.Now()
          	}
          }
          EOF
        '';
      });
    })
  ];
}
