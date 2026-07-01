/*
 * bev theme bootstrap (Bundes Corporate Design)
 * Loaded as /static/loader.js by the prebuilt Open WebUI shell.
 *
 * The rebrand image uses the prebuilt upstream frontend, whose compiled
 * theme logic only knows dark / light / oled-dark / her. This script
 * registers extra branded themes and keeps them in sync:
 *   - bev      : Farbtheme "Taubenblau"  (brand #286f9c)
 *   - bev-red  : Farbtheme "Rot" + AI coloring (brand #9e0529)
 *
 * It:
 *   1. Loads the Source Sans 3 web font (Bundes typeface).
 *   2. Adds each custom theme as an option in Settings -> Theme.
 *   3. Keeps <html> classes + meta theme-color in sync for the active
 *      custom theme (and cleans up its class when switching away).
 *   4. Fixes the FOUC from the upstream inline boot script on refresh.
 */
(function () {
	'use strict';

	var CUSTOM_THEMES = [
		{ id: 'bev', label: '🇦🇹 bev', brand: '#286f9c' },
		{ id: 'bev-red', label: '🇦🇹 bev · Rot', brand: '#9e0529' },
		{ id: 'bev-mono', label: '🇦🇹 bev · Mono', brand: '#000000' },
		{ id: 'bev-green', label: '🌿 bev · Green', brand: '#2d5a27' }
	];

	var html = document.documentElement;
	var ids = CUSTOM_THEMES.map(function (t) { return t.id; });

	function activeCustom() {
		return CUSTOM_THEMES.find(function (t) { return localStorage.theme === t.id; }) || null;
	}

	/* 1. Source Sans 3 (Bundes web typeface) ----------------------------- */
	(function loadFont() {
		if (document.getElementById('bev-font')) return;
		var head = document.head || html;
		var pre1 = document.createElement('link');
		pre1.rel = 'preconnect';
		pre1.href = 'https://fonts.googleapis.com';
		var pre2 = document.createElement('link');
		pre2.rel = 'preconnect';
		pre2.href = 'https://fonts.gstatic.com';
		pre2.crossOrigin = '';
		var f = document.createElement('link');
		f.id = 'bev-font';
		f.rel = 'stylesheet';
		f.href =
			'https://fonts.googleapis.com/css2?family=Source+Sans+3:ital,wght@0,400;0,600;0,700;1,400&display=swap';
		head.appendChild(pre1);
		head.appendChild(pre2);
		head.appendChild(f);
	})();

	/* 2. Sync <html> classes + meta for custom themes -------------------- *
	 * Re-entrancy guarded: toggling classes triggers the class observer,
	 * so we no-op when nothing actually needs to change. */
	var syncing = false;
	function sync() {
		if (syncing) return;
		syncing = true;
		try {
			var active = activeCustom();
			var changed = false;
			ids.forEach(function (id) {
				var want = !!active && active.id === id;
				if (html.classList.contains(id) !== want) {
					html.classList.toggle(id, want);
					changed = true;
				}
			});
			if (active) {
				if (!html.classList.contains('light')) {
					html.classList.add('light');
					changed = true;
				}
				if (html.classList.contains('dark')) {
					html.classList.remove('dark');
					changed = true;
				}
				var meta = document.querySelector('meta[name="theme-color"]');
				if (meta && meta.getAttribute('content') !== active.brand) {
					meta.setAttribute('content', active.brand);
				}
			}
		} finally {
			syncing = false;
		}
	}

	// Run as early as possible to correct the FOUC produced by the upstream
	// inline boot script (which falls back to `dark` for unknown themes).
	sync();

	// Re-sync whenever the upstream theme logic mutates <html> classes.
	new MutationObserver(sync).observe(html, { attributes: true, attributeFilter: ['class'] });

	/* 3. Inject the custom options into the Theme <select> --------------- *
	 * Only do work when a <select> is actually added to the DOM (e.g. the
	 * Settings panel opens), so we never scan the whole document during
	 * chat streaming. */
	function injectOptions(select) {
		if (!select || select.querySelector('option[value="oled-dark"]') === null) return;
		CUSTOM_THEMES.forEach(function (t) {
			if (select.querySelector('option[value="' + t.id + '"]')) return;
			var opt = document.createElement('option');
			opt.value = t.id;
			opt.textContent = t.label;
			select.appendChild(opt);
		});
		if (ids.indexOf(localStorage.theme) !== -1) {
			select.value = localStorage.theme;
		}
	}

	function nodeHasSelect(node) {
		if (node.nodeType !== 1) return false;
		return node.tagName === 'SELECT' || (node.querySelector && node.querySelector('select'));
	}

	function scanRoot() {
		var sels = document.querySelectorAll('select');
		for (var i = 0; i < sels.length; i++) {
			if (sels[i].querySelector('option[value="oled-dark"]')) injectOptions(sels[i]);
		}
	}

	// Initial pass (in case Settings is already open at load time).
	scanRoot();

	// Only react to <select> elements being added to the DOM.
	var scanTimer = null;
	function scheduleScan() {
		if (scanTimer) return;
		scanTimer = setTimeout(function () {
			scanTimer = null;
			scanRoot();
		}, 120);
	}

	new MutationObserver(function (records) {
		for (var i = 0; i < records.length; i++) {
			var added = records[i].addedNodes;
			for (var j = 0; j < added.length; j++) {
				if (nodeHasSelect(added[j])) {
					scheduleScan();
					return;
				}
			}
		}
	}).observe(document.body || html, { childList: true, subtree: true });

	/* 4. Inject bev-suggestions-grid class onto Suggestions list elements -- *
	 * The Docker rebrand uses the prebuilt upstream image, so Svelte source
	 * changes (className prop in Placeholder.svelte) are not compiled in.
	 * Instead, we inject the class at runtime so custom.css can style it. */
	function injectBlueprintGrid() {
		var lists = document.querySelectorAll('div[role="list"].items-start');
		for (var i = 0; i < lists.length; i++) {
			if (!lists[i].classList.contains('bev-suggestions-grid')) {
				lists[i].classList.add('bev-suggestions-grid');
			}
		}
	}

	// Run on load and whenever the chat area updates.
	injectBlueprintGrid();
	new MutationObserver(injectBlueprintGrid).observe(document.body || html, {
		childList: true,
		subtree: true
	});
})();