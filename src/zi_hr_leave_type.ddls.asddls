@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Type'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_HR_LEAVE_TYPE
  as select from zhr_leave_type
{
      @ObjectModel.text.element: [ 'Description' ]
  key leave_type      as LeaveType,
      description     as Description,
      max_days        as MaxDays,
      status          as Status,
      case status when 'A' then 'Active' else 'Inactive' end as StatusText,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt
}
