<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Risco BPP por ETC · Kangu Logistics</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<style>
:root{
  --bg:#f0f2f6; --card:#ffffff; --input:#f7f9fc; --line:#e2e8f0;
  --tx:#1a202c; --tx2:#718096;
  --head1:#1a1b2f; --head2:#17213e;
  --blue:#4c6ef5; --blue-bg:#f0f4ff;
  --red:#e53e3e; --orange:#dd6b20; --gold:#d69e2e; --green:#38a169;
  --purple:#9333ea; --sky:#0ea5e9;
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--tx);font-family:'Inter',system-ui,sans-serif;font-size:14px;line-height:1.5;min-height:100vh}
button,input,select{font-family:inherit;font-size:inherit;color:inherit}
:focus-visible{outline:2px solid var(--blue);outline-offset:2px}
.hidden{display:none!important}

/* Logo */
.logo{background:#FFE600;color:#000;font-weight:800;border-radius:8px;padding:6px 10px;letter-spacing:.5px;font-size:13px;display:inline-block}

/* Botões */
.btn{border-radius:8px;padding:8px 14px;font-weight:600;cursor:pointer;border:1px solid var(--line);background:#fff;transition:border-color .15s,color .15s,background .15s}
.btn:hover{border-color:var(--blue);color:var(--blue)}
.btn.primary{background:var(--blue);color:#fff;border-color:var(--blue)}
.btn.primary:hover{background:#3b5bdb;color:#fff;border-color:#3b5bdb}
.btn:disabled{opacity:.5;cursor:not-allowed}

/* Login */
#login{min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px;background:linear-gradient(135deg,var(--head1),var(--head2))}
.login-card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:32px;width:100%;max-width:400px;box-shadow:0 10px 30px rgba(0,0,0,.25)}
.login-card h1{font-size:20px;margin:18px 0 4px}
.login-card p{color:var(--tx2);margin-bottom:22px}
.field{margin-bottom:14px}
.field label{display:block;font-size:12px;color:var(--tx2);margin-bottom:6px;font-weight:500}
.field input{width:100%;background:var(--input);border:1px solid var(--line);border-radius:8px;padding:10px 12px}
.field input:focus{border-color:var(--blue);outline:none;background:#fff}
.err{color:var(--red);font-size:13px;margin:4px 0 12px;min-height:18px}
.login-card .btn{width:100%;padding:11px}

/* Header */
header{background:linear-gradient(90deg,var(--head1),var(--head2));color:#fff;padding:16px 24px;display:flex;align-items:center;gap:16px;flex-wrap:wrap}
header .titulo{flex:1;min-width:220px}
header h1{font-size:17px;font-weight:700}
header .sub{color:#a0aec0;font-size:12px}
.quem{color:#a0aec0;font-size:12px;text-align:right}
.quem b{color:#fff;font-weight:600}
header .btn{background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.25);color:#fff}
header .btn:hover{background:var(--blue);border-color:var(--blue);color:#fff}
main{padding:20px 24px 48px;max-width:1500px;margin:0 auto}

/* Cards genéricos */
.box{background:var(--card);border:1px solid var(--line);border-radius:12px;box-shadow:0 1px 3px rgba(26,32,44,.06)}
.filters{display:flex;gap:14px;flex-wrap:wrap;align-items:flex-end;padding:14px 16px;margin-bottom:16px}
.filters .f{display:flex;flex-direction:column;gap:5px;min-width:160px;flex:1;max-width:260px}
.filters label{font-size:12px;color:var(--tx2);font-weight:500}
.filters select{background:#fff;border:1px solid var(--line);border-radius:8px;padding:8px 10px}
.filters select:focus{border-color:var(--blue);outline:none}
.filters .count{margin-left:auto;background:var(--blue-bg);color:var(--blue);border-radius:999px;padding:5px 12px;font-size:12px;font-weight:600;white-space:nowrap}

/* Métricas */
.metrics{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:14px;margin-bottom:16px}
.metric{background:var(--card);border:1px solid var(--line);border-top:3px solid var(--c,var(--blue));border-radius:12px;padding:16px;box-shadow:0 1px 3px rgba(26,32,44,.06)}
.metric .l{color:var(--tx2);font-size:12px;font-weight:500}
.metric .v{font-size:28px;font-weight:800;margin:4px 0 2px;letter-spacing:-.5px}
.metric .n{color:var(--tx2);font-size:12px}

/* Gráficos */
.charts{display:grid;grid-template-columns:1fr 1fr 1.6fr;gap:14px;margin-bottom:16px}
.charts.solo{grid-template-columns:1fr 1fr}
.chart{padding:16px}
.chart h2{font-size:13px;font-weight:600;margin-bottom:12px}
.chart .cv{position:relative;height:230px}
.chart .hint{color:var(--tx2);font-size:11px;margin-top:8px}
@media(max-width:1100px){.charts,.charts.solo{grid-template-columns:1fr}}

/* Tabela */
.toolbar{display:flex;align-items:center;gap:12px;padding:12px 16px;border-bottom:1px solid var(--line);flex-wrap:wrap}
.toolbar .info{color:var(--tx2);font-size:12px;flex:1}
.pager{display:flex;align-items:center;gap:8px;font-size:12px;color:var(--tx2)}
.pager .btn{padding:5px 10px}
.twrap{overflow-x:auto}
table{width:100%;border-collapse:collapse;min-width:900px}
th{background:var(--input);text-align:left;font-size:12px;color:var(--tx2);font-weight:600;padding:10px 14px;border-bottom:1px solid var(--line);white-space:nowrap}
td{padding:10px 14px;border-bottom:1px solid var(--line);white-space:nowrap}
tbody tr{cursor:pointer}
tbody tr:hover{background:var(--blue-bg)}
td.num,th.num{text-align:right}
.chip{font-family:ui-monospace,Menlo,monospace;color:var(--blue);background:var(--blue-bg);border-radius:6px;padding:2px 7px;font-size:12px}
.badge{display:inline-block;border:1px solid;border-radius:999px;padding:1px 9px;font-size:11px;font-weight:600}
.b-red{color:#c53030;border-color:rgba(229,62,62,.35);background:#fff0f0}
.b-amber{color:#c05621;border-color:rgba(221,107,32,.35);background:#fff7ed}
.b-yellow{color:#b7791f;border-color:rgba(214,158,46,.4);background:#fffbea}
.b-green{color:#2f855a;border-color:rgba(56,161,105,.35);background:#f0fff4}
.b-blue{color:#3b5bdb;border-color:rgba(76,110,245,.35);background:var(--blue-bg)}
.b-purple{color:#7e22ce;border-color:rgba(147,51,234,.35);background:#faf5ff}
.b-gray{color:var(--tx2);border-color:var(--line);background:var(--input)}
.vazio{padding:40px 16px;text-align:center;color:var(--tx2)}

/* Drawer */
#backdrop{position:fixed;inset:0;background:rgba(26,32,44,.4);backdrop-filter:blur(3px);z-index:20}
#drawer{position:fixed;top:0;right:0;bottom:0;width:min(420px,100%);background:var(--card);border-left:1px solid var(--line);z-index:21;overflow-y:auto;transition:transform .2s;box-shadow:-10px 0 30px rgba(26,32,44,.15)}
#drawer.fechado{transform:translateX(100%)}
#drawer .dh{position:sticky;top:0;background:var(--card);border-bottom:1px solid var(--line);padding:16px 20px;display:flex;justify-content:space-between;align-items:center}
#drawer .dh h3{font-size:15px}
#drawer .db{padding:16px 20px}
.kv{display:flex;justify-content:space-between;gap:16px;padding:9px 0;border-bottom:1px solid var(--line)}
.kv span:first-child{color:var(--tx2)}
.kv span:last-child{text-align:right;font-weight:500}

#loading{position:fixed;inset:0;background:var(--bg);display:flex;align-items:center;justify-content:center;color:var(--tx2);z-index:30}
@media(prefers-reduced-motion:reduce){*{transition:none!important}}
</style>
</head>
<body>

<div id="loading">Carregando…</div>

<!-- LOGIN -->
<section id="login" class="hidden">
  <div class="login-card">
    <span class="logo">MELI</span>
    <h1>Risco BPP por ETC</h1>
    <p>Entre com o e-mail e a senha que você recebeu para ver os pacotes da sua transportadora.</p>
    <div class="field"><label for="email">E-mail</label><input id="email" type="email" autocomplete="username"></div>
    <div class="field"><label for="senha">Senha</label><input id="senha" type="password" autocomplete="current-password"></div>
    <div class="err" id="loginErr" role="alert"></div>
    <button class="btn primary" id="btnEntrar">Entrar</button>
  </div>
</section>

<!-- APP -->
<div id="app" class="hidden">
  <header>
    <span class="logo">MELI</span>
    <div class="titulo">
      <h1>Risco BPP por ETC</h1>
      <div class="sub" id="atualizado">—</div>
    </div>
    <div class="quem"><b id="quemNome">—</b><br><span id="quemTipo"></span></div>
    <button class="btn" id="btnSair">Sair</button>
  </header>

  <main>
    <div class="box filters">
      <div class="f" id="fEtcWrap"><label for="fEtc">ETC</label><select id="fEtc"></select></div>
      <div class="f"><label for="fReg">Regional</label><select id="fReg"></select></div>
      <div class="f"><label for="fUrg">Urgência</label><select id="fUrg"></select></div>
      <div class="f"><label for="fEst">Estágio BPP</label><select id="fEst"></select></div>
      <button class="btn" id="btnLimpar">Limpar filtros</button>
      <span class="count" id="countPill">0 pacotes</span>
    </div>

    <div class="metrics" id="metrics"></div>

    <div class="charts" id="charts">
      <div class="box chart">
        <h2>Pacotes por urgência</h2>
        <div class="cv"><canvas id="cUrg"></canvas></div>
        <div class="hint">Clique numa fatia para filtrar.</div>
      </div>
      <div class="box chart">
        <h2>Pacotes por classificação</h2>
        <div class="cv"><canvas id="cCls"></canvas></div>
      </div>
      <div class="box chart" id="boxTop">
        <h2 id="topTitulo">Top 10 ETCs por pacotes em risco</h2>
        <div class="cv"><canvas id="cTop"></canvas></div>
      </div>
    </div>

    <div class="box">
      <div class="toolbar">
        <div class="info" id="tInfo"></div>
        <div class="pager">
          <button class="btn" id="pPrev">Anterior</button>
          <span id="pTxt"></span>
          <button class="btn" id="pNext">Próxima</button>
        </div>
      </div>
      <div class="twrap">
        <table>
          <thead><tr>
            <th>Shipment ID</th><th>Data atribuição</th><th id="thEtc">ETC</th><th>Motorista</th>
            <th>Classificação</th><th>Urgência</th><th class="num">Dias estancado</th>
            <th>Estágio BPP</th><th class="num">GMV (R$)</th><th>Regional</th>
          </tr></thead>
          <tbody id="tbody"></tbody>
        </table>
      </div>
      <div class="vazio hidden" id="vazio">Nenhum pacote encontrado com esses filtros.</div>
    </div>
  </main>
</div>

<!-- DRAWER -->
<div id="backdrop" class="hidden"></div>
<aside id="drawer" class="fechado" aria-hidden="true">
  <div class="dh"><h3>Detalhes do pacote</h3><button class="btn" id="dClose">Fechar</button></div>
  <div class="db" id="dBody"></div>
</aside>

<script>
/* ============ CONFIGURAÇÃO ============ */
const SUPABASE_URL = 'https://lpwqikmnkhsuxozwpakn.supabase.co';
const SUPABASE_ANON_KEY = 'COLE_AQUI_A_CHAVE_ANON'; // Settings > API > anon public. NUNCA use a service_role.
const TABELA = 'ipo_risco_bpp';
const DOMINIO_ADMIN = '@mercadolivre.com';
const POR_PAGINA = 25;

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const $ = id => document.getElementById(id);

/* ============ ESTADO ============ */
let dados = [];
let isAdmin = false;
let filtros = {etc:'', reg:'', urg:'', est:''};
let pagina = 1;
let charts = {};

/* ============ UTILIDADES ============ */
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const norm = s => String(s ?? '').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toUpperCase().trim();
const num = v => Number(v) || 0;
const fmtInt = n => n.toLocaleString('pt-BR');
const fmtBRL = n => 'R$ ' + n.toLocaleString('pt-BR',{minimumFractionDigits:2,maximumFractionDigits:2});
function fmtCompacto(n){
  if(n >= 1e6) return 'R$ ' + (n/1e6).toFixed(1).replace('.',',') + ' mi';
  if(n >= 1e3) return 'R$ ' + (n/1e3).toFixed(1).replace('.',',') + ' mil';
  return 'R$ ' + n.toFixed(0);
}
function fmtData(v){
  if(!v) return '—';
  const d = new Date(v);
  return isNaN(d) ? esc(v) : d.toLocaleString('pt-BR',{dateStyle:'short',timeStyle:'short'});
}

// Urgência: usa a coluna da base; se vier vazia, calcula pelos dias estancado
function urgenciaDe(r){
  const u = norm(r.urgencia);
  if(u) return u;
  const d = num(r.dias_estancado);
  if(d >= 10) return 'CRITICO';
  if(d >= 7) return 'ALTO';
  if(d >= 3) return 'MEDIO';
  return 'BAIXO';
}
const URG = {
  CRITICO:{label:'Crítico', cor:'#e53e3e', badge:'b-red', ordem:0},
  ALTO:   {label:'Alto',    cor:'#dd6b20', badge:'b-amber', ordem:1},
  MEDIO:  {label:'Médio',   cor:'#d69e2e', badge:'b-yellow', ordem:2},
  BAIXO:  {label:'Baixo',   cor:'#38a169', badge:'b-green', ordem:3}
};
const CLS = {
  CRITICO:  {label:'Crítico',  cor:'#e53e3e', badge:'b-red'},
  ALTO:     {label:'Alto',     cor:'#dd6b20', badge:'b-amber'},
  MODERADO: {label:'Moderado', cor:'#9333ea', badge:'b-purple'}
};
const urgInfo = k => URG[k] || {label:k||'—', cor:'#718096', badge:'b-gray', ordem:9};
const clsInfo = k => CLS[k] || {label:k||'—', cor:'#718096', badge:'b-gray'};
const semPagamento = r => norm(r.estagio_bpp).includes('SEM PAG');

/* ============ LOGIN ============ */
async function entrar(){
  $('loginErr').textContent = '';
  const email = $('email').value.trim(), senha = $('senha').value;
  if(!email || !senha){ $('loginErr').textContent = 'Preencha e-mail e senha.'; return; }
  $('btnEntrar').disabled = true;
  const {error} = await sb.auth.signInWithPassword({email, password: senha});
  $('btnEntrar').disabled = false;
  if(error){ $('loginErr').textContent = 'E-mail ou senha incorretos.'; return; }
  await iniciar();
}
async function sair(){
  await sb.auth.signOut();
  dados = [];
  mostrar('login');
}
function mostrar(qual){
  $('loading').classList.add('hidden');
  $('login').classList.toggle('hidden', qual !== 'login');
  $('app').classList.toggle('hidden', qual !== 'app');
}

/* ============ CARGA DE DADOS ============ */
async function carregar(){
  // Busca em blocos de 1000 (limite padrão do PostgREST)
  const tamanho = 1000; let de = 0; let tudo = [];
  while(true){
    const {data, error} = await sb.from(TABELA).select('*').order('id').range(de, de + tamanho - 1);
    if(error) throw error;
    tudo = tudo.concat(data);
    if(data.length < tamanho) break;
    de += tamanho;
  }
  return tudo;
}

async function iniciar(){
  const {data:{session}} = await sb.auth.getSession();
  if(!session){ mostrar('login'); return; }
  const email = (session.user.email || '').toLowerCase();
  isAdmin = email.endsWith(DOMINIO_ADMIN);

  try{
    dados = (await carregar()).map(r => ({
      ...r,
      _urg: urgenciaDe(r),
      _cls: norm(r.classificacao),
      _etc: r.nome_etc || '—',
      _reg: r.regional || '—',
      _est: norm(r.estagio_bpp) || '—'
    }));
  }catch(e){
    console.error(e);
    alert('Não foi possível carregar os dados. Tente novamente em instantes.');
    return;
  }

  // Cabeçalho
  const etcs = [...new Set(dados.map(r => r._etc))];
  $('quemNome').textContent = email;
  $('quemTipo').textContent = isAdmin ? 'Acesso completo' : (etcs.length === 1 ? etcs[0] : 'Acesso por ETC');
  const maisRecente = dados.reduce((m,r) => r.atualizado_em && r.atualizado_em > m ? r.atualizado_em : m, '');
  $('atualizado').textContent = 'Atualizado em ' + fmtData(maisRecente) + ' · ' + fmtInt(dados.length) + ' pacotes';

  // Usuário de ETC não precisa do filtro de ETC nem do ranking entre ETCs
  $('fEtcWrap').classList.toggle('hidden', !isAdmin);
  $('thEtc').classList.toggle('hidden', !isAdmin);
  $('charts').classList.toggle('solo', !isAdmin);
  $('boxTop').classList.toggle('hidden', !isAdmin);

  filtros = {etc:'', reg:'', urg:'', est:''};
  montarFiltros();
  render();
  mostrar('app');
}

/* ============ FILTROS ============ */
function opcoes(sel, valores, rotulo, todos){
  const atual = sel.value;
  sel.innerHTML = `<option value="">${esc(todos)}</option>` +
    valores.map(v => `<option value="${esc(v.v)}">${esc(v.t)}</option>`).join('');
  sel.value = valores.some(v => v.v === atual) ? atual : '';
}
function montarFiltros(){
  const uniq = f => [...new Set(dados.map(f))].sort((a,b)=>a.localeCompare(b,'pt-BR'));
  opcoes($('fEtc'), uniq(r=>r._etc).map(v=>({v,t:v})), 'ETC', 'Todas as ETCs');
  opcoes($('fReg'), uniq(r=>r._reg).map(v=>({v,t:v})), 'Regional', 'Todas');
  const urgs = uniq(r=>r._urg).sort((a,b)=>urgInfo(a).ordem-urgInfo(b).ordem);
  opcoes($('fUrg'), urgs.map(v=>({v,t:urgInfo(v).label})), 'Urgência', 'Todas');
  opcoes($('fEst'), uniq(r=>r._est).map(v=>({v,t:v})), 'Estágio', 'Todos');
  $('fEtc').value = filtros.etc; $('fReg').value = filtros.reg;
  $('fUrg').value = filtros.urg; $('fEst').value = filtros.est;
}
function filtrados(){
  return dados.filter(r =>
    (!filtros.etc || r._etc === filtros.etc) &&
    (!filtros.reg || r._reg === filtros.reg) &&
    (!filtros.urg || r._urg === filtros.urg) &&
    (!filtros.est || r._est === filtros.est));
}

/* ============ RENDER ============ */
function render(){
  const lista = filtrados();
  $('countPill').textContent = fmtInt(lista.length) + ' pacotes';
  renderMetricas(lista);
  renderGraficos(lista);
  renderTabela(lista);
}

function renderMetricas(lista){
  const gmv = lista.reduce((s,r)=>s+num(r.gmv_brl),0);
  const simples = lista.filter(r => norm(r.estagio_bpp).includes('SIMPLES')).length;
  const semPag = lista.filter(semPagamento).length;
  const etcs = new Set(lista.map(r=>r._etc)).size;
  const cards = [
    {l:'Pacotes em risco', v:fmtInt(lista.length), n:'Total filtrado', c:'var(--red)'},
    {l:'GMV em risco', v:fmtCompacto(gmv), n:fmtBRL(gmv), c:'var(--orange)'},
    {l:'BPP simples', v:fmtInt(simples), n:'1 parte já paga — risco de duplo', c:'var(--red)'},
    {l:'Sem pagamento BPP', v:fmtInt(semPag), n:'Janela máxima para agir', c:'var(--blue)'}
  ];
  if(isAdmin) cards.push({l:'ETCs com risco', v:fmtInt(etcs), n:'ETCs únicas na extração', c:'var(--sky)'});
  $('metrics').innerHTML = cards.map(c => `
    <div class="metric" style="--c:${c.c}">
      <div class="l">${esc(c.l)}</div><div class="v">${esc(c.v)}</div><div class="n">${esc(c.n)}</div>
    </div>`).join('');
}

function contar(lista, chave){
  const m = {};
  lista.forEach(r => m[r[chave]] = (m[r[chave]]||0)+1);
  return m;
}
function desenhar(id, cfg){
  if(charts[id]) charts[id].destroy();
  charts[id] = new Chart($(id), cfg);
}
function renderGraficos(lista){
  Chart.defaults.color = '#718096';
  Chart.defaults.font.family = "'Inter', system-ui, sans-serif";

  // Urgência
  const cu = contar(lista,'_urg');
  const ku = Object.keys(cu).sort((a,b)=>urgInfo(a).ordem-urgInfo(b).ordem);
  desenhar('cUrg', {
    type:'doughnut',
    data:{labels:ku.map(k=>urgInfo(k).label), datasets:[{data:ku.map(k=>cu[k]), backgroundColor:ku.map(k=>urgInfo(k).cor), borderColor:'#ffffff', borderWidth:2}]},
    options:{maintainAspectRatio:false, cutout:'62%', plugins:{legend:{position:'bottom',labels:{boxWidth:10,color:'#1a202c'}}},
      onClick:(e,els)=>{ if(!els.length) return; const k=ku[els[0].index]; filtros.urg = filtros.urg===k?'':k; $('fUrg').value=filtros.urg; pagina=1; render(); },
      onHover:(e,els)=>{ e.native.target.style.cursor = els.length?'pointer':'default'; }}
  });

  // Classificação
  const cc = contar(lista,'_cls');
  const kc = Object.keys(cc);
  desenhar('cCls', {
    type:'doughnut',
    data:{labels:kc.map(k=>clsInfo(k).label), datasets:[{data:kc.map(k=>cc[k]), backgroundColor:kc.map(k=>clsInfo(k).cor), borderColor:'#ffffff', borderWidth:2}]},
    options:{maintainAspectRatio:false, cutout:'62%', plugins:{legend:{position:'bottom',labels:{boxWidth:10,color:'#1a202c'}}}}
  });

  // Top ETCs (só para o acesso completo)
  if(isAdmin){
    const porEtc = {};
    lista.forEach(r => { const o = porEtc[r._etc] ||= {n:0,gmv:0}; o.n++; o.gmv += num(r.gmv_brl); });
    const top = Object.entries(porEtc).sort((a,b)=>b[1].n-a[1].n).slice(0,10);
    desenhar('cTop', {
      type:'bar',
      data:{labels:top.map(t=>t[0].length>28?t[0].slice(0,27)+'…':t[0]), datasets:[{data:top.map(t=>t[1].n), backgroundColor:'#4c6ef5', borderRadius:4}]},
      options:{indexAxis:'y', maintainAspectRatio:false,
        plugins:{legend:{display:false}, tooltip:{callbacks:{label:c=>` ${c.parsed.x} pacotes · ${fmtCompacto(top[c.dataIndex][1].gmv)}`}}},
        scales:{x:{grid:{color:'#e2e8f0'}}, y:{grid:{display:false}, ticks:{color:'#1a202c',font:{size:11}}}},
        onClick:(e,els)=>{ if(!els.length) return; const nome=top[els[0].index][0]; filtros.etc = filtros.etc===nome?'':nome; $('fEtc').value=filtros.etc; pagina=1; render(); },
        onHover:(e,els)=>{ e.native.target.style.cursor = els.length?'pointer':'default'; }}
    });
  }
}

function ordenada(lista){
  return [...lista].sort((a,b) => num(b.dias_estancado) - num(a.dias_estancado));
}
function renderTabela(lista){
  const ord = ordenada(lista);
  const total = ord.length;
  const paginas = Math.max(1, Math.ceil(total / POR_PAGINA));
  if(pagina > paginas) pagina = paginas;
  const ini = (pagina-1)*POR_PAGINA;
  const fatia = ord.slice(ini, ini + POR_PAGINA);

  $('tInfo').textContent = total ? `Mostrando ${ini+1}–${ini+fatia.length} de ${fmtInt(total)} · ordenado por dias estancado` : '';
  $('pTxt').textContent = `${pagina} / ${paginas}`;
  $('pPrev').disabled = pagina <= 1;
  $('pNext').disabled = pagina >= paginas;
  $('vazio').classList.toggle('hidden', total > 0);

  $('tbody').innerHTML = fatia.map((r,i) => {
    const u = urgInfo(r._urg), c = clsInfo(r._cls);
    return `<tr data-i="${ini+i}">
      <td><span class="chip">${esc(r.shp_shipment_id)}</span></td>
      <td>${fmtData(r.data_atribuicao)}</td>
      ${isAdmin ? `<td>${esc(r._etc)}</td>` : ''}
      <td>${esc(r.nome_motorista)}</td>
      <td><span class="badge ${c.badge}">${esc(c.label)}</span></td>
      <td><span class="badge ${u.badge}">${esc(u.label)}</span></td>
      <td class="num">${esc(num(r.dias_estancado))}</td>
      <td>${esc(r.estagio_bpp)}</td>
      <td class="num">${num(r.gmv_brl).toLocaleString('pt-BR',{minimumFractionDigits:2,maximumFractionDigits:2})}</td>
      <td>${esc(r._reg)}</td>
    </tr>`;
  }).join('');
  tabelaAtual = ord;
}
let tabelaAtual = [];

/* ============ DRAWER ============ */
function abrirDrawer(r){
  const u = urgInfo(r._urg), c = clsInfo(r._cls);
  const linhas = [
    ['Shipment ID', `<span class="chip">${esc(r.shp_shipment_id)}</span>`],
    ['Código', esc(r.shp_code || '—')],
    ['Rota', esc(r.shp_lg_route_id || '—')],
    ['ETC', esc(r._etc)],
    ['Motorista', esc(r.nome_motorista || '—')],
    ['ID do motorista', esc(r.id_driver || '—')],
    ['Data de atribuição', fmtData(r.data_atribuicao)],
    ['Classificação', `<span class="badge ${c.badge}">${esc(c.label)}</span>`],
    ['Urgência', `<span class="badge ${u.badge}">${esc(u.label)}</span>`],
    ['Dias estancado', esc(num(r.dias_estancado))],
    ['Estágio BPP', esc(r.estagio_bpp || '—')],
    ['GMV', fmtBRL(num(r.gmv_brl))],
    ['Regional', esc(r._reg)]
  ];
  $('dBody').innerHTML = linhas.map(l => `<div class="kv"><span>${l[0]}</span><span>${l[1]}</span></div>`).join('');
  $('drawer').classList.remove('fechado'); $('drawer').setAttribute('aria-hidden','false');
  $('backdrop').classList.remove('hidden');
}
function fecharDrawer(){
  $('drawer').classList.add('fechado'); $('drawer').setAttribute('aria-hidden','true');
  $('backdrop').classList.add('hidden');
}

/* ============ EVENTOS ============ */
$('btnEntrar').addEventListener('click', entrar);
['email','senha'].forEach(id => $(id).addEventListener('keydown', e => { if(e.key==='Enter') entrar(); }));
$('btnSair').addEventListener('click', sair);
[['fEtc','etc'],['fReg','reg'],['fUrg','urg'],['fEst','est']].forEach(([id,k]) =>
  $(id).addEventListener('change', e => { filtros[k] = e.target.value; pagina = 1; render(); }));
$('btnLimpar').addEventListener('click', () => { filtros = {etc:'',reg:'',urg:'',est:''}; montarFiltros(); pagina = 1; render(); });
$('pPrev').addEventListener('click', () => { pagina--; renderTabela(filtrados()); });
$('pNext').addEventListener('click', () => { pagina++; renderTabela(filtrados()); });
$('tbody').addEventListener('click', e => {
  const tr = e.target.closest('tr'); if(!tr) return;
  const r = tabelaAtual[Number(tr.dataset.i)]; if(r) abrirDrawer(r);
});
$('dClose').addEventListener('click', fecharDrawer);
$('backdrop').addEventListener('click', fecharDrawer);
document.addEventListener('keydown', e => { if(e.key==='Escape') fecharDrawer(); });

// Se a sessão expirar, volta para o login
sb.auth.onAuthStateChange((evento) => { if(evento === 'SIGNED_OUT') mostrar('login'); });

iniciar();
</script>
</body>
</html>
