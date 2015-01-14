f_avg = {
	values: [{"value": 189693.2216, "faculty": "Sauder"}, {"value": 171984.6735, "faculty": "Law"}, {"value": 165811.0, "faculty": "Faculty of Health"}, {"value": 143282.2795, "faculty": "Medicine"}, {"value": 142148.75, "faculty": "Faculty of Management"}, {"value": 139202.6858, "faculty": "Engineering"}, {"value": 138648.2105, "faculty": "Dentistry"}, {"value": 134751.3113, "faculty": "Science"}, {"value": 133429.7536, "faculty": "Forestry"}, {"value": 130680.4857, "faculty": "Education"}, {"value": 129893.2677, "faculty": "Arts"}, {"value": 127244.2979, "faculty": "Land and Food Systems"}, {"value": 116850.9648, "faculty": "Barber Arts and Sciences"}, {"value": 116129.2, "faculty": "Health and Social Development"}, {"value": 111593.4615, "faculty": "Creative Studies"}, {"value": 106706.9459, "faculty": " Creative and Critical Studies"}]
	max: 189693
}

f_highest = {
	values: [{"employee": "Gavin Stuart", "value": 514303, "faculty": "Medicine"}, {"employee": "Dan Skarlicki", "value": 448346, "faculty": "Sauder"}, {"employee": "Paul Beaudry", "value": 333119, "faculty": "Arts"}, {"employee": "Joy Louise Johnson", "value": 301990, "faculty": "Engineering"}, {"employee": "Mary Anne Bobinski", "value": 301389, "faculty": "Law"}, {"employee": "Charles F Shuler", "value": 290115, "faculty": "Dentistry"}, {"employee": "Gary Hinshaw", "value": 276558, "faculty": "Science"}, {"employee": "John N Saddler", "value": 266067, "faculty": "Forestry"}, {"employee": "Robert Tierney", "value": 252261, "faculty": "Education"}, {"employee": "Roger Sugden", "value": 216740, "faculty": "Faculty of Management"}, {"employee": "Vuuren Hendrik Van", "value": 196550, "faculty": "Land and Food Systems"}, {"employee": "Gordon James Binsted", "value": 194745, "faculty": "Faculty of Health"}, {"employee": "Louise Nelson", "value": 189481, "faculty": "Barber Arts and Sciences"}, {"employee": "Philip Neil Ainslie", "value": 177988, "faculty": "Health and Social Development"}, {"employee": "Robert Belton", "value": 167298, "faculty": " Creative and Critical Studies"}, {"employee": "Neil Cadger", "value": 131684, "faculty": "Creative Studies"}],
	max: 514303,
}

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




