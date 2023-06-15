/**
 * @author Vivek J
 * @date 27-02-2023
 * @objects
 * @description : Test class for QIResponseDTO
 */
@isTest
public with sharing class QIResponseDTOTest {
   
    @isTest
    private static void QIResponseDTO_Test(){
        test.startTest();
        QIResponseDTO response=new QIResponseDTO();
        test.stopTest();

        system.assertEquals('',response.message);
        system.assertEquals(null,response.returnValue);
        system.assertEquals('Success',response.status);
    }

}