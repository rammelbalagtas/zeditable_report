@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for ZF001MATRANGE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_F001MATRANGE
  as select from zf001matrange
  association to parent ZI_F001APP as _App on $projection.Uname = _App.Uname
{
  key uname                 as Uname,
  key paramid               as Paramid,
      matnr_from            as MatnrFrom,
      matnr_to              as MatnrTo,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _App
}
