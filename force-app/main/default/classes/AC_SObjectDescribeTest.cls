@isTest
private class AC_SObjectDescribeTest {

    /**
     * Verify that the different ways of getting your hands on an SObjectDescribeinstance all handle null inputs
     * (and blank/empty strings, why not?) by returning null - since there's no possible way to resolve it.
    **/
    @isTest
    static void getDescribe_badInput(){
        String nullStr = null; //having it as a string var makes for unambiguous selection of overloads
        Schema.SObjectType nullType = null;
        Schema.DescribeSObjectResult nullDescribe = null;
        SObject nullSObject = null;
        System.assertEquals(null, AC_SObjectDescribe.getDescribe(nullStr));
        System.assertEquals(null, AC_SObjectDescribe.getDescribe(''));
        System.assertEquals(null, AC_SObjectDescribe.getDescribe(' '));
        System.assertEquals(null, AC_SObjectDescribe.getDescribe(nullType));
        System.assertEquals(null, AC_SObjectDescribe.getDescribe(nullDescribe));
        System.assertEquals(null, AC_SObjectDescribe.getDescribe(nullSObject));
    }

    @isTest
    static void NamespacedAttributeMap_implementations(){
        AC_SObjectDescribe.GlobalDescribeMap gdm = AC_SObjectDescribe.getGlobalDescribe();
        Schema.SObjectType accountObjType = gdm.get('AccOunT');
        System.assertEquals(accountObjType, Account.SobjectType);
        //System.assertEquals(Schema.getGlobalDescribe().size(), gdm.size());

        AC_SObjectDescribe acccountDescribe = AC_SObjectDescribe.getDescribe(accountObjType);
        AC_SObjectDescribe.FieldsMap fields = acccountDescribe.getFields();
        System.assert( fields.keySet().containsAll(acccountDescribe.getFieldsMap().keySet()) );

        System.assertEquals(fields.get('name'), Account.SObjectType.fields.name); //behavior of FieldsMap is tested in another method
        System.assertEquals(Schema.SObjectType.Account.fields.getMap().size(), fields.size());

        System.assertEquals(null, fields.get(null), 'Null input should result in null ouput.');
        System.assertEquals(null, fields.get(''), 'Invalid fieldname input should result in null ouput.');
    }

    @isTest
    static void FieldsMap(){
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectField> fakeFieldData = new Map<String,Schema.SObjectField>{
            'name__c' => Contact.SObjectType.fields.name, //re-use standard field types since we can't mock them
            fakeNamespace+'__name__c' => Account.SObjectType.fields.name,
            fakeNamespace+'__otherField__c' => Account.SObjectType.fields.name,
            'createddate' => Contact.SObjectType.fields.CreatedDate
        };
        AC_SObjectDescribe.FieldsMap fields = new AC_SObjectDescribe.FieldsMap(fakeFieldData);
        fields.currentNamespace = fakeNamespace;
        System.assertEquals(true, fields.containsKey('name__c') );
        System.assertEquals(true, fields.containsKey(fakeNamespace.toUpperCase()+'__nAMe__c') );
        System.assert(fields.get('NAme__c') === fields.get(fakeNamespace+'__namE__c'));

        System.assert(!fields.keySet(false).contains('otherField__c'));
        System.assert(fields.keySet(false).contains(fakeNamespace+'__otherField__c'));

        System.assert(fields.keySet(true).contains('otherField__c'));
        System.assert(!fields.keySet(true).contains(fakeNamespace+'__otherField__c'));

        fields.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(fields.get('name__C'), fields.get(fakeNamespace.capitalize()+'__nAme__c'));
    }

    @isTest
    static void GlobalDescribeMap(){
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectType> fakeFieldData = new Map<String,Schema.SObjectType>{
            'name__c' => Contact.SObjectType, //re-use stndard object types since we can't mock them
            fakeNamespace+'__name__c' => Account.SObjectType,
            'createddate' => Lead.SObjectType
        };
        AC_SObjectDescribe.GlobalDescribeMap gdm = new AC_SObjectDescribe.GlobalDescribeMap(fakeFieldData);
        gdm.currentNamespace = fakeNamespace;
        System.assertEquals(true, gdm.containsKey('name__c') );
        System.assertEquals(true, gdm.containsKey(fakeNamespace+'__name__c') );
        System.assert(gdm.get('name__c') === gdm.get(fakeNamespace+'__name__c'));

        gdm.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(gdm.get('name__c'), gdm.get(fakeNamespace+'__name__c'));
    }

    @isTest //Tests all forms of the getDescribe static
    static void getAccountDescribes(){
        AC_SObjectDescribe d = AC_SObjectDescribe.getDescribe('Account');
        AC_SObjectDescribe d2 = AC_SObjectDescribe.getDescribe(Account.SObjectType);
        AC_SObjectDescribe d3 = AC_SObjectDescribe.getDescribe(Schema.SObjectType.Account);
        System.assertEquals('Account', d.getDescribe().getName());
        System.assert( (d === d2 && d2 === d3) ,'All three getDescribe calls should return the same cached instance.');
    }

    @isTest
    static void simpleAccountFieldDescribe(){
        AC_SObjectDescribe d = AC_SObjectDescribe.getDescribe(Account.SObjectType);
        Map<String,Schema.SObjectField> fields;
        for(integer i = 0; i < 10; i++){
            fields = d.getFieldsMap();
        }

        // Describe Limits removed since Summer ’14.
        // https://developer.salesforce.com/releases/release/Summer14/New+Apex+Enhancements

        // Because describe limits are no longer enforced in any API version, this method is no longer available.
        // In API version 30.0 and earlier, this method is available but is deprecated.

        // System.assertEquals(1, Limits.getFieldsDescribes() );

        System.assertEquals(false,fields.isEmpty());
        System.assertEquals(Account.SObjectType, d.getSObjectType());
    }

    
    @isTest
        static void simpleAccountGetNameField(){
            AC_SObjectDescribe d = AC_SObjectDescribe.getDescribe(Account.SObjectType);
            Schema.SObjectField nameField = d.getNameField();
            System.assertEquals('Name', nameField.getDescribe().getName());
    }

    @isTest
    static void flushCache(){
        AC_SObjectDescribe d = AC_SObjectDescribe.getDescribe('Account');
        AC_SObjectDescribe.flushCache();
        AC_SObjectDescribe d2 = AC_SObjectDescribe.getDescribe('Account');
        System.assert(d !== d2, 'Second object should be a fresh instance after a cache flush.' );
    }

    @isTest
    static void rawGlobalDescribeCheck(){
        Map<String,Schema.SObjectType> systemGd = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectType> cachedGd = AC_SObjectDescribe.getRawGlobalDescribe();
        //System.assertEquals(systemGd.size(),cachedGd.size());
    }

}