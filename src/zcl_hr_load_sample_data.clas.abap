CLASS zcl_hr_load_sample_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_hr_load_sample_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " --- 1. POPULATE LEAVE TYPES ---
    MODIFY zhr_leave_type FROM TABLE @( VALUE #(
      ( leave_type = 'CL' description = 'Casual Leave'       max_days = 12 status = 'A' )
      ( leave_type = 'SL' description = 'Sick Leave'         max_days = 10 status = 'A' )
      ( leave_type = 'EL' description = 'Earned Leave'       max_days = 15 status = 'A' )
      ( leave_type = 'ML' description = 'Marriage Leave'     max_days = 5  status = 'A' )
      ( leave_type = 'DL' description = 'Family Death Leave' max_days = 5  status = 'A' )
      ( leave_type = 'PL' description = 'Paternity Leave'    max_days = 10 status = 'A' )
      ( leave_type = 'UL' description = 'Unpaid Leave'       max_days = 30 status = 'A' )
    ) ).

    IF sy-subrc <> 0.
      out->write( 'Error: leave types could not be saved.' ).
      RETURN.
    ENDIF.

    " --- 2. POPULATE EMPLOYEES (TOTAL 18) ---
    MODIFY zhr_employee FROM TABLE @( VALUE #(
      ( emp_id = '0000000001' emp_name = 'Hema Rao'        email = 'hema@example.com'    dept_id = 'HR'         manager_id = ''           join_date = '20200101' status = 'A' sap_user = 'ZHR_ADMIN' )
      ( emp_id = '0000000002' emp_name = 'Manoj Kumar'     email = 'manoj@example.com'   dept_id = 'IT'         manager_id = '0000000001' join_date = '20200301' status = 'A' sap_user = 'ZHR_MANAGER' )
      ( emp_id = '0000000003' emp_name = 'Esha Patel'      email = 'esha@example.com'    dept_id = 'IT'         manager_id = '0000000002' join_date = '20210601' status = 'A' sap_user = 'CB9980005490' )
      ( emp_id = '0000000004' emp_name = 'Ravi Das'        email = 'ravi@example.com'    dept_id = 'IT'         manager_id = '0000000002' join_date = '20220801' status = 'A' sap_user = 'ZHR_EMP2' )
      ( emp_id = '0000000005' emp_name = 'Ananya Sharma'   email = 'ananya@example.com'  dept_id = 'HR'         manager_id = '0000000001' join_date = '20230115' status = 'A' sap_user = 'ZHR_EMP3' )
      ( emp_id = '0000000006' emp_name = 'Vikram Singh'    email = 'vikram@example.com'  dept_id = 'FINANCE'    manager_id = '0000000001' join_date = '20230320' status = 'A' sap_user = 'ZHR_EMP4' )
      ( emp_id = '0000000007' emp_name = 'Priya Nair'      email = 'priya@example.com'   dept_id = 'FINANCE'    manager_id = '0000000006' join_date = '20230510' status = 'A' sap_user = 'ZHR_EMP5' )
      ( emp_id = '0000000008' emp_name = 'Amit Shah'       email = 'amit@example.com'    dept_id = 'IT'         manager_id = '0000000002' join_date = '20230901' status = 'A' sap_user = 'ZHR_EMP6' )
      ( emp_id = '0000000009' emp_name = 'Sneha Reddy'     email = 'sneha@example.com'   dept_id = 'SALES'      manager_id = '0000000001' join_date = '20231005' status = 'A' sap_user = 'ZHR_EMP7' )
      ( emp_id = '0000000010' emp_name = 'Rajesh Iyer'     email = 'rajesh@example.com'  dept_id = 'SALES'      manager_id = '0000000009' join_date = '20231112' status = 'A' sap_user = 'ZHR_EMP8' )
      ( emp_id = '0000000011' emp_name = 'Pooja Verma'     email = 'pooja@example.com'   dept_id = 'MARKETING'  manager_id = '0000000001' join_date = '20240110' status = 'A' sap_user = 'ZHR_EMP9' )
      ( emp_id = '0000000012' emp_name = 'Arjun Kapoor'    email = 'arjun@example.com'   dept_id = 'MARKETING'  manager_id = '0000000011' join_date = '20240215' status = 'A' sap_user = 'ZHR_EMP10' )
      ( emp_id = '0000000013' emp_name = 'Kavita Joshi'    email = 'kavita@example.com'  dept_id = 'OPERATIONS' manager_id = '0000000001' join_date = '20240401' status = 'A' sap_user = 'ZHR_EMP11' )
      ( emp_id = '0000000014' emp_name = 'Suresh Gupta'    email = 'suresh@example.com'  dept_id = 'OPERATIONS' manager_id = '0000000013' join_date = '20240520' status = 'A' sap_user = 'ZHR_EMP12' )
      ( emp_id = '0000000015' emp_name = 'Meera Mehta'     email = 'meera@example.com'   dept_id = 'HR'         manager_id = '0000000001' join_date = '20240601' status = 'A' sap_user = 'ZHR_EMP13' )
      ( emp_id = '0000000016' emp_name = 'Rohan Bhatia'    email = 'rohan@example.com'   dept_id = 'IT'         manager_id = '0000000002' join_date = '20240715' status = 'A' sap_user = 'ZHR_EMP14' )
      ( emp_id = '0000000017' emp_name = 'Deepa Kulkarni'  email = 'deepa@example.com'   dept_id = 'FINANCE'    manager_id = '0000000006' join_date = '20240810' status = 'A' sap_user = 'ZHR_EMP15' )
      ( emp_id = '0000000018' emp_name = 'Alok Mishra'     email = 'alok@example.com'    dept_id = 'SALES'      manager_id = '0000000009' join_date = '20240901' status = 'A' sap_user = 'ZHR_EMP16' )
    ) ).

    IF sy-subrc <> 0.
      out->write( 'Error: employee records could not be saved.' ).
      RETURN.
    ENDIF.

    out->write( '7 leave types and 18 employee records loaded successfully!' ).

  ENDMETHOD.

ENDCLASS.
