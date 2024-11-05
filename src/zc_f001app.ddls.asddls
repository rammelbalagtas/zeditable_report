@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Editable ALV Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZC_F001APP
  provider contract transactional_query as projection on ZI_F001APP
{
  key Uname,
      AppName,
      Status,
      Plant,
      Soldtoparty,
      Validasof,
      Updatedata,
      @Semantics.largeObject: {
        acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
        cacheControl.maxAge: #MEDIUM,
        contentDispositionPreference: #ATTACHMENT , // #ATTACHMENT - download as file
                                                    // #INLINE - open in new window
        fileName: 'Filename',
        mimeType: 'Mimetype'
      }
      UploadFile,
      Filename,
      @Semantics.mimeType: true
      Mimetype,
      Localcreatedby,
      Localcreatedat,
      Locallastchangedby,
      Locallastchangedat,
      Lastchangedat,
      /* Associations */
      _Materials : redirected to composition child ZC_F001MATRANGE,
      _Output : redirected to composition child zc_f001output
}
