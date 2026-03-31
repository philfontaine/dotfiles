const { execSync } = require('child_process');

const chunks = [];
process.stdin.on('data', d => chunks.push(d));
process.stdin.on('end', () => {
  let json = {};
  try { json = JSON.parse(chunks.join('')); } catch {}

  const ESC = '\x1b';
  const reset  = `${ESC}[0m`;
  const dim    = `${ESC}[2m`;
  const green  = `${ESC}[32m`;
  const yellow = `${ESC}[33m`;
  const red    = `${ESC}[31m`;
  const blue   = `${ESC}[34m`;
  const magenta= `${ESC}[35m`;
  const white  = `${ESC}[37m`;

  const parts = [];

  // Model
  const model = json.model?.display_name || json.model?.id || '?';
  parts.push(`${blue}${model}${reset}`);

  // Context %
  const ctxPct = json.context_window?.used_percentage;
  if (ctxPct != null) {
    const pct = Math.round(ctxPct);
    const color = pct >= 90 ? red : pct >= 70 ? yellow : green;
    parts.push(`${color}ctx:${pct}%${reset}`);
  }

  // Daily (5-hour window)
  const fiveHour = json.rate_limits?.five_hour;
  if (fiveHour?.used_percentage != null) {
    const pct = Math.round(fiveHour.used_percentage);
    const color = pct >= 90 ? red : pct >= 70 ? yellow : `${dim}${white}`;
    let label = `daily:${pct}%`;
    if (fiveHour.resets_at != null) {
      const resetsAt = new Date(fiveHour.resets_at * 1000);
      const now = new Date();
      const diffMs = resetsAt - now;
      if (diffMs > 0) {
        const hours = resetsAt.getHours();
        const suffix = hours >= 12 ? 'PM' : 'AM';
        const displayHour = hours % 12 || 12;
        label += ` (resets at ${displayHour}${suffix})`;
      } else {
        label += ` (resetting)`;
      }
    }
    parts.push(`${color}${label}${reset}`);
  }

  // Weekly (7-day window)
  const weekly = json.rate_limits?.seven_day?.used_percentage;
  if (weekly != null) {
    const pct = Math.round(weekly);
    const color = pct >= 90 ? red : pct >= 70 ? yellow : `${dim}${white}`;
    parts.push(`${color}weekly:${pct}%${reset}`);
  }

  // Current directory
  const cwd = json.cwd;
  if (cwd) {
    const dir = cwd.split(/[\\/]/).filter(Boolean).pop() || cwd;
    parts.push(`${ESC}[36m${dir}${reset}`);
  }

  // Git branch
  if (cwd) {
    try {
      const branch = execSync(`git -C "${cwd}" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null`, { encoding: 'utf8' }).trim();
      if (branch && branch !== 'HEAD') parts.push(`${magenta}${branch}${reset}`);
    } catch {}
  }

  process.stdout.write(parts.join(` ${dim}|${reset} `));
});
