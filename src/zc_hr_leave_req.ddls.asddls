@EndUserText.label: 'Leave Request Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_HR_LEAVE_REQ
    provider contract transactional_query
    as projection on ZI_HR_LEAVE_REQ
{
    @Search.defaultSearchElement: true
    key LeaveId,

    @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'ZI_HR_LVEMP_VH',
            element: 'EmpId'
        }
    }]
    @ObjectModel.text.element: ['EmpName']
    @UI.textArrangement: #TEXT_LAST
    @Search.defaultSearchElement: true
    EmpId,

    _Employee.EmpName as EmpName,

    @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'ZI_HR_LEAVE_TYPE_VH',
            element: 'LeaveType'
        }
    }]
    @ObjectModel.text.element: ['LeaveTypeDescription']
    @UI.textArrangement: #TEXT_LAST
    LeaveType,

    _LeaveType.Description as LeaveTypeDescription,

    FromDate,
    ToDate,
    TotalDays,

    @Search.defaultSearchElement: true
    Reason,

    @ObjectModel.text.element: ['StatusText']
    @UI.textArrangement: #TEXT_ONLY
    Status,

    StatusText,
    StatusCriticality,

    @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'ZI_HR_LVEMP_VH',
            element: 'EmpId'
        }
    }]
    @ObjectModel.text.element: ['ApproverName']
    @UI.textArrangement: #TEXT_LAST
    ApproverId,

    _Approver.EmpName as ApproverName,

    ApprovalComment,
    ApprovalDate,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,

    /* Associations */
    _Employee,
    _Approver,
    _LeaveType
}
