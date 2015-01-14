module.exports = (grunt) ->
    
    grunt.initConfig(
        pkg: grunt.file.readJSON "package.json"
        jade:
            build:
                expand: true
                cwd: "app/"
                src: ["*.jade"]
                dest: "app/"
                ext: ".html"
        coffee:
            build:
                expand: true
                cwd: "app/"
                src: ["*.coffee"]
                dest: "app/"
                ext: ".js"
        watch:
            coffee:
                files: ["app/*.coffee"]
                tasks: ["coffee:build"]
            jade:
                files: ["app/*.jade"]
                tasks: ["jade:build"]
    )
    
    grunt.loadNpmTasks "grunt-contrib-jade"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-watch"
    
    grunt.registerTask "build", ["jade:build", "coffee:build"]