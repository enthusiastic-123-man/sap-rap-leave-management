@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approved leave requests with leave year'
define view entity ZI_HR_LEAVE_APPROVED
  as select from zhr_leave_req
{
  key leave_id as LeaveId,
      emp_id   as EmpId,
      leave_type as LeaveType,
      cast( substring( cast( from_date as abap.char(8) ), 1, 4 ) as abap.char(4) ) as LeaveYear,
      total_days as TotalDays
}
where status = 'AP'
