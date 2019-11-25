@isTest
private class AC_SecurityUtilsTest {
    static User setupTestUser(String profileName){
        //username global uniqueness is still enforced in tests 
        //make sure we get something unique to avoid issues with parallel tests
        String uniqueness = DateTime.now()+':'+Math.random();
        try{ 
            throw new NullPointerException();
        }catch(Exception e){
            uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
        }
        Profile p = [SELECT id, Name FROM Profile WHERE Name = :profileName];
        User result = new User(
            username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
            alias = 'testExec',
            email='apextests@example.com',
            emailencodingkey='UTF-8',
            lastname='Testing',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/Los_Angeles'
        );
        insert result;
        return result;
    }
    
    @isTest
    static void readonly_field_access() {
        User testUser = setupTestUser('Read Only');
        System.runAs(testUser){
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkObjectIsDeletableNoException(Opportunity.SObjectType);
                    AC_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account.Name');
                System.assert(ex instanceof AC_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertEquals(null, ex, 'Read only profile should be able to read Contact.LastName');
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead.Company');
                System.assert(ex instanceof AC_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
            }
            
            AC_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
            { //no exceptions, despite no rights
                AC_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
                AC_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
                AC_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
            }
        }
    }
    
    @isTest
    static void readonly_object_access() {
        User testUser = setupTestUser('Read Only');
        System.runAs(testUser){
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account');
                System.assert(ex instanceof AC_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
                System.assert(ex instanceof AC_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
                    AC_SecurityUtils.checkObjectIsDeletableNoException(Opportunity.SObjectType);
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to delete Opportunity');
                System.assert(ex instanceof AC_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            
            AC_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
            { //no exceptions, despite no rights
                AC_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
                AC_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
                AC_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
                AC_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
            }
        }
    }
    
    @isTest
    static void readonly_objectAndField_access() {
        User testUser = setupTestUser('Read Only');
        System.runAs(testUser){
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkInsert(
                        Account.SObjectType,
                        new List<String>{
                            'Name',
                                'ParentId',
                                'ownerId'
                                }
                    );
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account');
                System.assert(ex instanceof AC_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkRead(
                        Contact.SObjectType,
                        new List<String>{
                            'LastName',
                                'accountId',
                                'ownerId'
                                }
                    );
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
            }
            {
                AC_SecurityUtils.SecurityException ex;
                try{
                    AC_SecurityUtils.checkUpdate(
                        Lead.SObjectType,
                        new List<String>{
                            'LastName',
                                'FirstNAMe',
                                'cOMPANY'
                                }
                    );
                }catch(AC_SecurityUtils.SecurityException e){
                    ex = e;
                }
                System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
                System.assert(ex instanceof AC_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
            }
            
            AC_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
            { //no exceptions, despite no rights
                AC_SecurityUtils.checkInsert(
                    Account.SObjectType,
                    new List<String>{
                        'Name',
                            'Type',
                            'ownerId'
                            }
                );
                AC_SecurityUtils.checkRead(
                    Contact.SObjectType,
                    new List<String>{
                        'LastName',
                            'accountId',
                            'ownerId'
                            }
                );
                AC_SecurityUtils.checkUpdate(
                    Lead.SObjectType,
                    new List<String>{
                        'LastName',
                            'FirstNAMe',
                            'cOMPANY'
                            }
                );
            }
        }
    }
    
    @isTest
    static void sysadmin_objectAndField_access() {
        User testUser = setupTestUser('System Administrator');
        System.assertEquals(testUser.alias,'testExec');
        System.runAs(testUser){
            AC_SecurityUtils.checkInsert(
                Account.SObjectType,
                new List<Schema.SObjectField>{
                    Account.SObjectType.fields.Name,
                        Account.SObjectType.fields.ParentId,
                        Account.SObjectType.fields.ownerId
                        }
            );
            AC_SecurityUtils.checkRead(
                Contact.SObjectType,
                new List<Schema.SObjectField>{
                    Contact.SObjectType.fields.LastName,
                        Contact.SObjectType.fields.accountId,
                        Contact.SObjectType.fields.ownerId
                        }
            );
            AC_SecurityUtils.checkUpdate(
                Lead.SObjectType,
                new List<Schema.SObjectField>{
                    Lead.SObjectType.fields.LastName,
                        Lead.SObjectType.fields.FirstNAMe,
                        Lead.SObjectType.fields.cOMPANY
                        }
            );
            
            Map<String, Schema.SObjectField> mapOfSobjFields = new Map<String, Schema.SObjectField>();
            mapOfSobjFields.put( 'LastName',  Lead.SObjectType.fields.LastName);
            
            Map<String, Schema.SObjectField> mapOfSobjFieldsFiletered1 = AC_SecurityUtils.checkInsertNoException(
                Lead.SObjectType, mapOfSobjFields
            );
            
            Map<String, Schema.SObjectField> mapOfSobjFieldsFiletered2 = AC_SecurityUtils.checkReadNoException(
                Lead.SObjectType, mapOfSobjFields
            );
            
            Boolean isObjCreatable = AC_SecurityUtils.checkInsertNoException(Account.SObjectType);
            System.assert(isObjCreatable != NULL);
            
        }
    }
    
}