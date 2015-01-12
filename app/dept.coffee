
debug = true
if not debug
    console.log = ->


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


faculty_search = (evt) ->
    fid = $(evt.currentTarget).val().split("fac")[1]
    
    if fid is "0"
        delete predicates.fac
    else
        predicates.fac = (d, i) ->
            d.faculty_id is fid
    _search()


campus_filter = (evt) ->
    campuses = (i.name.split("-")[1] for i in $(evt.currentTarget).find "input:checked")

    d3.selectAll ".dot"
        .classed "hidden", false
        .filter (d, i) ->
            d.dept_campus not in campuses
        .classed "hidden", true


search = (q) ->
    q = q.trim().toLowerCase()
        
    if q is ""
        delete predicates.q
    else
        predicates.q = (d, i) ->
            -1 < d.dept_name.toLowerCase().indexOf q
    _search()

searchWrapper = (evt) ->
    q = $(evt.currentTarget).find(".searchbar").val()
    search q
    
    if evt.type is "submit"
        evt.preventDefault()





data_hooks = []

fetch_data = (loader, uri, processor) ->
    loader uri, (err, data) ->
        data = processor data
        f err, data for f in data_hooks

chart_maker = (params) =>
    
    params.dataloader ?= (f) ->
        # f looks like (err, data) -> dosomething
        d3.csv "departments.csv", f
        data_hooks.push 
    
    fmt_dollars = d3.format "$,.0f"
    apply_fmt = (xy, axis) ->
        fmt = params["fmt_" + xy]
        if fmt is "$"
            axis.tickFormat fmt_dollars
        else if fmt
            axis.tickFormat fmt
    
    (parentdiv) ->
        
        if params.title?
            $(parentdiv).append $("<h2/>").text params.title
        
        margin =
            top: 20
            right: 20
            bottom: 30
            left: 50
        width = $(parentdiv).width() - margin.left - margin.right
        height = 500 - margin.top - margin.bottom
    
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
        
        if params.reference_line
            svg.append "path"
                .datum [0, 9999999]
                .attr "class", "reference-line"
                .attr "d", (d3.svg.line()
                    .x (d) -> d
                    .y (d) -> height - d)
        
        tip = d3.tip()
            .attr "class", "d3-tip"
            .html params.tip
        svg.call tip
        
        data_hooks.push (err, data) ->
            x.domain d3.extent data, params.d_x
            y.domain d3.extent data, params.d_y
        
            window.data = data
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
            
            if params.d_r?
                r = d3.scale.linear()
                    .range [2.5, 7]
                    .domain d3.extent data, params.d_r
            
            svg.selectAll ".dot"
                .data data
              .enter()
                .append "circle"
                .attr "class", "dot"
                .attr "r", if params.d_r? then ((d) -> r params.d_r d) else 3.5
                .attr "cx", (d) -> x params.d_x d
                .attr "cy", (d) -> y params.d_y d
                .on "mouseover", tip.show
                .on "mouseout", tip.hide


dept_tip = (d) -> "#{d.dept_name} <span>- ID##{d.dept_id}</span"

draw_gender_salary_chart = chart_maker(
    d_x: (d) -> +d.avg_salary_m
    d_y: (d) -> +d.avg_salary_f
    d_r: (d) -> +d.num_employees
    label_x: "MALE - Average Salary"
    label_y: "FEMALE - Average Salary"
    fmt_x: "$"
    fmt_y: "$"
    title: "Avg Salary, Male vs Female"
    processor: (data) -> (d for d in data when d.avg_salary_m isnt "NULL" and d.avg_salary_f isnt "NULL")
    tip: dept_tip
    reference_line: true
)

draw_salary_expenses_chart = chart_maker(
    d_x: (d) -> +d.avg_salary
    d_y: (d) -> +d.avg_expenses
    label_x: "Avg Salary"
    label_y: "Avg Expenses"
    fmt_x: "$"
    fmt_y: "$"
    title: "Avg Salary vs Expenses"
    tip: dept_tip
)

fetch_data d3.csv, "departments.csv", (data) ->
    d3.csv "faculties_list.csv", (err, data) ->
        f = $("#facultyselector")
        
        data.unshift
            faculty_name: "(All Faculties)"
            faculty_id: 0
        
        ($("<option/>")
                .attr "value", "fac#{d.faculty_id}"
                .text d.faculty_name
                .appendTo f) for d in data
    
    data
    #todo +d....

draw_gender_salary_chart "#deptchart"
draw_salary_expenses_chart "#expenseschart"

$("#searchform")
    .keyup searchWrapper
    .submit searchWrapper

$("#facultyselector")
    .change faculty_search

$("#campuses")
    .change campus_filter
