
debug = true
if not debug
    console.log = ->



search = ( (self) ->
    # This self-executing anonymous function allows for private and
    # public vars on the `search` object, which is passed in and
    # returned as `self`.
    
    # Dict of test predicates to apply to charts
    predicates = {}

    _search = ->
        results = d3.selectAll ".dot"
            .classed "searchresult", false
    
        if Object.keys(predicates).length is 0
            return
    
        results = results.filter (d, i) ->
            for own key, p of predicates
                if p and not p d, i
                    return false
            true
    
        results.classed "searchresult", true
        console.log results

    self.faculty_filter = (evt) ->
        fid = $(evt.currentTarget).val().split("fac")[1]
    
        if +fid is 0
            delete predicates.fac
        else
            predicates.fac = (d, i) ->
                d.faculty_id is fid
        _search()

    self.campus_filter = (evt) ->
        campuses = (i.name.split("-")[1] for i in $(evt.currentTarget).find "input:checked")

        d3.selectAll ".dot"
            .classed "hidden", false
            .filter (d, i) ->
                d.campus and d.campus not in campuses
            .classed "hidden", true

    self.text_search = (evt) ->
        if evt.type is "submit"
            evt.preventDefault()
        
        q = $(evt.currentTarget).find(".searchbar").val()
        q = q.trim().toLowerCase()
        
        if q is ""
            delete predicates.q
        else
            predicates.q = (d, i) ->
                haystack = d.dept_name or d.faculty_name
                -1 < haystack.toLowerCase().indexOf q
        _search()

    self
) {}



data_hooks = {}

fetch_data = (loader, uri, name) ->
    loader uri, (err, data) ->
        f err, data for f in data_hooks[name]
        return

chart_maker = (params) =>
    
    fmt_dollars = d3.format "$,.0f"
    apply_fmt = (xy, axis) ->
        fmt = params["fmt_" + xy]
        if fmt is "$"
            axis.tickFormat fmt_dollars
        else if fmt
            axis.tickFormat fmt
    
    # Return the following function
    (parentdiv) ->
        
        if params.title?
            $(parentdiv).append $("<h2/>").text params.title
        if params.subtitle?
            $(parentdiv).append $("<h3/>").text params.subtitle
        
        margin =
            top: 20
            right: 20
            bottom: 30
            left: 50
        width = $(parentdiv).width() - margin.left - margin.right
        height = (params.height or 500) - margin.top - margin.bottom
    
        x = d3.scale.linear()
            .range [0, width]
    
        y = d3.scale.linear()
            .range [height, 0]
    
        xAxis = d3.svg.axis()
            .scale x
            .orient "bottom"
        apply_fmt "x", xAxis
    
        yAxis = d3.svg.axis()
            .scale y
            .orient "left"
        apply_fmt "y", yAxis
    
        svg = d3.select parentdiv
            .append "svg"
            .attr "width", width + margin.left + margin.right
            .attr "height", height + margin.top + margin.bottom
          .append "g"
            .attr "transform", "translate(#{margin.left},#{margin.top})"
        
        tip = d3.tip()
            .attr "class", "d3-tip"
            .html params.tip
        svg.call tip
        
        data_hooks[params.src] = data_hooks[params.src] or []
        
        # This function will be called when the data is loaded.
        data_hooks[params.src].push (err, data) ->
            x.domain d3.extent data, params.d_x
            y.domain d3.extent data, params.d_y
        
            data = params.processor data if params.processor
        
            svg.append "g"
                .attr "class", "x axis"
                .attr "transform", "translate(0,#{height})"
                .call xAxis
              .append "text"
                .attr "class", "label"
                .attr "x", width
                .attr "y", -6
                .style "text-anchor", "end"
                .text params.label_x
    
            svg.append "g"
                .attr "class", "y axis"
                .call yAxis
              .append "text"
                .attr "class", "label"
                .attr "transform", "rotate(-90)"
                .attr "y", 6
                .attr "dy", ".71em"
                .style "text-anchor", "end"
                .text params.label_y
            
            switch typeof params.d_r
                when "function"
                    fr = d3.scale.linear()
                        .range [params.min_r or 2.5, params.max_r or 7]
                        .domain d3.extent data, params.d_r
                    r = (d) ->
                        fr params.d_r d
                when "number"
                    r = -> params.d_r
                else
                    r = 3.5
            
            if params.reference_line
                svg.append "path"
                    .datum d3.extent(data, params.d_x)
                    .attr "class", "reference-line"
                    .attr "d", (d3.svg.line()
                        .x (d) -> x d
                        .y (d) -> y d)
            
            if debug
                data.sort (a, b) ->
                    a.faculty_name.localeCompare b.faculty_name
            
            svg.selectAll ".dot"
                .data data
              .enter()
                .append "circle"
                .attr "class", "dot"
                .attr "r", r
                .attr "cx", (d) -> x params.d_x d
                .attr "cy", (d) -> y params.d_y d
                .on "mouseover", tip.show
                .on "mouseout", tip.hide
            
            if debug
                id_maker = (d) ->
                    `var reg = / /g;`   # would not compile properly in coffee, unsure why #todo
                    text = (d.dept_name or d.faculty_name).replace reg, "-"
                    prefix = d.faculty_name
                    "#{prefix}-dept-#{text}"
                
                svg.selectAll ".dot"
                    .attr "id", (d) -> id_maker d

uby_charts = ( (self) ->

    dept_tip = (d) ->
        r = "#{d.dept_name}"
        r += "<span> - ID##{d.dept_id}</span" if debug
        return r
    
    salary_mf_notnull = (data) ->
        (d for d in data when d.avg_salary_m isnt "NULL" and d.avg_salary_f isnt "NULL")
    
    self.departments =
        gender_salary: chart_maker(
            src: "dept"
            d_x: (d) -> +d.avg_salary_m
            d_y: (d) -> +d.avg_salary_f
            d_r: (d) -> +d.num_employees
            label_x: "MALE - Average Salary"
            label_y: "FEMALE - Average Salary"
            fmt_x: "$"
            fmt_y: "$"
            title: "Average Salary, Male vs Female, by Department"
            subtitle: "Reference line shows equality. Points are scaled by department size."
            processor: salary_mf_notnull
            tip: dept_tip
            reference_line: true
        )
        
        salary_expenses: chart_maker(
            src: "dept"
            d_x: (d) -> +d.avg_salary
            d_y: (d) -> +d.avg_expenses
            label_x: "Avg Salary"
            label_y: "Avg Expenses"
            fmt_x: "$"
            fmt_y: "$"
            title: "Avg Salary vs Expenses"
            tip: dept_tip
        )
    
    self.faculties =
        gender_salary: chart_maker(
            src: "fac"
            d_x: (d) -> +d.avg_salary_m
            d_y: (d) -> +d.avg_salary_f
            d_r: (d) -> +d.num_employees
            min_r: 4
            max_r: 9
            label_x: "MALE - Average Salary"
            label_y: "FEMALE - Average Salary"
            fmt_x: "$"
            fmt_y: "$"
            title: "Average Salary, Male vs Female, by Faculty"
            subtitle: "Reference line shows equality. Points are scaled by faculty size."
            processor: salary_mf_notnull
            ###
            processor: (data) ->
                for d in data
                    for a in ["m", "f"]
                        k = "avg_salary_#{a}"
                        d[k] = if d[k] is "NULL" then 0 else d[k]
                data
            ###
            height: 300
            tip: (d) ->
                # hacky but works for now
                d.dept_name = d.faculty_name
                d.dept_id = d.faculty_id
                dept_tip d
            reference_line: true
        )
    
    self
) {}


# Setup all charts, and then wait for data
uby_charts.departments.gender_salary "#deptchart"
uby_charts.departments.salary_expenses "#expenseschart"
uby_charts.faculties.gender_salary "#facchart"

# Fetch data sources and finish drawing each chart
# based on data_hooks callbacks
fetch_data d3.csv, "../data/departments.csv", "dept"
fetch_data d3.csv, "../data/faculties.csv", "fac"
# TODO change once uploaded to ubyssey wp site


d3.csv "../data/faculties_list.csv", (err, data) ->     # todo update link
    f = $("#facultyselector")
    
    data.unshift
        faculty_name: "(All Faculties)"
        faculty_id: 0
    
    ($("<option/>")
            .attr "value", "fac#{d.faculty_id}"
            .text d.faculty_name
            .appendTo f) for d in data

$("#searchform")
    .keyup search.text_search
    .submit search.text_search

$("#facultyselector")
    .change search.faculty_filter

$("#campuses")
    .change search.campus_filter
