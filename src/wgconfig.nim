import osproc, strutils

const defaultListPort = "15280"

type WGError = object of Exception

proc genPriKey(): string =
  let cmdTuple = execCmdEx("wg genkey")
  if cmdTuple.exitCode != 0:
    raise newException(WGError, "wg genkey command returned non-zero value")
  result = cmdTuple.output
  stripLineEnd(result)

proc genPubKey(priKey: string): string =
  let cmdTuple = execCmdEx("wg pubkey", input = priKey)
  if cmdTuple.exitCode != 0:
    raise newException(WGError, "wg pubkey command returned non-zero value")
  result = cmdTuple.output
  stripLineEnd(result)

proc writeNewIf(confPath, address, priKey = "", listPort = defaultListPort) =
  let priKey = if priKey == "": genPriKey() else: priKey
  var confStr = """[Interface]
  Address = $1
  PrivateKey = $2
  ListenPort = $3
  """ % [address, priKey, listPort]
  confStr = unindent(confStr)
  writeFile(confPath, confStr)
