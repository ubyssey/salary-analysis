(function() {
  var chart_maker, data_hooks, debug, fetch_data, search, uby_charts,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  debug = true;

  if (!debug) {
    console.log = function() {};
  }

  search = (function(self) {
    var predicates, _search;
    predicates = {};
    _search = function() {
      var results;
      results = d3.selectAll(".dot").classed("searchresult", false);
      if (Object.keys(predicates).length === 0) {
        return;
      }
      results = results.filter(function(d, i) {
        var key, p;
        for (key in predicates) {
          if (!__hasProp.call(predicates, key)) continue;
          p = predicates[key];
          if (p && !p(d, i)) {
            return false;
          }
        }
        return true;
      });
      results.classed("searchresult", true);
      return console.log(results);
    };
    self.faculty_filter = function(evt) {
      var fid;
      fid = $(evt.currentTarget).val().split("fac")[1];
      if (+fid === 0) {
        delete predicates.fac;
      } else {
        predicates.fac = function(d, i) {
          return d.faculty_id === fid;
        };
      }
      return _search();
    };
    self.campus_filter = function(evt) {
      var campuses, i;
      campuses = (function() {
        var _i, _len, _ref, _results;
        _ref = $(evt.currentTarget).find("input:checked");
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name.split("-")[1]);
        }
        return _results;
      })();
      return d3.selectAll(".dot").classed("hidden", false).filter(function(d, i) {
        var _ref;
        return d.campus && (_ref = d.campus, __indexOf.call(campuses, _ref) < 0);
      }).classed("hidden", true);
    };
    self.text_search = function(evt) {
      var q;
      if (evt.type === "submit") {
        evt.preventDefault();
      }
      q = $(evt.currentTarget).find(".searchbar").val();
      q = q.trim().toLowerCase();
      if (q === "") {
        delete predicates.q;
      } else {
        predicates.q = function(d, i) {
          var haystack;
          haystack = d.dept_name || d.faculty_name;
          return -1 < haystack.toLowerCase().indexOf(q);
        };
      }
      return _search();
    };
    return self;
  })({});

  data_hooks = {};

  fetch_data = function(loader, uri, name) {
    return loader(uri, function(err, data) {
      var f, _i, _len, _ref;
      _ref = data_hooks[name];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        f(err, data);
      }
    });
  };

  chart_maker = (function(_this) {
    return function(params) {
      var apply_fmt, fmt_dollars;
      fmt_dollars = d3.format("$,.0f");
      apply_fmt = function(xy, axis) {
        var fmt;
        fmt = params["fmt_" + xy];
        if (fmt === "$") {
          return axis.tickFormat(fmt_dollars);
        } else if (fmt) {
          return axis.tickFormat(fmt);
        }
      };
      return function(parentdiv) {
        var height, margin, svg, tip, width, x, xAxis, y, yAxis;
        if (params.title != null) {
          $(parentdiv).append($("<h2/>").text(params.title));
        }
        if (params.subtitle != null) {
          $(parentdiv).append($("<h3/>").text(params.subtitle));
        }
        margin = {
          top: 20,
          right: 20,
          bottom: 30,
          left: 50
        };
        width = $(parentdiv).width() - margin.left - margin.right;
        height = (params.height || 500) - margin.top - margin.bottom;
        x = d3.scale.linear().range([0, width]);
        y = d3.scale.linear().range([height, 0]);
        xAxis = d3.svg.axis().scale(x).orient("bottom");
        apply_fmt("x", xAxis);
        yAxis = d3.svg.axis().scale(y).orient("left");
        apply_fmt("y", yAxis);
        svg = d3.select(parentdiv).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
        tip = d3.tip().attr("class", "d3-tip").html(params.tip);
        svg.call(tip);
        data_hooks[params.src] = data_hooks[params.src] || [];
        return data_hooks[params.src].push(function(err, data) {
          var fr, id_maker, r;
          if (params.processor) {
            data = params.processor(data);
          }
          x.domain(d3.extent(data, params.d_x));
          y.domain(d3.extent(data, params.d_y));
          svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis).append("text").attr("class", "label").attr("x", width).attr("y", -6).style("text-anchor", "end").text(params.label_x);
          svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("class", "label").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text(params.label_y);
          switch (typeof params.d_r) {
            case "function":
              fr = d3.scale.linear().range([params.min_r || 2.5, params.max_r || 7]).domain(d3.extent(data, params.d_r));
              r = function(d) {
                return fr(params.d_r(d));
              };
              break;
            case "number":
              r = function() {
                return params.d_r;
              };
              break;
            default:
              r = 3.5;
          }
          if (params.reference_line) {
            svg.append("path").datum(d3.extent(data, params.d_x)).attr("class", "reference-line").attr("d", d3.svg.line().x(function(d) {
              return x(d);
            }).y(function(d) {
              return y(d);
            }));
          }
          if (debug) {
            data.sort(function(a, b) {
              return a.faculty_name.localeCompare(b.faculty_name);
            });
          }
          svg.selectAll(".dot").data(data).enter().append("circle").attr("class", "dot").attr("r", r).attr("cx", function(d) {
            return x(params.d_x(d));
          }).attr("cy", function(d) {
            return y(params.d_y(d));
          }).on("mouseover", tip.show).on("mouseout", tip.hide);
          if (debug) {
            id_maker = function(d) {
              var reg = / /g;;
              var prefix, text;
              text = (d.dept_name || d.faculty_name).replace(reg, "-");
              prefix = d.faculty_name;
              return "" + prefix + "-dept-" + text;
            };
            return svg.selectAll(".dot").attr("id", function(d) {
              return id_maker(d);
            });
          }
        });
      };
    };
  })(this);

  uby_charts = (function(self) {
    var dept_tip, salary_mf_notnull;
    dept_tip = function(d) {
      var r;
      r = "" + d.dept_name;
      if (debug) {
        r += "<span> - ID#" + d.dept_id + "</span";
      }
      return r;
    };
    salary_mf_notnull = function(data) {
      var d, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        d = data[_i];
        if (d.avg_salary_m !== "NULL" && d.avg_salary_f !== "NULL") {
          _results.push(d);
        }
      }
      return _results;
    };
    self.departments = {
      gender_salary: chart_maker({
        src: "dept",
        d_x: function(d) {
          return +d.avg_salary_m;
        },
        d_y: function(d) {
          return +d.avg_salary_f;
        },
        d_r: function(d) {
          return +d.num_employees;
        },
        label_x: "MALE - Average Salary",
        label_y: "FEMALE - Average Salary",
        fmt_x: "$",
        fmt_y: "$",
        title: "Average Salary, Male vs Female, by Department",
        subtitle: "Reference line shows equality. Points are scaled by department size.",
        processor: salary_mf_notnull,
        tip: dept_tip,
        reference_line: true
      }),
      salary_expenses: chart_maker({
        src: "dept",
        d_x: function(d) {
          return +d.avg_salary;
        },
        d_y: function(d) {
          return +d.avg_expenses;
        },
        label_x: "Avg Salary",
        label_y: "Avg Expenses",
        fmt_x: "$",
        fmt_y: "$",
        title: "Avg Salary vs Expenses",
        tip: dept_tip
      })
    };
    self.faculties = {
      gender_salary: chart_maker({
        src: "fac",
        d_x: function(d) {
          return +d.avg_salary_m;
        },
        d_y: function(d) {
          return +d.avg_salary_f;
        },
        d_r: function(d) {
          return +d.num_employees;
        },
        min_r: 4,
        max_r: 9,
        label_x: "MALE - Average Salary",
        label_y: "FEMALE - Average Salary",
        fmt_x: "$",
        fmt_y: "$",
        title: "Average Salary, Male vs Female, by Faculty",
        subtitle: "Reference line shows equality. Points are scaled by faculty size.",
        processor: salary_mf_notnull,

        /*
        processor: (data) ->
            for d in data
                for a in ["m", "f"]
                    k = "avg_salary_#{a}"
                    d[k] = if d[k] is "NULL" then 0 else d[k]
            data
         */
        height: 300,
        tip: function(d) {
          d.dept_name = d.faculty_name;
          d.dept_id = d.faculty_id;
          return dept_tip(d);
        },
        reference_line: true
      })
    };
    return self;
  })({});

  uby_charts.departments.gender_salary("#deptchart");

  uby_charts.departments.salary_expenses("#expenseschart");

  uby_charts.faculties.gender_salary("#facchart");

  fetch_data(d3.csv, "../data/departments.csv", "dept");

  fetch_data(d3.csv, "../data/faculties.csv", "fac");

  d3.csv("../data/faculties_list.csv", function(err, data) {
    var d, f, _i, _len, _results;
    f = $("#facultyselector");
    data.unshift({
      faculty_name: "(All Faculties)",
      faculty_id: 0
    });
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      _results.push($("<option/>").attr("value", "fac" + d.faculty_id).text(d.faculty_name).appendTo(f));
    }
    return _results;
  });

  $("#searchform").keyup(search.text_search).submit(search.text_search);

  $("#facultyselector").change(search.faculty_filter);

  $("#campuses").change(search.campus_filter);

}).call(this);
