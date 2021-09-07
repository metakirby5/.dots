// ==UserScript==
// @name         Facebook Messenger Shortcuts
// @author       metakirby5
// @match        https://www.messenger.com/*
// @icon         https://facebookbrand.com/wp-content/uploads/2020/10/Logo_Messenger_NewBlurple-399x399-1.png
// ==/UserScript==

(function() {
    'use strict';

    const ALL_MODS = ['ctrlKey', 'altKey', 'shiftKey', 'metaKey'];
    const KEY_MAP = [
        ['k', {'metaKey': true}, () => {
            document.querySelector('input[type="search"]').focus();
        }],
    ];

    document.addEventListener('keydown', e => {
        KEY_MAP.map(([key, mods, action]) => {
            if (e.key != key) {
                return;
            }

            for (const mod of ALL_MODS) {
                if (e[mod] !== !!mods[mod]) {
                    return;
                }
            }

            action();
        });
    });
})();