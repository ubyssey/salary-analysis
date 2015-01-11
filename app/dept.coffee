
chart_maker = (params) ->
    params.dataloader ?= (f) ->
        d3.csv "departments.csv", f
    
    (parentdiv) ->
        
        fmt_dollars = d3.format "$,.0f"
        
        $(parentdiv).append $("<h2/>").text params.title
        
        margin =
            top: 20
            right: 20
            bottom: 30
            left: 50
        width = $(parentdiv).width() - margin.left - margin.right
        height = 500 - margin.top - margin.bottom
    
        x = d3.scale.linear()
            .range([0, width])
    
        y = d3.scale.linear()
            .range([height, 0])
    
        xAxis = d3.svg.axis()
            .scale x
            .orient "bottom"
        
        if params.fmt_x is "dollars"
            xAxis.tickFormat(fmt_dollars)
        else if params.fmt_x
            xAxis.tickFormat(params.fmt_x)
    
        yAxis = d3.svg.axis()
            .scale y
            .orient "left"
        
        if params.fmt_y is "dollars"
            yAxis.tickFormat(fmt_dollars)
        else if params.fmt_y
            yAxis.tickFormat(params.fmt_y)
    
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
        
            svg.selectAll ".dot"
                .data data
              .enter()
                .append "circle"
                .attr "class", "dot"
                .attr "r", 3.5
                .attr "cx", (d) -> x params.d_x d
                .attr "cy", (d) -> y params.d_y d
                .on "mouseover", tip.show
                .on "mouseout", tip.hide


dept_tip = (d) -> "#{d.dept_name} <span>- ID##{d.dept_id}</span"

draw_gender_salary_chart = chart_maker(
    d_x: (d) -> +d.avg_salary_m
    d_y: (d) -> +d.avg_salary_f
    label_x: "MALE - Average Salary"
    label_y: "FEMALE - Average Salary"
    fmt_x: "dollars"
    fmt_y: "dollars"
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
    fmt_x: "dollars"
    fmt_y: "dollars"
    title: "Avg Salary vs Expenses"
    tip: dept_tip
)


draw_gender_salary_chart "#deptchart"
draw_salary_expenses_chart "#expenseschart"