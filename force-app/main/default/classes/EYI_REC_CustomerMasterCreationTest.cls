@isTest
public class EYI_REC_CustomerMasterCreationTest {

    @isTest
    static void testFullInitialization() {
        EYI_REC_CustomerMasterCreationWrapper wrapper = new EYI_REC_CustomerMasterCreationWrapper();
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.IM_CUSTOMER);

        // Partner
        EYI_REC_CustomerMasterCreationWrapper.cls_Partner partner = new EYI_REC_CustomerMasterCreationWrapper.cls_Partner();
        partner.PARVW = 'AG';
        partner.KTONR = '123';
        wrapper.IM_CUSTOMER.PARTNER.add(partner);

        // Customer ID
        EYI_REC_CustomerMasterCreationWrapper.cls_CustID custId = new EYI_REC_CustomerMasterCreationWrapper.cls_CustID();
        custId.IDTYPE = 'PAN';
        custId.IDNUMBER = 'ABCDE1234F';
        wrapper.IM_CUSTOMER.CUSTID.add(custId);

        // Tax ID
        EYI_REC_CustomerMasterCreationWrapper.cls_TaxID taxId = new EYI_REC_CustomerMasterCreationWrapper.cls_TaxID();
        taxId.TAXTYPE = 'GST';
        taxId.TAXNUM = '29ABCDE1234F1Z5';
        wrapper.IM_CUSTOMER.TAXID.add(taxId);

        // Address
        EYI_REC_CustomerMasterCreationWrapper.cls_Addr addr = new EYI_REC_CustomerMasterCreationWrapper.cls_Addr();
        addr.CITY1 = 'Bangalore';
        addr.COUNTRY = 'IN';
        wrapper.IM_CUSTOMER.ADDR.add(addr);

        // Communication
        EYI_REC_CustomerMasterCreationWrapper.cls_Comm comm = new EYI_REC_CustomerMasterCreationWrapper.cls_Comm();
        comm.TEL_NUMBER = '1234567890';
        comm.SMTP_ADDR = 'test@example.com';
        wrapper.IM_CUSTOMER.COMM.add(comm);

        // Bank
        EYI_REC_CustomerMasterCreationWrapper.cls_Bank bank = new EYI_REC_CustomerMasterCreationWrapper.cls_Bank();
        bank.BANK_ACCT = '000111222333';
        bank.BANK_KEY = 'HDFC0000123';
        wrapper.IM_CUSTOMER.BANK.add(bank);

        // Co-Applicant
        EYI_REC_CustomerMasterCreationWrapper.cls_CO_Applicant coApplicant = new EYI_REC_CustomerMasterCreationWrapper.cls_CO_Applicant();
        coApplicant.NAME_FIRST = 'John';
        coApplicant.NAME_LAST = 'Doe';
        coApplicant.TEL_NUMBER = '9876543210';
        coApplicant.PANNO = 'ABCDE1234X';
        wrapper.IM_CUSTOMER.CO_APPLICANT.add(coApplicant);

        // Core Customer Info
        wrapper.IM_CUSTOMER.NAME_FIRST = 'Sample';
        wrapper.IM_CUSTOMER.NAME_LAST = 'Customer';
        wrapper.IM_CUSTOMER.GSTIN = '29ABCDE1234F1Z5';
        wrapper.IM_CUSTOMER.ZTERM = '0001';

        // 🔍 Assertions
        System.assertEquals('AG', wrapper.IM_CUSTOMER.PARTNER[0].PARVW);
        System.assertEquals('PAN', wrapper.IM_CUSTOMER.CUSTID[0].IDTYPE);
        System.assertEquals('GST', wrapper.IM_CUSTOMER.TAXID[0].TAXTYPE);
        System.assertEquals('Bangalore', wrapper.IM_CUSTOMER.ADDR[0].CITY1);
        System.assertEquals('1234567890', wrapper.IM_CUSTOMER.COMM[0].TEL_NUMBER);
        System.assertEquals('HDFC0000123', wrapper.IM_CUSTOMER.BANK[0].BANK_KEY);
        System.assertEquals('John', wrapper.IM_CUSTOMER.CO_APPLICANT[0].NAME_FIRST);
        System.assertEquals('Sample', wrapper.IM_CUSTOMER.NAME_FIRST);
        System.assertEquals('Customer', wrapper.IM_CUSTOMER.NAME_LAST);
        System.assertEquals('29ABCDE1234F1Z5', wrapper.IM_CUSTOMER.GSTIN);
        System.assertEquals('0001', wrapper.IM_CUSTOMER.ZTERM);
    }
}