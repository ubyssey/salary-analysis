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
    )
    
    grunt.loadNpmTasks "grunt-contrib-jade"
    grunt.loadNpmTasks "grunt-contrib-coffee"