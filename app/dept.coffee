
search = (q) ->
    
    d3.selectAll ".dot"
        .classed "searchresult", false
    
    if q is ""
        return
    
    q = q.trim().toLowerCase()
    
    results = d3.selectAll ".dot"
        .filter (d, i) ->
            -1 < d.dept_name.toLowerCase().indexOf q
    
    results.classed "searchresult", true
    
    console.log results

searchWrapper = (evt) ->
    q = $(evt.currentTarget).find(".searchbar").val()
    search q
    
    if evt.type is "submit"
        evt.preventDefault()




chart_maker = (params) ->
    
    params.dataloader ?= (f) ->
        # f looks like (err, data) -> dosomething
        d3.csv "departments.csv", f
    
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
        
        params.dataloader (err, data) ->
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

###
Todo: Differentiate dots (colour) by campus or faculty, provide
      filters to show only certain facs.
###


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


draw_gender_salary_chart "#deptchart"
draw_salary_expenses_chart "#expenseschart"

$("#searchform")
    .keyup searchWrapper
    .submit searchWrapper
