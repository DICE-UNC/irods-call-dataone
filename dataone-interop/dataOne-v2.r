#
# Procedure:
# Make new collection for this search
#  [Search terms are SOLR queries such as 'carbon AND sequestration']
# Get resourceMaps that match search terms
# For each resourceMap
#  Create a new subcollection
#  Get identfiers for data data objects documented by resourceMap
#  For each identifier
#    Resolve the identifier
#    Retrieve the data file using the identifier
#    Put the data file in the subcollection
#
main {

        # Make new collection for this search
        msiGetSystemTime(*timestamp,"unix");
        # shim because ' ' is parsed by shell that is called by msiCmdExec
        *str = '\"' ++ *keywords ++ '\"';
        urlencode_plus(*str, *encoded_kw);
        writeLine("serverLog", "KEYWORDS: "++*keywords);
        writeLine("serverLog", "ENC KEYWORDS: "++*encoded_kw);
        *searchColl = *baseColl++"/DataONE_"++*encoded_kw++"_"++*timestamp
        msiCollCreate(*searchColl,"1",*foo);

        # Get resourceMaps from CN that match search terms
        *url = *searchURL++"?rows="++*maxRows++"&q="++*encoded_kw++"%20AND%20resourceMap:*";
        cn_id_call(*url, *resourceMaps);
        writeString("stdout", "Found resourceMaps: ");
        writeLine("stdout", *resourceMaps);

        # For each matching resourceMap
        foreach (*identifier in *resourceMaps) {
            # Create a new subcollection
            urlencode_plus(*identifier, *encodedplus_identifier);
            *resourceMapColl = *searchColl++"/"++*encodedplus_identifier;
            msiCollCreate(*resourceMapColl,"1",*foo);
            writeLine("serverLog", "Created resourcemap coll: "++*resourceMapColl);
            # Get identifiers for data objects in resourceMap
            encode_dataone(*identifier, *encoded_identifier);
            *url = *searchURL++"?q=isDocumentedBy:"++*encoded_identifier;
            cn_id_call(*url, *dataObjects);

            # resolve the data files and d/l them to resourceMap subcollection
            foreach (*identifier2 in *dataObjects) {
               writeLine("serverLog", "identifier2: "++*identifier2);
               cn_resolve(*identifier2, *downloadUrl);
               cn_get(*identifier2, *downloadUrl, *resourceMapColl, *resource);
            }

        }

}


cn_id_call(*url, *identifiers) {
  writeLine("serverLog", "CN_ID_CALL: "++*url++" ...");
  msiExecCmd("cn_id_call.py", *url, "localhost", "null", "null", *cmd_out);
  # Split result and return list of IDs
  msiGetStdoutInExecCmdOut(*cmd_out, *stdout);
  *identifiers = split(*stdout,"\n");
}


cn_resolve(*id, *downloadUrl) {
  encode_dataone2(*id, *encoded_identifier);
  *url = *resolveURL++"/"++*encoded_identifier;
  writeLine("serverLog", "CN_RESOLVE: "++*url++" ...");
  msiExecCmd("cn_resolve.py", *url, "localhost", "null", "null", *cmd_out);
  msiGetStdoutInExecCmdOut(*cmd_out, *stdout);
  *downloadUrl = *stdout;
  writeLine("serverLog", "DL_URL: "++*downloadUrl);
}


cn_get(*identifier, *downloadUrl, *targetColl, *targetResource) {
  # Encode identifier to avoid invalid chars in object name
  urlencode_plus(*identifier,*objName)
  *targetObj = *targetColl++"/"++*objName;

  # Create empty iRODS object
  # msiDataObjCreate(*targetObj, "forceFlag=1", *FD);
  msiDataObjCreate (*targetObj, "destRescName=" ++ *targetResource ++ "++++forceFlag=1", *FD);

  # Write dummy data
  msiDataObjWrite(*FD, "foo", *len);

  # Get file path on disk
  getFilePathForObj(*targetObj, *filePath, *targetResource)

  # Get xml file with cURL
#*args = "-o "++*filePath++" "++*getURL++"/"++*identifier;
  *args = "--insecure -o "++*filePath++" "++*downloadUrl;
  writeLine("serverLog", "CN_GET: "++*downloadUrl++" ...");
  msiExecCmd("curl", *args, "localhost", "null", "null", *cmd_out);

  # Close object
  msiDataObjClose(*FD, *foo);

}


getFilePathForObj(*objPath, *filePathOut, *resource) {

  # Split path to get obj and coll names
  msiSplitPath(*objPath, *collection, *object);
 
  msiAddSelectFieldToGenQuery("DATA_PATH", "null", *genQInp);
  msiAddConditionToGenQuery("DATA_NAME", "=", *object, *genQInp);
  msiAddConditionToGenQuery("COLL_NAME", "=", *collection, *genQInp);
  msiAddConditionToGenQuery("DATA_RESC_NAME", "=", *resource, *genQInp);

  msiExecGenQuery(*genQInp, *genQOut);

  # Extract path from query result
  foreach (*genQOut) {
    msiGetValByKey(*genQOut, "DATA_PATH", *filePathOut);
  }

# writeLine("serverLog", "GETFILEPATHFOROBJ: "++*filePathOut++" ...");
}


encode_dataone(*str, *encodedStr) {
  msiExecCmd("encode_dataone.py", *str, "localhost", "null", "null", *cmd_out);
  msiGetStdoutInExecCmdOut(*cmd_out, *stdout);

  # Strip trailing '\n'
  *encodedStr = substr(*stdout,0,strlen(*stdout)-1)
}


encode_dataone2(*str, *encodedStr) {
  msiExecCmd("encode_dataone2.py", *str, "localhost", "null", "null", *cmd_out);
  msiGetStdoutInExecCmdOut(*cmd_out, *stdout);

  # Strip trailing '\n'
  *encodedStr = substr(*stdout,0,strlen(*stdout)-1)
}


urlencode_plus(*str,*encodedStr) {
  *args=*str;
  msiExecCmd("urlencode_plus.py", *args, "localhost", "null", "null", *cmd_out);
  msiGetStdoutInExecCmdOut(*cmd_out, *stdout);

  # Strip trailing '\n'
  *encodedStr = substr(*stdout,0,strlen(*stdout)-1)
}

INPUT *keywords=$1,*baseColl=$2,*resource=$3,*maxRows=$4,*searchURL="https://cn.dataone.org/cn/v1/search/solr",*resolveURL="https://cn.dataone.org/cn/v1/resolve"
OUTPUT ruleExecOut
