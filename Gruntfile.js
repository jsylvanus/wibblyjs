/*global module:false*/
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>',

    browserify : {
    	dist : {
    		options : {
    			browserifyOptions : {
    				extensions: '.coffee'
    			},
    			transform : ['coffeeify'],
    			expose : 'WibblyElement'
    		},
    		files : {
    			'dist/wibbly.js' : ['src/wibblyElement.coffee'],
    			'dist/wibblyTabs.js' : ['src/wibblyTabs.coffee']
    		}
    	}
    },

    uglify : {
    	dist : {
    		files : {
    			'dist/wibbly.min.js' : [ 'dist/wibbly.js' ]
    		}
    	}
    },

    watch: {
  		dist : {
  			files: ['src/**/*.coffee'],
  			tasks: ['default'],
			options: {
				livereload: true,
			}
  		}
    }

  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-coffeeify');
  grunt.loadNpmTasks('grunt-browserify');

  // Tasks
  grunt.registerTask('default', ['browserify']);
  grunt.registerTask('build', ['default','uglify'])
};
