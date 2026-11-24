@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Leave Balance (current year)'
@Metadata.allowExtensions: true
define view entity ZI_HR_LEAVE_BALANCE
  as select from zhr_employee as emp
    cross join   zhr_leave_type as lt
    left outer join zhr_employee as mgr on mgr.emp_id = emp.manager_id
    left outer join ZI_HR_LEAVE_USED as used
      on  used.EmpId     = emp.emp_id
      and used.LeaveType = lt.leave_type
      and used.LeaveYear = cast( substring( cast( $session.system_date as abap.char(8) ), 1, 4 ) as abap.char(4) )
{
  key emp.emp_id      as EmpId,
  key lt.leave_type   as LeaveType,
      lt.description  as LeaveTypeDescription,
      cast( substring( cast( $session.system_date as abap.char(8) ), 1, 4 ) as abap.char(4) ) as LeaveYear,
      cast( lt.max_days as abap.int4 ) as Entitlement,
      coalesce( cast( used.UsedDays as abap.int4 ), 0 ) as UsedDays,
      cast( lt.max_days as abap.int4 ) - coalesce( cast( used.UsedDays as abap.int4 ), 0 ) as AvailableDays,
      emp.sap_user    as EmployeeUser,
      mgr.sap_user    as ManagerUser
}
where lt.status = 'A'
  and emp.status = 'A'
