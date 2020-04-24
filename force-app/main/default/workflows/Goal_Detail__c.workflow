<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Unique_Update</fullName>
        <field>SalesPeriod__c</field>
        <formula>Commission_Sales_Rep__c  +  Goal_Period__c</formula>
        <name>Unique Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Unique Field</fullName>
        <actions>
            <name>Unique_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( Commission_Sales_Rep__c ) ,ISCHANGED(  Goal_Period__c ), ISNEW()  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
