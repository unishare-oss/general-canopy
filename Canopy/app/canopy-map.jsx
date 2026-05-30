// canopy-map.jsx — Geo-tagged tree map with pins

function MapScreen({ trees, onOpenTree, pinStyle = 'pin' }) {
  const [selected, setSelected] = useState(null);
  const [filter, setFilter] = useState('all');

  const filtered = trees.filter(t => {
    if (filter === 'mine') return t.status === 'adopted';
    if (filter === 'available') return t.status === 'available';
    if (filter === 'attention') return t.health === 'attention' || t.health === 'risk';
    return true;
  });

  const selectedTree = selected && trees.find(t => t.id === selected);

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--surface)' }}>
      <TopBar
        title="Map"
        subtitle={`${filtered.length} trees in Maple Heights`}
        leading={null}
        trailing={
          <>
            <IconButton icon="ph-magnifying-glass" onClick={() => {}} />
            <IconButton icon="ph-layout" onClick={() => {}} />
          </>
        }
      />

      {/* Filter pill tabs */}
      <div style={{ padding: '0 16px 12px', display: 'flex', gap: 6 }}>
        {[
          { id: 'all', label: 'All', count: trees.length },
          { id: 'mine', label: 'Mine', count: trees.filter(t => t.status === 'adopted').length },
          { id: 'available', label: 'Open', count: trees.filter(t => t.status === 'available').length },
          { id: 'attention', label: 'Care', count: trees.filter(t => t.health === 'attention' || t.health === 'risk').length },
        ].map(t => (
          <button key={t.id} onClick={() => setFilter(t.id)} style={{
            flex: 1, padding: '8px 6px', whiteSpace: 'nowrap',
            background: filter === t.id ? 'var(--ink)' : 'var(--surface-card)',
            color: filter === t.id ? 'var(--canvas)' : 'var(--ink)',
            border: '1px solid var(--hairline)',
            borderColor: filter === t.id ? 'var(--ink)' : 'var(--hairline)',
            borderRadius: 'var(--radius-full)', fontSize: 13, fontWeight: 600,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5,
          }}>
            <span>{t.label}</span>
            <span style={{ fontSize: 11, opacity: 0.7, fontWeight: 500 }}>{t.count}</span>
          </button>
        ))}
      </div>

      {/* Map area */}
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
        <MapCanvas trees={filtered} pinStyle={pinStyle} onPin={(id) => setSelected(id)} selectedId={selected} />

        {/* Floating action buttons stack right side */}
        <div style={{ position: 'absolute', right: 12, top: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <MapFAB icon="ph-crosshair" weight="bold" onClick={() => {}} />
          <MapFAB icon="ph-plus" weight="bold" onClick={() => {}} />
          <MapFAB icon="ph-minus" weight="bold" onClick={() => {}} />
        </div>

        {/* Legend */}
        <div style={{
          position: 'absolute', left: 12, top: 12,
          background: 'var(--surface-card)', borderRadius: 'var(--radius-md)',
          padding: '8px 12px', boxShadow: 'var(--elev-1)',
          display: 'flex', flexDirection: 'column', gap: 4,
        }}>
          <LegendDot color="var(--pin-healthy)" label="Healthy" />
          <LegendDot color="var(--pin-attention)" label="Attention" />
          <LegendDot color="var(--pin-risk)" label="At risk" />
          <LegendDot color="var(--pin-available)" label="Available" />
        </div>

        {/* Selected tree bottom card */}
        {selectedTree && (
          <div style={{
            position: 'absolute', left: 12, right: 12, bottom: 12,
            background: 'var(--surface-card)', borderRadius: 'var(--radius-card)',
            padding: 14, boxShadow: 'var(--elev-3)',
            display: 'flex', gap: 12, alignItems: 'center',
            animation: 'canopy-fade-up 200ms var(--ease-out)',
          }} onClick={() => onOpenTree(selectedTree.id)}>
            <div style={{
              width: 56, height: 56, borderRadius: 12,
              background: 'var(--primary-surface)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <TreeIllustration species={selectedTree.species} color={selectedTree.color} size={50} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
                <span className="h3" style={{ fontSize: 16, fontWeight: 600 }}>{selectedTree.nickname || 'Available'}</span>
                <HealthDot status={selectedTree.status === 'adopted' ? selectedTree.health : 'available'} size={7} />
              </div>
              <div className="caption" style={{ marginTop: 1 }}>{selectedTree.species} · {selectedTree.street}</div>
              <div className="caption" style={{ marginTop: 1, color: 'var(--primary)', fontWeight: 600 }}>
                {selectedTree.distance} {selectedTree.status === 'adopted' ? '· Yours' : '· Available'}
              </div>
            </div>
            <button style={{
              border: 'none', background: 'var(--primary)', color: 'var(--on-primary)',
              borderRadius: '50%', width: 36, height: 36,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <i className="ph-bold ph-arrow-right pi-sm"></i>
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

// Stylized faux-map background
function MapCanvas({ trees, pinStyle, onPin, selectedId }) {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: 'var(--surface-raised)',
      overflow: 'hidden',
    }}>
      {/* SVG schematic map */}
      <svg viewBox="0 0 400 600" width="100%" height="100%" preserveAspectRatio="xMidYMid slice"
        style={{ position: 'absolute', inset: 0 }}>
        {/* park blocks */}
        <rect x="40" y="40" width="180" height="140" rx="6" fill="var(--primary-surface)" opacity="0.7" />
        <rect x="240" y="320" width="130" height="180" rx="6" fill="var(--primary-surface)" opacity="0.7" />
        {/* river */}
        <path d="M0 380 Q 80 360 160 400 T 320 420 T 400 410 L 400 460 L 0 460 Z" fill="var(--info-bg)" opacity="0.5" />
        {/* blocks */}
        <rect x="240" y="40" width="130" height="120" rx="3" fill="var(--canvas)" opacity="0.9" />
        <rect x="40" y="200" width="180" height="100" rx="3" fill="var(--canvas)" opacity="0.9" />
        <rect x="240" y="180" width="130" height="120" rx="3" fill="var(--canvas)" opacity="0.9" />
        <rect x="40" y="320" width="180" height="120" rx="3" fill="var(--canvas)" opacity="0.9" />
        <rect x="40" y="480" width="330" height="100" rx="3" fill="var(--canvas)" opacity="0.9" />
        {/* streets */}
        <line x1="0" y1="190" x2="400" y2="190" stroke="var(--hairline-strong)" strokeWidth="2" />
        <line x1="0" y1="310" x2="400" y2="310" stroke="var(--hairline-strong)" strokeWidth="2" />
        <line x1="0" y1="470" x2="400" y2="470" stroke="var(--hairline-strong)" strokeWidth="2" />
        <line x1="230" y1="0" x2="230" y2="600" stroke="var(--hairline-strong)" strokeWidth="2" />
        <line x1="30" y1="0" x2="30" y2="600" stroke="var(--hairline-strong)" strokeWidth="2" />
        {/* street names */}
        <text x="100" y="186" fontSize="9" fill="var(--ink-tertiary)" fontFamily="Inter">LINDEN AVE</text>
        <text x="100" y="306" fontSize="9" fill="var(--ink-tertiary)" fontFamily="Inter">CEDAR ST</text>
        <text x="100" y="466" fontSize="9" fill="var(--ink-tertiary)" fontFamily="Inter">ELM ST</text>
      </svg>

      {/* User location pulse */}
      <div style={{
        position: 'absolute', left: '46%', top: '50%', transform: 'translate(-50%, -50%)',
        width: 18, height: 18, borderRadius: '50%', background: 'var(--info)',
        border: '3px solid var(--canvas)', boxShadow: '0 0 0 6px rgba(42, 110, 187, 0.2)',
        zIndex: 4,
      }}></div>

      {/* Tree pins */}
      {trees.map(t => {
        const status = t.status === 'adopted' ? t.health : 'available';
        const left = `${t.lng * 90 + 4}%`;
        const top = `${t.lat * 80 + 8}%`;
        const isSelected = selectedId === t.id;
        return (
          <button key={t.id} onClick={() => onPin(t.id)} style={{
            position: 'absolute', left, top,
            transform: `translate(-50%, -100%) ${isSelected ? 'scale(1.15)' : 'scale(1)'}`,
            background: 'transparent', border: 'none', padding: 0,
            cursor: 'pointer', zIndex: isSelected ? 6 : 5,
            transition: 'transform 200ms var(--ease-out)',
          }}>
            <MapPin status={status} adopted={t.status === 'adopted'} style={pinStyle} color={t.color} species={t.species} highlighted={isSelected} />
          </button>
        );
      })}
    </div>
  );
}

function MapPin({ status, adopted, style = 'pin', color, species, highlighted }) {
  const fill = {
    healthy: 'var(--pin-healthy)',
    attention: 'var(--pin-attention)',
    risk: 'var(--pin-risk)',
    available: 'var(--pin-available)',
  }[status];

  if (style === 'pin') {
    // Classic teardrop pin
    return (
      <div style={{ position: 'relative' }}>
        <svg width="30" height="36" viewBox="0 0 30 36">
          <path d="M15 0 C7 0 1 6 1 14 C1 24 15 36 15 36 C15 36 29 24 29 14 C29 6 23 0 15 0 Z" fill={fill} stroke="var(--canvas)" strokeWidth="2" />
          <circle cx="15" cy="14" r="5" fill="var(--canvas)" />
        </svg>
        {highlighted && <div style={{ position: 'absolute', left: '50%', bottom: -3, transform: 'translateX(-50%)', width: 24, height: 4, borderRadius: 2, background: 'rgba(0,0,0,0.2)' }}></div>}
      </div>
    );
  }
  if (style === 'leaf') {
    // Leaf-shaped pin
    return (
      <svg width="32" height="36" viewBox="0 0 32 36">
        <path d="M16 4 C26 4 30 12 28 22 C26 32 16 34 16 34 C16 34 6 32 4 22 C2 12 6 4 16 4 Z" fill={fill} stroke="var(--canvas)" strokeWidth="2" />
        <path d="M16 8 L16 30 M16 14 Q 22 16 22 22 M16 14 Q 10 16 10 22" stroke="var(--canvas)" strokeWidth="1.5" fill="none" />
      </svg>
    );
  }
  if (style === 'dot') {
    // Minimal dot
    return (
      <div style={{
        width: 18, height: 18, borderRadius: '50%',
        background: fill,
        border: '3px solid var(--canvas)',
        boxShadow: highlighted ? `0 0 0 4px ${fill}40` : 'var(--elev-1)',
      }}></div>
    );
  }
  if (style === 'tree') {
    // Mini tree illustration as pin
    return (
      <div style={{
        position: 'relative',
        background: 'var(--canvas)', borderRadius: '50%',
        padding: 2, boxShadow: 'var(--elev-2)',
        border: `2px solid ${fill}`,
      }}>
        <TreeIllustration species={species} color={color} size={32} />
      </div>
    );
  }
  return null;
}

function MapFAB({ icon, weight = '', onClick }) {
  const prefix = weight && weight !== 'regular' ? `ph-${weight}` : 'ph';
  return (
    <button onClick={onClick} style={{
      width: 40, height: 40, borderRadius: 12,
      background: 'var(--surface-card)', border: 'none',
      boxShadow: 'var(--elev-2)', color: 'var(--ink)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <i className={`${prefix} ${icon} pi-sm`}></i>
    </button>
  );
}

function LegendDot({ color, label }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap' }}>
      <span style={{ width: 8, height: 8, borderRadius: '50%', background: color, flexShrink: 0 }}></span>
      <span className="caption" style={{ fontSize: 11 }}>{label}</span>
    </div>
  );
}

Object.assign(window, { MapScreen, MapCanvas, MapPin });
