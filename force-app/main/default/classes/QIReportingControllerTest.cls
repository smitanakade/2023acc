@isTest
public with sharing class QIReportingControllerTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();
        Integer currentYear =  System.Today().year();
        Integer lastYear =  currentYear - 1;
		Test.startTest();
		System.runAs(testUser){
            List<Reporting_Period__c> quarters = new List<Reporting_Period__c>();
            // create Q1
            Reporting_Period__c q1 = new Reporting_Period__c();
            q1.Reporting_Period_Type__c = 'Quarter';
            q1.Start_Date__c = Date.newInstance(lastYear, 07, 01);
            q1.End_Date__c = Date.newInstance(lastYear, 09, 31);
            q1.QI_Submission_Due_Dt__c   = Date.newInstance(lastYear, 10, 21);
            quarters.add(q1);

            // create Q2
            Reporting_Period__c q2 = new Reporting_Period__c();
            q2.Reporting_Period_Type__c = 'Quarter';
            q2.Start_Date__c = Date.newInstance(lastYear, 10, 01);
            q2.End_Date__c = Date.newInstance(lastYear, 12, 31);
            q2.QI_Submission_Due_Dt__c   = Date.newInstance(currentYear, 01, 21);
            quarters.add(q2);

            // create Q3
            Reporting_Period__c q3 = new Reporting_Period__c();
            q3.Reporting_Period_Type__c = 'Quarter';
            q3.Start_Date__c = Date.newInstance(currentYear, 01, 01);
            q3.End_Date__c = Date.newInstance(currentYear, 03, 31);
            q3.QI_Submission_Due_Dt__c   = Date.newInstance(currentYear, 04, 21);
            quarters.add(q3);

            // create Q4
            Reporting_Period__c q4 = new Reporting_Period__c();
            q4.Reporting_Period_Type__c = 'Quarter';
            q4.Start_Date__c = Date.newInstance(currentYear, 04, 01);
            q4.End_Date__c = Date.newInstance(currentYear, 06, 31);
            q4.QI_Submission_Due_Dt__c   = Date.newInstance(currentYear, 07, 21);
            quarters.add(q4);

            insert quarters;
        }
        Test.stopTest();
    }


    @istest
    static void getReportingQuartersTest(){
        User testUser = TestDataFactory.createSystemAdminUser();
		System.runAs(testUser){
            List<Reporting_Period__c> result = new List<Reporting_Period__c>();
            test.startTest();
            result = QIReportingController.getReportingQuarters();
            System.assert(result.size() > 0  , result.size() + ' quarters returned. 4 expected' );
            test.stopTest();
        }
     }

     @istest
     static void getReportingForQuarter1Test(){
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser){
            Map<String , Reporting_Period__c> resultMap = new Map<String , Reporting_Period__c>();
            test.startTest();
            QIReportingController.getReportingForQuarter1( System.Today().year() - 1 ,  System.Today().year() , resultMap);
            System.assert(resultMap.size() > 0 , resultMap.size() + ' quarters returned. 3 expected' );
            test.stopTest();
        }
      }

      @istest
      static void getReportingForQuarter2Test(){
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser){
            Map<String , Reporting_Period__c> resultMap = new Map<String , Reporting_Period__c>();
            test.startTest();
            QIReportingController.getReportingForQuarter2( System.Today().year() , resultMap);
            System.assert(resultMap.size() > 0 , resultMap.size() + ' quarters returned. 3 expected' );
            test.stopTest();
        }
       }

       @istest
       static void getReportingForQuarter3Test(){
        User testUser = TestDataFactory.createSystemAdminUser();
            System.runAs(testUser){
                Map<String , Reporting_Period__c> resultMap = new Map<String , Reporting_Period__c>();
                test.startTest();
                QIReportingController.getReportingForQuarter3( System.Today().year() , resultMap);
                System.assert(resultMap.size() > 0 , resultMap.size() + ' quarters returned. 3 expected' );
                test.stopTest();
            }
        }

        @istest
        static void getReportingForQuarter4Test(){
         User testUser = TestDataFactory.createSystemAdminUser();
             System.runAs(testUser){
                 Map<String , Reporting_Period__c> resultMap = new Map<String , Reporting_Period__c>();
                 test.startTest();
                 QIReportingController.getReportingForQuarter4( System.Today().year() ,  System.Today().year() - 1 , resultMap);
                 System.assert(resultMap.size() > 0 , resultMap.size() + ' quarters returned. 3 expected' );
                 test.stopTest();
             }
         }
      
}