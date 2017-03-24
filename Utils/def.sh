#!/bin/bash

#
# Define the database structure for DTN Network Management stuff in Elasticsearch
#

HOST='192.168.250.1'
THEINDEX="bpnm"

echo "HOST is: $HOST"
echo "HOST:9200 is: $HOST:9200"

function deleteIndex {
	# Blow away an index
	THEINDEX=$1
	echo ""
	echo "Blowing away index $THEINDEX"
	curl --noproxy $HOST -XDELETE "http://$HOST:9200/$THEINDEX/"
	echo ""
}

function listIndices {
# list all indices
	echo ""
	echo "List of all current indices:"
	curl --noproxy $HOST,localhost "http://$HOST:9200/_cat/indices?v"
	echo ""
}

#
# Populate index for bpnm
#
#curl --noproxy $HOST,localhost -Xput "http://$HOST:9200/$THEINDEX/" -d '{
#	"mappings": {
#		"BP_RPT_FULL_MID": {
#			"properties":  {
#				"message": {
#					"type": "text"
#				}
#				"ADM_BP_AD_BNDL_CUR_NORM_RES_CNT": {
#					"type": "integer"
#				}
#			}
#		}
#	}
#}'


function createTestIndex {
	echo ""
	echo "Creating test index (twitter)"
	curl --noproxy $HOST,localhost -XPUT "$HOST:9200/twitter?pretty" -d'
	{
	    "settings" : {
		"index" : {
		    "number_of_shards" : 3, 
		    "number_of_replicas" : 2 
		}
	    }
	}'
	echo ""
}

function createIndex {
	THEINDEX=$1
	echo ""
	echo "Creating index $THEINDEX"
	curl --noproxy $HOST,localhost -XPUT "$HOST:9200/$THEINDEX?pretty" -d '
	{
		"mappings": {
			"BP_RPT_FULL_MID": {
				"properties": {
					"ADM_BP_AD_BNDL_BULK_SRC_BYTES_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_BULK_SRC_CNT_MID":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_CUR_BULK_RES_BYT":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_CUR_EXP_BYTES_MI":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_CUR_EXP_RES_CNT_":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_CUR_NORM_BYTES_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_CUR_NORM_RES_CNT":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_EXP_SRC_BYTES_MI":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_EXP_SRC_CNT_MID": 	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_FRAGMENTED_CNT_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_FRAG_PRODUCED_MI":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_NORM_SRC_BYTES_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_BNDL_NORM_SRC_CNT_MID":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_ABANDONED_BYTES_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_ABANDONED_CNT_MID":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_BAD_BLOCK_DEL_CNT":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_BAD_EID_DEL_CNT_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_BUNDLES_DEL_CNT_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_CANCEL_DEL_CNT_MI":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_DISCARD_BYTES_MID":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_DISCARD_CNT_MID":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_EXPIRED_DEL_CNT_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_FAIL_CUST_XFER_BY":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_FAIL_CUST_XFER_CN":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_FAIL_FWD_BYTES_MI":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_FAIL_FWD_CNT_MID": 	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_NOINFO_DEL_CNT_MI":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_NO_CONTACT_DEL_CN":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_NO_ROUTE_DEL_CNT_":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_NO_STRG_DEL_CNT_M":	{ "type": "long", "store": "yes" },
					"ADM_BP_AD_RPT_UNI_FWD_DEL_CNT_M":	{ "type": "long", "store": "yes" },
					"AVAIL_STOR":				{ "type": "string", "store": "yes" },
					"CUR_BULK_RES_CNT":			{ "type": "long", "store": "yes" },
					"CUR_DISPATCH_PEND_CNT":		{ "type": "long", "store": "yes" },
					"CUR_FWD_PEND_CNT":			{ "type": "long", "store": "yes" },
					"CUR_IN_CUSTODY_CNT":			{ "type": "long", "store": "yes" },
					"CUR_REASSMBL_PEND_CNT":		{ "type": "long", "store": "yes" },
					"ENDPT_NAMES":				{ "type": "string", "store": "yes"},
					"NODE_ID":				{ "type": "string", "store": "yes" },
					"NODE_VER":				{ "type": "long", "store": "yes" },
					"NUM_REG":				{ "type": "long", "store": "yes" },
					"sendTimestamp":			{ "type": "date", "store": "yes" },
					"receive_timestamp":			{ "type": "date", "store": "yes" }
				}
			}
		}
					
	}'
	echo ""
}

function createStatsIndex {
	echo ""
	echo "Creating BPStats mapping in $THEINDEX"
	# "sendTimestamp":	{ "type": "date", "store": "yes" },
	curl --noproxy $HOST,localhost -XPUT "$HOST:9200/$THEINDEX/_mapping/BPStats" -d '
	{
		"properties": {
			"nodeNumber":		{ "type": "long", "store": "yes" },
			"sendTimestamp":	{ "type": "date", "store": "yes" },
			"src_0_bundles":	{ "type": "long", "store": "yes" },
			"src_0_bytes":		{ "type": "long", "store": "yes" },
			"src_1_bundles":	{ "type": "long", "store": "yes" },
			"src_1_bytes":		{ "type": "long", "store": "yes" },
			"src_2_bundles":	{ "type": "long", "store": "yes" },
			"src_2_bytes":		{ "type": "long", "store": "yes" },
			"fwd_0_bundles":	{ "type": "long", "store": "yes" },
			"fwd_0_bytes":		{ "type": "long", "store": "yes" },
			"fwd_1_bundles":	{ "type": "long", "store": "yes" },
			"fwd_1_bytes":		{ "type": "long", "store": "yes" },
			"fwd_2_bundles":	{ "type": "long", "store": "yes" },
			"fwd_2_bytes":		{ "type": "long", "store": "yes" },
			"fwd_total_bundles":	{ "type": "long", "store": "yes" },
			"fwd_total_bytes":	{ "type": "long", "store": "yes" },
			"xmt_0_bundles":	{ "type": "long", "store": "yes" },
			"xmt_0_bytes":		{ "type": "long", "store": "yes" },
			"xmt_1_bundles":	{ "type": "long", "store": "yes" },
			"xmt_1_bytes":		{ "type": "long", "store": "yes" },
			"xmt_2_bundles":	{ "type": "long", "store": "yes" },
			"xmt_2_bytes":		{ "type": "long", "store": "yes" },
			"xmt_total_bytes":	{ "type": "long", "store": "yes" },
			"xmt_total_bundles":	{ "type": "long", "store": "yes" },
			"rcv_0_bundles":	{ "type": "long", "store": "yes" },
			"rcv_0_bytes":		{ "type": "long", "store": "yes" },
			"rcv_1_bundles":	{ "type": "long", "store": "yes" },
			"rcv_1_bytes":		{ "type": "long", "store": "yes" },
			"rcv_2_bundles":	{ "type": "long", "store": "yes" },
			"rcv_2_bytes":		{ "type": "long", "store": "yes" },
			"rcv_total_bundles":	{ "type": "long", "store": "yes" },
			"rcv_total_bytes":	{ "type": "long", "store": "yes" },
			"dlv_0_bundles":	{ "type": "long", "store": "yes" },
			"dlv_0_bytes":		{ "type": "long", "store": "yes" },
			"dlv_1_bundles":	{ "type": "long", "store": "yes" },
			"dlv_1_bytes":		{ "type": "long", "store": "yes" },
			"dlv_2_bundles":	{ "type": "long", "store": "yes" },
			"dlv_2_bytes":		{ "type": "long", "store": "yes" },
			"dlv_total_bundles":	{ "type": "long", "store": "yes" },
			"dlv_total_bytes":	{ "type": "long", "store": "yes" },
			"ctr_0_bundles":	{ "type": "long", "store": "yes" },
			"ctr_0_bytes":		{ "type": "long", "store": "yes" },
			"ctr_1_bundles":	{ "type": "long", "store": "yes" },
			"ctr_1_bytes":		{ "type": "long", "store": "yes" },
			"ctr_2_bundles":	{ "type": "long", "store": "yes" },
			"ctr_2_bytes":		{ "type": "long", "store": "yes" },
			"ctr_total_bundles":	{ "type": "long", "store": "yes" },
			"ctr_total_bytes":	{ "type": "long", "store": "yes" },
			"rfw_0_bundles":	{ "type": "long", "store": "yes" },
			"rfw_0_bytes":		{ "type": "long", "store": "yes" },
			"rfw_1_bundles":	{ "type": "long", "store": "yes" },
			"rfw_1_bytes":		{ "type": "long", "store": "yes" },
			"rfw_2_bundles":	{ "type": "long", "store": "yes" },
			"rfw_2_bytes":		{ "type": "long", "store": "yes" },
			"rfw_total_bundles":	{ "type": "long", "store": "yes" },
			"rfw_total_bytes":	{ "type": "long", "store": "yes" },
			"exp_0_bundles":	{ "type": "long", "store": "yes" },
			"exp_0_bytes":		{ "type": "long", "store": "yes" },
			"exp_1_bundles":	{ "type": "long", "store": "yes" },
			"exp_1_bytes":		{ "type": "long", "store": "yes" },
			"exp_2_bundles":	{ "type": "long", "store": "yes" },
			"exp_2_bytes":		{ "type": "long", "store": "yes" },
			"exp_total_bytes":	{ "type": "long", "store": "yes" }
			"exp_total_bundles":	{ "type": "long", "store": "yes" },
		}
	}'
}

#deleteIndex twitter
#deleteIndex bpnm
#deleteIndex bpnmoo
#createIndex bpnm
createStatsIndex bpnm
#createMappings
#createTestIndex
listIndices

