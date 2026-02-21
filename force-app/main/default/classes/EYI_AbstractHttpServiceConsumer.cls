public abstract class EYI_AbstractHttpServiceConsumer {
	public static final Set<Integer> STATUS_RESPONSE_OK = new Set<Integer>{200, 201};
	public static final Integer MAX_STRING_LENGTH = 32768;

	@TestVisible
	private static Logger logger;
	private static Integer numOfCallouts = 0;

	private Boolean paramSet = false;

	static {
		if( IntegrationSettings__c.getInstance().EnableCalloutsLogging__c ) {
			logger = new Logger();
		}
	}

	@TestVisible
	Public class Logger implements Queueable {
		private List<CalloutLog__c> entries = new List<CalloutLog__c>();

		public void addEntry(HttpRequest request, HttpResponse response, DateTime requestTime) {
			List<String> endpointParts = request.getEndpoint().split('\\?', 2);
			entries.add(new CalloutLog__c(
					RequestBody__c = (endpointParts.size() > 1 ? 'QUERY STRING: ?' + endpointParts[1] + '\n\n' : '') + request.getBody(),
					ResponseBody__c = response.getBody(),
					Endpoint__c = endpointParts[0],
					Type__c =  EYI_AbstractHttpServiceConsumer.STATUS_RESPONSE_OK.contains(response.getStatusCode())
							? 'INFO' : 'ERROR',
					RequestTime__c = requestTime,
					ResponseTime__c = DateTime.now(), // log entry is created immediately after response is received
					HttpStatusCode__c = response.getStatusCode()
			));
		}

		public void execute(QueueableContext context) {
			this.flush();
		}

		public void flush() {
			Database.DMLOptions options = new Database.DMLOptions();
			options.allowFieldTruncation = true;
			List<Database.SaveResult> sr = Database.insert( entries, options );

			List<CalloutLog__c> entries = new List<CalloutLog__c>();
		}

		public void flushEvent() {
			List<Callout_Log__e> events = new List<Callout_Log__e>();
			for(CalloutLog__c log : entries) {
				events.add(new Callout_Log__e(
					RequestBody__c = log.RequestBody__c.abbreviate(EYI_AbstractHttpServiceConsumer.MAX_STRING_LENGTH),
					ResponseBody__c = log.ResponseBody__c.abbreviate(EYI_AbstractHttpServiceConsumer.MAX_STRING_LENGTH),
					Endpoint__c = log.Endpoint__c,
					Type__c = log.Type__c,
					RequestTime__c = log.RequestTime__c,
					HttpStatusCode__c = log.HttpStatusCode__c
				));
			}
			
			if(!events.isEmpty()) EventBus.publish(events);
			List<CalloutLog__c> entries = new List<CalloutLog__c>();
		}
	}

	public class HttpException extends Exception {
		private HttpResponse response;

		public HttpException( HttpResponse response, String message ) {
			this.response = response;
			this.setMessage( message );
		}

		public HttpResponse getResponse() {
			return response;
		}
	}

	protected Http http;
	protected HttpRequest request;
	protected HttpResponse response;

	protected Map<String, String> params = new Map<String, String>();

	protected EYI_AbstractHttpServiceConsumer( String method, String endpoint ) {
		this.http = new Http();
		this.init( method, endpoint );
	}

	public static Integer getNumOfCallouts() {
		return numOfCallouts;
	}

	// flushes all log messages if any
	public static void flushLog() {
		flushLog( false );
	}

	public static void flushLog( Boolean isAsync ) {
		if(logger != null) {
			if(isAsync) {
				System.enqueueJob( logger );
			}
			else {
				logger.flush();
			}
		}
	}

	public static void flushLogEvent() {
		if(logger != null) {
			logger.flushEvent();
		}
	}

	protected void init( String method, String endpoint ) {
		this.request = new HttpRequest();
		this.request.setMethod( method );
		this.request.setEndpoint( endpoint );
	}

	protected virtual HttpResponse send() {
		if (!paramSet && !params.isEmpty()) {
			String pq = '';

			for (String p : params.keySet()) {
				pq += '&' + p + '=' + params.get(p);
			}

			this.request.setEndpoint(this.request.getEndpoint() + '?' + pq.substring(1));
			this.paramSet = true;
		}
		this.request.setTimeout(120000);

		System.debug( Logginglevel.INFO, 'REQUESTING: ' + this.request.getEndpoint() );
		System.debug( Logginglevel.INFO, 'PAYLOAD: ' + this.request.getBody() );
		DateTime requestTime = DateTime.now();
        try {
			response = this.http.send( this.request );
            if (this.request.getEndpoint() != null && 
                (this.request.getEndpoint().contains(':SAP_Outstanding_Report') || this.request.getEndpoint().contains(':SAP_Ageing_Report') 
                || this.request.getEndpoint().contains(':SAP_DemandRaiseSalesForce'))) { 
                System.debug('Skipping logging for batch or excluded endpoint: ' + this.request.getEndpoint());
                }else{
                   enqueueLogger(this.request, response, requestTime);
					System.debug('logger : '+logger); 
                }
            
			//if( logger != null ) logger.addEntry( this.request, response, requestTime );
			numOfCallouts++;
            return this.handleStatus(response);
        }
        catch(Exception e){
            HttpResponse fakeRes = new HttpResponse();
            fakeRes.setStatusCode(500);
            fakeRes.setBody('Exception: ' + e.getMessage());

            enqueueLogger(this.request, fakeRes, requestTime);
            throw e;
        }

	//	System.debug( Logginglevel.INFO, 'RESPONSE: ' + response.getBody() );

		
	}
    private void enqueueLogger(HttpRequest req, HttpResponse res, DateTime reqTime) {
        //System.debug('logger : '+logger);
       if (logger != null) {
            logger.addEntry(req, res, reqTime);
            //logger.flushEvent(); // No Queueable jobs involved
            System.enqueueJob(logger); 
      }
    }

	public void setParam(String name, String value) {
		params.put( name, value );
	}

	public String getParam(String name) {
		return params.get(name);
	}

	private HttpResponse handleStatus( HttpResponse response ) {
		if(STATUS_RESPONSE_OK.contains(response.getStatusCode())) {
			return response;
		}

		throw new HttpException( response, 'Server returned unexpected HTTP Response code: ' + response.getStatusCode() + '. Status: ' + response.getStatus() );
	}
}