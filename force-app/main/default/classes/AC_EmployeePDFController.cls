public with sharing class AC_EmployeePDFController {
    // public List<agileComp__commissionEmployeeAttainedValue__c> eavList {get;set;}
    public List<agileComp__commissionEmployeeAttainedDetail__c> eadList {get;set;}
    public agileComp__CommissionPeriod__c period {get;set;} 
    public List<agileComp__commissionAdjustmentDetail__c> adjList {get;set;}
    public List<AggregateResult> agregateList {get;set;}
    // public List<AggregateResult> agregateInputs {get;set;}
    public List<Decimal> agregateInputs {get;set;}
    public List<agileComp__commissionBaseInput__c> baseInputs {get;set;}
    public AC_EmployeePDFController(ApexPages.StandardController stdController) {
        baseInputs = new List<agileComp__commissionBaseInput__c>();
        String eavId = ApexPages.currentPage().getParameters().get('id');
        String periodId = [SELECT agileComp__Commission_Period__c FROM agileComp__commissionEmployeeAttainedValue__c WHERE Id = : eavId].agileComp__Commission_Period__c;
        period = [SELECT Id, Name, agileComp__dateStart__c, agileComp__dateEnd__c FROM agileComp__CommissionPeriod__c WHERE Id = : periodId];
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.agileComp__commissionEmployeeAttainedDetail__c.FieldSets.agileComp__EAD_CommStmtFieldSet.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query = query.substringBeforeLast(',');
        query += ' FROM agileComp__commissionEmployeeAttainedDetail__c WHERE agileComp__Commission_Employee_Attained_Value__c = :eavId';
        eadList = Database.query(query);
        query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.agileComp__commissionAdjustmentDetail__c.FieldSets.agileComp__Adj_Comm_Stmt.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query = query.substringBeforeLast(',');
        query += ' FROM agileComp__commissionAdjustmentDetail__c WHERE agileComp__Commission_Employee_Attained_Value_Recor__c = :eavId';
        adjList = Database.query(query);
        agregateList = [SELECT agileComp__Adjustment_Type__c, SUM(agileComp__Adjustment_Amount__c) amt
                        FROM agileComp__commissionAdjustmentDetail__c
                        WHERE agileComp__Commission_Employee_Attained_Value_Recor__c = :eavId
                        GROUP BY agileComp__Adjustment_Type__c ];
        if (ApexPages.currentPage().getParameters().get('includeDetails') == 'true') {
            String agQuery = 'SELECT ';
            String bQuery = 'SELECT ';
            for(Schema.FieldSetMember f : SObjectType.agileComp__commissionBaseInput__c.FieldSets.agileComp__commissionDetailReport.getFields()) {
                bQuery += f.getFieldPath() + ', ';
                if (String.valueOf(f.getType()) == 'CURRENCY') {
                    agQuery += 'sum('+f.getFieldPath()+') '+ f.getFieldPath()+', ';
                }
            }
            agQuery = agQuery.substringBeforeLast(',');
            bQuery = bQuery.substringBeforeLast(',');
            String uId = UserInfo.getUserId();
            agQuery += ' FROM agileComp__commissionBaseInput__c WHERE agileComp__Commission_Sales_Rep__r.agileComp__Sales_Rep__c = :uId GROUP BY agileComp__Commission_Sales_Rep__c';
            bQuery += ' FROM agileComp__commissionBaseInput__c WHERE agileComp__Commission_Sales_Rep__r.agileComp__Sales_Rep__c = :uId';
            baseInputs = Database.query(bQuery);
            List<AggregateResult> agregateResult = Database.query(agQuery);
            agregateInputs = new List<Decimal>();
            if (agregateResult.size() > 0) {
                for(Schema.FieldSetMember f : SObjectType.agileComp__commissionBaseInput__c.FieldSets.agileComp__commissionDetailReport.getFields()) {
                    // agileComp__commissionBaseInput__c commInput = new agileComp__commissionBaseInput__c();
    
                    if (String.valueOf(f.getType()) == 'CURRENCY') {
                        // commInput.put(String.valueOf(f.getFieldPath()),agregateResult[0].get(String.valueOf(f.getFieldPath())));
                        agregateInputs.add(Decimal.valueOf(String.valueOf(agregateResult[0].get(String.valueOf(f.getFieldPath())))));
                    }
                    else {
                        agregateInputs.add(0);
                    }
                } 
            }
            
        }
    }
}