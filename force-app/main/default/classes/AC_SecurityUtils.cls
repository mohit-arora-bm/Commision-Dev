public with sharing class AC_SecurityUtils  
{
    @testVisible 
    private Enum OperationType { CREATE, READ, MODIFY, DEL } //UPDATE and DELETE are reserved words

    public virtual class SecurityException extends Exception {
        protected OperationType m_operation;
        protected Schema.SObjectType m_objectType;
    }    
    public class CrudException extends SecurityException{
        
        private CrudException(OperationType operation, Schema.SObjectType objectType){
            this.m_operation = operation;
            this.m_objectType = objectType;
            if(operation == OperationType.CREATE)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not insertable.');
            else if(operation == OperationType.READ)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not readable.');
            else if(operation == OperationType.MODIFY)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not updateable.');
            else if(operation == OperationType.DEL)                
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not deletable.');

            this.setMessage(
                String.format(
                    this.getMessage(),
                    new List<String>{
                        objectType.getDescribe().getName()
                    } 
                )
            );
        }
    }
    
    public class FlsException extends SecurityException{
        private Schema.SObjectField m_fieldToken;

        private FlsException(OperationType operation, Schema.SObjectType objectType, Schema.SObjectField fieldToken){
            this.m_operation = operation;
            this.m_objectType = objectType;
            this.m_fieldToken = fieldToken;
            if(operation == OperationType.CREATE)
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + ' not insertable.');
            else if(operation == OperationType.READ)
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + '  not readable.');
            else if(operation == OperationType.MODIFY)
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + '  not updateable.');

            this.setMessage(
                String.format(
                    this.getMessage(),
                    new List<String>{
                        objectType.getDescribe().getName(),
                        fieldToken.getDescribe().getName()
                    }
                )
            );
        }
    }
        
    public static boolean BYPASS_INTERNAL_FLS_AND_CRUD = false;
    
    public static void checkInsert(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsInsertable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsInsertable(objType, fieldName);
        }
    }
        
    public static void checkInsert(SObjectType objType, List<SObjectField> fieldTokens)
    {
        checkObjectIsInsertable(objType);
        for (SObjectField fieldToken : fieldTokens)
        {
            checkFieldIsInsertable(objType, fieldToken);
        }
    }

    // throw no exception - insert
    public static Map<String, Schema.SObjectField> checkInsertNoException(SObjectType objType, Map<String, Schema.SObjectField> fieldsMap) {
        checkObjectIsInsertable(objType);
        Map<String, Schema.SObjectField> creatableFieldsMap = new Map<String, Schema.SObjectField>();
        for(String fieldAPIName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldAPIName).getDescribe().isCreateable()) {
                creatableFieldsMap.put(fieldAPIName, fieldsMap.get(fieldAPIName));
            }
        }
        return creatableFieldsMap;
    }

    // check whether sobjectType is creatable or not and throw no exception - insert
    public static Boolean checkInsertNoException( SObjectType objType ) {
        return checkObjectIsInsertableNoException(objType);
    }

    // throw no exception - read
    public static Map<String, Schema.SObjectField> checkReadNoException(SObjectType objType, Map<String, Schema.SObjectField> fieldsMap) {
        checkObjectIsReadable(objType);
        Map<String, Schema.SObjectField> readableFieldsMap = new Map<String, Schema.SObjectField>();
        for(String fieldAPIName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldAPIName).getDescribe().isAccessible()) {
                readableFieldsMap.put(fieldAPIName, fieldsMap.get(fieldAPIName));
            }
        }
        return readableFieldsMap;
    }

    /*throw no exceptions for fields
    public static List<String> checkReadNoException(String objName, List<String> fieldList) {
        List<String> accesiblefieldList = new List<String>();
                
        Map<String, Schema.SObjectField> fieldsMapDescribe  = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();

        for(String fld :  fieldsMapDescribe.keySet()) {
            for( String fldName : fieldList ) {
                if( fldName == fld &&  fieldsMapDescribe.get( fld ).getDescribe().isAccessible() ) {
                    accesiblefieldList.add( fld );
                }
            }
            
        }
        return accesiblefieldList;
    }*/
   
    public static void checkRead(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsReadable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsReadable(objType, fieldName);
        }
    }
        
    public static void checkRead(SObjectType objType, List<SObjectField> fieldTokens)
    {
        checkObjectIsReadable(objType);
        for (SObjectField fieldToken : fieldTokens)
        {
            checkFieldIsReadable(objType, fieldToken);
        }
    }

    
    public static void checkUpdate(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsUpdateable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsUpdateable(objType, fieldName);
        }
    }
        
    public static void checkUpdate(SObjectType objType, List<SObjectField> fieldTokens)
    {
        checkObjectIsUpdateable(objType);
        for (SObjectField fieldToken : fieldTokens)
        {
            checkFieldIsUpdateable(objType, fieldToken);
        }
    }

    public static void checkFieldIsInsertable(SObjectType objType, String fieldName)
    {
        checkFieldIsInsertable(objType, AC_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    public static void checkFieldIsInsertable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsInsertable(objType, fieldToken.getDescribe());
    }

    public static void checkFieldIsInsertable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isCreateable())
            throw new FlsException(OperationType.CREATE, objType, fieldDescribe.getSObjectField());
    }
 
    public static void checkFieldIsReadable(SObjectType objType, String fieldName)
    {
        checkFieldIsReadable(objType, AC_SObjectDescribe.getDescribe(objType).getField(fieldName.trim()));
    }

    public static void checkFieldIsReadable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsReadable(objType, fieldToken.getDescribe());
    }

    public static void checkFieldIsReadable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isAccessible())
            throw new FlsException(OperationType.READ, objType, fieldDescribe.getSObjectField());
    }
    
    public static void checkFieldIsUpdateable(SObjectType objType, String fieldName)
    {
        checkFieldIsUpdateable(objType, AC_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    public static void checkFieldIsUpdateable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsUpdateable(objType, fieldToken.getDescribe());
    }

    public static void checkFieldIsUpdateable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isUpdateable())
            throw new FlsException(OperationType.MODIFY, objType, fieldDescribe.getSObjectField());
    }

    public static void checkObjectIsInsertable(SObjectType objType)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isCreateable())
        {
            throw new CrudException(OperationType.CREATE, objType);
        }
    }

    public static Boolean checkObjectIsInsertableNoException(SObjectType objType)
    {
        if (objType.getDescribe().isCreateable()) {
           return true;
        }else {
            return false;
        }
    }
    /*public static Boolean checkObjectIsReadableNoException(SObjectType objType)
    {
        if (objType.getDescribe().isAccessible()) {
           return true;
        }else {
            return false;
        }
    }*/
    
    public static void checkObjectIsReadable(SObjectType objType)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isAccessible())
            throw new CrudException(OperationType.READ, objType);
    }

    public static void checkObjectIsUpdateable(SObjectType objType)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isUpdateable())
            throw new CrudException(OperationType.MODIFY, objType);
    }

    public static void checkObjectIsDeletable(SObjectType objType)
    {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isDeletable())
            throw new CrudException(OperationType.DEL, objType);
    }

     public static Boolean checkObjectIsDeletableNoException(SObjectType objType) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return false;
        if (objType.getDescribe().isDeletable()) {
            return true;
        }else {
           return false; 
        }

    }

    
   /* public static void checkInsertThrowException( SObjectType objType, Schema.DescribeFieldResult fldDescribe) {
          throw new FlsException(OperationType.CREATE, objType, fldDescribe.getSObjectField());
    }

    public static void checkUpdateThrowException( SObjectType objType, Schema.DescribeFieldResult fldDescribe) {
          throw new FlsException(OperationType.MODIFY, objType, fldDescribe.getSObjectField());
    }*/
}