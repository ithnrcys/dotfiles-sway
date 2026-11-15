// Firefox preferences kept in the dotfiles repo.
// Symlinked to <profile>/user.js; Firefox re-applies every line at each start,
// so a setting listed here cannot be changed for good from the settings page —
// edit or delete the line instead.
// The profile had no user.js before this one: site breakage came from the
// stacked blocker extensions (see README), not from a hardening script.

// Strict tracking protection stays on, but with Mozilla's exception lists for
// sites that are known to break under it (both boxes under
// Settings → Privacy & Security → Enhanced Tracking Protection → Strict).
user_pref("privacy.trackingprotection.allow_list.baseline.enabled", true);
user_pref("privacy.trackingprotection.allow_list.convenience.enabled", true);
