import{_ as a,o as i,c as n,ag as t}from"./chunks/framework.VvOSaRrC.js";const c=JSON.parse('{"title":"Codemap & Cleanup Commands","description":"","frontmatter":{},"headers":[],"relativePath":"ko/codemap.md","filePath":"ko/codemap.md"}'),e={name:"ko/codemap.md"};function l(p,s,h,d,k,r){return i(),n("div",null,[...s[0]||(s[0]=[t(`<h1 id="codemap-cleanup-commands" tabindex="-1">Codemap &amp; Cleanup Commands <a class="header-anchor" href="#codemap-cleanup-commands" aria-label="Permalink to &quot;Codemap &amp; Cleanup Commands&quot;">​</a></h1><p>아키텍처 문서화와 코드 정리를 위한 명령어 레퍼런스입니다.</p><h2 id="overview" tabindex="-1">Overview <a class="header-anchor" href="#overview" aria-label="Permalink to &quot;Overview&quot;">​</a></h2><table tabindex="0"><thead><tr><th>명령어</th><th>목적</th><th>주요 도구</th></tr></thead><tbody><tr><td><code>/kroot:codemap</code></td><td>AST 분석 기반 아키텍처 문서화</td><td>ts-morph, madge</td></tr><tr><td><code>/kroot:cleanup</code></td><td>Dead code 탐지 및 안전한 제거</td><td>knip, depcheck, ts-prune</td></tr></tbody></table><hr><h2 id="kroot-codemap" tabindex="-1">/kroot:codemap <a class="header-anchor" href="#kroot-codemap" aria-label="Permalink to &quot;/kroot:codemap&quot;">​</a></h2><p><strong>AST 분석 기반 아키텍처 매핑</strong></p><table tabindex="0"><thead><tr><th>항목</th><th>내용</th></tr></thead><tbody><tr><td><strong>설명</strong></td><td>코드베이스에서 아키텍처 문서를 자동 생성</td></tr><tr><td><strong>Type</strong></td><td>Utility (Type B)</td></tr><tr><td><strong>Context</strong></td><td>sync.md</td></tr><tr><td><strong>Skill</strong></td><td>kroot-workflow-codemap</td></tr><tr><td><strong>단독 사용</strong></td><td>✅ 높음 - 언제든 독립 실행 가능</td></tr></tbody></table><h3 id="usage" tabindex="-1">Usage <a class="header-anchor" href="#usage" aria-label="Permalink to &quot;Usage&quot;">​</a></h3><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 전체 아키텍처 맵 생성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> all</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 특정 영역만 생성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> frontend</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> backend</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> database</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> integrations</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># AST 분석 포함 (TypeScript/JavaScript)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> all</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --ast</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 의존성 그래프 생성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> all</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --deps</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 강제 재생성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> all</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --refresh</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># JSON 출력 (자동화용)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:codemap</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> all</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --json</span></span></code></pre></div><h3 id="options" tabindex="-1">Options <a class="header-anchor" href="#options" aria-label="Permalink to &quot;Options&quot;">​</a></h3><table tabindex="0"><thead><tr><th>Option</th><th>설명</th></tr></thead><tbody><tr><td><code>all</code></td><td>모든 영역의 codemap 생성</td></tr><tr><td><code>frontend</code></td><td>프론트엔드 아키텍처만</td></tr><tr><td><code>backend</code></td><td>백엔드/API 아키텍처만</td></tr><tr><td><code>database</code></td><td>데이터베이스 스키마/모델</td></tr><tr><td><code>integrations</code></td><td>외부 서비스 연동</td></tr><tr><td><code>--ast</code></td><td>ts-morph로 AST 분석 활성화</td></tr><tr><td><code>--deps</code></td><td>madge로 의존성 그래프 생성</td></tr><tr><td><code>--refresh</code></td><td>캐시 무시하고 강제 재생성</td></tr><tr><td><code>--json</code></td><td>자동화를 위한 JSON 출력</td></tr></tbody></table><h3 id="분석-도구" tabindex="-1">분석 도구 <a class="header-anchor" href="#분석-도구" aria-label="Permalink to &quot;분석 도구&quot;">​</a></h3><h4 id="_1-ts-morph-ast-분석" tabindex="-1">1. ts-morph (AST 분석) <a class="header-anchor" href="#_1-ts-morph-ast-분석" aria-label="Permalink to &quot;1. ts-morph (AST 분석)&quot;">​</a></h4><p>TypeScript/JavaScript 프로젝트의 구조적 분석:</p><div class="language-typescript vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">typescript</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">// 추출 정보</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> 모든 exported 함수, 클래스, 타입</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> import</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">/export 관계</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">- 모듈 의존성</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">- 라우트 정의 (Next.js, Express 등)</span></span></code></pre></div><h4 id="_2-madge-의존성-그래프" tabindex="-1">2. madge (의존성 그래프) <a class="header-anchor" href="#_2-madge-의존성-그래프" aria-label="Permalink to &quot;2. madge (의존성 그래프)&quot;">​</a></h4><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># SVG 그래프 생성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> madge</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --image</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> docs/CODEMAPS/assets/dependency-graph.svg</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> src/</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 순환 의존성 탐지</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> madge</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --circular</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> src/</span></span></code></pre></div><h3 id="프레임워크-감지" tabindex="-1">프레임워크 감지 <a class="header-anchor" href="#프레임워크-감지" aria-label="Permalink to &quot;프레임워크 감지&quot;">​</a></h3><table tabindex="0"><thead><tr><th>감지 파일</th><th>프레임워크</th><th>Codemap 초점</th></tr></thead><tbody><tr><td><code>next.config.*</code></td><td>Next.js</td><td>App Router, API Routes, Pages</td></tr><tr><td><code>vite.config.*</code></td><td>Vite</td><td>Components, Modules</td></tr><tr><td><code>angular.json</code></td><td>Angular</td><td>Modules, Services, Components</td></tr><tr><td><code>nuxt.config.*</code></td><td>Nuxt</td><td>Pages, Plugins, Modules</td></tr><tr><td><code>package.json</code> + express</td><td>Express</td><td>Routes, Middleware</td></tr><tr><td><code>go.mod</code></td><td>Go</td><td>Packages, Handlers</td></tr><tr><td><code>Cargo.toml</code></td><td>Rust</td><td>Crates, Modules</td></tr><tr><td><code>pyproject.toml</code></td><td>Python</td><td>Packages, Modules</td></tr></tbody></table><h3 id="output-structure" tabindex="-1">Output Structure <a class="header-anchor" href="#output-structure" aria-label="Permalink to &quot;Output Structure&quot;">​</a></h3><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>docs/</span></span>
<span class="line"><span>├── CODEMAPS/</span></span>
<span class="line"><span>│   ├── INDEX.md              # 아키텍처 개요</span></span>
<span class="line"><span>│   ├── frontend.md           # 프론트엔드 구조</span></span>
<span class="line"><span>│   ├── backend.md            # 백엔드/API 구조</span></span>
<span class="line"><span>│   ├── database.md           # 데이터베이스 스키마</span></span>
<span class="line"><span>│   ├── integrations.md       # 외부 서비스</span></span>
<span class="line"><span>│   └── assets/</span></span>
<span class="line"><span>│       ├── dependency-graph.svg</span></span>
<span class="line"><span>│       └── architecture-diagram.svg</span></span></code></pre></div><h3 id="codemap-파일-형식" tabindex="-1">Codemap 파일 형식 <a class="header-anchor" href="#codemap-파일-형식" aria-label="Permalink to &quot;Codemap 파일 형식&quot;">​</a></h3><div class="language-markdown vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">markdown</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;"># [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">Area</span><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">] Codemap</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Last Updated:**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> YYYY-MM-DD</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Version:**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> X.Y.Z</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Entry Points:**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [주요 진입점 목록]</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## Overview</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">[영역에 대한 간략한 설명]</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## Architecture</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">[컴포넌트 관계를 보여주는 ASCII 다이어그램]</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## Key Modules</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Module | Purpose | Exports | Dependencies |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">|--------|---------|---------|--------------||</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| ... | ... | ... | ... |</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## Data Flow</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">[이 영역을 통한 데이터 흐름 설명]</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## External Dependencies</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> package@version - 용도</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> ...</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## Related Codemaps</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">Related Area</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">](</span><span style="--shiki-light:#24292E;--shiki-light-text-decoration:underline;--shiki-dark:#E1E4E8;--shiki-dark-text-decoration:underline;">./related.md</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h3 id="process" tabindex="-1">Process <a class="header-anchor" href="#process" aria-label="Permalink to &quot;Process&quot;">​</a></h3><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>Phase 1: Discovery</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  프레임워크, 언어, 프로젝트 타입 감지</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  진입점과 핵심 파일 식별</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>Phase 2: Analysis</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  AST 파싱 (ts-morph for TS/JS)</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  의존성 그래프 (madge)</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  패턴 인식 (MVC, Clean 등)</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>Phase 3: Generation</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  구조화된 codemap 생성</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  ASCII 다이어그램 생성</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  관계 테이블 빌드</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>Phase 4: Validation</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  경로 존재 확인</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  링크 타겟 검증</span></span>
<span class="line"><span>    ↓</span></span>
<span class="line"><span>  커버리지 통계 리포트</span></span></code></pre></div><hr><h2 id="kroot-cleanup" tabindex="-1">/kroot:cleanup <a class="header-anchor" href="#kroot-cleanup" aria-label="Permalink to &quot;/kroot:cleanup&quot;">​</a></h2><p><strong>Dead Code 탐지 및 안전한 제거</strong></p><table tabindex="0"><thead><tr><th>항목</th><th>내용</th></tr></thead><tbody><tr><td><strong>설명</strong></td><td>종합적인 dead code 분석과 DELETION_LOG 추적</td></tr><tr><td><strong>Type</strong></td><td>Utility (Type B)</td></tr><tr><td><strong>Context</strong></td><td>dev.md</td></tr><tr><td><strong>Agent</strong></td><td>refactorer</td></tr><tr><td><strong>단독 사용</strong></td><td>✅ 높음 - 언제든 독립 실행 가능</td></tr></tbody></table><h3 id="usage-1" tabindex="-1">Usage <a class="header-anchor" href="#usage-1" aria-label="Permalink to &quot;Usage&quot;">​</a></h3><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Dead code 스캔 (분석만, 변경 없음)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> scan</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Safe 항목만 제거 (저위험)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> remove</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --safe</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Careful 항목 포함 제거 (중위험, 확인 필요)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> remove</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --careful</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 특정 카테고리만 대상</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> remove</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --deps</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">      # 미사용 npm 의존성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> remove</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --exports</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">   # 미사용 exports</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> remove</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --files</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">     # 미사용 파일</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Dry run (무엇이 제거될지 보여줌)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> scan</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --dry-run</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 삭제 기록 확인</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> log</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 종합 정리 리포트 생성</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:cleanup</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> report</span></span></code></pre></div><h3 id="options-1" tabindex="-1">Options <a class="header-anchor" href="#options-1" aria-label="Permalink to &quot;Options&quot;">​</a></h3><table tabindex="0"><thead><tr><th>Option</th><th>설명</th></tr></thead><tbody><tr><td><code>scan</code></td><td>코드베이스의 dead code 분석 (변경 없음)</td></tr><tr><td><code>remove</code></td><td>감지된 dead code 제거</td></tr><tr><td><code>report</code></td><td>종합 정리 리포트 생성</td></tr><tr><td><code>log</code></td><td>DELETION_LOG.md 기록 확인</td></tr><tr><td><code>--safe</code></td><td>저위험 항목만 제거</td></tr><tr><td><code>--careful</code></td><td>중위험 항목 포함 (검증 필요)</td></tr><tr><td><code>--deps</code></td><td>미사용 의존성 대상</td></tr><tr><td><code>--exports</code></td><td>미사용 exports 대상</td></tr><tr><td><code>--files</code></td><td>미사용 파일 대상</td></tr><tr><td><code>--dry-run</code></td><td>무엇이 제거될지 보여줌</td></tr></tbody></table><h3 id="분석-도구-1" tabindex="-1">분석 도구 <a class="header-anchor" href="#분석-도구-1" aria-label="Permalink to &quot;분석 도구&quot;">​</a></h3><h4 id="_1-knip-종합-dead-code-탐지" tabindex="-1">1. knip - 종합 Dead Code 탐지 <a class="header-anchor" href="#_1-knip-종합-dead-code-탐지" aria-label="Permalink to &quot;1. knip - 종합 Dead Code 탐지&quot;">​</a></h4><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 설치</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -D</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> knip</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 전체 분석</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> knip</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># JSON 리포트</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> knip</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --reporter</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> json</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> &gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> .kroot/cleanup/knip-report.json</span></span></code></pre></div><p><strong>탐지 항목</strong>:</p><ul><li>미사용 파일</li><li>미사용 exports</li><li>미사용 dependencies</li><li>미사용 devDependencies</li><li>미사용 types</li></ul><h4 id="_2-depcheck-의존성-분석" tabindex="-1">2. depcheck - 의존성 분석 <a class="header-anchor" href="#_2-depcheck-의존성-분석" aria-label="Permalink to &quot;2. depcheck - 의존성 분석&quot;">​</a></h4><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 설치</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -D</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> depcheck</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 분석</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> depcheck</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># JSON 리포트</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> depcheck</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --json</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> &gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> .kroot/cleanup/depcheck-report.json</span></span></code></pre></div><p><strong>탐지 항목</strong>:</p><ul><li>미사용 dependencies</li><li>누락된 dependencies</li><li>Phantom dependencies</li></ul><h4 id="_3-ts-prune-typescript-export-분석" tabindex="-1">3. ts-prune - TypeScript Export 분석 <a class="header-anchor" href="#_3-ts-prune-typescript-export-분석" aria-label="Permalink to &quot;3. ts-prune - TypeScript Export 분석&quot;">​</a></h4><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 설치</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -D</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> ts-prune</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 분석</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> ts-prune</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 필터링</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> ts-prune</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> |</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> grep</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -v</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;used in module&quot;</span></span></code></pre></div><p><strong>탐지 항목</strong>:</p><ul><li>미사용 exports</li><li>미사용 types</li><li>Dead code paths</li></ul><h4 id="_4-eslint-미사용-지시문" tabindex="-1">4. ESLint - 미사용 지시문 <a class="header-anchor" href="#_4-eslint-미사용-지시문" aria-label="Permalink to &quot;4. ESLint - 미사용 지시문&quot;">​</a></h4><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 미사용 eslint-disable 코멘트 확인</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npx</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> eslint</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> .</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --report-unused-disable-directives</span></span></code></pre></div><h3 id="위험-분류-시스템" tabindex="-1">위험 분류 시스템 <a class="header-anchor" href="#위험-분류-시스템" aria-label="Permalink to &quot;위험 분류 시스템&quot;">​</a></h3><h4 id="safe-자동-제거-가능" tabindex="-1">SAFE (자동 제거 가능) <a class="header-anchor" href="#safe-자동-제거-가능" aria-label="Permalink to &quot;SAFE (자동 제거 가능)&quot;">​</a></h4><table tabindex="0"><thead><tr><th>카테고리</th><th>위험</th><th>탐지 방법</th><th>검증</th></tr></thead><tbody><tr><td>미사용 npm deps</td><td>낮음</td><td>depcheck</td><td>import 없음 확인</td></tr><tr><td>미사용 devDeps</td><td>낮음</td><td>depcheck</td><td>스크립트에서 사용 없음</td></tr><tr><td>주석 처리된 코드</td><td>낮음</td><td>Regex 패턴</td><td>시각적 확인</td></tr><tr><td>미사용 imports</td><td>낮음</td><td>ESLint + knip</td><td>참조 없음</td></tr><tr><td>미사용 eslint-disable</td><td>낮음</td><td>ESLint 리포트</td><td>지시문 확인</td></tr></tbody></table><h4 id="careful-확인-필요" tabindex="-1">CAREFUL (확인 필요) <a class="header-anchor" href="#careful-확인-필요" aria-label="Permalink to &quot;CAREFUL (확인 필요)&quot;">​</a></h4><table tabindex="0"><thead><tr><th>카테고리</th><th>위험</th><th>탐지 방법</th><th>검증</th></tr></thead><tbody><tr><td>미사용 exports</td><td>중간</td><td>ts-prune + knip</td><td>Grep + git history</td></tr><tr><td>미사용 파일</td><td>중간</td><td>knip</td><td>동적 import 확인</td></tr><tr><td>미사용 types</td><td>중간</td><td>ts-prune</td><td>타입 추론 확인</td></tr><tr><td>Dead branches</td><td>중간</td><td>Coverage report</td><td>런타임 테스트</td></tr></tbody></table><h4 id="risky-수동-리뷰-필요" tabindex="-1">RISKY (수동 리뷰 필요) <a class="header-anchor" href="#risky-수동-리뷰-필요" aria-label="Permalink to &quot;RISKY (수동 리뷰 필요)&quot;">​</a></h4><table tabindex="0"><thead><tr><th>카테고리</th><th>위험</th><th>탐지 방법</th><th>검증</th></tr></thead><tbody><tr><td>Public API</td><td>높음</td><td>API tests</td><td>통합 테스트</td></tr><tr><td>공유 유틸리티</td><td>높음</td><td>크로스 프로젝트 검색</td><td>이해관계자 리뷰</td></tr><tr><td>동적 imports</td><td>높음</td><td>String 패턴 검색</td><td>런타임 테스트</td></tr><tr><td>Reflection 코드</td><td>높음</td><td>패턴 분석</td><td>전체 테스트 스위트</td></tr></tbody></table><h3 id="ddd-aligned-workflow" tabindex="-1">DDD-Aligned Workflow <a class="header-anchor" href="#ddd-aligned-workflow" aria-label="Permalink to &quot;DDD-Aligned Workflow&quot;">​</a></h3><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>Phase 1: ANALYZE</span></span>
<span class="line"><span>    └─ 모든 탐지 도구 병렬 실행</span></span>
<span class="line"><span>    └─ 위험 분류와 함께 결과 집계</span></span>
<span class="line"><span>    └─ 영향받는 코드의 테스트 커버리지 확인</span></span>
<span class="line"><span>    └─ 컨텍스트를 위한 git history 리뷰</span></span>
<span class="line"><span>         ↓</span></span>
<span class="line"><span>Phase 2: PRESERVE</span></span>
<span class="line"><span>    └─ 영향받는 코드에 특성화 테스트 존재 확인</span></span>
<span class="line"><span>    └─ 백업 브랜치 생성: cleanup/YYYY-MM-DD-HHMM</span></span>
<span class="line"><span>    └─ 테스트 없으면 현재 동작 문서화</span></span>
<span class="line"><span>         ↓</span></span>
<span class="line"><span>Phase 3: IMPROVE</span></span>
<span class="line"><span>    └─ 카테고리별 제거 (가장 안전한 것부터):</span></span>
<span class="line"><span>        a. 미사용 npm dependencies</span></span>
<span class="line"><span>        b. 미사용 devDependencies</span></span>
<span class="line"><span>        c. 미사용 imports</span></span>
<span class="line"><span>        d. 미사용 exports</span></span>
<span class="line"><span>        e. 미사용 files</span></span>
<span class="line"><span>    └─ 각 카테고리 후:</span></span>
<span class="line"><span>        - 빌드 실행</span></span>
<span class="line"><span>        - 전체 테스트 스위트 실행</span></span>
<span class="line"><span>        - 통과하면 커밋</span></span>
<span class="line"><span>        - DELETION_LOG.md 업데이트</span></span></code></pre></div><h3 id="deletion-log-md-형식" tabindex="-1">DELETION_LOG.md 형식 <a class="header-anchor" href="#deletion-log-md-형식" aria-label="Permalink to &quot;DELETION_LOG.md 형식&quot;">​</a></h3><p>모든 삭제는 <code>docs/DELETION_LOG.md</code>에 추적됩니다:</p><div class="language-markdown vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">markdown</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;"># Code Deletion Log</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">코드 정리 작업의 감사 추적 기록.</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">---</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## [YYYY-MM-DD HH:MM] Cleanup Session</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Operator**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: J.A.R.V.I.S. / refactorer agent</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Branch**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: cleanup/YYYY-MM-DD-HHMM</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Commit**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: abc123def</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Tools**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">: knip v5.x, depcheck v1.x, ts-prune v0.x</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Summary</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Category | Items | Lines | Size Impact |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">|----------|-------|-------|-------------|</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Dependencies | 5 | - | -120 KB |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| DevDependencies | 3 | - | -45 KB |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Files | 12 | 1,450 | -45 KB |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Exports | 23 | 89 | - |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Imports | 45 | 45 | - |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| </span><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Total**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> | </span><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**88**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> | </span><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**1,584**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> | </span><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**-210 KB**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> |</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Dependencies Removed</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Package | Version | Reason | Alternative |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">|---------|---------|--------|-------------|</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| lodash | 4.17.21 | Not imported | Use native methods |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| moment | 2.29.4 | Deprecated | date-fns already used |</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Files Deleted</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Path | Lines | Last Modified | Replaced By |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">|------|-------|---------------|-------------|</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| src/utils/old-helpers.ts | 120 | 2023-08-15 | N/A (unused) |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| src/components/LegacyButton.tsx | 85 | 2023-09-01 | Button.tsx |</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Verification Results</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">x</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] TypeScript compiles: </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">\`npx tsc --noEmit\`</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">x</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] Build succeeds: </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">\`npm run build\`</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">x</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] Tests pass: 47/47 (100%)</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">x</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] No lint errors: </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">\`npm run lint\`</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> [</span><span style="--shiki-light:#032F62;--shiki-light-text-decoration:underline;--shiki-dark:#DBEDFF;--shiki-dark-text-decoration:underline;">x</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] Bundle size verified</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Recovery Instructions</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">\`\`\`bash</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 이 정리 후 문제 발생 시:</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">git</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> log</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --oneline</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> |</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> head</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -5</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">  # 정리 커밋 찾기</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">git</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> revert</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> &lt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">commit-sh</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">a</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">       # 특정 커밋 되돌리기</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">                   # 의존성 재설치</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> run</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> build</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> &amp;&amp; </span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> test</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">     # 복구 확인</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span></span></span>
<span class="line"><span>### Protected Items</span></span>
<span class="line"><span></span></span>
<span class="line"><span>\`.kroot/cleanup/protected.yaml\`에서 제거 금지 항목 관리:</span></span>
<span class="line"><span></span></span>
<span class="line"><span>\`\`\`yaml</span></span>
<span class="line"><span># 제거하면 안 되는 항목</span></span>
<span class="line"><span>protected:</span></span>
<span class="line"><span>  dependencies:</span></span>
<span class="line"><span>    - &quot;@types/*&quot;  # 타입 정의</span></span>
<span class="line"><span>    - &quot;eslint-*&quot;  # 린팅 인프라</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  files:</span></span>
<span class="line"><span>    - &quot;src/polyfills/*&quot;  # 브라우저 호환성</span></span>
<span class="line"><span>    - &quot;src/lib/dynamic-*&quot;  # 동적 import 대상</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  exports:</span></span>
<span class="line"><span>    - &quot;src/api/public.ts:*&quot;  # Public API</span></span>
<span class="line"><span>    - &quot;src/sdk/index.ts:*&quot;   # SDK exports</span></span>
<span class="line"><span></span></span>
<span class="line"><span>  patterns:</span></span>
<span class="line"><span>    - &quot;**/index.ts&quot;  # Barrel files (미사용으로 보일 수 있음)</span></span>
<span class="line"><span>    - &quot;**/__tests__/*&quot;  # 테스트 유틸리티</span></span></code></pre></div><h3 id="safety-checklist" tabindex="-1">Safety Checklist <a class="header-anchor" href="#safety-checklist" aria-label="Permalink to &quot;Safety Checklist&quot;">​</a></h3><p><strong>제거 전 검증</strong>:</p><ul><li>[ ] 모든 탐지 도구 실행됨</li><li>[ ] 위험 분류 완료</li><li>[ ] 백업 브랜치 생성됨</li><li>[ ] 특성화 테스트 존재 (또는 생성됨)</li><li>[ ] 컨텍스트를 위한 git history 리뷰됨</li><li>[ ] 동적 import 패턴 확인됨</li><li>[ ] Public API 영향 평가됨</li></ul><p><strong>제거 후 검증</strong>:</p><ul><li>[ ] TypeScript 에러 없이 컴파일</li><li>[ ] 빌드 성공</li><li>[ ] 모든 테스트 통과</li><li>[ ] 콘솔 에러 없음</li><li>[ ] 번들 사이즈 측정됨</li><li>[ ] DELETION_LOG.md 업데이트됨</li><li>[ ] 커밋 메시지 상세함</li></ul><hr><h2 id="trust-5-integration" tabindex="-1">TRUST 5 Integration <a class="header-anchor" href="#trust-5-integration" aria-label="Permalink to &quot;TRUST 5 Integration&quot;">​</a></h2><table tabindex="0"><thead><tr><th>원칙</th><th>Codemap</th><th>Cleanup</th></tr></thead><tbody><tr><td><strong>T</strong>ested</td><td>생성된 문서 경로 검증</td><td>각 제거 후 테스트 실행</td></tr><tr><td><strong>R</strong>eadable</td><td>명확한 구조와 ASCII 다이어그램</td><td>노이즈 제거, 신호/잡음비 개선</td></tr><tr><td><strong>U</strong>nified</td><td>일관된 문서 형식</td><td>중복 통합</td></tr><tr><td><strong>S</strong>ecured</td><td>민감 정보 노출 방지</td><td>취약점 있는 미사용 deps 제거</td></tr><tr><td><strong>T</strong>rackable</td><td>타임스탬프와 버전 관리</td><td>DELETION_LOG.md 감사 추적</td></tr></tbody></table><hr><h2 id="j-a-r-v-i-s-출력-형식" tabindex="-1">J.A.R.V.I.S. 출력 형식 <a class="header-anchor" href="#j-a-r-v-i-s-출력-형식" aria-label="Permalink to &quot;J.A.R.V.I.S. 출력 형식&quot;">​</a></h2><h3 id="j-a-r-v-i-s-개발" tabindex="-1">J.A.R.V.I.S. (개발) <a class="header-anchor" href="#j-a-r-v-i-s-개발" aria-label="Permalink to &quot;J.A.R.V.I.S. (개발)&quot;">​</a></h3><div class="language-markdown vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">markdown</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## J.A.R.V.I.S.: Codemap Generation Complete</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Generated Files</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| File | Lines | Modules Documented |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">|------|-------|-------------------|</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| docs/CODEMAPS/INDEX.md | 120 | 5 entry points |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| docs/CODEMAPS/frontend.md | 85 | 12 components |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| docs/CODEMAPS/backend.md | 95 | 8 endpoints |</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Coverage</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Files analyzed: 47</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Modules documented: 25</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Dependencies mapped: 32</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Circular dependencies: 0</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Predictive Suggestions</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Consider documenting workers/ directory</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> API rate limiting not documented</span></span></code></pre></div><div class="language-markdown vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">markdown</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">## J.A.R.V.I.S.: Cleanup Scan Complete</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Dead Code Summary</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Category | Found | Risk | Action |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">|----------|-------|------|--------|</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Dependencies | 5 | SAFE | Auto-remove |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Exports | 23 | CAREFUL | Review |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Files | 12 | CAREFUL | Review |</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">| Dynamic refs | 2 | RISKY | Skip |</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Recommended Actions</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Immediate (SAFE)**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">:</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">1.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Remove 5 unused dependencies (-120 KB)</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">2.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Remove 15 unused imports</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-light-font-weight:bold;--shiki-dark:#E1E4E8;--shiki-dark-font-weight:bold;">**Review Required (CAREFUL)**</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">:</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">1.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> 12 files appear unused but check git history</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">2.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> 23 exports not directly referenced</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-light-font-weight:bold;--shiki-dark:#79B8FF;--shiki-dark-font-weight:bold;">### Estimated Impact</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Bundle size: -165 KB (~8% reduction)</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Lines of code: -1,539</span></span>
<span class="line"><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70;">-</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Files: -12</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Proceed with --safe removal? Use: /kroot:cleanup remove --safe</span></span></code></pre></div><hr><h2 id="command-comparison" tabindex="-1">Command Comparison <a class="header-anchor" href="#command-comparison" aria-label="Permalink to &quot;Command Comparison&quot;">​</a></h2><table tabindex="0"><thead><tr><th>상황</th><th>권장 명령어</th></tr></thead><tbody><tr><td>아키텍처 문서화 필요</td><td><code>/kroot:codemap all</code></td></tr><tr><td>의존성 그래프 시각화</td><td><code>/kroot:codemap all --deps</code></td></tr><tr><td>Dead code 현황 파악</td><td><code>/kroot:cleanup scan</code></td></tr><tr><td>안전한 정리 작업</td><td><code>/kroot:cleanup remove --safe</code></td></tr><tr><td>정리 기록 확인</td><td><code>/kroot:cleanup log</code></td></tr><tr><td>리팩토링 전 정리</td><td><code>/kroot:cleanup scan</code> → <code>/kroot:refactor</code></td></tr></tbody></table><hr><h2 id="related-commands" tabindex="-1">Related Commands <a class="header-anchor" href="#related-commands" aria-label="Permalink to &quot;Related Commands&quot;">​</a></h2><ul><li><code>/kroot:docs</code> - 문서 업데이트 및 동기화</li><li><code>/kroot:refactor</code> - DDD 기반 코드 리팩토링</li><li><code>/kroot:learn</code> - 코드베이스 탐색 및 학습</li></ul><hr><h2 id="related-skills" tabindex="-1">Related Skills <a class="header-anchor" href="#related-skills" aria-label="Permalink to &quot;Related Skills&quot;">​</a></h2><ul><li><code>kroot-workflow-codemap</code> - Codemap 생성 워크플로우</li><li><code>kroot-workflow-ddd</code> - DDD 방법론 (ANALYZE-PRESERVE-IMPROVE)</li><li><code>kroot-foundation-quality</code> - TRUST 5 품질 프레임워크</li></ul><hr><p>Version: 1.0.0 Last Updated: 2026-01-25 Integration: AST analysis (ts-morph), Dependency graphs (madge), Dead code detection (knip, depcheck, ts-prune)</p>`,86)])])}const g=a(e,[["render",l]]);export{c as __pageData,g as default};
