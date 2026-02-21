@isTest
private class EYI_RECVendorCreationWrapperTest {

    @isTest
    static void testWrapperInitialization() {

        EYI_RECVendorCreationWrapper wrapper = new EYI_RECVendorCreationWrapper();
        
        System.assertNotEquals(null, wrapper.ImVendor, 'ImVendor should be initialized');

        System.assertEquals('', wrapper.ImVendor.Type);
        System.assertEquals('', wrapper.ImVendor.Lifnr);
        System.assertEquals('', wrapper.ImVendor.NameFirst);
        System.assertEquals(0, wrapper.ImVendor.Vendorid.size(), 'Vendorid list should be empty');
        System.assertEquals(0, wrapper.ImVendor.Addr.size(), 'Addr list should be empty');
        System.assertEquals(0, wrapper.ImVendor.Comm.size(), 'Comm list should be empty');
        System.assertEquals(0, wrapper.ImVendor.ContactPerson.size(), 'ContactPerson list should be empty');
        System.assertEquals(0, wrapper.ImVendor.Bankdetail.size(), 'Bankdetail list should be empty');

        EYI_RECVendorCreationWrapper.cls_Vendorid vendorId = new EYI_RECVendorCreationWrapper.cls_Vendorid();
        System.assertEquals('', vendorId.Idtype);
        System.assertEquals('', vendorId.Idnumber);

        EYI_RECVendorCreationWrapper.cls_Addr addr = new EYI_RECVendorCreationWrapper.cls_Addr();
        System.assertEquals('', addr.Street);
        System.assertEquals('', addr.Country);

        EYI_RECVendorCreationWrapper.cls_Comm comm = new EYI_RECVendorCreationWrapper.cls_Comm();
        System.assertEquals('', comm.TelNumber);
        System.assertEquals('', comm.MobNumber);

        EYI_RECVendorCreationWrapper.ContactPerson contact = new EYI_RECVendorCreationWrapper.ContactPerson();
        System.assertEquals('', contact.Firstname);
        System.assertEquals('', contact.Email);

        EYI_RECVendorCreationWrapper.Bankdetail bank = new EYI_RECVendorCreationWrapper.Bankdetail();
        System.assertEquals('', bank.BankAcct);
        System.assertEquals('', bank.Accountholder);
    }
}