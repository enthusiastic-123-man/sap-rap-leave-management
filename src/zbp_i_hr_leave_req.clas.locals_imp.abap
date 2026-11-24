CLASS lhc_LeaveRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR LeaveRequest RESULT result.

    " Dynamic feature control declaration (Enables/disables buttons on Fiori UI)
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR LeaveRequest RESULT result.

    METHODS approveLeave FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~approveLeave RESULT result.

    METHODS rejectLeave FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~rejectLeave RESULT result.

    METHODS submitLeave FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~submitLeave RESULT result.

    METHODS cancelLeave FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~cancelLeave RESULT result.

    METHODS recalculateTotalDays FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LeaveRequest~recalculateTotalDays.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR LeaveRequest~validateDates.

    METHODS validateReason FOR VALIDATE ON SAVE
      IMPORTING keys FOR LeaveRequest~validateReason.

ENDCLASS.

CLASS lhc_LeaveRequest IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = VALUE #(
      FOR key_item IN keys (
        %tky                 = key_item-%tky
        %update              = if_abap_behv=>auth-allowed
        %delete              = if_abap_behv=>auth-allowed
        %action-approveLeave = if_abap_behv=>auth-allowed
        %action-rejectLeave  = if_abap_behv=>auth-allowed
        %action-submitLeave  = if_abap_behv=>auth-allowed
        %action-cancelLeave  = if_abap_behv=>auth-allowed
      )
    ).
  ENDMETHOD.

  " --- DYNAMIC FEATURE CONTROL: Enables/Disables Buttons ---
  METHOD get_instance_features.
    DATA: lv_current_user TYPE syuname,
          lv_emp_id       TYPE zhr_employee-emp_id,
          lv_dept_id      TYPE zhr_employee-dept_id.

    lv_current_user = cl_abap_context_info=>get_user_technical_name( ).

    SELECT SINGLE emp_id, dept_id
      FROM zhr_employee
      WHERE sap_user = @lv_current_user
      INTO (@lv_emp_id, @lv_dept_id).

    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( EmpId Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave_reqs).

    result = VALUE #(
      FOR ls_req IN lt_leave_reqs (
        %tky = ls_req-%tky
        %action-approveLeave = COND #(
          WHEN ( ls_req-EmpId = lv_emp_id AND lv_dept_id <> 'HR' )
            OR ls_req-Status <> 'P'
          THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled
        )
        %action-rejectLeave = COND #(
          WHEN ( ls_req-EmpId = lv_emp_id AND lv_dept_id <> 'HR' )
            OR ls_req-Status <> 'P'
          THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled
        )
      )
    ).
  ENDMETHOD.

  " --- ACTION: Approve Leave ---
  METHOD approveLeave.
    DATA: lv_current_user  TYPE syuname,
          lv_approver_emp  TYPE zhr_employee-emp_id,
          lv_approver_dept TYPE zhr_employee-dept_id,
          lt_keys_to_read  TYPE TABLE FOR READ IMPORT zi_hr_leave_req.

    lv_current_user = cl_abap_context_info=>get_user_technical_name( ).

    SELECT SINGLE emp_id, dept_id
      FROM zhr_employee
      WHERE sap_user = @lv_current_user
      INTO (@lv_approver_emp, @lv_approver_dept).

    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( EmpId Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave_reqs).

    LOOP AT lt_leave_reqs INTO DATA(ls_req).
      IF ls_req-Status <> 'P'.
        APPEND VALUE #( %tky = ls_req-%tky ) TO failed-leaverequest.
        APPEND VALUE #(
          %tky = ls_req-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Only pending leave requests can be approved.'
          )
        ) TO reported-leaverequest.
        CONTINUE.
      ENDIF.

      SELECT SINGLE manager_id
        FROM zhr_employee
        WHERE emp_id = @ls_req-EmpId
        INTO @DATA(lv_req_manager_id).

      IF lv_approver_dept = 'HR'
        OR ( lv_approver_emp IS NOT INITIAL AND lv_approver_emp = lv_req_manager_id ).

        MODIFY ENTITIES OF zi_hr_leave_req IN LOCAL MODE
          ENTITY LeaveRequest
          UPDATE FIELDS ( Status ApproverId ApprovalDate )
          WITH VALUE #( (
            %tky         = ls_req-%tky
            Status       = 'AP'
            ApproverId   = lv_current_user
            ApprovalDate = cl_abap_context_info=>get_system_date( )
          ) )
          FAILED failed
          REPORTED reported.

        APPEND VALUE #( %tky = ls_req-%tky ) TO lt_keys_to_read.
      ELSE.
        APPEND VALUE #( %tky = ls_req-%tky ) TO failed-leaverequest.
        APPEND VALUE #(
          %tky = ls_req-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Unauthorized: Only HR or the assigned Manager can approve this leave!'
          )
        ) TO reported-leaverequest.
      ENDIF.
    ENDLOOP.

    IF lt_keys_to_read IS NOT INITIAL.
      READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
        ENTITY LeaveRequest
        ALL FIELDS
        WITH lt_keys_to_read
        RESULT DATA(lt_approved).

      result = VALUE #(
        FOR row_app IN lt_approved (
          %tky   = row_app-%tky
          %param = row_app
        )
      ).
    ENDIF.
  ENDMETHOD.

  " --- ACTION: Reject Leave ---
  METHOD rejectLeave.
    DATA: lv_current_user  TYPE syuname,
          lv_approver_emp  TYPE zhr_employee-emp_id,
          lv_approver_dept TYPE zhr_employee-dept_id,
          lt_keys_to_read  TYPE TABLE FOR READ IMPORT zi_hr_leave_req.

    lv_current_user = cl_abap_context_info=>get_user_technical_name( ).

    SELECT SINGLE emp_id, dept_id
      FROM zhr_employee
      WHERE sap_user = @lv_current_user
      INTO (@lv_approver_emp, @lv_approver_dept).

    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( EmpId Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave_reqs).

    LOOP AT lt_leave_reqs INTO DATA(ls_req).
      IF ls_req-Status <> 'P'.
        APPEND VALUE #( %tky = ls_req-%tky ) TO failed-leaverequest.
        APPEND VALUE #(
          %tky = ls_req-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Only pending leave requests can be rejected.'
          )
        ) TO reported-leaverequest.
        CONTINUE.
      ENDIF.

      SELECT SINGLE manager_id
        FROM zhr_employee
        WHERE emp_id = @ls_req-EmpId
        INTO @DATA(lv_req_manager_id).

      IF lv_approver_dept = 'HR'
        OR ( lv_approver_emp IS NOT INITIAL AND lv_approver_emp = lv_req_manager_id ).

        MODIFY ENTITIES OF zi_hr_leave_req IN LOCAL MODE
          ENTITY LeaveRequest
          UPDATE FIELDS ( Status ApproverId ApprovalDate )
          WITH VALUE #( (
            %tky         = ls_req-%tky
            Status       = 'RJ'
            ApproverId   = lv_current_user
            ApprovalDate = cl_abap_context_info=>get_system_date( )
          ) )
          FAILED failed
          REPORTED reported.

        APPEND VALUE #( %tky = ls_req-%tky ) TO lt_keys_to_read.
      ELSE.
        APPEND VALUE #( %tky = ls_req-%tky ) TO failed-leaverequest.
        APPEND VALUE #(
          %tky = ls_req-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Unauthorized: Only HR or the assigned Manager can reject this leave!'
          )
        ) TO reported-leaverequest.
      ENDIF.
    ENDLOOP.

    IF lt_keys_to_read IS NOT INITIAL.
      READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
        ENTITY LeaveRequest
        ALL FIELDS
        WITH lt_keys_to_read
        RESULT DATA(lt_rejected).

      result = VALUE #(
        FOR row_rej IN lt_rejected (
          %tky   = row_rej-%tky
          %param = row_rej
        )
      ).
    ENDIF.
  ENDMETHOD.

  " --- ACTION: Submit Leave ---
  METHOD submitLeave.
    MODIFY ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      UPDATE FIELDS ( Status )
      WITH VALUE #(
        FOR k IN keys (
          %tky   = k-%tky
          Status = 'SB'
        )
      )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_submitted).

    result = VALUE #(
      FOR row_sub IN lt_submitted (
        %tky   = row_sub-%tky
        %param = row_sub
      )
    ).
  ENDMETHOD.

  " --- ACTION: Cancel Leave ---
  METHOD cancelLeave.
    MODIFY ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      UPDATE FIELDS ( Status )
      WITH VALUE #(
        FOR k IN keys (
          %tky   = k-%tky
          Status = 'CA'
        )
      )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cancelled).

    result = VALUE #(
      FOR row_can IN lt_cancelled (
        %tky   = row_can-%tky
        %param = row_can
      )
    ).
  ENDMETHOD.

  " --- DETERMINATION: Auto-Calculate Total Days ---
  METHOD recalculateTotalDays.
    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( FromDate ToDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reqs).

    DATA lt_update TYPE TABLE FOR UPDATE zi_hr_leave_req.

    LOOP AT lt_reqs INTO DATA(ls_req) WHERE FromDate IS NOT INITIAL AND ToDate IS NOT INITIAL.
      DATA(lv_days) = COND i(
        WHEN ls_req-ToDate >= ls_req-FromDate
        THEN ls_req-ToDate - ls_req-FromDate + 1
        ELSE 0
      ).

      APPEND VALUE #(
        %tky      = ls_req-%tky
        TotalDays = lv_days
      ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_hr_leave_req IN LOCAL MODE
        ENTITY LeaveRequest
        UPDATE FIELDS ( TotalDays )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

  " --- VALIDATION: Check Dates ---
  METHOD validateDates.
    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( FromDate ToDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reqs).

    LOOP AT lt_reqs INTO DATA(ls_req).
      IF ls_req-FromDate IS NOT INITIAL
        AND ls_req-ToDate IS NOT INITIAL
        AND ls_req-ToDate < ls_req-FromDate.

        APPEND VALUE #( %tky = ls_req-%tky ) TO failed-leaverequest.
        APPEND VALUE #(
          %tky = ls_req-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'To Date must be on or after From Date'
          )
          %element-todate = if_abap_behv=>mk-on
        ) TO reported-leaverequest.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " --- VALIDATION: Check Reason ---
  METHOD validateReason.
    READ ENTITIES OF zi_hr_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( Reason )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reqs).

    LOOP AT lt_reqs INTO DATA(ls_req) WHERE Reason IS INITIAL.
      APPEND VALUE #( %tky = ls_req-%tky ) TO failed-leaverequest.
      APPEND VALUE #(
        %tky = ls_req-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Reason is mandatory'
        )
        %element-reason = if_abap_behv=>mk-on
      ) TO reported-leaverequest.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
