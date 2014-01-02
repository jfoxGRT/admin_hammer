function unpack (smalldata, parsed) {
		
		dataHash = smalldata["data"]
		cmdKeyMap = smalldata["keymap"]["commands"]
		summaryKeyMap = smalldata["keymap"]["summary"]
		for (millis in dataHash) {
				cmdHash = dataHash[millis]["commands"]
				summaryHash = dataHash[millis]["summary"]
				for (command in cmdKeyMap) {
						cmdKey = cmdKeyMap[command]
						if (cmdHash[cmdKey]!=undefined) {
								if (parsed["command"][millis] == undefined) {
										parsed["command"][millis] = {}
								}
								parsed["command"][millis][command] = cmdHash[cmdKey]
						}
				}
				for (summary in summaryKeyMap) {
						summaryKey = summaryKeyMap[summary]
						if (summaryHash[summaryKey]!=undefined) {
								if (parsed["summary"][summary] == undefined) {
										parsed["summary"][summary] = {}
								}
								parsed["summary"][summary][millis] = summaryHash[summaryKey]
						}
				}
		}
}
