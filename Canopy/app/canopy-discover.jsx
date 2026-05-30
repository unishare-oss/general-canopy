// canopy-discover.jsx — swipe adoption flow + adoption success modal

function DiscoverScreen({ trees, onAdopt, onOpenTree, cardStyle = 'a' }) {
  const [stack, setStack] = useState(trees.filter(t => t.status === 'available'));
  const [drag, setDrag] = useState({ x: 0, y: 0, active: false });
  const [exit, setExit] = useState(null); // 'left' | 'right' | null
  const [adopted, setAdopted] = useState(null); // tree just adopted (success modal)
  const [history, setHistory] = useState([]);
  const startRef = useRef(null);

  const top = stack[0];
  const next = stack[1];
  const third = stack[2];

  // Reset deck when trees prop changes
  useEffect(() => {
    setStack(trees.filter(t => t.status === 'available'));
  }, [trees]);

  const advance = (direction) => {
    if (!top || exit) return;
    setExit(direction);
    setTimeout(() => {
      if (direction === 'right') {
        onAdopt(top.id);
        setAdopted(top);
      }
      setHistory(h => [...h, top]);
      setStack(s => s.slice(1));
      setExit(null);
      setDrag({ x: 0, y: 0, active: false });
    }, 280);
  };

  const undo = () => {
    if (history.length === 0) return;
    const last = history[history.length - 1];
    setHistory(h => h.slice(0, -1));
    setStack(s => [last, ...s]);
  };

  const onPointerDown = (e) => {
    if (exit) return;
    startRef.current = { x: e.clientX, y: e.clientY };
    setDrag({ x: 0, y: 0, active: true });
    e.currentTarget.setPointerCapture(e.pointerId);
  };
  const onPointerMove = (e) => {
    if (!drag.active || !startRef.current) return;
    setDrag({ x: e.clientX - startRef.current.x, y: e.clientY - startRef.current.y, active: true });
  };
  const onPointerUp = (e) => {
    if (!drag.active) return;
    const { x } = drag;
    const threshold = 100;
    if (x > threshold) advance('right');
    else if (x < -threshold) advance('left');
    else setDrag({ x: 0, y: 0, active: false });
  };

  const cardWidth = 312;
  const cardHeight = 460;

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--surface)' }}>
      <TopBar
        title="Discover"
        subtitle="Saplings waiting on your block"
        large
        leading={null}
        trailing={
          <>
            <IconButton icon="ph-funnel" onClick={() => {}} />
            <IconButton icon="ph-bell" dot onClick={() => {}} />
          </>
        }
      />
      {/* Filter chips */}
      <div className="scroll-x" style={{ flex: '0 0 auto', padding: '0 16px', display: 'flex', gap: 8, paddingBottom: 8 }}>
        {['Near me · 1 mi', 'Saplings only', 'Full sun', 'Low water', 'Quick wins'].map((c, i) => (
          <span key={c} className={`chip ${i === 0 ? 'primary' : ''}`} style={{ height: 32, fontSize: 13, padding: '0 14px', flexShrink: 0, whiteSpace: 'nowrap' }}>
            {i === 0 && <i className="ph-bold ph-map-pin pi-sm" style={{ marginRight: 2 }}></i>}
            {c}
          </span>
        ))}
      </div>

      {/* Swipe deck area */}
      <div style={{
        flex: 1, position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center',
        paddingBottom: 16,
      }}>
        {/* Empty state */}
        {!top && (
          <div style={{ textAlign: 'center', padding: 40, color: 'var(--ink-secondary)' }}>
            <i className="ph-duotone ph-tree pi" style={{ fontSize: 56, color: 'var(--primary)' }}></i>
            <div className="h2" style={{ marginTop: 16 }}>That's everyone nearby.</div>
            <div className="body-md" style={{ color: 'var(--ink-tertiary)', marginTop: 8 }}>Widen your radius, or check back next week — more saplings are planted every Tuesday.</div>
            <button className="btn" style={{ marginTop: 20 }} onClick={undo}>
              <i className="ph-bold ph-arrow-counter-clockwise pi-sm"></i> Bring back the last one
            </button>
          </div>
        )}

        {/* Render stack: bottom → top */}
        {third && (
          <DeckCard tree={third} cardStyle={cardStyle}
            style={{ transform: 'scale(0.92) translateY(20px)', opacity: 0.55, zIndex: 1 }} />
        )}
        {next && (
          <DeckCard tree={next} cardStyle={cardStyle}
            style={{ transform: 'scale(0.96) translateY(10px)', opacity: 0.85, zIndex: 2 }} />
        )}
        {top && (
          <DeckCard
            tree={top} cardStyle={cardStyle}
            interactive
            drag={drag} exit={exit}
            onPointerDown={onPointerDown}
            onPointerMove={onPointerMove}
            onPointerUp={onPointerUp}
            onTap={() => onOpenTree(top.id)}
            style={{ zIndex: 3 }}
            width={cardWidth}
            height={cardHeight}
          />
        )}
      </div>

      {/* Action buttons */}
      {top && (
        <div style={{
          flex: '0 0 auto', display: 'flex', justifyContent: 'center', alignItems: 'center',
          gap: 18, padding: '8px 16px 20px',
        }}>
          <RoundAction icon="ph-arrow-counter-clockwise" subtle onClick={undo} disabled={history.length === 0} />
          <RoundAction icon="ph-x" big color="var(--ink-secondary)" onClick={() => advance('left')} />
          <RoundAction icon="ph-info" subtle onClick={() => onOpenTree(top.id)} />
          <RoundAction icon="ph-heart" big color="var(--primary)" fill onClick={() => advance('right')} />
          <RoundAction icon="ph-map-pin" subtle onClick={() => {}} />
        </div>
      )}

      {/* Adoption success overlay */}
      {adopted && (
        <AdoptionSuccess tree={adopted} onClose={() => setAdopted(null)} onViewTree={() => { const t = adopted; setAdopted(null); onOpenTree(t.id); }} />
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// DeckCard — a single swipeable card
// ─────────────────────────────────────────────────────────────
function DeckCard({ tree, style = {}, interactive = false, drag, exit, cardStyle = 'a',
  onPointerDown, onPointerMove, onPointerUp, onTap, width = 312, height = 460 }) {
  const x = drag?.x || 0;
  const y = drag?.y || 0;
  const rot = x * 0.04;
  const exitTransform =
    exit === 'right' ? 'translate(420px, -40px) rotate(20deg)' :
    exit === 'left'  ? 'translate(-420px, -40px) rotate(-20deg)' : null;
  const transform =
    exitTransform ||
    (interactive ? `translate(${x}px, ${y * 0.3}px) rotate(${rot}deg)` : style.transform);

  // Like / Nope overlays
  const likeOpacity = interactive ? Math.min(1, Math.max(0, x / 80)) : 0;
  const nopeOpacity = interactive ? Math.min(1, Math.max(0, -x / 80)) : 0;

  return (
    <div
      onPointerDown={interactive ? onPointerDown : undefined}
      onPointerMove={interactive ? onPointerMove : undefined}
      onPointerUp={interactive ? onPointerUp : undefined}
      onClick={interactive && Math.abs(x) < 6 ? onTap : undefined}
      style={{
        position: 'absolute', width, height,
        borderRadius: 22, overflow: 'hidden',
        background: 'var(--surface-card)',
        boxShadow: 'var(--elev-3)',
        transform, transformOrigin: 'center bottom',
        transition: drag?.active ? 'none' : 'transform 280ms var(--ease-out), opacity 200ms',
        touchAction: 'none', userSelect: 'none', cursor: interactive ? 'grab' : 'default',
        ...style,
      }}
    >
      {cardStyle === 'a' && <DeckCardA tree={tree} />}
      {cardStyle === 'b' && <DeckCardB tree={tree} />}
      {cardStyle === 'c' && <DeckCardC tree={tree} />}

      {/* Like / Nope stamps */}
      {interactive && (
        <>
          <div style={{
            position: 'absolute', top: 24, left: 20,
            border: '3px solid var(--primary)', color: 'var(--primary)',
            padding: '6px 14px', borderRadius: 8, fontWeight: 800, fontSize: 22,
            transform: 'rotate(-14deg)', opacity: likeOpacity, letterSpacing: 1,
            background: 'rgba(255,255,255,0.85)',
          }}>ADOPT</div>
          <div style={{
            position: 'absolute', top: 24, right: 20,
            border: '3px solid var(--ink-secondary)', color: 'var(--ink-secondary)',
            padding: '6px 14px', borderRadius: 8, fontWeight: 800, fontSize: 22,
            transform: 'rotate(14deg)', opacity: nopeOpacity, letterSpacing: 1,
            background: 'rgba(255,255,255,0.85)',
          }}>PASS</div>
        </>
      )}
    </div>
  );
}

// Card style A — the chosen direction (light card, illustrated header band)
function DeckCardA({ tree }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ flex: '0 0 56%', position: 'relative' }}>
        <CardScene color={tree.color}>
          <div style={{
            position: 'absolute', inset: 0, display: 'flex',
            alignItems: 'flex-end', justifyContent: 'center', paddingBottom: 10,
          }}>
            <TreeIllustration species={tree.species} color={tree.color} size={210} />
          </div>
          {/* distance chip top-left */}
          <div style={{ position: 'absolute', top: 16, left: 16, display: 'flex', gap: 6, alignItems: 'center' }}>
            <span className="chip" style={{ background: 'rgba(255,255,255,0.85)', color: 'var(--ink)', backdropFilter: 'blur(6px)' }}>
              <i className="ph-fill ph-map-pin pi-sm" style={{ color: 'var(--primary)' }}></i> {tree.distance}
            </span>
          </div>
          <div style={{ position: 'absolute', top: 16, right: 16 }}>
            <span className="chip" style={{ background: 'rgba(255,255,255,0.85)', color: 'var(--ink)' }}>
              <HealthDot status="available" size={6} /> Available
            </span>
          </div>
        </CardScene>
      </div>
      <div style={{ flex: 1, padding: '18px 20px 16px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
          <div className="h-display" style={{ fontSize: 28 }}>{tree.nickname}</div>
          <span className="caption">{tree.age}</span>
        </div>
        <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 2 }}>
          {tree.species} · <span style={{ fontStyle: 'italic' }}>{tree.latin}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 10, color: 'var(--ink-tertiary)' }}>
          <i className="ph ph-map-pin pi-sm"></i>
          <span className="body-sm">{tree.street}</span>
        </div>
        <div className="body-sm" style={{
          color: 'var(--ink-secondary)', marginTop: 12,
          textWrap: 'pretty', flex: 1,
        }}>
          "{tree.personality}"
        </div>
        <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
          <span className="chip"><i className="ph ph-drop pi-sm"></i> {tree.waterNeed}</span>
          <span className="chip"><i className="ph ph-sun pi-sm"></i> {tree.light}</span>
        </div>
      </div>
    </div>
  );
}

// Card style B — full-bleed illustration, info overlaid at bottom
function DeckCardB({ tree }) {
  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <CardScene color={tree.color}>
        <div style={{
          position: 'absolute', inset: 0, top: 40, display: 'flex',
          alignItems: 'center', justifyContent: 'center',
        }}>
          <TreeIllustration species={tree.species} color={tree.color} size={260} />
        </div>
      </CardScene>
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        padding: 20,
        background: 'linear-gradient(180deg, transparent 0%, rgba(255,255,255,0.85) 30%, var(--surface-card) 65%)',
      }}>
        <div style={{ height: 90 }}></div>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
          <div className="h-display" style={{ fontSize: 26 }}>{tree.nickname}</div>
          <span className="chip primary">{tree.distance}</span>
        </div>
        <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 2 }}>
          {tree.species} · {tree.street}
        </div>
        <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 8, textWrap: 'pretty' }}>
          "{tree.personality}"
        </div>
      </div>
    </div>
  );
}

// Card style C — botanical specimen card (cream, serif, hairline border)
function DeckCardC({ tree }) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', height: '100%',
      background: '#FBF6E9',
      border: '1.5px solid var(--bark)',
      borderRadius: 22, padding: 16,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <div className="micro" style={{ fontSize: 10, letterSpacing: 2, color: 'var(--bark)' }}>SPECIMEN №{tree.id.slice(-2)}</div>
          <div className="h-display" style={{ fontSize: 30, color: 'var(--bark)', fontStyle: 'italic', marginTop: 4 }}>{tree.nickname}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div className="caption" style={{ color: 'var(--bark)' }}>{tree.distance}</div>
          <div className="caption" style={{ color: 'var(--bark)' }}>{tree.age}</div>
        </div>
      </div>
      <div style={{ height: 1, background: 'var(--bark)', opacity: 0.3, margin: '10px 0' }}></div>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <TreeIllustration species={tree.species} color={tree.color} size={210} />
      </div>
      <div style={{ height: 1, background: 'var(--bark)', opacity: 0.3, margin: '10px 0' }}></div>
      <div>
        <div className="body-sm" style={{ color: 'var(--ink-secondary)', fontStyle: 'italic' }}>{tree.latin}</div>
        <div className="body-sm" style={{ color: 'var(--ink)', marginTop: 4 }}>{tree.species} · {tree.street}</div>
        <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 8, textWrap: 'pretty' }}>
          "{tree.personality}"
        </div>
      </div>
    </div>
  );
}

// Round circular action button
function RoundAction({ icon, color = 'var(--ink-secondary)', onClick, big = false, subtle = false, fill = false, disabled = false }) {
  const size = big ? 60 : 44;
  return (
    <button onClick={onClick} disabled={disabled} style={{
      width: size, height: size, borderRadius: '50%',
      border: subtle ? '1px solid var(--hairline)' : 'none',
      background: subtle ? 'var(--surface-card)' : 'var(--surface-card)',
      color: disabled ? 'var(--ink-disabled)' : color,
      boxShadow: big ? 'var(--elev-2)' : 'var(--elev-1)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      transition: 'transform 100ms var(--ease-out)',
    }}>
      <i className={`${fill ? 'ph-fill' : 'ph-bold'} ${icon} pi`} style={{ fontSize: big ? 26 : 18 }}></i>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// AdoptionSuccess — full-screen overlay with confetti vibe
// ─────────────────────────────────────────────────────────────
function AdoptionSuccess({ tree, onClose, onViewTree }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 50,
      background: 'var(--surface)',
      animation: 'canopy-fadein 200ms ease',
      display: 'flex', flexDirection: 'column',
    }}>
      <div style={{ flex: 1, position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {/* falling leaves decoration */}
        {Array.from({ length: 8 }).map((_, i) => (
          <div key={i} style={{
            position: 'absolute',
            top: `${10 + i * 10}%`,
            left: `${(i * 13 + 8) % 90}%`,
            width: 10, height: 10, borderRadius: '40% 60% 50% 50% / 50% 50% 40% 60%',
            background: i % 2 ? 'var(--accent)' : 'var(--primary-light)',
            transform: `rotate(${i * 47}deg)`, opacity: 0.5,
          }}></div>
        ))}
        <div style={{ textAlign: 'center', padding: 24 }}>
          <div style={{ display: 'inline-block', marginBottom: 20 }}>
            <TreeIllustration species={tree.species} color={tree.color} size={180} />
          </div>
          <div className="micro" style={{ color: 'var(--primary)', fontWeight: 700 }}>NEW GUARDIAN</div>
          <div className="h-display" style={{ fontSize: 36, marginTop: 4 }}>{tree.nickname} is yours.</div>
          <div className="body-md" style={{ color: 'var(--ink-secondary)', marginTop: 12, maxWidth: 280, marginLeft: 'auto', marginRight: 'auto', textWrap: 'pretty' }}>
            We'll text you when {tree.nickname} needs water. First check-in: <span style={{ color: 'var(--ink)', fontWeight: 600 }}>in 3 days</span>.
          </div>
        </div>
      </div>
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
        <button className="btn block" onClick={onViewTree}>
          Meet {tree.nickname}
          <i className="ph-bold ph-arrow-right pi-sm"></i>
        </button>
        <button className="btn ghost block" onClick={onClose}>
          Keep browsing
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { DiscoverScreen, DeckCard, DeckCardA, DeckCardB, DeckCardC, AdoptionSuccess });
