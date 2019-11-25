public with sharing class CreateTestData {
    public void makeTestData() 
    {
        Savepoint sp = Database.setSavepoint();
        String period = '2019/010';
        String DocType = 'SINV';
        String pDocType = 'PIN';
        String TranType = 'Invoice';
        //String TranType = 'Purchase Invoice';
        Date startDate = Date.newInstance(2019,10,22);
        //Integer docNumber = 1;
        Integer docDays = 8;
        Integer docDay = 1;
        List<cflCustStruct__Transaction_Line_Item__c> transLineItems = new List<cflCustStruct__Transaction_Line_Item__c>();
        List<cflCustStruct__Transaction__c> transHeaders = new List<cflCustStruct__Transaction__c>();
        List<cflCustStruct__Transaction__c> pTransHeaders = new List<cflCustStruct__Transaction__c>();
        list<user> salesReps = [Select id,Email from user where email = 'cloudfirsttestacct@gmail.com'];
        List<Account> accts = [Select id,OwnerId from Account];
        List<cflCustStruct__Sales_Order__c> sOrders = new List<cflCustStruct__Sales_Order__c>();
        while(docDay <= docDays)
        {
            Integer docsPerDay = Integer.valueOf((Math.random() * 50));
            System.debug('Random Docs Per Day for day ' + docDay + ' = '+docsPerDay); 
            System.debug('Start Date = '+startDate);           
            for(Integer i = 0; i < docsPerDay;i++)
            {
                
                Integer randAcctToPull = (Math.random() * accts.size()).intValue();
                Account acct = accts[randAcctToPull];
                String docIdNum = String.valueOf(i);
                cflCustStruct__Transaction__c tHeader = new cflCustStruct__Transaction__c();
                tHeader.cflCustStruct__Document_Number__c = DocType + docIdNum.leftPad(6,'0');
                tHeader.cflCustStruct__Period__c = period;
                tHeader.cflCustStruct__Transaction_Date__c = startDate;
                tHeader.cflCustStruct__Transaction_Type__c = TranType;
                transHeaders.add(tHeader);
                sOrders.add(createSalesOrder(acct.OwnerId,acct.Id));
                cflCustStruct__Transaction__c pHeader = new cflCustStruct__Transaction__c();
                pHeader.cflCustStruct__Document_Number__c = pDocType + docIdNum.leftPad(7,'0');
                pHeader.cflCustStruct__Period__c = period;
                pHeader.cflCustStruct__Transaction_Date__c = startDate;
                pHeader.cflCustStruct__Transaction_Type__c = 'Purchase Invoice';
                pTransHeaders.add(pHeader);
            }
            startDate = startDate.addDays(1);
            docDay++;

        }

        Insert transHeaders;
        Insert pTransHeaders;
        Insert sORders;
        Integer hdrs = 0;
        Integer hdrAcct = 0;
        system.debug('HdrACcount count = '+ accts.size());
        for(cflCustStruct__Transaction__c header : transHeaders)
        {
            Integer rAndArAmount = generateRandomFromRange(1000,150000);
            Integer rAndSalesAmount =-1*generateRandomFromRange(Integer.valueOf(rAndArAmount*.85),Integer.valueOf(rAndArAmount*.95));
            Integer freightAmount =-1*(rAndArAmount+rAndSalesAmount);
            Integer rSalesRep = generateRandomFromRange(0,(salesReps.size()-1));
            system.debug('Sales rep Id = '+rSalesrep);
            Integer rAccountsPayable = generateRandomFromRange(Integer.valueOf(rAndSalesAmount*.75),Integer.valueOf(rAndSalesAmount*.95));
            Integer rCost =-1* generateRandomFromRange(Integer.valueOf(rAccountsPayable*.75),Integer.valueOf(rAccountsPayable*.95));
            Integer freightCost =-1*(rAccountsPayable+rCost);            
            system.debug('hdrAcct - '+hdrAcct);
            if(hdrAcct == 123)
                hdrAcct = 0;
            //Sales Side
                cflCustStruct__Transaction_Line_Item__c lItemAr = new cflCustStruct__Transaction_Line_Item__c();
                //Transaction Number
                lItemAr.cflCustStruct__Transaction_Number__c = header.Id;
                //Account
                lItemAr.cflCustStruct__Account__c = accts[hdrAcct].Id; //Need some account
                //Custoemr ACcount
                lItemAr.cflCustStruct__Customer_Account__c = accts[hdrAcct].Id; //Need some account              
                //GL Account
                lItemAr.cflCustStruct__General_Ledger_Account__c = 'a0D4T0000000y0gUAA';                
                //Value
                lItemAr.cflCustStruct__Value__c = rAndArAmount; //Need some $$               
                //Sales Order
                lItemAr.cflCustStruct__Sales_Order__c = sOrders[hdrs].Id;  
                //Sales Rep
                lItemAr.cflCustStruct__Sales_Rep__c = salesReps[rSalesRep].Id;

                cflCustStruct__Transaction_Line_Item__c lItemSales = new cflCustStruct__Transaction_Line_Item__c();
                //Transaction Number
                lItemSales.cflCustStruct__Transaction_Number__c = header.Id;
                //Custoemr ACcount
                lItemSales.cflCustStruct__Customer_Account__c = accts[hdrAcct].Id; //Need some account              
                //GL Account
                lItemSales.cflCustStruct__General_Ledger_Account__c = 'a0D4T0000000y0RUAQ';                
                //Value
                lItemSales.cflCustStruct__Value__c = rAndSalesAmount; //Need some $$               
                //Sales Order
                lItemSales.cflCustStruct__Sales_Order__c = sOrders[hdrs].Id;  
                //Sales Rep
                lItemSales.cflCustStruct__Sales_Rep__c = salesReps[rSalesRep].Id;

                cflCustStruct__Transaction_Line_Item__c lItemFrRev = new cflCustStruct__Transaction_Line_Item__c();
                //Transaction Number
                lItemFrRev.cflCustStruct__Transaction_Number__c = header.Id;
                //Custoemr ACcount
                lItemFrRev.cflCustStruct__Customer_Account__c = accts[hdrAcct].Id; //Need some account              
                //GL Account
                lItemFrRev.cflCustStruct__General_Ledger_Account__c = 'a0D4T0000000y0bUAA';                
                //Value
                lItemFrRev.cflCustStruct__Value__c = freightAmount; //Need some $$               
                //Sales Order
                lItemFrRev.cflCustStruct__Sales_Order__c = sOrders[hdrs].Id;  
                //Sales Rep
                lItemFrRev.cflCustStruct__Sales_Rep__c = salesReps[rSalesRep].Id;

                transLineItems.add(lItemAr);
                System.debug('lItemAr - '+lItemAr);
                transLineItems.add(lItemSales);
                System.debug('lItemSales - '+lItemSales);
                transLineItems.add(lItemFrRev);
                System.debug('lItemFrRev - '+lItemFrRev);

                cflCustStruct__Transaction__c pInv = pTransHeaders[hdrs];
            //Purchase Side
                cflCustStruct__Transaction_Line_Item__c lItemAp = new cflCustStruct__Transaction_Line_Item__c();
                //Transaction Number
                lItemAp.cflCustStruct__Transaction_Number__c = pInv.Id;
                //Account
                lItemAp.cflCustStruct__Account__c = accts[hdrAcct].Id; //Need some account
                //Custoemr ACcount
                lItemAp.cflCustStruct__Customer_Account__c = accts[hdrAcct].Id; //Need some account              
                //GL Account
                lItemAp.cflCustStruct__General_Ledger_Account__c = 'a0D4T0000000y0cUAA';                
                //Value
                lItemAp.cflCustStruct__Value__c = rAccountsPayable; //Need some $$               
                //Sales Order
                lItemAp.cflCustStruct__Sales_Order__c = sOrders[hdrs].Id;  
                //Sales Rep
                lItemAp.cflCustStruct__Sales_Rep__c = salesReps[rSalesRep].Id;

                cflCustStruct__Transaction_Line_Item__c lItemCost = new cflCustStruct__Transaction_Line_Item__c();
                //Transaction Number
                lItemCost.cflCustStruct__Transaction_Number__c = pInv.Id;
                //Custoemr ACcount
                lItemCost.cflCustStruct__Customer_Account__c = accts[hdrAcct].Id; //Need some account              
                //GL Account
                lItemCost.cflCustStruct__General_Ledger_Account__c = 'a0D4T0000000y0WUAQ';                
                //Value
                lItemCost.cflCustStruct__Value__c = rCost; //Need some $$               
                //Sales Order
                lItemCost.cflCustStruct__Sales_Order__c = sOrders[hdrs].Id;  
                //Sales Rep
                lItemCost.cflCustStruct__Sales_Rep__c = salesReps[rSalesRep].Id;

                cflCustStruct__Transaction_Line_Item__c lItemFrCst = new cflCustStruct__Transaction_Line_Item__c();
                //Transaction Number
                lItemFrCst.cflCustStruct__Transaction_Number__c = pInv.Id;
                //Custoemr ACcount
                lItemFrCst.cflCustStruct__Customer_Account__c = accts[hdrAcct].Id; //Need some account              
                //GL Account
                lItemFrCst.cflCustStruct__General_Ledger_Account__c = 'a0D4T0000000y0XUAQ';                
                //Value
                lItemFrCst.cflCustStruct__Value__c = freightCost; //Need some $$               
                //Sales Order
                lItemFrCst.cflCustStruct__Sales_Order__c = sOrders[hdrs].Id;  
                //Sales Rep
                lItemFrCst.cflCustStruct__Sales_Rep__c = salesReps[rSalesRep].Id;                
                transLineItems.add(lItemAp);
                System.debug('lItemAP - '+lItemAp);
                transLineItems.add(lItemCost);
                System.debug('lItemCost - '+lItemCost);
                transLineItems.add(lItemFrCst);
                System.debug('lItemFrCst - '+lItemFrCst);

                hdrs++;
                hdrAcct++;

                If(hdrAcct == (transHeaders.size()-1))
                {
                    hdrAcct = 0;
                }
        }
        system.debug('TransLines size - '+transLineItems.size());
        insert transLineItems;
        
        system.debug('Transheaders size - '+transHeaders.size());
        // Database.rollback( sp );
    }

    private cflCustStruct__Sales_Order__c createSalesOrder(Id userId,Id accountId)
    {        
        cflCustStruct__Sales_Order__c sOrder = new cflCustStruct__Sales_Order__c();
        sOrder.cflCustStruct__Billed_Status__c = 'Completely Billed';
        sOrder.cflCustStruct__Company__c = 'CALIFORNIA HYDRONICS CORP.';
        sORder.cflCustStruct__Customer_Purchase_Order__c = string.valueOf((Math.random() * 1000).intValue());
        sOrder.cflCustStruct__Customer_Site_Sold_To__c = accountId;
        sOrder.cflCustStruct__Primary_Sales_Rep__c = userId;
        return sOrder;
    }

    public static Integer generateRandomFromRange(integer startNum, integer endNum)
    {
        Integer returnValue;
        //Logic- first we will generate random boolean value which will decide if we want to
        //add the random number from startNum or will subtract random number from endNum
        Integer randomNumber = Integer.valueof((math.random() * 10));
        boolean addSubFlag= math.mod(randomNumber,2) == 0 ? true : false;
        
        integer diffInRange = endNum-startNum;
        //Now find random number staring from 0 to diffInRange
        Integer randomNum = Math.mod(Math.round(Math.random()*diffInRange+1),diffInRange);
        
        //If addSubFlag is true, we will add random number generated between 0 and diffInRange from start number
        //else we will subtract random number from end number
        if(addSubFlag)
        {
            if(diffInRange > 1)
                returnValue = startNum + randomNum;
            else
                returnValue = startNum;
        }else
        {
            if(diffInRange > 1)
                returnValue = endNum - randomNum;
            else
                returnValue = endNum;
        }
        return returnValue;
    }
}