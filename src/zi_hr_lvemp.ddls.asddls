@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Employee'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_HR_LVEMP
  as select from zhr_employee as emp
    left outer join zhr_employee as mgr on mgr.emp_id = emp.manager_id
{
      @ObjectModel.text.element: [ 'EmpName' ]
  key emp.emp_id            as EmpId,
      emp.emp_name          as EmpName,
      emp.email             as Email,
      emp.dept_id           as DeptId,
      emp.manager_id        as ManagerId,
      emp.join_date         as JoinDate,
      emp.status            as Status,
      case emp.status when 'A' then 'Active' else 'Inactive' end as StatusText,
      emp.sap_user          as SapUser,
      mgr.emp_name          as ManagerName,
      mgr.sap_user          as ManagerUser,
      @Semantics.user.createdBy: true
      emp.created_by        as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      emp.created_at        as CreatedAt,
      @Semantics.user.lastChangedBy: true
      emp.last_changed_by   as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      emp.last_changed_at   as LastChangedAt
}
