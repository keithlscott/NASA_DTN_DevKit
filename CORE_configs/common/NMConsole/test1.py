#!/usr/bin/python

import time
import math

from datetime import datetime
from elasticsearch import Elasticsearch
import elasticsearch

es = Elasticsearch(['http://192.168.250.1'])

def listAll(es, index):
	print 'Listing all search hits for index %s' % (index)
	try:
		res = es.search(index=index, body={'query': {'match_all': {}}})
		for hit in res['hits']['hits']:
			print hit
	except:
		print 'Cant list'

def insertTestData(es, index, docType):
	for i in range(20):
		bar = datetime.utcnow().isoformat()
		doc = {
			'val1': (i*4) % 5,
			'val2': math.cos(i),
			'timestamp': bar
		}

		print 'Adding item: %s' % (doc)

		res = es.index(index=index,
			       doc_type=docType,
			       timestamp=bar,
			       id=i,
			       body=doc,
			       refresh='true')
		print res
		time.sleep(1)

def delete_es_type(es, index, type_):
    try:
        count = es.count(index, type_)['count']
	if count==0:
		return
        response = es.search(
            index=index,
            filter_path=["hits.hits._id"],
            body={"size": count, "query": {"filtered" : {"filter" : {
                  "type" : {"value": type_ }}}}})
        ids = [x["_id"] for x in response["hits"]["hits"]]
        bulk_body = [
            '{{"delete": {{"_index": "{}", "_type": "{}", "_id": "{}"}}}}'
            .format(index, type_, x) for x in ids]
        es.bulk('\n'.join(bulk_body))
        # es.indices.flush_synced([index])
    except elasticsearch.ElasticsearchException as ex:
        print("Elasticsearch error: " + ex.error)
        raise ex

if __name__=='__main__':
	print 'Current records:'
	listAll(es, 'bpnm')
	#listAll(es, 'filebeat-2016.12.06')
	print '--------'
	#insertTestData(es, 'test1', 'testDocType')
	# delete_es_type(es, 'test1', 'testType')
	print es.exists_type(index='bpnm', doc_type='BPStats')


