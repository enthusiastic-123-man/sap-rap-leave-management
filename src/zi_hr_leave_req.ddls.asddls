@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request Root Interface View'

define root view entity ZI_HR_LEAVE_REQ
    as select from zhr_leave_req

    association [1..1] to ZI_HR_LVEMP as _Employee
        on $projection.EmpId = _Employee.EmpId

    association [0..1] to ZI_HR_LVEMP as _Approver
        on $projection.ApproverId = _Approver.EmpId

    association [1..1] to ZI_HR_LEAVE_TYPE as _LeaveType
        on $projection.LeaveType = _LeaveType.LeaveType
{
    key leave_id as LeaveId,

    emp_id as EmpId,
    leave_type as LeaveType,
    from_date as FromDate,
    to_date as ToDate,
    total_days as TotalDays,
    reason as Reason,
    status as Status,

    // --- 1. User-Friendly Status Text Mapping ---
    case status
        when 'A' then cast( 'Approved' as abap.char(15) )
        when 'AP' then cast( 'Approved' as abap.char(15) )
        when 'R' then cast( 'Rejected' as abap.char(15) )
        when 'RJ' then cast( 'Rejected' as abap.char(15) )
        when 'SB' then cast( 'Submitted' as abap.char(15) )
        when 'DR' then cast( 'Draft' as abap.char(15) )
        when 'CA' then cast( 'Cancelled' as abap.char(15) )
        else cast( '' as abap.char(15) )
    end as StatusText,

    // --- 2. Fiori Badge Color Mapping (Criticality) ---
    case status
        when 'A' then 3 // Green (Success)
        when 'AP' then 3 // Green (Success)
        when 'SB' then 2 // Yellow (Warning)
        when 'R' then 1 // Red (Error)
        when 'RJ' then 1 // Red (Error)
        when 'CA' then 1 // Red (Error)
        else 0 // Neutral / Gray
    end as StatusCriticality,

    approver_id as ApproverId,
    approval_comment as ApprovalComment,
    approval_date as ApprovalDate,

    @Semantics.user.createdBy: true
    created_by as CreatedBy,

    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,

    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,

    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,

    /* Associations */
    _Employee,
    _Approver,
    _LeaveType
}
