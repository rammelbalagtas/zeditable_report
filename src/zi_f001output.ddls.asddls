@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for zf001out'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_f001output
  as select from zf001out
  association to parent ZI_F001APP as _App on $projection.Uname = _App.Uname
{
  key uname       as Uname,
  key sequence    as Sequence,
      plant       as Plant,
      material    as Material,
      soldtoparty as Soldtoparty,
      startdate   as Startdate,
      enddate     as Enddate,
      description as Description,
      quantity    as Quantity,
      newquantity as NewQuantity,
      @Semantics.amount.currencyCode : 'Currency'
      price       as Price,
      @Semantics.amount.currencyCode : 'Currency'
      newprice    as NewPrice,
      currency    as Currency,
      exclude     as Exclude,
      processed   as Processed,
      message     as Message,
      _App
}
