global with sharing class AC_GetQuoteDocsForProcessing 
{
	@InvocableMethod(label='Get Quotes To Process')
    public static list<WrapperClass> getQuotesToProcess()
    {
        List<WrapperClass> lc = new List<WrapperClass>();
        WrapperClass wc = new WrapperClass();
        List<Quote> qts = [SELECT Id,
            			   	      Name            				      
            		       FROM Quote];
        System.debug(qts);
        wc.qte = qts;
        list<Account> accts = [select id,Name from Account];
        wc.accts = accts;
        lc.add(wc);
        return lc;
    }
    
    global class WrapperClass
    {
        @InvocableVariable
        global list<Quote> qte;
        
        @InvocableVariable
        global list<Account> accts;
    }
}