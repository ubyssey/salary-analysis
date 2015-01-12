# FACULTIES REPORT
select
	f.id as faculty_id,
	f.full_name as faculty_name,
	sum(e.remuneration) as salary_total,
    avg(e.remuneration) as avg_salary,
    avg(if(e.gender="m", e.remuneration, null)) as avg_salary_m,
    avg(if(e.gender="f", e.remuneration, null)) as avg_salary_f,
    avg(if(e.gender is null, e.remuneration, null)) as avg_salary_unknown_gender,
    sum(e.expenses) as expenses_total,
    avg(e.expenses) as avg_expenses,
    sum(e.rating) / sum(e.num_ratings) as avg_emp_rating,
    sum(e.num_ratings) as num_ratings,
    count(*) as num_employees,
    count(nullif(e.gender, "M")) as female_count,
    count(nullif(e.gender, "F")) as male_count,
    sum(isnull(e.gender)) as no_gender_count # Use SUM because ISNULL returns 1 or 0, and COUNT will still count zeros.
from
	salarydb.main_employee as e
join salarydb.main_faculty f on (e.faculty_id = f.id)
group by
	f.id
order by
	salary_total desc
