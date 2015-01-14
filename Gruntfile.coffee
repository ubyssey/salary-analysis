module.exports = (grunt) ->
    
    grunt.initConfig(
        pkg: grunt.file.readJSON "package.json"
        jade:
            build:
                expand: true
                cwd: "charts/src/"
                src: ["*.jade"]
                dest: "charts/"
                ext: ".html"
        coffee:
            build:
                expand: true
                cwd: "scripts/src/"
                src: ["dept.coffee"]
                dest: "scripts/"
                ext: ".js"
        watch:
            coffee:
                files: ["scripts/src/*.coffee"]
                tasks: ["coffee:build"]
            jade:
                files: ["charts/src/*.jade"]
                tasks: ["jade:build"]
    )
    
    grunt.loadNpmTasks "grunt-contrib-jade"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-watch"
    
    grunt.registerTask "build", ["jade:build", "coffee:build"]