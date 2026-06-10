import{_ as s,o as n,c as t,ag as e}from"./chunks/framework.VvOSaRrC.js";const k=JSON.parse('{"title":"PR 라이프사이클 자동화","description":"","frontmatter":{},"headers":[],"relativePath":"ko/pr-lifecycle.md","filePath":"ko/pr-lifecycle.md"}'),p={name:"ko/pr-lifecycle.md"};function l(i,a,d,r,h,c){return n(),t("div",null,[...a[0]||(a[0]=[e(`<h1 id="pr-라이프사이클-자동화" tabindex="-1">PR 라이프사이클 자동화 <a class="header-anchor" href="#pr-라이프사이클-자동화" aria-label="Permalink to &quot;PR 라이프사이클 자동화&quot;">​</a></h1><blockquote><p>CI 모니터링과 리뷰 해결을 포함한 PR 생성부터 머지까지의 자동화 워크플로우입니다.</p></blockquote><h2 id="개요" tabindex="-1">개요 <a class="header-anchor" href="#개요" aria-label="Permalink to &quot;개요&quot;">​</a></h2><p>PR 라이프사이클 자동화는 전체 풀 리퀘스트 워크플로우를 처리합니다:</p><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>사전 검증 (빌드, 테스트, 린트)</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>PR 생성 (gh pr create)</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>CI 모니터링 루프 (최대 10분, 5회 재시도)</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>리뷰 해결 루프 (최대 3회)</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>머지 &amp; 정리</span></span></code></pre></div><hr><h2 id="워크플로우-단계" tabindex="-1">워크플로우 단계 <a class="header-anchor" href="#워크플로우-단계" aria-label="Permalink to &quot;워크플로우 단계&quot;">​</a></h2><h3 id="_1단계-사전-검증" tabindex="-1">1단계: 사전 검증 <a class="header-anchor" href="#_1단계-사전-검증" aria-label="Permalink to &quot;1단계: 사전 검증&quot;">​</a></h3><p>PR 생성 전 확인 사항:</p><ul><li>커밋되지 않은 변경사항 없음</li><li>로컬 빌드 통과</li><li>로컬 테스트 통과</li><li>로컬 린트 통과</li><li>브랜치가 리모트에 푸시됨</li></ul><h3 id="_2단계-pr-생성" tabindex="-1">2단계: PR 생성 <a class="header-anchor" href="#_2단계-pr-생성" aria-label="Permalink to &quot;2단계: PR 생성&quot;">​</a></h3><p>구조화된 PR 설명 생성:</p><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>## Summary</span></span>
<span class="line"><span>- 이 PR이 하는 일 (1-3개 항목)</span></span>
<span class="line"><span></span></span>
<span class="line"><span>## Changes</span></span>
<span class="line"><span>- 주요 변경사항 목록</span></span>
<span class="line"><span></span></span>
<span class="line"><span>## Test Plan</span></span>
<span class="line"><span>- [ ] 단위 테스트 통과</span></span>
<span class="line"><span>- [ ] 통합 테스트 통과</span></span>
<span class="line"><span>- [ ] 수동 테스트 완료</span></span></code></pre></div><p>PR 제목은 컨벤셔널 커밋 형식: <code>feat(scope): description</code></p><h3 id="_3단계-ci-모니터링-루프" tabindex="-1">3단계: CI 모니터링 루프 <a class="header-anchor" href="#_3단계-ci-모니터링-루프" aria-label="Permalink to &quot;3단계: CI 모니터링 루프&quot;">​</a></h3><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>┌──────────────────────────────────────────────────┐</span></span>
<span class="line"><span>│              CI 모니터링 루프                      │</span></span>
<span class="line"><span>│                                                   │</span></span>
<span class="line"><span>│  CI 상태 확인 ──▶ 전체 통과? ──▶ 완료            │</span></span>
<span class="line"><span>│       │                 │                         │</span></span>
<span class="line"><span>│       │            아니오 (실패)                    │</span></span>
<span class="line"><span>│       │                 │                         │</span></span>
<span class="line"><span>│       │      ┌──────────▼──────────┐              │</span></span>
<span class="line"><span>│       │      │ 실패 진단          │              │</span></span>
<span class="line"><span>│       │      │ 이슈 수정          │              │</span></span>
<span class="line"><span>│       │      │ 수정 푸시          │              │</span></span>
<span class="line"><span>│       │      └──────────┬──────────┘              │</span></span>
<span class="line"><span>│       │                 │                         │</span></span>
<span class="line"><span>│       │          재시도 &lt; 5회?                     │</span></span>
<span class="line"><span>│       │         ├── 예 → 재확인                   │</span></span>
<span class="line"><span>│       │         └── 아니오 → 중단                  │</span></span>
<span class="line"><span>│       │                                           │</span></span>
<span class="line"><span>│       └── 대기중? 60초 후 재확인 (최대 10분)       │</span></span>
<span class="line"><span>└──────────────────────────────────────────────────┘</span></span></code></pre></div><p><strong>CI 실패 분류</strong>:</p><table tabindex="0"><thead><tr><th>분류</th><th>자동 수정</th><th>예시</th></tr></thead><tbody><tr><td>린트 에러</td><td>가능</td><td><code>npm run lint --fix</code></td></tr><tr><td>타입 에러</td><td>타입 수정</td><td>누락된 타입 어노테이션</td></tr><tr><td>테스트 실패</td><td>코드 수정</td><td>어서션 불일치</td></tr><tr><td>빌드 에러</td><td>빌드 수정</td><td>누락된 의존성</td></tr><tr><td>불안정 테스트</td><td>재실행</td><td><code>gh run rerun &lt;id&gt;</code></td></tr></tbody></table><h3 id="_4단계-리뷰-해결-루프" tabindex="-1">4단계: 리뷰 해결 루프 <a class="header-anchor" href="#_4단계-리뷰-해결-루프" aria-label="Permalink to &quot;4단계: 리뷰 해결 루프&quot;">​</a></h3><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>모든 리뷰 코멘트 읽기</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>분류 (버그/스타일/제안/질문)</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>모든 이슈를 단일 커밋으로 수정</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>푸시 및 리뷰 재요청</span></span>
<span class="line"><span>  ↓</span></span>
<span class="line"><span>반복 (최대 3회)</span></span></code></pre></div><p><strong>코멘트 우선순위</strong>:</p><table tabindex="0"><thead><tr><th>유형</th><th>우선순위</th><th>조치</th></tr></thead><tbody><tr><td>버그/로직 오류</td><td>크리티컬</td><td>즉시 수정</td></tr><tr><td>스타일/컨벤션</td><td>중간</td><td>제안 적용</td></tr><tr><td>제안/선택사항</td><td>낮음</td><td>평가 후 응답</td></tr><tr><td>질문</td><td>낮음</td><td>코멘트로 답변</td></tr></tbody></table><h3 id="_5단계-머지-정리" tabindex="-1">5단계: 머지 &amp; 정리 <a class="header-anchor" href="#_5단계-머지-정리" aria-label="Permalink to &quot;5단계: 머지 &amp; 정리&quot;">​</a></h3><ul><li>모든 CI 체크 통과 확인</li><li>리뷰 승인 확인</li><li>Squash 머지 및 브랜치 삭제</li><li>main 체크아웃 및 pull</li></ul><hr><h2 id="타임아웃-보호" tabindex="-1">타임아웃 보호 <a class="header-anchor" href="#타임아웃-보호" aria-label="Permalink to &quot;타임아웃 보호&quot;">​</a></h2><table tabindex="0"><thead><tr><th>파라미터</th><th>기본값</th><th>설명</th></tr></thead><tbody><tr><td>CI 대기 타임아웃</td><td>10분</td><td>CI 완료 대기 최대 시간</td></tr><tr><td>CI 재시도 횟수</td><td>5회</td><td>수정-재확인 최대 시도 횟수</td></tr><tr><td>폴링 간격</td><td>60초</td><td>CI 상태 확인 간격</td></tr><tr><td>리뷰 루프</td><td>3회</td><td>리뷰 해결 최대 횟수</td></tr></tbody></table><hr><h2 id="사용법" tabindex="-1">사용법 <a class="header-anchor" href="#사용법" aria-label="Permalink to &quot;사용법&quot;">​</a></h2><h3 id="슬래시-커맨드" tabindex="-1">슬래시 커맨드 <a class="header-anchor" href="#슬래시-커맨드" aria-label="Permalink to &quot;슬래시 커맨드&quot;">​</a></h3><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 기본 PR 라이프사이클 (squash 머지, main 브랜치)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:pr-lifecycle</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 커스텀 베이스 브랜치</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:pr-lifecycle</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --base</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> develop</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Draft PR</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:pr-lifecycle</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --draft</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 머지 커밋 (squash 대신)</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:pr-lifecycle</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --merge</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 머지 후 브랜치 유지</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">/kroot:pr-lifecycle</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> --no-delete-branch</span></span></code></pre></div><h3 id="커맨드-옵션" tabindex="-1">커맨드 옵션 <a class="header-anchor" href="#커맨드-옵션" aria-label="Permalink to &quot;커맨드 옵션&quot;">​</a></h3><table tabindex="0"><thead><tr><th>옵션</th><th>설명</th><th>기본값</th></tr></thead><tbody><tr><td><code>--base &lt;branch&gt;</code></td><td>PR의 베이스 브랜치</td><td>main</td></tr><tr><td><code>--squash</code></td><td>Squash 머지</td><td>true</td></tr><tr><td><code>--merge</code></td><td>머지 커밋</td><td>false</td></tr><tr><td><code>--no-delete-branch</code></td><td>머지 후 브랜치 유지</td><td>false</td></tr><tr><td><code>--draft</code></td><td>Draft PR로 생성</td><td>false</td></tr></tbody></table><h3 id="스킬로-사용" tabindex="-1">스킬로 사용 <a class="header-anchor" href="#스킬로-사용" aria-label="Permalink to &quot;스킬로 사용&quot;">​</a></h3><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>Skill(&quot;kroot-workflow-pr-lifecycle&quot;)</span></span></code></pre></div><hr><h2 id="관련-문서" tabindex="-1">관련 문서 <a class="header-anchor" href="#관련-문서" aria-label="Permalink to &quot;관련 문서&quot;">​</a></h2><ul><li><a href="./poc-first.html">POC-First 워크플로우</a> — Phase 5에서 이 스킬 사용</li><li><a href="./task-format.html">구조화된 태스크 포맷</a> — PR 태스크의 5필드 포맷</li><li><a href="./ralph-loop.html">Ralph Loop</a> — CI 수정 루프와 유사한 패턴</li><li><a href="./tdd-ddd.html">TDD &amp; DDD 워크플로우</a> — 대안 개발 방법론</li></ul>`,38)])])}const b=s(p,[["render",l]]);export{k as __pageData,b as default};
