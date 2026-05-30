// canopy-components.jsx — shared primitives + tree illustration system
const { useState, useEffect, useRef, useMemo, useCallback } = React;

// ─────────────────────────────────────────────────────────────
// TreeIllustration — stylized SVG trees, varied by species
// ─────────────────────────────────────────────────────────────
const TREE_SHAPES = {
  'Eastern Redbud': 'cloud',     // rounded canopy
  'Sugar Maple':    'lobed',     // five-lobe canopy
  'Flowering Dogwood': 'cloud',
  'Red Oak':        'lobed',
  'River Birch':    'tall',      // narrow upright
  'Tulip Poplar':   'tall',
  'White Pine':     'conifer',   // triangular
  'American Sycamore': 'broad',
  'Honey Locust':   'lobed',
  'Pin Oak':        'lobed',
  'Black Walnut':   'broad',
};

function TreeIllustration({ species = 'Sugar Maple', color = '#9CC066', size = 120, bg = null, accent = null }) {
  const shape = TREE_SHAPES[species] || 'cloud';
  const bark = 'var(--bark)';
  // Render different SVG shapes
  const renderShape = () => {
    switch (shape) {
      case 'cloud':
        return (
          <g>
            <circle cx="60" cy="48" r="22" fill={color} />
            <circle cx="42" cy="56" r="18" fill={color} />
            <circle cx="78" cy="56" r="18" fill={color} />
            <circle cx="60" cy="68" r="20" fill={color} />
            {accent && <circle cx="48" cy="44" r="3" fill={accent} opacity="0.85" />}
            {accent && <circle cx="72" cy="52" r="2.5" fill={accent} opacity="0.85" />}
            {accent && <circle cx="62" cy="62" r="2.5" fill={accent} opacity="0.85" />}
          </g>
        );
      case 'lobed':
        return (
          <g>
            <path
              d="M60 22 C48 22 38 30 36 42 C26 44 22 52 26 60 C18 64 18 76 28 80 C28 92 44 94 52 86 C56 92 64 92 68 86 C76 94 92 92 92 80 C102 76 102 64 94 60 C98 52 94 44 84 42 C82 30 72 22 60 22 Z"
              fill={color}
            />
            {accent && <path d="M50 50 L55 55 M70 50 L65 55 M60 70 L60 78" stroke={accent} strokeWidth="1.4" strokeLinecap="round" opacity="0.7" />}
          </g>
        );
      case 'tall':
        return (
          <g>
            <ellipse cx="60" cy="42" rx="14" ry="16" fill={color} />
            <ellipse cx="50" cy="56" rx="16" ry="14" fill={color} />
            <ellipse cx="70" cy="56" rx="16" ry="14" fill={color} />
            <ellipse cx="60" cy="72" rx="22" ry="14" fill={color} />
            {accent && <ellipse cx="52" cy="48" rx="2" ry="3" fill={accent} opacity="0.8" />}
            {accent && <ellipse cx="68" cy="64" rx="2" ry="3" fill={accent} opacity="0.8" />}
          </g>
        );
      case 'conifer':
        return (
          <g>
            <path d="M60 20 L80 50 L68 50 L86 78 L34 78 L52 50 L40 50 Z" fill={color} />
            <path d="M60 32 L74 56 L46 56 Z" fill="rgba(0,0,0,0.08)" />
          </g>
        );
      case 'broad':
        return (
          <g>
            <ellipse cx="60" cy="56" rx="36" ry="28" fill={color} />
            <ellipse cx="44" cy="48" rx="14" ry="10" fill={color} />
            <ellipse cx="76" cy="48" rx="14" ry="10" fill={color} />
            {accent && <circle cx="50" cy="50" r="2.5" fill={accent} opacity="0.8" />}
            {accent && <circle cx="72" cy="58" r="2.5" fill={accent} opacity="0.8" />}
          </g>
        );
      default:
        return <circle cx="60" cy="56" r="32" fill={color} />;
    }
  };
  return (
    <div style={{
      width: size, height: size, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: bg, borderRadius: bg ? 'var(--radius-card)' : 0,
    }}>
      <svg viewBox="0 0 120 120" width="100%" height="100%" preserveAspectRatio="xMidYMid meet">
        {/* ground hint */}
        <ellipse cx="60" cy="106" rx="28" ry="3" fill="rgba(0,0,0,0.08)" />
        {/* trunk */}
        <rect x="56" y="78" width="8" height="26" rx="2" fill={bark} />
        {/* canopy */}
        {renderShape()}
      </svg>
    </div>
  );
}

// Background scene for swipe cards — soft gradient horizon + sun
function CardScene({ color, accent, children, dark }) {
  // Soft sky → soil gradient
  const sky1 = dark ? '#1F2A22' : '#E8F0DA';
  const sky2 = dark ? '#162018' : '#F4EBD2';
  const soil = dark ? '#262922' : '#EBE3D1';
  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%',
      background: `linear-gradient(180deg, ${sky1} 0%, ${sky2} 60%, ${soil} 100%)`,
      overflow: 'hidden',
    }}>
      {/* sun */}
      <div style={{
        position: 'absolute', top: 28, right: 32,
        width: 56, height: 56, borderRadius: '50%',
        background: dark ? 'rgba(232,190,111,0.18)' : 'rgba(217,164,65,0.32)',
        filter: 'blur(2px)',
      }} />
      {/* far hill */}
      <svg viewBox="0 0 400 200" style={{
        position: 'absolute', bottom: 60, left: 0, right: 0, width: '100%', height: 120,
      }} preserveAspectRatio="none">
        <path d="M0 120 Q 100 60 200 90 T 400 80 L 400 200 L 0 200 Z" fill={dark ? 'rgba(91, 193, 130, 0.12)' : 'rgba(47, 125, 79, 0.12)'} />
      </svg>
      {/* near hill */}
      <svg viewBox="0 0 400 200" style={{
        position: 'absolute', bottom: 40, left: 0, right: 0, width: '100%', height: 100,
      }} preserveAspectRatio="none">
        <path d="M0 140 Q 80 100 180 120 T 400 110 L 400 200 L 0 200 Z" fill={dark ? 'rgba(91, 193, 130, 0.2)' : 'rgba(47, 125, 79, 0.2)'} />
      </svg>
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// TopBar — single contextual app bar
// ─────────────────────────────────────────────────────────────
function TopBar({ title, subtitle, leading, trailing, large = false, transparent = false, dark = false }) {
  return (
    <div style={{
      flex: '0 0 auto',
      background: transparent ? 'transparent' : 'var(--surface)',
      padding: large ? '12px 16px 16px' : '8px 8px',
      display: 'flex', alignItems: large ? 'flex-end' : 'center', minHeight: 56,
      gap: 8,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', minWidth: 44, justifyContent: 'flex-start' }}>
        {leading}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        {large ? (
          <div>
            <div className="h-display" style={{ fontSize: 28 }}>{title}</div>
            {subtitle && <div className="caption" style={{ marginTop: 2 }}>{subtitle}</div>}
          </div>
        ) : (
          <div style={{ textAlign: 'left', paddingLeft: 4 }}>
            <div className="h3" style={{ fontSize: 17 }}>{title}</div>
            {subtitle && <div className="caption" style={{ marginTop: 1 }}>{subtitle}</div>}
          </div>
        )}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
        {trailing}
      </div>
    </div>
  );
}

// IconButton — circular tap target for top bar
function IconButton({ icon, onClick, dot = false, weight = '' }) {
  // Phosphor: regular = 'ph', bold/fill/duotone = 'ph-bold' etc.
  const prefix = weight && weight !== 'regular' ? `ph-${weight}` : 'ph';
  return (
    <button onClick={onClick} style={{
      width: 44, height: 44, border: 'none', background: 'transparent',
      color: 'var(--ink-secondary)', borderRadius: '50%',
      display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
    }}>
      <i className={`${prefix} ${icon} pi`}></i>
      {dot && <span style={{
        position: 'absolute', top: 10, right: 10, width: 8, height: 8,
        borderRadius: '50%', background: 'var(--primary)',
        border: '2px solid var(--surface)',
      }}></span>}
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// BottomNav
// ─────────────────────────────────────────────────────────────
const NAV_ITEMS = [
  { id: 'discover', label: 'Discover', icon: 'ph-compass', fill: 'ph-fill ph-compass' },
  { id: 'map',      label: 'Map',      icon: 'ph-map-pin', fill: 'ph-fill ph-map-pin' },
  { id: 'grove',    label: 'Grove',    icon: 'ph-tree',    fill: 'ph-fill ph-tree' },
  { id: 'impact',   label: 'Impact',   icon: 'ph-pulse',   fill: 'ph-fill ph-pulse' },
  { id: 'you',      label: 'You',      icon: 'ph-user-circle', fill: 'ph-fill ph-user-circle' },
];

function BottomNav({ active, onChange, labeled = true }) {
  return (
    <div style={{
      flex: '0 0 auto',
      background: 'var(--surface-card)',
      borderTop: '1px solid var(--hairline)',
      paddingBottom: 'env(safe-area-inset-bottom, 0)',
      display: 'flex',
      height: labeled ? 64 : 56,
    }}>
      {NAV_ITEMS.map(item => {
        const isActive = active === item.id;
        return (
          <button key={item.id} onClick={() => onChange(item.id)} style={{
            flex: 1, border: 'none', background: 'transparent',
            display: 'flex', flexDirection: 'column', alignItems: 'center',
            justifyContent: 'center', gap: 2,
            color: isActive ? 'var(--primary)' : 'var(--ink-tertiary)',
            padding: '6px 0',
            position: 'relative',
          }}>
            <div style={{
              width: 48, height: labeled ? 24 : 28, display: 'flex',
              alignItems: 'center', justifyContent: 'center',
              borderRadius: 14,
              background: isActive ? 'var(--primary-surface)' : 'transparent',
              transition: 'background 150ms',
            }}>
              <i className={`${isActive ? item.fill : 'ph ' + item.icon} pi`} style={{ fontSize: labeled ? 20 : 24 }}></i>
            </div>
            {labeled && (
              <span style={{ fontSize: 11, fontWeight: isActive ? 600 : 500 }}>{item.label}</span>
            )}
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// HealthDot
// ─────────────────────────────────────────────────────────────
function HealthDot({ status, size = 10 }) {
  const color = {
    healthy: 'var(--pin-healthy)',
    attention: 'var(--pin-attention)',
    risk: 'var(--pin-risk)',
    available: 'var(--pin-available)',
  }[status] || 'var(--ink-tertiary)';
  return <span style={{ display: 'inline-block', width: size, height: size, borderRadius: '50%', background: color, flexShrink: 0 }}></span>;
}

function HealthChip({ status }) {
  const label = { healthy: 'Healthy', attention: 'Needs attention', risk: 'At risk', available: 'Available' }[status];
  const cls = { healthy: 'profit', attention: 'warn', risk: 'danger', available: '' }[status] || '';
  return (
    <span className={`chip ${cls}`}>
      <HealthDot status={status} size={6} /> {label}
    </span>
  );
}

// ─────────────────────────────────────────────────────────────
// ProgressRing — circular progress for health score
// ─────────────────────────────────────────────────────────────
function ProgressRing({ value = 0, size = 56, stroke = 5, color = 'var(--primary)', label }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const offset = c - (value / 100) * c;
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--hairline)" strokeWidth={stroke} />
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke}
          strokeDasharray={c} strokeDashoffset={offset} strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 600ms var(--ease-out)' }} />
      </svg>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', alignItems: 'center',
        justifyContent: 'center', flexDirection: 'column',
      }}>
        {label}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// StatBlock — number + label
// ─────────────────────────────────────────────────────────────
function StatBlock({ value, label, unit, accent, sublabel }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <div className="micro" style={{ color: 'var(--ink-tertiary)' }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
        <span className="num-hero" style={{ color: accent || 'var(--ink)' }}>{value}</span>
        {unit && <span className="body-sm" style={{ color: 'var(--ink-tertiary)' }}>{unit}</span>}
      </div>
      {sublabel && <div className="caption">{sublabel}</div>}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// SectionHeader — for use within a screen body
// ─────────────────────────────────────────────────────────────
function SectionHeader({ title, action, live = false }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
      padding: '0 16px', marginBottom: 12,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span className="h3" style={{ fontSize: 16, fontWeight: 600 }}>{title}</span>
        {live && (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            <span className="live-dot"></span>
            <span className="micro" style={{ fontSize: 10, color: 'var(--profit)' }}>LIVE</span>
          </span>
        )}
      </div>
      {action}
    </div>
  );
}

// Photo placeholder block — for tree photos in profiles
function PhotoPlaceholder({ width = '100%', height = 160, label, dark, treeColor = '#9CC066', species = 'Sugar Maple', date }) {
  // Soft gradient placeholder with a tiny tree mark
  const a = dark ? '#2A332E' : '#E8F0DA';
  const b = dark ? '#1F2823' : '#F4EBD2';
  return (
    <div style={{
      width, height, position: 'relative', overflow: 'hidden',
      borderRadius: 'var(--radius-md)',
      background: `linear-gradient(135deg, ${a} 0%, ${b} 100%)`,
    }}>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <TreeIllustration species={species} color={treeColor} size={Math.min(height - 20, 100)} />
      </div>
      {(label || date) && (
        <div style={{
          position: 'absolute', bottom: 8, left: 8, right: 8,
          display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end',
        }}>
          {label && <span className="caption" style={{ color: 'var(--ink-secondary)', fontWeight: 500 }}>{label}</span>}
          {date && <span className="caption" style={{ background: 'rgba(255,255,255,0.7)', padding: '2px 6px', borderRadius: 4, color: 'var(--ink)' }}>{date}</span>}
        </div>
      )}
    </div>
  );
}

// Avatar — circle with initials
function Avatar({ name = 'You', size = 36, hue = 120, you = false }) {
  const initials = name.split(' ').slice(0, 2).map(s => s[0]).join('').toUpperCase();
  const bg = you ? 'var(--primary)' : `hsl(${hue} 30% 78%)`;
  const fg = you ? 'var(--on-primary)' : 'var(--ink)';
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: bg, color: fg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontSize: size * 0.36, fontWeight: 600, flexShrink: 0,
    }}>{initials}</div>
  );
}

// Expose to other babel scripts
Object.assign(window, {
  TreeIllustration, CardScene, TopBar, IconButton, BottomNav, NAV_ITEMS,
  HealthDot, HealthChip, ProgressRing, StatBlock, SectionHeader,
  PhotoPlaceholder, Avatar,
  TREE_SHAPES,
});
