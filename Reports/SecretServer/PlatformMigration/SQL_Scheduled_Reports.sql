select sch.ScheduleId, ScheduleName,rep.name,rep.Description,AdditionalEmails,sch.HistorySize, StartDate,Recurrence,isnull(WeeklyDays,'monthly') as [Recurrence] from tbSchedule sch
full join tbScheduledReport sr on sr.ScheduleId = sch.ScheduleId
join tbCustomReport rep on rep.CustomReportId = sr.ReportId
Where sch.active = 1 and rep.Active =1

/*
.PURPOSE
Returns a list of active SQL report schedules
*/
