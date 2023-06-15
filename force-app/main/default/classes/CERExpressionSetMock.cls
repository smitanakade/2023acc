@isTest
public with sharing class CERExpressionSetMock implements HttpCalloutMock {
	public HttpResponse respond(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(
			JSON.serialize(
				new Map<String, Object>{
					'outputs' => new List<Object>{
						new Map<String, Object>{
							'results' => new Map<String, Object>{
								'CER_Total_Stars_II__Label' => 'Acceptable',
								'CER_Total_Stars_II__Rating' => 3.0
							}
						}
					}
				}
			)
		);
		res.setStatusCode(201);
		return res;
	}
}