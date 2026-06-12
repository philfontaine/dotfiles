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

  // Repo: current directory + git branch
  const cwd = json.cwd;
  if (cwd) {
    const dir = cwd.split(/[\\/]/).filter(Boolean).pop() || cwd;
    parts.push(`${ESC}[36m${dir}${reset}`);
  }
  if (cwd) {
    try {
      const branch = execSync(`git -C "${cwd}" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null`, { encoding: 'utf8' }).trim();
      if (branch && branch !== 'HEAD') parts.push(`${magenta}${branch}${reset}`);
    } catch {}
  }

  // Model + effort
  const model = json.model?.display_name || json.model?.id || '?';
  const effort = json.effort?.level;
  const modelLabel = effort ? `${model} ${dim}[${effort}]${reset}` : model;
  parts.push(`${blue}${modelLabel}${reset}`);

  // Context %
  const ctxPct = json.context_window?.used_percentage;
  if (ctxPct != null) {
    const pct = Math.round(ctxPct);
    const color = pct >= 90 ? red : pct >= 70 ? yellow : green;
    parts.push(`${color}ctx:${pct}%${reset}`);
  }

  // 5-hour window
  const fiveHour = json.rate_limits?.five_hour;
  if (fiveHour?.used_percentage != null) {
    const pct = Math.round(fiveHour.used_percentage);
    const color = pct >= 90 ? red : pct >= 70 ? yellow : `${dim}${white}`;
    let label = `5h: ${pct}%`;
    if (fiveHour.resets_at != null) {
      const resetsAt = new Date(fiveHour.resets_at * 1000);
      if (resetsAt - new Date() > 0) {
        const hours = resetsAt.getHours();
        const suffix = hours >= 12 ? 'PM' : 'AM';
        const displayHour = hours % 12 || 12;
        label += ` (${displayHour}${suffix})`;
      } else {
        label += ` (resetting)`;
      }
    }
    parts.push(`${color}${label}${reset}`);
  }

  // 7-day window
  const sevenDay = json.rate_limits?.seven_day;
  if (sevenDay?.used_percentage != null) {
    const pct = Math.round(sevenDay.used_percentage);
    const color = pct >= 90 ? red : pct >= 70 ? yellow : `${dim}${white}`;
    let label = `7d: ${pct}%`;
    if (sevenDay.resets_at != null) {
      const resetsAt = new Date(sevenDay.resets_at * 1000);
      if (resetsAt - new Date() > 0) {
        const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        const hours = resetsAt.getHours();
        const suffix = hours >= 12 ? 'PM' : 'AM';
        const displayHour = hours % 12 || 12;
        label += ` (${days[resetsAt.getDay()]} ${months[resetsAt.getMonth()]} ${resetsAt.getDate()} ${displayHour}${suffix})`;
      } else {
        label += ` (resetting)`;
      }
    }
    parts.push(`${color}${label}${reset}`);
  }

  process.stdout.write(parts.join(` ${dim}|${reset} `));
});
