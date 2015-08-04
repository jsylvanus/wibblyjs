/*global module:false*/
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>',

	coffee : {
		dist : {
			files : [ {
				expand : true,
				flatten : true,
				cwd : 'src/',
				src : ['**/*.coffee'],
				dest : 'build/',
				ext : '.js'
			} ]
		}
	},

    concat : {
    	options : {
    		separator : ';'
    	},
    	dist : {
    		files : {
    			'dist/wibbly.js' : [
					'build/vector.js',
					'build/dimensions.js',
					'build/scalableBezier.js',
					'build/backgroundStrategy.js',
					'build/imageBackground.js',
					'build/solidBackground.js',
					'build/videoBackground.js',
					'build/wibblyElement.js'
	    		]
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

  // Tasks
  grunt.registerTask('default', ['coffee','concat']);
  grunt.registerTask('build', ['default','uglify'])
};