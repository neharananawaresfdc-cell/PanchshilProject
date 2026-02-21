/**
 * Created by Abhishek on 1/24/19.
 */

@IsTest
private class EYI_AbstractHttpServiceConsumerTest {
	abstract class DummyIntegration extends EYI_AbstractHttpServiceConsumer {
		public DummyIntegration(String method, String endpoint) {
			super(method, 'endpoint/' + endpoint);
			logger = new Logger(); // THIS IS FOR TEST PURPOSES ONLY, LOGGING IS CONTROLLED BY Integration Settings
		}
	}

	private class DummyIntegrationGet extends DummyIntegration {
		public DummyIntegrationGet(String service) {
			super('GET', service);
			setParam('param1', 'a');
		}

		public HttpResponse call() {
			return send();
		}
	}
 
	@IsTest
	static void testBehaviorSuccess() {
		Test.setMock(HttpCalloutMock.class, new EYI_AbstractHttpServiceConsumerMock());

		DummyIntegrationGet caller = new DummyIntegrationGet('success');
		Assert.areEqual(caller.getParam('param1'), 'a', 'getParams test');

		HttpResponse response = caller.call();
		Assert.areEqual('success response', response.getBody(), 'correct response');
		Assert.areEqual(1, EYI_AbstractHttpServiceConsumer.getNumOfCallouts(), 'getNumOfCallouts test');

		EYI_AbstractHttpServiceConsumer.flushLog();

		CalloutLog__c log = [SELECT HttpStatusCode__c FROM CalloutLog__c];
		Assert.areEqual(log.HttpStatusCode__c, 200, 'CalloutLog inserted correctly');
	}
 
	@IsTest
	static void testBehaviorError() {
		Test.setMock(HttpCalloutMock.class, new EYI_AbstractHttpServiceConsumerMock());

		DummyIntegrationGet caller = new DummyIntegrationGet('error');
		try {
			caller.call();
			System.assert(false, 'should throw an exception before this');
		}

		catch (Exception e) {
			Assert.areEqual('EYI_AbstractHttpServiceConsumer.HttpException', e.getTypeName(), 'correct exception');
			System.assert(e.getMessage().contains('400'), 'exception message contains status code');
			EYI_AbstractHttpServiceConsumer.flushLog();
		}
 
		Assert.areEqual(1, EYI_AbstractHttpServiceConsumer.getNumOfCallouts(), 'getNumOfCallouts test');
 
		//CalloutLog__c log = [SELECT HttpStatusCode__c FROM CalloutLog__c ];
		//Assert.areEqual(log.HttpStatusCode__c, 400, 'CalloutLog inserted correctly');
	}
	@IsTest
	static void testFlushLogEvent() {
		Test.setMock(HttpCalloutMock.class, new EYI_AbstractHttpServiceConsumerMock());

		DummyIntegrationGet caller = new DummyIntegrationGet('success');
		Assert.areEqual(caller.getParam('param1'), 'a', 'getParams test');

		HttpResponse response = caller.call();
		Assert.areEqual('success response', response.getBody(), 'correct response');
		Assert.areEqual(1, EYI_AbstractHttpServiceConsumer.getNumOfCallouts(), 'getNumOfCallouts test');
		Test.StartTest();
		EYI_AbstractHttpServiceConsumer.flushLogEvent();
		Test.StopTest();
		/*CalloutLog__c log = [SELECT HttpStatusCode__c FROM CalloutLog__c];
        system.debug('logs -> '+log);
		Assert.areEqual(log.HttpStatusCode__c, 200, 'CalloutLog inserted correctly');*/
	}
		
	@IsTest
	static void testEnqueuedJobs() {
		Test.setMock(HttpCalloutMock.class, new EYI_AbstractHttpServiceConsumerMock());

		DummyIntegrationGet caller = new DummyIntegrationGet('success');
		Assert.areEqual(caller.getParam('param1'), 'a', 'getParams test');
 
		HttpResponse response = caller.call();
		Assert.areEqual('success response', response.getBody(), 'correct response');
		Assert.areEqual(1, EYI_AbstractHttpServiceConsumer.getNumOfCallouts(), 'getNumOfCallouts test');
		Test.StartTest();
		EYI_AbstractHttpServiceConsumer.flushLog(true);
		Test.StopTest();
		//CalloutLog__c log = [SELECT HttpStatusCode__c FROM CalloutLog__c];
		//Assert.areEqual(log.HttpStatusCode__c, 200, 'CalloutLog inserted correctly');
	}
}