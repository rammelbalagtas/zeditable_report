@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view entity for F001'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_F001APP
  as select from    zuser_db   as _User
    left outer join zf001param as _Parameters on _User.bname = _Parameters.uname
  composition [0..*] of ZI_F001MATRANGE as _Materials
  composition [0..*] of zi_f001output   as _Output
{
  key _User.bname                    as Uname,
      'Editable ALV Report'          as AppName,
      _Parameters.status             as Status,
      _Parameters.plant              as Plant,
      _Parameters.soldtoparty        as Soldtoparty,
      _Parameters.validasof          as Validasof,
      _Parameters.updatedata         as Updatedata,
      _Parameters.attachment         as UploadFile,
      _Parameters.filename           as Filename,
      _Parameters.mimetype           as Mimetype,
      _Parameters.localcreatedby     as Localcreatedby,
      _Parameters.localcreatedat     as Localcreatedat,
      _Parameters.locallastchangedby as Locallastchangedby,
      _Parameters.locallastchangedat as Locallastchangedat,
      _Parameters.lastchangedat      as Lastchangedat,
      _Materials,
      _Output
}

where
  _User.bname = $session.user
