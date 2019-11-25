/**
 * Created by Bob.Jones on 9/27/2019.
 */

public with sharing class getQuoteSourceDocuments {
public void process()
{
    Map<id,agileComp__commissionSplit__c> splitOrg = new map<id,agileComp__commissionSplit__c>([select
            Id,
            Name,
            agileComp__Split_Percent__c,
            agileComp__Quote_Document__c,
            agileComp__accountSplit__c,
            agileComp__Commission_Sales_Rep__c
    from agileComp__commissionSplit__c]);

    map<id,list<agileComp__commissionSplit__c>> acctSplits = new map<id,list<agileComp__commissionSplit__c>>();
    map<id,list<agileComp__commissionSplit__c>> docSplits = new map<id,list<agileComp__commissionSplit__c>>();

    for(agileComp__commissionSplit__c cspli : splitOrg.values())
    {
        if(cspli.agileComp__accountSplit__c != null)
        {
            //We have an account split Check to see if we have this account in the system already
            if(acctSplits.containsKey(cspli.agileComp__accountSplit__c))
            {
                acctSplits.get(cspli.agileComp__accountSplit__c).add(cspli);
            }
            else
            {
                acctSplits.put(cspli.agileComp__accountSplit__c,new list<agileComp__commissionSplit__c>{cspli});
            }

        }

        if(cspli.agileComp__Quote_Document__c != null)
        {
            //We have an document split Check to see if we have this account in the system already
            if(docSplits.containsKey(cspli.agileComp__Quote_Document__c))
            {
                acctSplits.get(cspli.agileComp__Quote_Document__c).add(cspli);
            }
            else
            {
                acctSplits.put(cspli.agileComp__Quote_Document__c,new list<agileComp__commissionSplit__c>{cspli});
            }
        }
    }

    list<agileComp__commissionBaseInput__c> itemsToInputToBase = new list<agileComp__commissionBaseInput__c>();
//Ok Get the documents for this time period

    for(AggregateResult[] qtRes : [select
            quote.AccountId,
            quoteId,
            Sum(listPrice) listPrice,
            Sum(SubTotal) SubTotal,
            Sum(TotalPrice) TotalPrice
    from quoteLineItem
    WHERE quote.CreatedDate > 2019-09-01T17:52:28.000Z
    GROUP By quote.AccountId,quoteId
    ])

    {
        for(AggregateResult ar : qtRes)
        {
            if(docSplits.containsKey((id)ar.get('QuoteId')))
            {
                //We have a doc Split
                for(agileComp__commissionSplit__c comSp : docSplits.get((id)ar.get('QuoteId')))
                {



                }
            }
            else
            {
                if(acctSplits.containsKey((id)ar.get('accountId')))
                {
                    //Process With Account Split
                }
                else
                {
                    //Process Normal
                }
            }
        }

    }

}
    private agileComp__commissionBaseInput__c assignBaseValuesFromAggregate(AggregateResult aResult,commissionBaseInput__c cSplit,string splitType)
    {
        agileComp__commissionBaseInput__c bi = new agileComp__commissionBaseInput__c();
        if(cSplit != null)
        {

            bi.agileComp__Split_Document_Origin__c= splitType;
            bi.agileComp__Quote__c= (Id)aResult.get('QuoteId');
            bi.agileComp__documentType__c= 'Quote';
            bi.agileComp__Commission_Sales_Rep__c= cSplit.agileComp__Commission_Sales_Rep__c;
            bi.agileComp__Split_Percent__c= cSplit.agileComp__Split_Percent__c;

           // bi.agileComp__Orig_Doc_Unit_Cost__c = 0.00;
            //bi.agileComp__Split_Doc_Unit_Cost__c= 0.00;
            bi.agileComp__Orig_Doc_Ext_Cost__c= 0.00;
            // bi.agileComp__Split_Doc_Ext_Cost__c= 0.00;

            bi.agileComp__Orig_Doc_Freight__c= 0.00;
            // bi.agileComp__Split_Doc_Freight__c= 0.00;

            //bi.agileComp__Orig_Doc_Unit_Sales__c = 0.00;
            //bi.agileComp__Split_Doc_Unit_Sales__c = 0.00;
            bi.agileComp__Orig_Doc_Ext_Sales__c= 0.00;
            // bi.agileComp__Split_Doc_Ext_Sales__c= 0.00;

            bi.agileComp__Commission_Split__c= cSplit.Id;
        }
        else
        {

            bi.agileComp__Split_Document_Origin__c= 'None';
            bi.agileComp__Quote__c= (Id)aResult.get('QuoteId');
            bi.agileComp__documentType__c= 'Quote';
            bi.agileComp__Commission_Sales_Rep__c= cSplit.agileComp__Commission_Sales_Rep__c;
            bi.agileComp__Split_Percent__c= 1;

            //bi.agileComp__Orig_Doc_Unit_Cost__c = 0.00;
            //bi.agileComp__Split_Doc_Unit_Cost__c= 0.00;
            bi.agileComp__Orig_Doc_Ext_Cost__c= 0.00;
            // bi.agileComp__Split_Doc_Ext_Cost__c= 0.00;

            bi.agileComp__Orig_Doc_Freight__c= 0.00;
            // bi.agileComp__Split_Doc_Freight__c= 0.00;

            //bi.agileComp__Orig_Doc_Unit_Sales__c = 0.00;
            //bi.agileComp__Split_Doc_Unit_Sales__c = 0.00;
            bi.agileComp__Orig_Doc_Ext_Sales__c= 0.00;
            // bi.agileComp__Split_Doc_Ext_Sales__c= 0.00;

            bi.agileComp__Commission_Split__c= cSplit.Id;
        }
        return bi;
    }
}