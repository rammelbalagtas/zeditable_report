@EndUserText.label: 'ZI_F001MATRANGE'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_F001MATRANGE
  as projection on ZI_F001MATRANGE
{
  key Uname,
  key Paramid,
      MatnrFrom,
      MatnrTo,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
       _App : redirected to parent ZC_F001APP
}
