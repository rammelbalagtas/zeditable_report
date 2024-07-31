CLASS lhc_output DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateNewPrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Output~validateNewPrice.

    METHODS validateNewQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR Output~validateNewQuantity.

ENDCLASS.

CLASS lhc_output IMPLEMENTATION.

  METHOD validateNewPrice.
    READ ENTITIES OF zi_f001app IN LOCAL MODE
          ENTITY Output
          FIELDS ( NewPrice ) WITH CORRESPONDING #( keys )
          RESULT DATA(lt_output).

    READ ENTITIES OF zi_f001app IN LOCAL MODE
      ENTITY Output BY \_App
        FROM CORRESPONDING #( lt_output )
      LINK DATA(output_app_links).

    LOOP AT lt_output INTO DATA(ls_output).
      APPEND VALUE #(  %tky        = ls_output-%tky
                       %state_area = 'VALIDATE_NEWPRICE'
                    ) TO reported-output.

      IF ls_output-newprice < 0.
        APPEND VALUE #( %tky = ls_output-%tky ) TO failed-output.
        APPEND VALUE #( %tky = ls_output-%tky
                        %state_area         = 'VALIDATE_NEWPRICE'
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = 'Enter a price that is not less than zero' )
                        %path = VALUE #( app-%tky  = output_app_links[ KEY id source-%tky = ls_output-%tky ]-target-%tky )
                        %element-newprice   = if_abap_behv=>mk-on
                       ) TO reported-output.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateNewQuantity.
    READ ENTITIES OF zi_f001app IN LOCAL MODE
          ENTITY Output
          FIELDS ( NewQuantity ) WITH CORRESPONDING #( keys )
          RESULT DATA(lt_output).

    READ ENTITIES OF zi_f001app IN LOCAL MODE
      ENTITY Output BY \_App
        FROM CORRESPONDING #( lt_output )
      LINK DATA(output_app_links).

    LOOP AT lt_output INTO DATA(ls_output).
      APPEND VALUE #(  %tky        = ls_output-%tky
                       %state_area = 'VALIDATE_NEWQUANTITY'
                    ) TO reported-output.

      IF ls_output-NewQuantity < 0.
        APPEND VALUE #( %tky = ls_output-%tky ) TO failed-output.
        APPEND VALUE #( %tky = ls_output-%tky
                        %state_area         = 'VALIDATE_NEWQUANTITY'
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = 'Enter a quantity that is not less than zero' )
                        %path = VALUE #( app-%tky  = output_app_links[ KEY id source-%tky = ls_output-%tky ]-target-%tky )
                        %element-NewQuantity   = if_abap_behv=>mk-on
                       ) TO reported-output.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_App DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR App RESULT result.
    METHODS extractData FOR MODIFY
      IMPORTING keys FOR ACTION App~extractData RESULT result.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE App.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR App RESULT result.
    METHODS clearinput FOR MODIFY
      IMPORTING keys FOR ACTION app~clearinput RESULT result.

    METHODS validateentries FOR MODIFY
      IMPORTING keys FOR ACTION app~validateentries RESULT result.

ENDCLASS.

CLASS lhc_App IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD extractData.

    READ ENTITIES OF zi_f001app IN LOCAL MODE
        ENTITY App
           ALL FIELDS
          WITH CORRESPONDING #(  keys  )
        RESULT DATA(lt_app)
        ENTITY App BY \_Materials
          ALL FIELDS
          WITH CORRESPONDING #(  keys  )
        RESULT DATA(lt_materials).

    LOOP AT lt_app INTO DATA(ls_app_temp).
      IF ls_app_temp-Plant IS INITIAL.
        APPEND VALUE #(  %tky = ls_app_temp-%tky ) TO failed-app.
        APPEND VALUE #(  %tky = ls_app_temp-%tky
                         %state_area         = 'VALIDATE_PLANT'
                         %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                           text = 'Plant is mandatory' )
                         %element-Plant   = if_abap_behv=>mk-on
                       ) TO reported-app.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA: lr_matnr  TYPE RANGE OF zzmatnr,
          ls_matnr  LIKE LINE OF lr_matnr,
          lr_soldto TYPE RANGE OF /dmo/customer_id,
          ls_soldto LIKE LINE OF lr_soldto,
          lr_plant  TYPE RANGE OF zzplant,
          ls_plant  LIKE LINE OF lr_plant.

    "Material filter
    ls_matnr-sign = 'I'.
    ls_matnr-option = 'EQ'.
    LOOP AT lt_materials INTO DATA(ls_material).
      ls_matnr-low = ls_material-MatnrFrom.
      ls_matnr-high = ls_material-MatnrTo.
      APPEND ls_matnr TO lr_matnr.
    ENDLOOP.

    "Plant
    ls_plant-sign = 'I'.
    ls_plant-option = 'EQ'.
    ls_plant-low = ls_app_temp-Plant.
    APPEND ls_plant TO lr_plant.

    "Soldto
    IF ls_app_temp-soldtoparty IS NOT INITIAL.
      ls_soldto-sign = 'I'.
      ls_soldto-option = 'EQ'.
      ls_soldto-low = ls_app_temp-soldtoparty.
      APPEND ls_soldto TO lr_soldto.
    ENDIF.

    IF ls_app_temp-Validasof IS INITIAL.
      SELECT * FROM zf001ds
              WHERE plant IN @lr_plant
                AND soldtoparty IN @lr_soldto
                AND material IN @lr_matnr
               ORDER BY PRIMARY KEY
               INTO TABLE @DATA(lt_data).
    ELSE.
      SELECT * FROM zf001ds
               WHERE plant IN @lr_plant
                 AND soldtoparty IN @lr_soldto
                 AND material IN @lr_matnr
                 AND startdate >= @ls_app_temp-Validasof
                 AND enddate <= @ls_app_temp-Validasof
               ORDER BY PRIMARY KEY
               INTO TABLE @lt_data.
    ENDIF.

    DATA lt_output TYPE TABLE FOR CREATE zi_f001app\_Output.

    lt_output = VALUE #( (
                            %cid_ref  = keys[ 1 ]-%cid_ref
                            %is_draft = keys[ 1 ]-%is_draft
                            uname  = keys[ 1 ]-uname
                            %target   = VALUE #( FOR ls_data IN lt_data (
                                                                          %is_draft = keys[ 1 ]-%is_draft
                                                                          uname     = keys[ 1 ]-uname
                                                                          sequence  = '00000'
                                                                          plant     = ls_data-plant
                                                                          material     = ls_data-material
                                                                          soldtoparty  = ls_data-soldtoparty
                                                                          startdate    = ls_data-startdate
                                                                          enddate  = ls_data-enddate
                                                                          price = ls_data-price
                                                                          quantity = ls_data-quantity
                                                                          currency = ls_data-currency
                                                                          %control = VALUE #( uname       = if_abap_behv=>mk-on
                                                                                              sequence    = if_abap_behv=>mk-on
                                                                                              plant       = if_abap_behv=>mk-on
                                                                                              material    = if_abap_behv=>mk-on
                                                                                              soldtoparty = if_abap_behv=>mk-on
                                                                                              startdate   = if_abap_behv=>mk-on
                                                                                              enddate     = if_abap_behv=>mk-on
                                                                                              price       = if_abap_behv=>mk-on
                                                                                              quantity     = if_abap_behv=>mk-on
                                                                                              currency     = if_abap_behv=>mk-on ) ) ) ) ).
    DATA lv_sequence TYPE n LENGTH 5.
    lv_sequence = 1.
    LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<fs_output>).
      LOOP AT <fs_output>-%target ASSIGNING FIELD-SYMBOL(<fs_target>).
        <fs_target>-Sequence = lv_sequence.
        lv_sequence = lv_sequence + 1.
      ENDLOOP.
    ENDLOOP.

    READ ENTITIES OF zi_f001app IN LOCAL MODE
    ENTITY App
    BY \_Output
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_bo_output).

    "Delete already existing entries from child entity
    MODIFY ENTITIES OF zi_f001app IN LOCAL MODE
    ENTITY Output
    DELETE FROM VALUE #( FOR ls_bo_output IN lt_bo_output (  %is_draft = ls_bo_output-%is_draft
                                                                 %key  = ls_bo_output-%key ) )
    MAPPED DATA(lt_mapped_delete)
    REPORTED DATA(lt_reported_delete)
    FAILED DATA(lt_failed_delete).

    "Create records from newly extract data
    MODIFY ENTITIES OF zi_f001app IN LOCAL MODE
    ENTITY App
    CREATE BY \_Output
    AUTO FILL CID
    WITH lt_output
    MAPPED DATA(lt_mapped_create)
    REPORTED DATA(lt_mapped_reported)
    FAILED DATA(lt_mapped_failed).

    APPEND VALUE #( %tky = lt_app[ 1 ]-%tky ) TO mapped-app.
    APPEND VALUE #(  %tky = ls_app_temp-%tky
                     %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                       text = 'Records were extracted. Check the Output tab' )
                   ) TO reported-app.

    READ ENTITIES OF zi_f001app IN LOCAL MODE
        ENTITY App
           ALL FIELDS
          WITH CORRESPONDING #(  keys  )
        RESULT lt_app.

    result = VALUE #( FOR ls_app IN lt_app
                          ( %tky   = ls_app-%tky
                            %param = ls_app ) ).

  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_f001app IN LOCAL MODE
       ENTITY App
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_app).
    result = VALUE #( FOR ls_app IN lt_app
                        ( %tky = ls_app-%tky
                          %action-extractData = COND #( WHEN ls_app-%is_draft = if_abap_behv=>mk-off
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )
                          %action-validateEntries = COND #( WHEN ls_app-%is_draft = if_abap_behv=>mk-off
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )
                          %action-clearInput = COND #( WHEN ls_app-%is_draft = if_abap_behv=>mk-off
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )
                          ) ).
  ENDMETHOD.

  METHOD clearInput.
  ENDMETHOD.

  METHOD validateEntries.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_F001APP DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_F001APP IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_app     LIKE create-app,
          lt_output  LIKE create-output,
          lt_data    TYPE STANDARD TABLE OF zf001ds,
          ls_data    LIKE LINE OF lt_data,
          lt_f001    TYPE STANDARD TABLE OF zf001param,
          lt_f001out TYPE STANDARD TABLE OF zf001out,
          ls_f001out LIKE LINE OF lt_f001out.

    IF create-app IS NOT INITIAL.
      lt_app = create-app.
    ELSEIF update-app IS NOT INITIAL.
      lt_app = update-app.
    ENDIF.

    IF create-output IS NOT INITIAL.
      lt_output = create-output.
    ELSEIF update-output IS NOT INITIAL.
      lt_output = update-output.
    ENDIF.

    IF lt_output IS NOT INITIAL.
      LOOP AT lt_output INTO DATA(ls_output).
        IF ls_output-Exclude EQ abap_false.
          CLEAR ls_data.
          MOVE-CORRESPONDING ls_output TO ls_data.
          ls_data-price = ls_output-newprice.
          ls_data-quantity = ls_output-newquantity.
          APPEND ls_data TO lt_data.
        ENDIF.

        MOVE-CORRESPONDING ls_output TO ls_f001out.
        IF ls_output-Exclude EQ abap_true.
          ls_f001out-message = 'No updates were made'.
        ELSE.
          ls_f001out-message = 'Data has been updated'.
        ENDIF.
        APPEND ls_f001out TO lt_f001out.
      ENDLOOP.

      IF failed-output IS INITIAL AND
         lt_data IS NOT INITIAL.
        MODIFY zf001ds FROM TABLE @lt_data.

        IF lt_app IS NOT INITIAL.
          MOVE-CORRESPONDING lt_App TO lt_f001.
          MODIFY zf001param FROM TABLE @lt_f001.
        ENDIF.

        IF lt_f001out IS NOT INITIAL.
          MODIFY zf001out FROM TABLE @lt_f001out.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
