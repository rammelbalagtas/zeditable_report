CLASS zf001_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZF001_UPLOAD IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA lt_data TYPE STANDARD TABLE OF zf001ds.
    DATA ls_data TYPE zf001ds.

    DELETE FROM zf001ds.

    "YYZA, MAT1 - 3, SOLDTO 1 - 2
    ls_data-currency = 'CAD'.
    ls_data-plant  = 'YYZA'.
    ls_data-material = 'MAT1'.
    ls_data-soldtoparty = '000001'.
    ls_data-startdate = '20240101'.
    ls_data-enddate = '99991231'.
    ls_data-quantity = 100.
    ls_data-price = '100.00'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT2'.
    ls_data-soldtoparty = '000001'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT3'.
    ls_data-soldtoparty = '000001'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT1'.
    ls_data-soldtoparty = '000002'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT2'.
    ls_data-soldtoparty = '000002'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT3'.
    ls_data-soldtoparty = '000002'.
    APPEND ls_data TO lt_data.


    "YYZB, MAT1 - 3, SOLDTO 1 - 2
    ls_data-currency = 'CAD'.
    ls_data-plant  = 'YYZB'.
    ls_data-material = 'MAT1'.
    ls_data-soldtoparty = '000001'.
    ls_data-startdate = '20240101'.
    ls_data-enddate = '99991231'.
    ls_data-quantity = 100.
    ls_data-price = '100.00'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT2'.
    ls_data-soldtoparty = '000001'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT3'.
    ls_data-soldtoparty = '000001'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT1'.
    ls_data-soldtoparty = '000002'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT2'.
    ls_data-soldtoparty = '000002'.
    APPEND ls_data TO lt_data.

    ls_data-material = 'MAT3'.
    ls_data-soldtoparty = '000002'.
    APPEND ls_data TO lt_data.

    INSERT zf001ds FROM TABLE @lt_data.

    DATA lt_params TYPE STANDARD TABLE OF zf001param.
    DATA ls_params TYPE zf001param.

    DELETE FROM zf001param.
    ls_params-uname = sy-uname.
    APPEND ls_params TO lt_params.

    INSERT zf001param FROM TABLE @lt_params.

     DATA lt_user TYPE STANDARD TABLE OF zuser_db.
     DATA ls_user LIKE LINE OF lt_user.

     ls_user-bname = sy-uname.
     APPEND ls_user to lt_user.
     INSERT zuser_db FROM TABLE @lt_user.

  ENDMETHOD.
ENDCLASS.
