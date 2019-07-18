select datediff(SECOND, l.StartTime, l.EndTime) seconds_taken, l.*  
from Monitoring.AuditLog l
order by AuditLogID desc
