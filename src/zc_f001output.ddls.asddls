@EndUserText.label: 'Output Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI.headerInfo: {
    typeName: 'Result',
    typeNamePlural: 'Result'
}
@Metadata.allowExtensions: true
define view entity zc_f001output
  as projection on  zi_f001output
{
  key Uname,
  key Sequence,
      Plant,
      Material,
      Soldtoparty,
      Startdate,
      Enddate,
      Description,
      Quantity,
      NewQuantity,
      @Semantics.amount.currencyCode : 'Currency'
      Price,
      @Semantics.amount.currencyCode : 'Currency'
      NewPrice,
      Currency,
      Exclude,
      Processed,
      Message,
      /* Associations */
      _App : redirected to parent ZC_F001APP
}
