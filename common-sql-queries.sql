//select reports with the name
select * from org.reportcataloggeneral where reportname like 'My Work Habit'

//Update report, active imactive
update org.reportcataloggeneral set isactive = 0 where reportname like 'My Work Habit'.  