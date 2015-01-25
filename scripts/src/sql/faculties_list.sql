SELECT
#    if(d.campus is null, "van", d.campus) as campus,
    d.faculty_id,
    f.full_name as faculty_name
FROM salarydb.main_department d
JOIN salarydb.main_faculty f ON (f.id = d.faculty_id)
GROUP BY
    d.faculty_id
#    , d.campus