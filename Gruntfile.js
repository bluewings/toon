/*jslint regexp: true */
'use strict';

module.exports = function (grunt) {

  var _, localConfig, hashCode, yeoman;

  _ = require('lodash');

  try {
    localConfig = require('./server/local.env');
  } catch (_err) {
    localConfig = {};
  }

  hashCode = function(str) {
    var base16, base36, chr, hash, i, len;
    hash = 0;
    if (typeof str === 'object' && str !== null) {
      str = JSON.stringify(str);
    }
    if (str.length === 0) {
      return hash;
    }
    i = 0;
    len = str.length;
    while (i < len) {
      chr = str.charCodeAt(i);
      hash = (hash << 5) - hash + chr;
      hash |= 0;
      i++;
    }
    base16 = hash.toString(16).replace(/[^a-z0-9]/g, '');
    base36 = hash.toString(36).replace(/[^a-z0-9]/g, '');
    hash = (parseInt(base16.substr(0, 1), 16) + 10).toString(36) + base36;
    console.log(str, hash)
    return hash;
  };

  // Configurable paths for the application
  yeoman = {
    client: 'public',
    dist: 'dist'
  };

  yeoman.srcpath = {
    jade: {
      cwd: yeoman.client,
      src: [
        '*.jade',
        '**/*.jade',
        '!bower_components/**/*.jade'
      ]
    },
    sass: {
      src: yeoman.client + '/app/app.scss'
    },
    less: {
      cwd: yeoman.client,
      src: ['bower_components/bootstrap/less/*.less']
    },
    coffee: {
      cwd: yeoman.client,
      src: [
        '*.coffee',
        '**/*.coffee',
        '!{,*/}*.{spec,mock}.coffee',
        '!bower_components/**/*.coffee'
      ]
    },
    copyOverride: {
      cwd: yeoman.client + '/overrides',
      src: ['bootstrap/**/*']
    },
    injectTheme: {
      src: [
        yeoman.client + '/app/styles/themes/*.scss',
        '!' + yeoman.client + '/app/styles/themes/*.*.scss'
      ]
    },
    injectSass: {
      src: [
        yeoman.client + '/app/**/{app,style}.scss',
        yeoman.client + '/app/**/*.scss',
        '!' + yeoman.client + '/app/*.scss',
        '!' + yeoman.client + '/app/**/customize.*.scss',
        '!' + yeoman.client + '/app/styles/**/*.scss',
        // '!' + yeoman.client + '/app/styles/themes/*.scss',
        // '!' + yeoman.client + '/app/styles/themes/**/*.scss',
        '!' + yeoman.client + '/app/_trashcan/**/*.scss'
      ]
    },
    themeSass: {
      src: [
        yeoman.client + '/app/*.scss',
        // yeoman.client + '/app/styles/themes/*.scss',
        // yeoman.client + '/app/styles/themes/**/*.scss'
        yeoman.client + '/app/styles/**/*.scss'
      ]
    },
    customizeSass: {
      src: [
        yeoman.client + '/app/**/customize.*.scss'
      ]
    },
    injectJS: {
      src: [
        '.tmp/app/config.js',
        '.tmp/app/app.js',
        '.tmp/app/**/app.js',
        '.tmp/app/**/*.js',
        '!.tmp/app/{,*/}*.{spec,mock}.js',
        yeoman.client + '/assets/**/*.js'
        // 'tmp/app/config.js',
        // 'tmp/app/app.js',
        // 'tmp/app/**/app.js',
        // 'tmp/app/**/*.js',
        // '!tmp/app/{,*/}*.{spec,mock}.js',
      ]
    },
    injectCss: {
      src: [
        '.tmp/app/*.css',
        '.tmp/app/**/*.css'
      ]
    }
  };

  function generateFiles(data) {
    var cwd, file, i, len, src;
    data.files = [];
    if (!data.src) {
      return;
    }
    src = typeof data.src === 'string' ? [data.src] : data.src;
    if (data.cwd) {
      cwd = data.cwd + '/';
    } else {
      cwd = '';
    }
    for (i = 0, len = src.length; i < len; i++) {
      file = src[i];
      data.files.push(file.replace(/^([!]{0,1})/, '$1' + cwd));
    }
  }

  Object.keys(yeoman.srcpath).forEach(function (name) {
    generateFiles(yeoman.srcpath[name]);
  });

  // Load grunt tasks automatically, when needed
  require('jit-grunt')(grunt, {
    express: 'grunt-express-server',
    useminPrepare: 'grunt-usemin',
    ngtemplates: 'grunt-angular-templates',
    ngconstant: 'grunt-ng-constant',
    injector: 'grunt-asset-injector',
    i18nextract: 'grunt-angular-translate'
  });

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Project settings
    yeoman: yeoman,

    env: {
      test: {
        NODE_ENV: 'test'
      },
      prod: {
        NODE_ENV: 'production'
      },
      all: localConfig
    },

    express: {
      options: {
        port: process.env.PORT || 8010
      },
      dev: {
        options: {
          opts: ['node_modules/coffee-script/bin/coffee'],
          // script: 'server/app.js',
          script: 'server/app.coffee',
          debug: true
        }
      },
      dev2: {
        options: {
          port: 8010,
          opts: ['node_modules/coffee-script/bin/coffee'],
          // script: 'server/app.js',
          script: 'server/app.coffee',
          debug: true
        }
      },
      prod: {
        options: {
          script: 'dist/server/app.js'
        }
      }
    },

    open: {
      server: {
        url: 'http://127.0.0.1:<%= express.options.port %>',
        app: process.platform.search(/^win/i) !== -1 ? 'Chrome' : 'Google Chrome'
      }
    },

    watch: {
      jade: {
        files: yeoman.srcpath.jade.files,
        tasks: ['newer:jade']
      },
      sass: {
        files: _.flatten([
          yeoman.srcpath.injectSass.files,
          yeoman.srcpath.customizeSass.files,
          yeoman.srcpath.themeSass.files,
          yeoman.srcpath.sass.files
        ]),
        tasks: ['sass', 'autoprefixer']
      },
      less: {
        files: yeoman.srcpath.less.files,
        tasks: ['less']
      },
      coffee: {
        files: yeoman.srcpath.coffee.files,
        tasks: ['newer:coffee']
      },
      tooltipextract: {
        files: ['.tmp/app/**/*.html', '.tmp/app/**/*.js'],
        tasks: ['tooltipextract']
      },
      i18nextract: {
        files: ['.tmp/app/**/*.html', '.tmp/app/**/*.js', '<%= yeoman.client %>/assets/json/tooltip.json'],
        tasks: ['i18nextract']
      },
      copyOverride: {
        files: yeoman.srcpath.copyOverride.files,
        tasks: ['copy:override']
      },
      injectJS: {
        files: yeoman.srcpath.injectJS.files,
        tasks: ['injector:scripts']
      },
      injectTheme: {
        files: yeoman.srcpath.injectTheme.files,
        tasks: ['injector:theme']
      },
      injectSass: {
        files: _.flatten([
          yeoman.srcpath.injectSass.files, [yeoman.client + '/app/app.scss']
        ]),
        tasks: ['injector:sass']
      },
      injectCss: {
        files: yeoman.srcpath.injectCss.files,
        tasks: ['injector:css']
      },
      injectAll: {
        files: ['.tmp/index.html'],
        tasks: ['injector:scripts', 'injector:css', 'wiredep']
      },
      livereload: {
        files: [
          '{.tmp,<%= yeoman.client %>}/app/**/*.css',
          '{.tmp,<%= yeoman.client %>}/app/**/*.html',
          '{.tmp,<%= yeoman.client %>}/app/**/*.js',
          '!{.tmp,<%= yeoman.client %>}app/**/*.spec.js',
          '!{.tmp,<%= yeoman.client %>}/app/**/*.mock.js',
          '<%= yeoman.client %>/assets/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ],
        options: {
          livereload: 35299
        }
      }
    },

    // Empties folders to start fresh
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/*'
          ]
        }]
      },
      server: '.tmp'
    },

    injector: {

      // Inject theme scss into app.scss
      theme: {
        options: {
          transform: function (filePath) {
            var lines, theme, themeClass;
            lines = [];
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/app/', '');
            theme = filePath.split('/').pop().replace(/\.scss$/, '');
            themeClass = 't' + hashCode('theme-' + theme);
            lines.push('/* theme-' + theme + ' */');
            lines.push('.' + themeClass + ' {');
            // lines.push('    @import "app.config.scss";');
            lines.push('    @import "' + filePath.replace(/\.scss/, '.config.scss') + '";');
            lines.push('    // injector');
            lines.push('    // endinjector');
            lines.push('    @import "' + filePath.replace(/\.scss/, '.config.scss') + '";');
            lines.push('    @import "' + filePath + '";');
            lines.push('}');
            lines.push('');
            return lines.join('\n');
          },
          starttag: '// themeinjector',
          endtag: '// endthemeinjector'
        },
        files: {
          '<%= yeoman.client %>/app/app.scss': yeoman.srcpath.injectTheme.src
        }
      },

      // Inject component scss into app.scss
      sass: {
        options: {
          transform: function (filePath) {
            var lines;
            // hashCode
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/app/', '');
            // console.log(hashCode(filePath.replace(/\.scss$/, '')));
            lines = [];
            lines.push('.' + hashCode(filePath.replace(/\.scss$/, '')) + ' {');
            lines.push('    @import "' + filePath + '";');
            lines.push('}');
            lines.push('');
            console.log(lines);
            return lines.join('\n');


            // return '@import "' + filePath + '";';
          },





          starttag: '// injector',
          endtag: '// endinjector'
        },
        files: {
          '<%= yeoman.client %>/app/app.scss': yeoman.srcpath.injectSass.src
        }
      },

      // Inject application script files into index.html (doesn't include bower)
      scripts: {
        options: {
          transform: function (filePath) {
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/', '');
            filePath = filePath.replace('/.tmp/', '');
            return '<script src="' + filePath + '"></script>';
          },
          starttag: '<!-- injector:js -->',
          endtag: '<!-- endinjector -->'
        },
        files: {
          '.tmp/index.html': yeoman.srcpath.injectJS.src
        }
      },

      // Inject component css into index.html
      css: {
        options: {
          transform: function (filePath) {
            filePath = filePath.replace('/' + grunt.config('yeoman.client') + '/', '');
            filePath = filePath.replace('/.tmp/', '');
            return '<link rel="stylesheet" href="' + filePath + '">';
          },
          starttag: '<!-- injector:css -->',
          endtag: '<!-- endinjector -->'
        },
        files: {
          '.tmp/index.html': yeoman.srcpath.injectCss.src
        }
      }
    },

    // Compiles Jade to html
    jade: {
      compile: {
        options: {
          data: {
            debug: false
          },
          pretty: true
        },
        files: [{
          expand: true,
          cwd: yeoman.srcpath.jade.cwd,
          src: yeoman.srcpath.jade.src,
          dest: '.tmp',
          ext: '.html',
          extDot: 'last'
        }]
      }
    },

    // Compiles Sass to CSS
    sass: {
      compile: {
        options: {
          compass: false
        },
        files: {
          '.tmp/app/app.css': yeoman.srcpath.sass.src
        }
      }
    },

    // Compiles less to CSS (bootstrao only)
    less: {
      compile: {
        files: {
          'public/bower_components/bootstrap/dist/css/bootstrap.css': yeoman.client + '/bower_components/bootstrap/less/bootstrap.less'
        }
      }
    },

    // Compiles CoffeeScript to JavaScript
    coffee: {
      compile: {
        options: {
          sourceMap: true
        },
        files: [{
          expand: true,
          cwd: yeoman.srcpath.coffee.cwd,
          src: yeoman.srcpath.coffee.src,
          dest: '.tmp',
          ext: '.js',
          extDot: 'last'
        }]
      }
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      server: [
        'jade',
        'sass',
        'less',
        'coffee'
      ],
      dist: [
        'jade',
        'sass',
        'less',
        'coffee'
      ]
    },

    // Extract all the tooltip keys for tooltip directive
    tooltipextract: {
      default_options: {
        src: [
          '.tmp/app/**/*.html', '.tmp/app/index.html', '.tmp/app/**/*.js'
        ],
        dest: '<%= yeoman.client %>/assets/json/tooltip.json'
      }
    },

    // Extract all the translation keys for angular-translate
    i18nextract: {
      default_options: {
        nullEmpty: false,
        namespace: true,
        safeMode: false,
        stringifyOptions: {
          space: 2
        },
        customRegex: [
          'translationId\\s*:\\s*\'(([a-zA-Z0-9\\.\\_\\-])+)\'',
          '"translationId"\\s*:\\s*"(([a-zA-Z0-9\\.\\_\\-])+)"',
          '"titleTranslationId"\\s*:\\s*"(([a-zA-Z0-9\\.\\_\\-])+)"',
          '{{{translate\\s+\'(([a-zA-Z0-9\\.\\_\\-])+)\'\\s*}}}',
          '{{{translate\\s+"(([a-zA-Z0-9\\.\\_\\-])+)"\\s*}}}'
        ],
        prefix: 'locale-',
        suffix: '.json',
        src: [
          '.tmp/app/**/*.html', '.tmp/app/index.html', '.tmp/app/**/*.js', '<%= yeoman.client %>/assets/json/tooltip.json',
          '!.tmp/app/**/*.decorator.html'
        ],
        lang: ['ko-KR', 'en-US', 'ja-JP'],
        dest: '<%= yeoman.client %>/assets/i18n'
      }
    },

    // Automatically inject Bower components into the app
    wiredep: {
      target: {
        overrides: {
          // see `Bower Overrides` section below.
          //
          // This inline object offers another way to define your overrides if
          // modifying your project's `bower.json` isn't an option.
          bootstrap: {
            main: ['dist/css/bootstrap.css', 'dist/js/bootstrap.js']
          },
          'bootswatch-dist': {
            main: ['css/bootstrap.css']
          },
          'angular-jquery': {
            main: ['dist/angular-jquery.js']
          },
          'font-awesome': {
            main: ['css/font-awesome.css']
          },
          'highlight-js': {
            main: ['src/highlight.js', 'src/styles/monokai-sublime.css']
          },
          moment: {
            main: ['moment.js', 'locale/ko.js', 'locale/en.js', 'locale/ja.js']
          },
          trianglify: {
            main: ['dist/trianglify.min.js']
          },
          geopattern: {
            main: ['js/geopattern.min.js']
          }
        },
        src: '.tmp/index.html',
        ignorePath: '../<%= yeoman.client %>/'
      }
    },

    // Add vendor prefixed styles
    autoprefixer: {
      options: {
        browsers: ['last 3 versions', 'ie 8', 'ie 9']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/',
          src: '{,*/}*.css',
          dest: '.tmp/'
        }]
      }
    },

    htmlmin: {
      dist: {
        options: {
          collapseWhitespace: true,
          conservativeCollapse: true,
          collapseBooleanAttributes: true,
          removeCommentsFromCDATA: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: ['*.html', '{,*/}*.html'],
          dest: '<%= yeoman.dist %>'
        }]
      }
    },

    // http://stackoverflow.com/questions/16339595/how-do-i-configure-different-environments-in-angular-js
    ngconstant: {
      options: {
        name: 'config',
        dest: '.tmp/app/config.js'
      },
      dev: {
        constants: function () {
          return {
            config: grunt.file.readJSON('./public/config/config.dev.json')
          };
        }
      },
      test: {
        constants: function () {
          return {
            config: grunt.file.readJSON('./public/config/config.test.json')
          };
        }
      },
      prod: {
        constants: function () {
          return {
            config: grunt.file.readJSON('./public/config/config.release.json')
          };
        }
      },
    },

    // Package all the html partials into a single javascript payload
    ngtemplates: {
      options: {
        // This should be the name of your apps angular module
        module: 'james',
        htmlmin: {
          collapseBooleanAttributes: true,
          collapseWhitespace: true,
          removeAttributeQuotes: true,
          removeEmptyAttributes: true,
          removeRedundantAttributes: true,
          removeScriptTypeAttributes: true,
          removeStyleLinkTypeAttributes: true
        },
        usemin: 'app/app.js'
      },
      main: {
        cwd: '.tmp',
        src: [
          'app/*.html',
          'app/**/*.html'
        ],
        dest: '.tmp/templates.js'
      }
    },

    // Allow the use of non-minsafe AngularJS files. Automatically makes it
    // minsafe compatible so Uglify does not destroy the ng references
    ngAnnotate: {
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/concat',
          src: '*/**.js',
          dest: '.tmp/concat'
        }]
      }
    },

    // Copies remaining files to places other tasks can use
    copy: {
      override: {
        files: [{
          expand: true,
          dot: true,
          cwd: yeoman.srcpath.copyOverride.cwd,
          src: yeoman.srcpath.copyOverride.src,
          dest: '<%= yeoman.client %>/bower_components'
        }]
      },
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.client %>',
          dest: '<%= yeoman.dist %>/public',
          src: [
            '*.{ico,png,txt}',
            '.htaccess',
            'assets/css/{,*/}*',
            'assets/img/{,*/}*',
            'assets/i18n/{,*/}*',
            'assets/json/{,*/}*',
            'fonts/**/*'
          ]
        }, {
          expand: true,
          cwd: '<%= yeoman.client %>/bower_components/font-awesome',
          dest: '<%= yeoman.dist %>/public',
          src: ['fonts/*']
        }, {
          expand: true,
          cwd: '<%= yeoman.client %>/bower_components/pixeden-stroke-7-icon/pe-icon-7-stroke',
          dest: '<%= yeoman.dist %>/public',
          src: ['fonts/*']
        }, {
          expand: true,
          cwd: '.tmp',
          dest: '<%= yeoman.dist %>/public',
          src: ['index.html']
        }, {
          expand: true,
          dest: '<%= yeoman.dist %>',
          src: [
            'package.json',
            'server/**/*'
          ]
        }]
      }
    },

    // Renames files for browser caching purposes
    filerev: {
      dist: {
        src: [
          '<%= yeoman.dist %>/public/{,*/}*.{js,css}'
        ]
      }
    },

    // Reads HTML for usemin blocks to enable smart builds that automatically
    // concat, minify and revision files. Creates configurations in memory so
    // additional tasks can operate on them
    useminPrepare: {
      html: ['.tmp/index.html'],
      options: {
        dest: '<%= yeoman.dist %>/public'
      }
    },

    // Performs rewrites based on rev and the useminPrepare configuration
    usemin: {
      html: ['<%= yeoman.dist %>/public/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/public/{,*/}*.css'],
      js: ['<%= yeoman.dist %>/public/{,*/}*.js'],
      options: {
        assetsDirs: ['<%= yeoman.dist %>/public']
      }
    },

    // Generate manifest file for offline app cache
    manifest: {
      prod: {
        options: {
          network: ['*'],
          // fallback: ['/ /offline.html'],
          // preferOnline: true,
          verbose: true,
          timestamp: true
        },
        cwd: './<%= yeoman.dist %>/public',
        src: ['*.html', '{app,assets,fonts}/**/*.{js,css,woff}'],
        dest: './<%= yeoman.dist %>/public/manifest.appcache'
      }
    },

    // Change html tag manifest attribute for offline appcache
    replace: {
      overrideAngularTranslate: {
        options: {
          patterns: [{
            match: /(\(\s*translation\s*,\s*interpolateParams\s*)\)/g,
            replacement: '$1, translationId)'
          }]
        },
        files: {
          '<%= yeoman.client %>/bower_components/angular-translate/angular-translate.js': '<%= yeoman.client %>/bower_components/angular-translate/angular-translate.js'
        }
      },
      prod: {
        options: {
          patterns: [{
            match: /<(html)>/i,
            replacement: '<$1 manifest="manifest.appcache">'
          }]
        },
        files: {
          './<%= yeoman.dist %>/public/index.html': './<%= yeoman.dist %>/public/index.html'
        }
      }
    },

    forever: {
      server: {
        options: {
          command: 'coffee',
          index: 'server/app.coffee'
        }
      }
    }
  });

  // Used for delaying livereload until after server has restarted
  grunt.registerTask('wait', function () {
    var done;
    grunt.log.ok('Waiting for server reload...');
    done = this.async();
    setTimeout(function () {
      grunt.log.writeln('Done waiting!');
      done();
    }, 1500);
  });

  grunt.registerTask('express-keepalive', 'Keep grunt running', function () {
    this.async();
  });

  grunt.registerTask('serve', 'Compile then start a connect web server', function (target) {
    if (target === 'dist') {
      return grunt.task.run([
        'build',
        'env:all',
        'env:prod',
        'express:prod',
        'wait',
        'open',
        'express-keepalive'
      ]);
    }

    if (target === 'content') {
      return grunt.task.run([
        'clean:server',
        'copy:override',
        'replace:overrideAngularTranslate',
        'env:all',
        'ngconstant:dev',
        'injector:theme',
        'injector:sass',
        'concurrent:server',
        'tooltipextract',
        'i18nextract',
        'injector',
        'wiredep',
        'autoprefixer',
        'express:dev',
        'wait',
	'forever'
      ]);
    }

    grunt.task.run([
      'clean:server',
      'copy:override',
      'replace:overrideAngularTranslate',
      'env:all',
      'ngconstant:dev',
      'injector:theme',
      'injector:sass',
      'concurrent:server',
      'tooltipextract',
      'i18nextract',
      'injector',
      'wiredep',
      'autoprefixer',
      'express:dev',
      'wait',
      'open',
      'watch'
    ]);
  });

  grunt.registerTask('build', 'Build application for deployment', function (target) {
    if (target === 'test') {
      return grunt.task.run([
        'clean:dist',
        'copy:override',
        'ngconstant:test',
        'injector:theme',
        'injector:sass',
        'concurrent:dist',
        'injector',
        'wiredep',
        'useminPrepare',
        'autoprefixer',
        'ngtemplates',
        'concat',
        'ngAnnotate',
        'copy:dist',
        'cssmin',
        'uglify',
        'filerev',
        'usemin',
        'htmlmin',
        'manifest',
        'replace'
      ]);
    }

    grunt.task.run([
      'clean:dist',
      'copy:override',
      'ngconstant:prod',
      'injector:theme',
      'injector:sass',
      'concurrent:dist',
      'injector',
      'wiredep',
      'useminPrepare',
      'autoprefixer',
      'ngtemplates',
      'concat',
      'ngAnnotate',
      'copy:dist',
      'cssmin',
      'uglify',
      'filerev',
      'usemin',
      'htmlmin',
      'manifest',
      'replace'
    ]);
  });

  grunt.registerMultiTask('tooltipextract', 'Generate json tooltip definition file for tooltip directive', function () {
    var _file, _log, after, append, before, destFilename, files, i, len, newTooltips, regex, regexs, regexPatterns, tooltipId, tooltipIds, tooltips;
    _log = grunt.log;
    _file = grunt.file;
    if (!Array.isArray(this.data.src)) {
      grunt.fail('src is required.');
    }
    if (!this.data.dest) {
      grunt.fail('dest is required.');
    }
    files = _file.expand(this.data.src);
    destFilename = this.data.dest;
    if (_file.exists(destFilename)) {
      tooltips = _file.readJSON(destFilename);
    }
    if (!tooltips || typeof tooltips !== 'object') {
      tooltips = {};
    }
    before = JSON.stringify(tooltips);
    append = function (tree) {
      if (!tooltips[tree]) {
        tooltips[tree] = {
          translationId: 'TOOLTIP.' + tree,
          align: ''
        };
      }
      tooltips[tree]._found = true;
    };
    regexPatterns = [
      '<tooltip\\s+[^>]*tooltip-id=[\'"]([a-zA-Z0-9\\_\\.]+)[\'"][^>]*>',
      'tooltip\\s*:\\s*[\'"]([a-zA-Z0-9\\_\\.]+)[\'"]',
    ];
    regexs = [];
    for (i = 0, len = regexPatterns.length; i < len; i++) {
      regex = regexPatterns[i];
      regexs.push({
        find: new RegExp(regex, 'ig'),
        match: new RegExp(regex, 'i')
      });
    }
    files.forEach(function (file) {
      var content, found, j, k, len1, len2, matched, results;
      _log.debug('Process file: ' + file);
      for (j = 0, len1 = regexs.length; j < len1; j++) {
        regex = regexs[j];
        content = _file.read(file);
        results = content.match(regex.find);
        if (results) {
          for (k = 0, len2 = results.length; k < len2; k++) {
            found = results[k];
            matched = found.match(regex.match);
            if (matched && matched.length > 1) {
              append(matched[1], tooltips);
            }
          }
        }
      }
    });
    for (tooltipId in tooltips) {
      tooltipId = tooltipId;
      tooltipId = tooltipId;
      if (tooltips.hasOwnProperty(tooltipId) && !tooltips[tooltipId]._found) {
        delete tooltips[tooltipId];
      } else {
        delete tooltips[tooltipId]._found;
      }
    }
    tooltipIds = Object.keys(tooltips);
    tooltipIds.sort();
    newTooltips = {};
    while (tooltipId = tooltipIds.shift()) {
      newTooltips[tooltipId] = tooltips[tooltipId];
    }
    after = JSON.stringify(newTooltips);
    if (before !== after) {
      _file.write(destFilename, JSON.stringify(newTooltips, null, 2));
    }
  });
};
