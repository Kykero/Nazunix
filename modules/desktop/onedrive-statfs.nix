# onedriver answers every statfs with a Graph request for the drive quota
# (fs/fs.go, StatFs -> graph.GetDrive), about half a second each. Nautilus
# statfs's ~/OneDrive several times on its main thread whenever a window
# opens or closes (sidebar bookmark, home listing), so it froze for seconds.
# The quota is cached for a minute here, and a stale one is kept when a
# refresh fails (offline). Built locally, not substituted.
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
          	driveCacheM  sync.Mutex
          	driveCache   graph.Drive
          	driveCacheAt time.Time
          )

          func cachedDrive(auth *graph.Auth) (graph.Drive, error) {
          	driveCacheM.Lock()
          	defer driveCacheM.Unlock()
          	if time.Since(driveCacheAt) < time.Minute {
          		return driveCache, nil
          	}
          	drive, err := graph.GetDrive(auth)
          	if err != nil {
          		if driveCacheAt.IsZero() {
          			return drive, err
          		}
          		return driveCache, nil
          	}
          	driveCache, driveCacheAt = drive, time.Now()
          	return drive, nil
          }
          EOF
        '';
      });
    })
  ];
}
