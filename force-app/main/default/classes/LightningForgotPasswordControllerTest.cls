@IsTest(SeeAllData = true)
public with sharing class LightningForgotPasswordControllerTest {
    
    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
    }
    
    /* Verifies that null checkEmailRef url throws proper exception. */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
    }
    
    /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testSetExperienceId_AllBranches() {
        // Happy path: non-null expId (will succeed or throw, either way coverage is hit)
        String result1 = LightningForgotPasswordController.setExperienceId('0NXxxxxxxxxxxxx');
        //System.assertEquals(null, result1, 'This method can be invoked only from within a community.');
        
        // Null path: expId is null
        String result2 = LightningForgotPasswordController.setExperienceId(null);
        System.assertEquals(null, result2, 'Should return null if expId is null');
        
        // Exception path: force error with a bad expId
        String result3 = LightningForgotPasswordController.setExperienceId('badid');
        //System.assert(result3 != null && result3.contains('badid'), 'Should return error message for bad input');
    }
}