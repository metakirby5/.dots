module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 14,

    // font family with optional fallbacks
    fontFamily: 'Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',

    // terminal cursor background color (hex)
    cursorColor: '#eeeeea',

    // color of the text
    foregroundColor: '#eeeeea',

    // terminal background color
    backgroundColor: '#1b1b1b',

    // border color (window, tabs)
    borderColor: '#333',

    // custom css to embed in the main window
    css: '',

    // custom padding (css format, i.e.: `top right bottom left`)
    termCSS: '',

    // custom padding
    padding: '15px',

    // some color overrides. see http://bit.ly/29k1iU2 for
    // the full list
    colors: [
      '#343935',
      '#cc4061',
      '#7db660',
      '#e7b13b',
      '#509bd1',
      '#a481c1',
      '#34cbd4',
      '#eeeeea',
      '#525751',
      '#e7496e',
      '#8dcd6b',
      '#ffc440',
      '#5db1ef',
      '#ca9dee',
      '#3deffa',
      '#fbfaf7'
    ]
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hypersolar`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: ['hyper-vibrant'],

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []
};
