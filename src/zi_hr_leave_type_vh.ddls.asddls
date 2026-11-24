@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Active Leave Types (Value Help)'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_HR_LEAVE_TYPE_VH
  as select from zhr_leave_type
{
      @ObjectModel.text.element: [ 'Description' ]
      @Search.defaultSearchElement: true
  key leave_type  as LeaveType,
      @Search.defaultSearchElement: true
      description as Description,
      max_days    as MaxDays
}
where status = 'A'
