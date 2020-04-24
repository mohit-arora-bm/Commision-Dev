global with sharing class AC_SchedulerTemplateController {

    static Map<String,String> symbolMap = new Map<String,String>();
    global static String uniqueId;
    @AuraEnabled
    global static void scheduleTemplate(String templateId, String cronExp, String scheduleOn, String expiresOn, String userId){
        try {
            AC_SecurityUtils.checkUpdate( agileComp__AC_Templates_Config__c.SObjectType,new List<String> {
                'agileComp__AC_SuccessDateMap__c'
            });

            List<agileComp__AC_Templates_Config__c> configs = [SELECT 
                                                               agileComp__AC_Object__c,
                                                               agileComp__AC_TemplateDataJson__c,
                                                               agileComp__AC_Name__c,
                                                               agileComp__AC_SuccessDateMap__c,
                                                               agileComp__AC_BatchClassName__c
                                                               FROM agileComp__AC_Templates_Config__c
                                                               WHERE Id = : templateId];
                System.debug(expiresOn);
            
            if (!configs.isEmpty()) { 
                
                List<DataListWrapper> dataList = (List<DataListWrapper>)JSON.deserialize(configs[0].agileComp__AC_TemplateDataJson__c,List<DataListWrapper>.class);
                List<String> JSONStrs = new List<String>();
                Map<Integer,Datetime> SuccessDateMap = new Map<Integer,Datetime>();
                Integer index = 1;
                Datetime currentDate = null;
                if (!String.isEmpty(configs[0].agileComp__AC_SuccessDateMap__c)) {
                    Map<Integer,Datetime> oldDateMap = (Map<Integer,Datetime>)JSON.deserialize(configs[0].agileComp__AC_SuccessDateMap__c, Map<Integer,Datetime>.class);
                    List<Datetime> oldDates = oldDateMap.values();
                    oldDates.sort();
                    currentDate = oldDates[0];
                }
                
                for(DataListWrapper obj : dataList) {
                    JSONStrs.add(JSON.serialize(obj));
                    SuccessDateMap.put(index,currentDate);
                    index++;
                }
                // if (String.isEmpty(configs[0].agileComp__AC_SuccessDateMap__c)) {
                    configs[0].agileComp__AC_SuccessDateMap__c = JSON.serialize(SuccessDateMap); 
                // }
                System.debug('JSONStrs.size' + JSONStrs.size());
                update configs;
                TemplateBatchScheduler sc = new TemplateBatchScheduler(JSONStrs,configs[0].agileComp__AC_Object__c,templateId,configs[0].agileComp__AC_BatchClassName__c,userId);
                System.debug('cronExp     '+cronExp);
                if (!String.isEmpty(cronExp)) { 
                    String jobID = system.schedule(configs[0].agileComp__AC_Name__c, cronExp, sc);
                }
                System.debug('scheduleOn=====  '+scheduleOn);
                if (!String.isEmpty(scheduleOn)) {
                    scheduleOn = scheduleOn.replace('T', ' ');
                    scheduleOn = scheduleOn.substringBeforeLast('.');
                    DateTime scheduleDate = DateTime.valueOf(scheduleOn);
                    String cronStr = 'S Min H D M ? Y';
                    cronStr = cronStr.replace('S', String.valueOf(scheduleDate.second()));
                    cronStr = cronStr.replace('Min', String.valueOf(scheduleDate.minute()));
                    cronStr = cronStr.replace('H', String.valueOf(scheduleDate.hour()));
                    cronStr = cronStr.replace('D', String.valueOf(scheduleDate.day()));
                    cronStr = cronStr.replace('M', String.valueOf(scheduleDate.month()));
                    cronStr = cronStr.replace('Y', String.valueOf(scheduleDate.year()));
                    System.debug('cronStr--------------------      '+cronStr);
                    String jobID = system.schedule(configs[0].agileComp__AC_Name__c, cronStr, sc);
                    System.debug('jobID--------------------      '+jobID);
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }
    global static void createCommisionInput(String objStr, String objAPI, List<AggregateResult> baseObjList, String templateId) {
   
        System.debug('baseObjListbaseObjList>>>'+baseObjList.size());
        try {
            AC_SecurityUtils.checkRead( agileComp__AC_Templates_Config__c.SObjectType,new List<String> {
                'Name',
                'agileComp__AC_TemplateDataJson__c',
                'agileComp__AC_Object__c',
                'agileComp__AC_Name__c',
                'agileComp__AC_SuccessDateMap__c'
                });
            AC_SecurityUtils.checkUpdate( agileComp__commissionBaseInput__c.SObjectType,new List<String> {
                'Name',
                'agileComp__Templates_Config__c',
                'agileComp__Document_Date__c',
                'agileComp__Split_Percent__c'
                });
            AC_SecurityUtils.checkInsert( agileComp__commissionBaseInput__c.SObjectType,new List<String> {
                'Name',
                'agileComp__Templates_Config__c',
                'agileComp__Document_Date__c',
                'agileComp__Split_Percent__c'
                });
            AC_SecurityUtils.checkInsert( agileComp__Commission_Sales_Rep__c.SObjectType,new List<String> {
                'Name',
                'agileComp__isActive__c',
                'agileComp__Sales_Rep__c'
                });
            
            DataListWrapper obj = (DataListWrapper)JSON.deserialize(objStr, DataListWrapper.class);
            List<agileComp__commissionBaseInput__c> commInputs = new List<agileComp__commissionBaseInput__c>();
            Map<String,List<agileComp__commissionBaseInput__c>> oldCommInputMap = new  Map<String,List<agileComp__commissionBaseInput__c>>();
            List<String> userIds = new List<String>();
            
            Map<String,List<String>> fieldMapping = new Map<String,List<String>>();
            Map<String,String> fieldTypeMapping = new Map<String,String>();
            Map<String,List<agileComp__commissionSplit__c>> commSplitMap = new Map<String,List<agileComp__commissionSplit__c>>();
            
            Map<String,List<String>> splitFldIds = new Map<String,List<String>>();
            
            String salesRepFLD = '';
            List<agileComp__AC_Templates_Config__c> templates = [SELECT Id,agileComp__AC_SuccessDateMap__c FROM agileComp__AC_Templates_Config__c WHERE Id = : templateId];
            Datetime lastSuccessDate = null;
            
            if (!templates.isEmpty() && templates[0].agileComp__AC_SuccessDateMap__c != null) {
                Map<Integer,Datetime> SuccessDateMap = (Map<Integer,Datetime>)JSON.deserialize(templates[0].agileComp__AC_SuccessDateMap__c, Map<Integer,Datetime>.class);
                List<DateTime> successDateList = SuccessDateMap.values();
                successDateList.sort();
                lastSuccessDate = successDateList[0];
            }
            String AaccMainFld = '';
            String AdocMainFld = '';
            String accMainFld = '';
    
            if (obj.accountField.isFieldRelated) {
                accMainFld = ((DataWrapper)JSON.deserialize(obj.accountField.selectedField,DataWrapper.class)).relatedField;
            }
            else {
                accMainFld = obj.accountField.selectedField;
            }
            System.debug('accMainFld>>>'+accMainFld);
            String docMainFld = '';
            if (obj.documentField.isFieldRelated) {
                docMainFld = ((DataWrapper)JSON.deserialize(obj.documentField.selectedField,DataWrapper.class)).relatedField;
            }
            else {
                docMainFld = obj.documentField.selectedField;
            }
            System.debug('docMainFld>>>'+docMainFld);
            // create a fieldMap for Mapping base
            for(DataWrapper data : obj.selectedFieldOptions) {
                String selectedField = '';
                    
                if (!data.isFieldRelated) {
                    selectedField = data.selectedField;
                }
                else {
                    selectedField = ((DataWrapper)JSON.deserialize(data.selectedField,DataWrapper.class)).relatedField;
                }
                if(accMainFld == selectedField) {
                    AaccMainFld = data.customLabel;
                }
                else if (docMainFld == selectedField) {
                    AdocMainFld = data.customLabel;
                }
                if ( !String.isEmpty(data.mapping) && data.userLookup != true) {
                    fieldTypeMapping.put(data.mapping, data.apexDataType);
                    fieldMapping.put(data.customLabel, new List<String>{data.mapping,data.mathFunc});
                }
                else if (data.userLookup == true) {
                    salesRepFLD = data.customLabel;
                }
                
            }
            System.debug('salesRepFLD>>>'+salesRepFLD);
            List<List<String>> commInputFieldsToMap = fieldMapping.values();
            if (!commInputFieldsToMap.isEmpty()) {
                List<String> baseIds = new List<String>();
                List<String> accIds = new List<String>();
                Integer intId = 1;
                for (AggregateResult baseObj: baseObjList) {
                    if (!String.isEmpty(AdocMainFld)) {
                        baseIds.add(String.valueOf(baseObj.get(AdocMainFld)));
                    }
                    if (!String.isEmpty(AaccMainFld)) {
                        accIds.add(String.valueOf(baseObj.get(AaccMainFld)));
                    }
                    if (!String.isEmpty(salesRepFLD)) {
                        userIds.add(String.valueOf(baseObj.get(salesRepFLD)));
                    }
                }

                List<agileComp__Commission_Sales_Rep__c> saleReps = [SELECT Id,agileComp__Sales_Rep__c
                                                                        FROM agileComp__Commission_Sales_Rep__c 
                                                                        WHERE agileComp__isActive__c = true 
                                                                        AND agileComp__Sales_Rep__c IN : userIds];
    
                Map<String,String> userSalesRepMap = new Map<String,String>();
                for (agileComp__Commission_Sales_Rep__c rep : saleReps) {
                    userSalesRepMap.put(rep.agileComp__Sales_Rep__c,rep.Id);
                }

                System.debug('saleRepssaleReps>>> '+saleReps);
                Map<String,Schema.SObjectField> inputFieldMap = Schema.getGlobalDescribe().get('agileComp__commissionBaseInput__c').getDescribe().fields.getMap();
                Map<String,Schema.SObjectField> splitObjFieldMap = Schema.getGlobalDescribe().get('agileComp__commissionSplit__c').getDescribe().fields.getMap();
                String baseObjApi = '';
                if (!String.isEmpty(docMainFld)) {
                    if (docMainFld.toUpperCase() == 'ID') {
                        baseObjApi = objAPI;
                    }
                    else {
                        baseObjApi = obj.documentField.relatedObjectName;
                    }
                }
                String inputMainFld = '';
                String splitMainFld = '';
                if (!String.isEmpty(baseObjApi)) {
                    inputMainFld = fetchMainField(baseObjApi,inputFieldMap);
                    splitMainFld = fetchMainField(baseObjApi,splitObjFieldMap);
                }

                System.debug('splitMainFldsplitMainFldsplitMainFld>>'+splitMainFld+'   '+baseObjApi);
                AC_SecurityUtils.checkRead( agileComp__commissionSplit__c.SObjectType,new List<String> {
                'Name',
                'agileComp__accountSplit__c',
                'agileComp__Split_Percent__c',
                'agileComp__Commission_Sales_Rep__c',
                splitMainFld
                });
                System.debug('after slpit check ');
                String splitquery = 'SELECT Id,agileComp__accountSplit__c,agileComp__Split_Percent__c,agileComp__Commission_Sales_Rep__c ';
    
                if (splitMainFld != 'agileComp__accountSplit__c' && !String.isEmpty(splitMainFld)) {
                    splitquery += ',' + splitMainFld;
                }
                splitquery += ' FROM agileComp__commissionSplit__c';
                if ((!String.isEmpty(splitMainFld) && !baseIds.isEmpty()) || !accIds.isEmpty()) {
                    splitquery += ' WHERE ';
                }
                if (!String.isEmpty(splitMainFld) && !baseIds.isEmpty()) {
                    splitquery += splitMainFld +' IN : baseIds';
                }
                if ((!String.isEmpty(splitMainFld) && !baseIds.isEmpty()) && !accIds.isEmpty()) {
                    splitquery += ' OR ';
                }
                if (!accIds.isEmpty()) {
                    splitquery += 'agileComp__accountSplit__c IN : accIds';
                }
                System.debug('splitquerysplitquery>>'+splitquery+'  '+splitMainFld);
                List<agileComp__commissionSplit__c> commSplits = Database.query(splitquery);
                System.debug('splitquerysplitquery>>'+commSplits);
                List<String> splitIds = new List<String>();
                for (agileComp__commissionSplit__c cSplit : commSplits) {
                    if (!String.isEmpty(splitMainFld) && cSplit.get(splitMainFld) != null) {
                        if (commSplitMap.containsKey(String.valueOf(cSplit.get(splitMainFld)))) {
                            commSplitMap.get(String.valueOf(cSplit.get(splitMainFld))).add(cSplit);
                        }
                        else {
                            commSplitMap.put(String.valueOf(cSplit.get(splitMainFld)),new List<agileComp__commissionSplit__c>{cSplit});
                            
                        }
                    }
                    else if (cSplit.get('agileComp__accountSplit__c') != null) {
                        if (commSplitMap.containsKey(String.valueOf(cSplit.get('agileComp__accountSplit__c')))) {
                            commSplitMap.get(String.valueOf(cSplit.get('agileComp__accountSplit__c'))).add(cSplit);
                        }
                        else {
                            commSplitMap.put(String.valueOf(cSplit.get('agileComp__accountSplit__c')),new List<agileComp__commissionSplit__c>{cSplit});
                            
                        }
                    }
                }
                String commInputQuery = 'SELECT Id,agileComp__Account__c, agileComp__Document_Date__c,agileComp__Split_Percent__c,agileComp__documentType__c,agileComp__Commission_Sales_Rep__c,agileComp__Commission_Split__c';
                
                for(List<String> fld : fieldMapping.values()) {
                    if (!commInputQuery.containsIgnoreCase(fld[0])) {
                        commInputQuery += ',' + fld[0];
                    }
                }
                commInputQuery += ' FROM agileComp__commissionBaseInput__c  WHERE  agileComp__Templates_Config__c = : templateId AND agileComp__Commission_Base_Unique_Id__c =: uniqueId ';
                if (!String.isEmpty(inputMainFld)) {
                    commInputQuery += 'AND ' + inputMainFld + ' IN : baseIds';
                }
                if (lastSuccessDate != null) {
                    commInputQuery += ' AND CreatedDate >= ' + lastSuccessDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                }
                List<agileComp__commissionBaseInput__c> oldCommInputs = Database.query(commInputQuery);
                
                for (agileComp__commissionBaseInput__c commInput : oldCommInputs) {
                    String key = '';
                    if (! String.isEmpty(String.valueOf(commInput.get(inputMainFld)))) {
                        key += String.valueOf(commInput.get(inputMainFld)).trim();
                    }
                    key += '-';
                    // String key = String.valueOf(commInput.get(inputMainFld)).trim() + '-' ;
                    if (!String.isEmpty(String.valueOf(commInput.get('agileComp__Account__c')))) {
                        key += String.valueOf(commInput.get('agileComp__Account__c')).trim();
                    }
                    key += '-';
                    if (!String.isEmpty(String.valueOf(commInput.get('agileComp__Commission_Split__c')))) {
                        key +=  String.valueOf(commInput.get('agileComp__Commission_Split__c')).trim();
                    }
                    if (oldCommInputMap.containsKey(key)) {
                        oldCommInputMap.get(key).add(commInput);
                    }
                    else {
                        oldCommInputMap.put(key,new List<agileComp__commissionBaseInput__c>{commInput});
                    }
                }
                for (AggregateResult  baseObj: baseObjList) {
                    System.debug('in aggregate result '+baseObj);
                    String key =  String.valueOf(baseObj.get(AdocMainFld)) + '-';
                    if (!String.isEmpty(AaccMainFld) && !String.isEmpty(String.valueOf(baseObj.get(AaccMainFld)))) {
                        key += String.valueOf(baseObj.get(AaccMainFld)).trim();
                    }
                    key += '-';
                    if (!String.isEmpty(AdocMainFld) && commSplitMap.containsKey(String.valueOf(baseObj.get(AdocMainFld)))) {
                        System.debug('in doc field '+AdocMainFld+'  '+String.valueOf(baseObj.get(AdocMainFld)));
                        List<agileComp__commissionSplit__c> tempCommSplits = commSplitMap.get(String.valueOf(baseObj.get(AdocMainFld)));
                        for (agileComp__commissionSplit__c commSplit : tempCommSplits) {
                            if (oldCommInputMap.containsKey(key + commSplit.Id)) {
                                List<agileComp__commissionBaseInput__c> oCommInputs = oldCommInputMap.get(key + commSplit.Id);
                                if (!oCommInputs.isEmpty()) {
                                    agileComp__commissionBaseInput__c ci = oCommInputs.remove(0);
                                    oldCommInputMap.put(key + commSplit.Id,oCommInputs);
                                    // update commInput
                                    agileComp__commissionBaseInput__c commInput = createCommInputObj(fieldMapping, commSplit.agileComp__Split_Percent__c, baseObj,salesRepFLD,commSplit.agileComp__Commission_Sales_Rep__c,userSalesRepMap,commSplit.Id,templateId,fieldTypeMapping,'DS',ci);
                                    if (commInput != null) {
                                        commInputs.add(commInput);
                                    }
                                }
                            }
                            else {
                                // create new commInput
                                agileComp__commissionBaseInput__c commInput = createCommInputObj(fieldMapping, commSplit.agileComp__Split_Percent__c, baseObj,salesRepFLD,commSplit.agileComp__Commission_Sales_Rep__c,userSalesRepMap,commSplit.Id,templateId,fieldTypeMapping,'DS',null);
                                if (commInput != null) {
                                    commInput.agileComp__Commission_Base_Unique_Id__c = uniqueId;
                                    commInputs.add(commInput);
                                }
                            }
                        }
                        
                    }
                    else if (!String.isEmpty(AaccMainFld) && commSplitMap.containsKey(String.valueOf(baseObj.get(AaccMainFld)))) {
                        System.debug('in ACC field '+AdocMainFld+'  '+String.valueOf(baseObj.get(AdocMainFld)));
                        List<agileComp__commissionSplit__c> tempCommSplits = commSplitMap.get(String.valueOf(baseObj.get(AaccMainFld)));
                        for (agileComp__commissionSplit__c commSplit : tempCommSplits) {
                            
                            if (oldCommInputMap.containsKey(key + commSplit.Id)) {
                                List<agileComp__commissionBaseInput__c> oCommInputs = oldCommInputMap.get(key + commSplit.Id);
                                if (!oCommInputs.isEmpty()) {
                                    agileComp__commissionBaseInput__c ci = oCommInputs.remove(0);
                                    oldCommInputMap.put(key + commSplit.Id,oCommInputs);
                                    // update commInput
                                    agileComp__commissionBaseInput__c commInput = createCommInputObj(fieldMapping, commSplit.agileComp__Split_Percent__c, baseObj,salesRepFLD,commSplit.agileComp__Commission_Sales_Rep__c,userSalesRepMap,commSplit.Id,templateId,fieldTypeMapping,'AS',ci);
                                    if (commInput != null) {
                                        commInputs.add(commInput);
                                    }
                                }
                            }
                            else {
                                // create new commInput
                                agileComp__commissionBaseInput__c commInput = createCommInputObj(fieldMapping, commSplit.agileComp__Split_Percent__c, baseObj,salesRepFLD,commSplit.agileComp__Commission_Sales_Rep__c,userSalesRepMap,commSplit.Id,templateId,fieldTypeMapping,'AS',null);
                                if (commInput != null) {
                                    commInput.agileComp__Commission_Base_Unique_Id__c = uniqueId;
                                    commInputs.add(commInput);
                                }
                            }
                        }
                    }
                    else {
                        System.debug('in else ');
                       if (oldCommInputMap.containsKey(key)) {
                            List<agileComp__commissionBaseInput__c> oCommInputs = oldCommInputMap.get(key);
                            if (!oCommInputs.isEmpty()) {
                                agileComp__commissionBaseInput__c ci = oCommInputs.remove(0);
                                oldCommInputMap.put(key,oCommInputs);
                                agileComp__commissionBaseInput__c commInput = createCommInputObj(fieldMapping, 100, baseObj,salesRepFLD,'',userSalesRepMap,null,templateId,fieldTypeMapping,'None',ci);
                                if (commInput != null) {
                                    commInputs.add(commInput);
                                } 
                            }
                        }
                        else {
                            System.debug('in inner else');
                            agileComp__commissionBaseInput__c commInput = createCommInputObj(fieldMapping, 100, baseObj,salesRepFLD,'',userSalesRepMap,null,templateId,fieldTypeMapping,'None',null);
                            System.debug('in inner else '+commInput);
                            if (commInput != null) {
                                commInput.agileComp__Commission_Base_Unique_Id__c = uniqueId;
                                commInputs.add(commInput);
                            }
                        }
                        
                    }
                    
                }
                upsert commInputs;
            }
        } catch (Exception ex) {
            AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());
        }
        
        
    }
    private static agileComp__commissionBaseInput__c createCommInputObj( Map<String,List<String>> fieldMapping, 
                                                                        Decimal percent,
                                                                        AggregateResult baseObj, 
                                                                        String salesRepFLD, 
                                                                        String salesRepId, 
                                                                        Map<String,String> userSalesRepMap,
                                                                        String splitId, 
                                                                        String templateId,
                                                                        Map<String,String> fieldTypeMapping,
                                                                        String type,
                                                                        agileComp__commissionBaseInput__c oldCommInput) {
                                                                            System.debug(Date.today().year()+' ' +Date.today().month()+' '+Date.today().day());
        String commInputStr = '{ "agileComp__Document_Date__c" : "' + Date.today().year() + '-' + Date.today().month() +'-' + Date.today().day() + '","agileComp__Split_Percent__c" : "' + percent +'","agileComp__Split_Document_Origin__c" : "'+type+'",';
        for (String key: fieldMapping.keySet()) {
            if (baseObj.get(key) != null) {
                commInputStr += '"' + fieldMapping.get(key)[0] + '":' ;
                if (!String.isEmpty(fieldMapping.get(key)[1])) {
                    Decimal dValue = 0;
                    if (fieldMapping.get(key)[1] == 'Absolute') {
                        dValue = Math.abs(Decimal.valueOf(String.valueOf(baseObj.get(key))));
                    }
                    else if(fieldMapping.get(key)[1] == 'Invert'){
                        dValue = -1 * Decimal.valueOf(String.valueOf(baseObj.get(key)));
                    }
                    commInputStr += '"' + dValue + '",';
                }
                else if (fieldTypeMapping.containsKey(fieldMapping.get(key)[0]) && fieldTypeMapping.get(fieldMapping.get(key)[0]).contains('DATE')) {
                    Date objDate = Date.valueOf(baseObj.get(key));
                    commInputStr += '"' +  objDate.year() + '-' + objDate.month() +'-' + objDate.day() + '",';
                }
                else {
                    commInputStr += '"' + baseObj.get(key) + '",';
                }
            }
        }
        commInputStr = commInputStr.substringBeforeLast(',');
        commInputStr += '}';
        agileComp__commissionBaseInput__c commInput = (agileComp__commissionBaseInput__c)JSON.deserialize(commInputStr, agileComp__commissionBaseInput__c.class);
        if (oldCommInput != null) {
            commInput.Id = oldCommInput.Id;
        }
        if (!String.isEmpty(splitId)) {
            commInput.agileComp__Commission_Split__c = splitId;
        }
        commInput.agileComp__Templates_Config__c = templateId;
        if (String.isNotEmpty(salesRepFLD)) {
            if (type != 'None') {
                commInput.agileComp__Commission_Sales_Rep__c = salesRepId;
            }
            else {
                String uId = String.valueOf(baseObj.get(salesRepFLD));
                if (userSalesRepMap.containsKey(uId)) {
                    System.debug('containskey');
                    commInput.agileComp__Commission_Sales_Rep__c = userSalesRepMap.get(uId);
                }
            }
        }
        return commInput;
    }

    private static String fetchMainField(String baseObjName, Map<String,Schema.SObjectField> sObjectFieldMap){
        for(String sobjectField : sObjectFieldMap.keyset()){
            Schema.DescribeFieldResult fieldDescribed = sObjectFieldMap.get(sobjectField).getDescribe();
            if(String.valueOf(fieldDescribed.getType()).toLowerCase() == 'reference' ){
                List<Schema.sObjectType> sobjectTypeList = fieldDescribed.getReferenceTo();
                if (String.valueOf(sobjectTypeList[0].getDescribe().getName()) == baseObjName) {
                    return fieldDescribed.getName();
                }
            }
        }
        return null;
    }
    private static String fetchFieldRefrence(String fieldApi, Map<String,Schema.SObjectField> sObjectFieldMap) {
        Schema.DescribeFieldResult fieldDescribed = sObjectFieldMap.get(fieldApi).getDescribe();
        if(String.valueOf(fieldDescribed.getType()).toLowerCase() == 'reference' ){
            List<Schema.sObjectType> sobjectTypeList = fieldDescribed.getReferenceTo();
            return String.valueOf(sobjectTypeList[0].getDescribe().getName());
        }
        return null;
    }
    global static String queryGenerator(String objStr, String objAPI, Integer ind, String templateId) {
        try {
            DataListWrapper obj = (DataListWrapper)JSON.deserialize(objStr, DataListWrapper.class);
            // String baseobjAccField = fetchMainField(objAPI,'Account');  
            String mainObjQuery = 'SELECT ';
            Datetime lastSuccessDatetime = null;
            List<String> queryIds = new List<String>();
            List<DataWrapper> selectedFieldOptions = obj.selectedFieldOptions;
            List<DataWrapper> filterMappings = obj.selectedFilters;
            Set<String> groupByList = new Set<String>();
            List<agileComp__AC_Templates_Config__c> configs = [SELECT Id, agileComp__AC_SuccessDateMap__c FROM agileComp__AC_Templates_Config__c WHERE Id = : templateId ORDER BY CreatedDate DESC LIMIT 1];
            
            if (!configs.isEmpty() && configs[0].agileComp__AC_SuccessDateMap__c != null) {
                Map<Integer,Datetime> SuccessDateMap = (Map<Integer,Datetime>)JSON.deserialize(configs[0].agileComp__AC_SuccessDateMap__c, Map<Integer,Datetime>.class);
                List<Datetime> dateList = SuccessDateMap.values();
                dateList.sort();
                lastSuccessDatetime = dateList[0];
            }
            for(DataWrapper data : selectedFieldOptions) {
                mainObjQuery += ', ';
                if (!String.isEmpty( data.func ) ) {
                    mainObjQuery += data.func + '(';
                }
                String fieldAPI = '';
                if (!data.isFieldRelated) {
                    fieldAPI += data.selectedField;
                }
                else {
                    fieldAPI += ((DataWrapper)JSON.deserialize(data.selectedField,DataWrapper.class)).relatedField;
                }
                mainObjQuery += fieldAPI;
                if (!String.isEmpty( data.func ) ) {
                    mainObjQuery += ')';
                }
                else {
                    groupByList.add(fieldAPI);
                }
                mainObjQuery += ' ' +  + data.customLabel;
            }
            mainObjQuery = mainObjQuery.replaceFirst(',', '');
            mainObjQuery = mainObjQuery + ' FROM ' + objAPI + ' WHERE (';
            
            String operator = obj.selectedFilterCombo;
            String filterCombo = obj.filterCombo;
            Integer index = 1;
            Map<String,String> filterIndexMapping = new Map<String,String>();
            for (DataWrapper filter : filterMappings) {
                if ((filter.apexDataType.toUpperCase() == 'DATETIME' || filter.apexDataType.toUpperCase() == 'DATE') && lastSuccessDatetime == null && filter.filterValue == 'lastSuccessDate') {
                    filter.operation = 'NotEqualTo';
                }
                String filterStr = '';
                String operation = '';
                if (symbolMap.get(filter.operation).contains('NOT LIKE')) {
                    filterStr += '( NOT ';
                    operation = 'LIKE';
                }
                else {
                    operation = symbolMap.get(filter.operation);
                }
                if (!filter.isFieldRelated) {
                    filterStr += ' ' + filter.selectedField + ' ' + operation;
                }
                else {
                    filterStr += ' ' + ((DataWrapper)JSON.deserialize(filter.selectedField,DataWrapper.class)).relatedField + ' ' + operation;
                }
                if (filter.apexDataType == 'REFERENCE' || filter.apexDataType == 'ID') {
                    String Id = '';
                    if (filter.selectedRecord != null && filter.selectedRecord.Id != null) {
                        Id = filter.selectedRecord.Id;
                    }
                    filterStr += ' \'' + Id + '\'';
                }
                else {
                    if (filter.dataType == 'text' || filter.dataType == 'email') {
                        if (symbolMap.get(filter.operation).contains('LIKE')) {
                            if(symbolMap.get(filter.operation).contains('NOT')) {
                                filterStr += ' \'%' + filter.filterValue + '%\')';
                            }
                            else {
                                filterStr += ' \'%' + filter.filterValue + '%\'';
                            }
                        }
                        else {
                            filterStr += ' \'' + filter.filterValue + '\''; 
                        }
                    }
                    else if(filter.apexDataType.toUpperCase() == 'DATETIME' && filter.filterValue == 'lastSuccessDate' && lastSuccessDatetime != null){
                        filterStr += ' ' + lastSuccessDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    }
                    else if(filter.apexDataType.toUpperCase() == 'DATE' && filter.filterValue == 'lastSuccessDate' && lastSuccessDatetime != null){
                        filterStr += ' ' + lastSuccessDatetime.yearGmt() + '-' + lastSuccessDatetime.monthGmt() + '-' + lastSuccessDatetime.dateGmt();
                        
                    }
                    else if((filter.apexDataType.toUpperCase() == 'DATETIME' || filter.apexDataType.toUpperCase() == 'DATE') && filter.filterValue == 'lastSuccessDate') {
                        filterStr += ' ' + null;
                    }
                    else {
                        if (filter.dataType == 'boolean' && String.isEmpty(filter.filterValue)) {
                            filter.filterValue = 'true';
                        }
                        if (String.isEmpty(filter.filterValue)) {
                            filter.filterValue = null;
                        }
                        filterStr += ' ' + filter.filterValue;
                    }
                }
                if (!obj.isCustom) {
                    mainObjQuery += filterStr + ' ' + operator;
                }
                else {
                    filterIndexMapping.put(String.valueOf(index), filterStr);
                    index++;
                }
            }
            if (!obj.isCustom) {
                mainObjQuery = mainObjQuery.substringBeforeLast(operator);
            }
            else {
                for (String op : filterCombo.split('')) {
                    if (filterIndexMapping.containsKey(op)) {
                        mainObjQuery += filterIndexMapping.get(op);
                    }
                    else {
                        mainObjQuery += op;
                    }
                }
            }
            mainObjQuery += ')';
            if (!groupByList.isEmpty()) {
                List<String> gg = new List<String>();
                gg.addAll(groupByList);
        
                mainObjQuery += ' GROUP By ' + String.join(gg, ',');
            }
            System.debug(mainObjQuery.split('WHERE')[0]+' LIMIT 2000');
            System.debug('WHERE ');
            System.debug(mainObjQuery.split('WHERE')[1].split(' GROUP By ')[0]);
            System.debug(mainObjQuery.split('WHERE')[1].split(' GROUP By ')[1]);
            return mainObjQuery;
        } catch(Exception ex) {
            AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());
        }
        return null;
    }
    
    global static void batchFinal(Database.BatchableContext bc, String templateId, Integer index, List<String> JSONStrs, String objAPI, String userId) {
        try {
            AsyncApexJob job = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :bc.getJobId()];  
            
            List<agileComp__AC_Templates_Config__c> configs = [SELECT Id, agileComp__AC_Name__c,
                                                                    agileComp__AC_SuccessDateMap__c,
                                                                    agileComp__AC_BatchClassName__c 
                                                                FROM agileComp__AC_Templates_Config__c 
                                                                WHERE Id = : templateId ORDER BY CreatedDate DESC LIMIT 1];
            
            
            if (String.isEmpty(job.ExtendedStatus) && !configs.isEmpty()) {
                if (JSONStrs.size() > index) {
                    String query = AC_SchedulerTemplateController.queryGenerator(JSONStrs[index], objAPI, index + 1, templateId);
                    Type customType = Type.forName(configs[0].agileComp__AC_BatchClassName__c);
                    AC_BatchInterface instance = (AC_BatchInterface)customType.newInstance();
                    instance.setVariables(JSONStrs, objAPI, query, index + 1, templateId,userId);
                    instance.setUniqueString(uniqueId);
                    database.executebatch(instance,200);
                }
            }
            if (!configs.isEmpty()) {
                List<CronTrigger> schedJobs = [SELECT Id, CronJobDetail.Name, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = : configs[0].agileComp__AC_Name__c];
                for (CronTrigger sjob : schedJobs) {
                    if (sjob.NextFireTime == null) {
                        System.abortJob(sjob.Id);
                    }
                }
                Map<Integer,Datetime> SuccessDateMap;
                if(configs[0].agileComp__AC_SuccessDateMap__c != null) {
                    SuccessDateMap = (Map<Integer,Datetime>)JSON.deserialize(configs[0].agileComp__AC_SuccessDateMap__c, Map<Integer,Datetime>.class);   
                }
                if (String.isEmpty(job.ExtendedStatus)) {
                    if(SuccessDateMap != null) {
                        SuccessDateMap.put(index, Datetime.now());
                    }
                }
                else {
                    sendEmail(userId, configs[0].agileComp__AC_Name__c,job.ExtendedStatus);
                    Datetime min;
                    if (SuccessDateMap != null) {
                        min = SuccessDateMap.values()[0];
                        List<Integer> keys = new List<Integer>();
                        for (Integer key : SuccessDateMap.keySet()) {
                            keys.add(key);
                            if (SuccessDateMap.get(key) == null) {
                                min = null;
                                break;
                            }
                            else if (SuccessDateMap.get(key) < min) {
                                min = SuccessDateMap.get(key);
                            }
                        }
                        for (Integer key : keys) {
                            SuccessDateMap.put(key, min);
                        }
                    }
                    String query = 'SELECT Id,agileComp__Commission_Sales_Rep__c,CreatedDate FROM agileComp__commissionBaseInput__c where agileComp__Templates_Config__c = \'' + templateId + '\'';
                    if (min != null) {
                        query += ' AND CreatedDate > ' + min.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    }
                    AC_DeleteCommInputBatch deleteBatch = new AC_DeleteCommInputBatch(query);
                    database.executebatch(deleteBatch,200);
                }
                if (SuccessDateMap != null) {
                    configs[0].agileComp__AC_SuccessDateMap__c = JSON.serialize(SuccessDateMap);
                    update configs;
                }
            }
        } catch (Exception ex) {
            AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());
        }
        
    }
    static void sendEmail(String userId, String templateName, String errorMessage) {
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            // message.toAddresses = new String[] { 'abc2@gmail.com', 'abc2@gmail.com' };
            message.optOutPolicy = 'FILTER';
            message.subject = 'Template Error : '+templateName ;
            message.plainTextBody = 'Hi User \n You get an error \n ' +errorMessage;
            message.saveAsActivity = false;
            message.setTargetObjectId(userId);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        } catch (Exception ex) {
            AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());
        }
        
    }
    global class DataListWrapper {
        List<DataWrapper> selectedFieldOptions;
        List<DataWrapper> selectedFilters;
        String selectedFilterCombo;
        String filterCombo;
        Boolean isCustom;
        String mainField;
        SplitSelect documentField;
        SplitSelect accountField;
    }
    global class SplitSelect {
        Boolean isFieldRelated;
        String selectedField;
        String relatedObjectName;
    }
    global class DataWrapper {
        Boolean isFieldRelated;
        String selectedField;
        String customLabel;
        String relatedField;
        String func;
        String mapping;
        String apexDataType;
        String dataType;
        Boolean userLookup;
        Boolean useForSplit;
        String mathFunc;
        String operation;
        String filterValue;
        ObjWrapper selectedRecord;
    }
    global class ObjWrapper {
        String Id;
        String Name;
    }
    static {
        symbolMap.put('EqualTo','=');
        symbolMap.put('NotEqualTo','!=');
        symbolMap.put('GreaterThan','>');
        symbolMap.put('GreaterThanOrEqualTo','>=');
        symbolMap.put('LessThan','<');
        symbolMap.put('LessThanOrEqualTo','<=');
        symbolMap.put('Includes','LIKE');
        symbolMap.put('Contains','LIKE');
        symbolMap.put('Not Contains','NOT LIKE');
        symbolMap.put('NotContains','NOT LIKE');
        symbolMap.put('Excludes','NOT LIKE');
    }
}