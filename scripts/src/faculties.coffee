plotChart = (container, data, label_func, href_func, label, value) ->
	chart = d3.select(container)
	header = chart.append("li")
		.attr("class", "header")
	header.append("a")
		.text(label)
	header.append("label")
		.text(value)
	bars = chart.selectAll("li.bar")
		.data(data.values)
			.enter().append("li")
			.attr("class", "bar")
	bars.append("span")
		.style("width", (d) -> parseInt(d.value) / data.max * 100 + "%")
		.append("a")
			.attr("href", href_func)
			.text(label_func)
	bars.append("label")
		.text((d) -> "$" + accounting.formatNumber(d.value))

plotFacultyAverage = ->
	d3.json("http://ubyssey.ca/wp-content/themes/theme/snippets/charts/salaries/faculty_average.json", (error, json) ->
		plotChart(
			'.faculty-average', 
			json, 
			(d) -> d.faculty,
			(d) -> "http://ubyssey.ca/salaries/search?faculty_id=" + d.id,
			'Faculty',
			'Average Salary'))

plotFacultyHighest = ->
	d3.json("http://ubyssey.ca/wp-content/themes/theme/snippets/charts/salaries/faculty_highest.json", (error, json) ->
		plotChart(
			'.faculty-highest', 
			json, 
			(d) -> d.employee + " (" + d.faculty + ")",
			(d) -> "http://ubyssey.ca/salaries/employee/" + d.url,
			'Employee',
			'Salary'))

plotFacultyAverage()
plotFacultyHighest()




