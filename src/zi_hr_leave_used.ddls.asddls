@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approved leave days per year'
define view entity ZI_HR_LEAVE_USED
  as select from ZI_HR_LEAVE_APPROVED
{
  EmpId,
  LeaveType,
  LeaveYear,
  sum( TotalDays ) as UsedDays
}
group by
  EmpId,
  LeaveType,
  LeaveYear
