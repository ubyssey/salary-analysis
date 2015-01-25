module.exports = (grunt) ->
    
    # Build:
    # 1. CSS -> minified css
    # 2. Jade -> HTML (inlines the minified CSS into HTML output)
    # 3. Coffee -> JS -> minified JS -> concat d3-tip with chart code
    
    grunt.initConfig(
        pkg: grunt.file.readJSON "package.json"
        jade:
            build:
                expand: true
                cwd: "charts/src/"
                src: ["*.jade", "!search-filters.jade"]
                dest: "charts/"
                ext: ".html"
        cssmin:
            minify:
                expand: true
                cwd: "charts/src/"
                src: ["*.css"]
                dest: "charts/"
                ext: ".min.css"
        coffee:
            build:
                expand: true
                cwd: "scripts/src/"
                src: ["dept.coffee"]
                dest: "scripts/"
                ext: ".js"
        uglify:
            options:
                preserveComments: "some"
            minify:
                expand: true
                cwd: "scripts/"
                src: ["dept.js"]
                dest: "scripts/"
                ext: ".min.js"
            d3tip:
                files: "scripts/d3-tip.min.js": ["scripts/d3-tip.js"]
        concat:
            build:
                options:
                    separator: ";\n\n\n"
                src: ["scripts/d3-tip.min.js", "scripts/dept.min.js"]
                dest: "scripts/dept.concat.min.js"
        watch:
            cssmin:
                files: ["charts/src/*.css"]
                tasks: ["cssmin:minify"]
            coffee:
                files: ["scripts/src/*.coffee"]
                tasks: ["coffee:build"]
            jade:
                files: ["charts/src/*.jade", "charts/*.css"]
                tasks: ["jade:build"]
    )
    
    grunt.loadNpmTasks "grunt-contrib-jade"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-watch"
    grunt.loadNpmTasks "grunt-contrib-cssmin"
    grunt.loadNpmTasks "grunt-contrib-uglify"
    grunt.loadNpmTasks "grunt-contrib-concat"
    
    grunt.registerTask "build", ["cssmin:minify", "jade:build",
                                 "coffee:build", "uglify:minify", "concat:build"]