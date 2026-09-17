/* ==========================================================================
   Minh N. T. Nguyen - personal site
   No dependencies. Every feature degrades gracefully if its node is missing.
   ========================================================================== */

(function () {
  'use strict';

  var root = document.documentElement;
  var $  = function (sel) { return document.querySelector(sel); };
  var $$ = function (sel) { return Array.prototype.slice.call(document.querySelectorAll(sel)); };

  /* ------------------------------------------------------------- theme */

  var toggle = $('#themeToggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) { /* private mode */ }
    });
  }

  // Follow the OS setting only while the visitor has not chosen for themselves.
  try {
    var mq = window.matchMedia('(prefers-color-scheme: dark)');
    var onSchemeChange = function (e) {
      var chosen = null;
      try { chosen = localStorage.getItem('theme'); } catch (err) { /* ignore */ }
      if (!chosen) root.setAttribute('data-theme', e.matches ? 'dark' : 'light');
    };
    if (mq.addEventListener) mq.addEventListener('change', onSchemeChange);
    else if (mq.addListener) mq.addListener(onSchemeChange);
  } catch (e) { /* matchMedia unavailable */ }

  /* -------------------------------------------- portrait with fallback */

  var portrait = $('#portraitImg');
  var fallback = $('#portraitFallback');
  if (portrait && fallback) {
    var showFallback = function () {
      portrait.hidden = true;
      fallback.hidden = false;
    };
    portrait.addEventListener('error', showFallback);
    // The error event may have fired before this script ran.
    if (portrait.complete && portrait.naturalWidth === 0) showFallback();
  }

  /* -------------------------------- scroll: progress, sticky nav, top */

  var progress = $('#progress');
  var nav      = $('#nav');
  var toTop    = $('#toTop');
  var ticking  = false;

  function onScroll() {
    var y = window.pageYOffset || root.scrollTop;
    var max = Math.max(1, root.scrollHeight - window.innerHeight);

    if (progress) progress.style.width = Math.min(100, (y / max) * 100) + '%';
    if (nav) nav.classList.toggle('is-stuck', y > 8);
    if (toTop) toTop.classList.toggle('is-visible', y > 600);

    spy(y);
    ticking = false;
  }

  window.addEventListener('scroll', function () {
    if (!ticking) {
      ticking = true;
      window.requestAnimationFrame(onScroll);
    }
  }, { passive: true });

  if (toTop) {
    toTop.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  /* ------------------------------------------------------- scrollspy */

  var links = $$('#navLinks a');
  var sections = links
    .map(function (a) { return document.getElementById(a.getAttribute('href').slice(1)); })
    .filter(Boolean);
  var activeId = null;

  function spy(y) {
    if (!sections.length) return;

    var offset = y + (nav ? nav.offsetHeight : 0) + 40;
    var current = null;

    for (var i = 0; i < sections.length; i++) {
      if (sections[i].offsetTop <= offset) current = sections[i].id;
    }

    // Once the page bottom is reached, the last section wins regardless of height.
    if (y + window.innerHeight >= root.scrollHeight - 4) {
      current = sections[sections.length - 1].id;
    }

    if (current === activeId) return;
    activeId = current;

    links.forEach(function (a) {
      a.classList.toggle('is-active', a.getAttribute('href') === '#' + current);
    });
  }

  /* --------------------------------------------- publication filtering */

  var pubs   = $$('#pubList .pub');
  var search = $('#pubSearch');
  var count  = $('#pubCount');
  var empty  = $('#pubEmpty');
  var chips  = $$('.chip[data-filter]');
  var activeFilter = 'all';

  // Cache the searchable text once instead of re-reading the DOM on every keystroke.
  var haystacks = pubs.map(function (li) {
    return li.textContent.toLowerCase().replace(/\s+/g, ' ');
  });

  function applyFilters() {
    var terms = (search ? search.value : '')
      .toLowerCase()
      .split(/\s+/)
      .filter(Boolean);

    var shown = 0;

    pubs.forEach(function (li, i) {
      var matchesType = activeFilter === 'all' || li.dataset.type === activeFilter;
      var matchesText = terms.every(function (t) { return haystacks[i].indexOf(t) !== -1; });
      var visible = matchesType && matchesText;

      li.hidden = !visible;
      if (visible) shown++;
    });

    if (count) {
      count.textContent = shown === pubs.length
        ? pubs.length + ' publications'
        : shown + ' of ' + pubs.length + ' publications';
    }
    if (empty) empty.hidden = shown !== 0;
  }

  if (search) {
    var timer;
    search.addEventListener('input', function () {
      clearTimeout(timer);
      timer = setTimeout(applyFilters, 110);
    });
  }

  chips.forEach(function (chip) {
    chip.addEventListener('click', function () {
      activeFilter = chip.dataset.filter;
      chips.forEach(function (c) {
        c.setAttribute('aria-pressed', String(c === chip));
      });
      applyFilters();
    });
  });

  /* ------------------------------------------------------------ misc */

  var year = $('#year');
  if (year) year.textContent = String(new Date().getFullYear());

  applyFilters();
  onScroll();
})();
