/*******************************************************************************************
* @Name             BusinessLicense
* @Test class       BusinessLicenseTriggerTest
* @Author           Gabriel Piragibe Cova Leda de Almeida
* @Date             23-09-2022
* @Story#           225789 (SR-QI ART Planning Sprint 4)
* @LWC Component    None
* @Description      Dispatch after update in Services object and depending on conditions
*                   system exemptions will be created or recalculation of subcategories will
be executed
*******************************************************************************************/
/* MODIFICATION LOG
* Version       Developer                                Date                Description
*-------------------------------------------------------------------------------------------
*  1.0     		Gabriel Piragibe Cova Leda de Almeida    23-09-2022          Initial Creation                                                       
*******************************************************************************************/
trigger BusinessLicense on BusinessLicense (after insert, after update, before delete) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        switch on Trigger.operationType {
            when AFTER_UPDATE{
                TriggerDispatcher.dispatch(new BusinessLicenseHandler(), TriggerOperation.AFTER_UPDATE);
            }

            when AFTER_INSERT{
                TriggerDispatcher.dispatch(new BusinessLicenseHandler(), TriggerOperation.AFTER_INSERT);
            }

            when BEFORE_DELETE{
                TriggerDispatcher.dispatch(new BusinessLicenseHandler(), TriggerOperation.BEFORE_DELETE);
            }
        }
    }
}