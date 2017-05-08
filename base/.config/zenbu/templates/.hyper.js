module.exports = {
  config: {
    fontSize: 14,
    fontFamily: 'Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',

    cursorColor: '{{ fgc }}',
    cursorShape: 'BLOCK',
    cursorBlink: false,

    foregroundColor: '{{ fgc }}',
    backgroundColor: '{{ bgc }}',
    borderColor: '{{ bgc }}',

    css: `
      .header_header {
        display: none;
      }
      .terms_terms {
        margin-top: {{ term_padding }}px;
      }
    `,

    padding: '{{ term_padding }}',

    colors: [
      '{{ n_black }}',
      '{{ n_red }}',
      '{{ n_green }}',
      '{{ n_yellow }}',
      '{{ n_blue }}',
      '{{ n_magenta }}',
      '{{ n_cyan }}',
      '{{ n_white }}',
      '{{ b_black }}',
      '{{ b_red }}',
      '{{ b_green }}',
      '{{ b_yellow }}',
      '{{ b_blue }}',
      '{{ b_magenta }}',
      '{{ b_cyan }}',
      '{{ b_white }}',
    ],

    shell: '/usr/local/bin/tmux',
    shellArgs: [],

    bell: false,

    modifierKeys: {
      altIsMeta: true,
    },
  },

  plugins: [],
  localPlugins: [],
};
