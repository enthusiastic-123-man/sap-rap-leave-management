@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Active Employees (Value Help)'
@Search.searchable: true
define view entity ZI_HR_LVEMP_VH
  as select from zhr_employee
{
      @ObjectModel.text.element: [ 'EmpName' ]
      @Search.defaultSearchElement: true
  key emp_id   as EmpId,
      @Search.defaultSearchElement: true
      emp_name as EmpName,
      dept_id  as DeptId
}
where status = 'A'
