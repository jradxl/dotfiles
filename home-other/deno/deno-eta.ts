#!/usr/bin/env -S /home/jradley/.deno/bin/deno run -A

//Compile Command is: deno compile -A ./deno-eta.ts

import { Eta } from "https://deno.land/x/eta@v3.5.0/src/index.ts";

console.log("Deno-Eta Borg Config creator...")
console.log("NOTE: Edit this script for the values needed")
console.log("A DENO install is required")
console.log("DON'T edit this file in the Chezmoi directories!")

if (Deno.uid() != 0) {
    console.log("This script is intended to run as root: Use SUDO.");
    Deno.exit(1);
}

const repo = "REPO_ID"
const hostname = Deno.hostname() + "";
const configFile = "config.yaml";
const configDir = "/etc/borgmatic";

//WARN: Eta removes \n when template ends line
const keypath = "/root/.ssh/my-keys/borgbase.key";
const keypassphrase = "Secret!-Change-Me";

//Error if existing ignored
try {   
    Deno.mkdirSync(configDir);
}
catch (_err) {const _notused = "" } ;

const eta = new Eta({ views: configDir });

//return string is whole of file
const res = eta.render("config.eta", {repo: repo, label: hostname, keypath: keypath, password: keypassphrase });

const encoder = new TextEncoder();
const data = encoder.encode(res);
try {   
    Deno.writeFileSync(configDir + "/" + configFile, data, {append: false, create: true})
}
catch (_err) { const _notused = "" } ;

console.log("Values Used:")
console.log("\tRepo: " + repo + "@" + repo + ".repo.borgbase.com/./repo")
console.log("\tLabel: " + hostname)
console.log("\tKeypath: " + keypath)
console.log("\tPassphrase: Not shown.")
console.log("Done!")
